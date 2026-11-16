"""HueForge-style filament painting of Toninho.

Turns the photo into a height map printed with thin layers; filament swaps at
fixed layer heights blend through the translucent PLA to rebuild the image.

Usage:
    python hueforge_toninho.py <photo.png> <out_dir> [--stl]

Without --stl only the simulation preview is written (fast, for approval).
"""

import itertools
import json
import struct
import sys
from pathlib import Path

import cv2
import numpy as np

# --- Panel ---
PANEL_WIDTH = 100.0      # mm (height follows the crop aspect)
PIXEL_SIZE = 0.2         # mm per height-map pixel (image is resampled to this)

# --- Layers ---
FIRST_LAYER = 0.16       # mm
LAYER_HEIGHT = 0.08      # mm
BASE_LAYERS = 6          # solid layers on top of the first layer (first filament)
RELIEF_LAYERS = 30       # max layers of image relief above the base
BACKGROUND_EXTRA_LAYERS = 18  # background rises this much above the relief so the white covers fully
DETAIL_BLUR_PX = 0.6     # light blur before mapping to remove sensor noise (px, source scale)
HEIGHT_MEDIAN = 3        # median filter on the layer map (odd px) to avoid single-pixel spikes

# --- Filaments, bottom -> top: (name, sRGB hex, transmission distance TD in mm) ---
# TD = thickness at which the filament is practically opaque. Values are estimates;
# replace them with the real HueForge TD of your filaments for a better match.
FILAMENTS = [
    ("Preto", "#1A1A1A", 0.6),
    ("Marrom", "#6E4A2E", 1.0),
    ("Caramelo", "#C99A64", 1.8),
    ("Branco", "#F2F2F2", 2.6),
]

# --- Background removal (reference image has a plain white background) ---
WHITE_DISTANCE_LOW = 18   # color distance from white below this = background (0-255 scale)
WHITE_DISTANCE_HIGH = 45  # above this = dog; in between = soft fur edge
CROP_MARGIN = 0.04        # empty border around the dog, fraction of the dog's size
BACKGROUND_RGB = (242, 242, 242)  # background printed as the top filament (white)


def hex_to_rgb(h: str) -> np.ndarray:
    return np.array([int(h[i : i + 2], 16) for i in (1, 3, 5)], np.float32) / 255.0


def segment(img: np.ndarray) -> np.ndarray:
    """Return a float alpha mask (1 = dog) for a photo on a white background."""
    dist = np.linalg.norm(255.0 - img.astype(np.float32), axis=-1)
    hard = (dist > WHITE_DISTANCE_HIGH).astype(np.uint8) * 255
    hard = cv2.morphologyEx(hard, cv2.MORPH_CLOSE, np.ones((9, 9), np.uint8))
    n, labels, stats, _ = cv2.connectedComponentsWithStats(hard)
    biggest = 1 + int(np.argmax(stats[1:, cv2.CC_STAT_AREA]))
    body = (labels == biggest).astype(np.uint8) * 255
    # fill interior holes (light fur highlights must not become background)
    contours, _ = cv2.findContours(body, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    cv2.drawContours(body, contours, -1, 255, -1)
    soft = np.clip((dist - WHITE_DISTANCE_LOW) / (WHITE_DISTANCE_HIGH - WHITE_DISTANCE_LOW), 0, 1)
    near_body = cv2.dilate(body, np.ones((15, 15), np.uint8)) > 0
    return np.maximum(body / 255.0, soft * near_body).astype(np.float32)


def auto_crop(alpha: np.ndarray) -> tuple[int, int, int, int]:
    ys, xs = np.where(alpha > 0.5)
    x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
    m = int(CROP_MARGIN * max(x1 - x0, y1 - y0))
    h, w = alpha.shape
    return max(0, x0 - m), max(0, y0 - m), min(w, x1 + m), min(h, y1 + m)


def layer_colors(swaps: tuple[int, ...], n_layers: int) -> np.ndarray:
    """Simulated sRGB color seen from the top for 0..n_layers relief layers.

    swaps[i] = relief layer index where filament i+1 starts.
    """
    starts = [0, *swaps]
    out = np.zeros((n_layers + 1, 3), np.float32)
    base_thickness = FIRST_LAYER + BASE_LAYERS * LAYER_HEIGHT
    for k in range(n_layers + 1):
        color = np.zeros(3, np.float32)
        for i, (_, hx, td) in enumerate(FILAMENTS):
            lo = starts[i]
            hi = starts[i + 1] if i + 1 < len(starts) else n_layers
            t = max(0, min(hi, k) - lo) * LAYER_HEIGHT
            if i == 0:
                t += base_thickness
            if t <= 0:
                continue
            alpha = 1.0 - np.exp(-3.0 * t / td)  # ~95% opaque at TD
            color = color * (1 - alpha) + hex_to_rgb(hx) * alpha
        out[k] = color
    return out


def to_lab(rgb: np.ndarray) -> np.ndarray:
    shape = rgb.shape
    lab = cv2.cvtColor(rgb.reshape(-1, 1, 3).astype(np.float32), cv2.COLOR_RGB2Lab)
    return lab.reshape(shape)


def assign_layers(target_lab: np.ndarray, lut_lab: np.ndarray) -> np.ndarray:
    """Pick, per pixel, the relief layer count whose simulated color is closest.

    Lightness weighs double: it carries most of the detail in a filament painting.
    """
    w = np.array([2.0, 1.0, 1.0], np.float32)
    d = (((target_lab[..., None, :] - lut_lab) * w) ** 2).sum(-1)
    return np.argmin(d, axis=-1)


def best_swaps(target_lab: np.ndarray) -> tuple[tuple[int, ...], float]:
    rng = np.random.default_rng(0)
    flat = target_lab.reshape(-1, 3)
    sample = flat[rng.choice(len(flat), size=min(3000, len(flat)), replace=False)]
    best = (None, np.inf)
    for swaps in itertools.combinations(range(1, RELIEF_LAYERS + 1), len(FILAMENTS) - 1):
        lut = to_lab(layer_colors(swaps, RELIEF_LAYERS))
        k = assign_layers(sample, lut)
        err = float(np.sqrt(((sample - lut[k]) ** 2).sum(-1)).mean())
        if err < best[1]:
            best = (swaps, err)
    return best


def write_heightmap_stl(path: Path, heights: np.ndarray, px: float) -> None:
    """Closed binary STL: top height field, four side walls, bottom fan."""
    rows, cols = heights.shape
    ys = (rows - 1 - np.arange(rows)) * px  # image row 0 = top of the panel
    xs = np.arange(cols) * px
    X, Y = np.meshgrid(xs, ys)
    top = np.stack([X, Y, heights], -1)

    a, b = top[:-1, :-1], top[:-1, 1:]
    c, d = top[1:, :-1], top[1:, 1:]
    # rows go downward in Y, so (a, c, b) is counter-clockwise seen from above
    tris = [np.stack([a, c, b], -2).reshape(-1, 3, 3), np.stack([b, c, d], -2).reshape(-1, 3, 3)]

    # perimeter, counter-clockwise seen from above: bottom row L->R, right col B->T, top row R->L, left col T->B
    edge = np.concatenate([top[-1, :], top[::-1, -1][1:], top[0, ::-1][1:], top[:, 0][1:]])
    nxt = np.roll(edge, -1, axis=0)
    low, low_n = edge.copy(), nxt.copy()
    low[:, 2] = 0
    low_n[:, 2] = 0
    tris.append(np.stack([low, low_n, nxt], 1))
    tris.append(np.stack([low, nxt, edge], 1))
    center = np.array([xs[-1] / 2, ys[0] / 2, 0.0])
    tris.append(np.stack([np.broadcast_to(center, low.shape), low_n, low], 1))

    tri = np.concatenate(tris).astype(np.float32)
    normals = np.cross(tri[:, 1] - tri[:, 0], tri[:, 2] - tri[:, 0])
    normals /= np.linalg.norm(normals, axis=1, keepdims=True) + 1e-12
    data = np.zeros(len(tri), dtype=[("n", "<f4", 3), ("v", "<f4", (3, 3)), ("a", "<u2")])
    data["n"], data["v"] = normals, tri
    with open(path, "wb") as f:
        f.write(b"hueforge-toninho".ljust(80, b" "))
        f.write(struct.pack("<I", len(tri)))
        f.write(data.tobytes())


def main(photo: Path, out_dir: Path, export_stl: bool) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    img = cv2.imread(str(photo))
    alpha = segment(img)

    rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB).astype(np.float32) / 255.0
    rgb = cv2.GaussianBlur(rgb, (0, 0), DETAIL_BLUR_PX)
    bg = np.array(BACKGROUND_RGB, np.float32) / 255.0
    rgb = rgb * alpha[..., None] + bg * (1 - alpha[..., None])

    x0, y0, x1, y1 = auto_crop(alpha)
    rgb, alpha = rgb[y0:y1, x0:x1], alpha[y0:y1, x0:x1]
    cols = int(round(PANEL_WIDTH / PIXEL_SIZE))
    rows = int(round(cols * (y1 - y0) / (x1 - x0)))
    rgb = cv2.resize(rgb, (cols, rows), interpolation=cv2.INTER_AREA).clip(0, 1)
    alpha = cv2.resize(alpha, (cols, rows), interpolation=cv2.INTER_AREA)

    target_lab = to_lab(rgb)
    swaps, err = best_swaps(target_lab[alpha > 0.9])  # fit the dog's colors, not the background
    top_layer = RELIEF_LAYERS + BACKGROUND_EXTRA_LAYERS
    lut_rgb = layer_colors(swaps, top_layer)
    # Candidates: every relief level plus the background level, so light fur edges
    # and highlights can fall to clean white instead of a beige halo.
    candidates = np.r_[np.arange(RELIEF_LAYERS + 1), top_layer]
    pick = assign_layers(target_lab, to_lab(lut_rgb[candidates]))
    layers = candidates[pick].astype(np.uint8)
    layers[alpha < 0.5] = top_layer  # background: thick white
    layers = cv2.medianBlur(layers, HEIGHT_MEDIAN)

    sim = (lut_rgb[layers] * 255).astype(np.uint8)
    orig = (rgb * 255).astype(np.uint8)
    side = np.concatenate([orig, np.full((rows, 12, 3), 255, np.uint8), sim], 1)
    cv2.imwrite(str(out_dir / "simulacao.png"), cv2.cvtColor(side, cv2.COLOR_RGB2BGR))

    base_top = FIRST_LAYER + BASE_LAYERS * LAYER_HEIGHT
    plan = {
        "panel_mm": [PANEL_WIDTH, round(rows * PIXEL_SIZE, 1)],
        "max_height_mm": round(base_top + top_layer * LAYER_HEIGHT, 2),
        "total_layers": 1 + BASE_LAYERS + top_layer,
        "first_layer_mm": FIRST_LAYER,
        "layer_height_mm": LAYER_HEIGHT,
        "mean_color_error_deltaE": round(err, 1),
        "swaps": [
            {
                "filament": FILAMENTS[i + 1][0],
                "hex": FILAMENTS[i + 1][1],
                "start_height_mm": round(base_top + s * LAYER_HEIGHT, 2),
                "start_layer_number": 1 + BASE_LAYERS + s + 1,
            }
            for i, s in enumerate(swaps)
        ],
        "start_filament": {"filament": FILAMENTS[0][0], "hex": FILAMENTS[0][1]},
    }
    (out_dir / "trocas.json").write_text(json.dumps(plan, indent=2, ensure_ascii=False), encoding="utf-8")
    print(json.dumps(plan, indent=2, ensure_ascii=False))

    if export_stl:
        heights = base_top + layers.astype(np.float32) * LAYER_HEIGHT
        write_heightmap_stl(out_dir / "hueforge-toninho.stl", heights, PIXEL_SIZE)
        print("STL written")


if __name__ == "__main__":
    main(Path(sys.argv[1]), Path(sys.argv[2]), "--stl" in sys.argv[3:])
