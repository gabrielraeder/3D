// Self-draining cutlery holder that hangs on the sink backsplash.
// Two parts: a drain tray (with hooks + spout) and a perforated basket.
// Coordinates: x = along the backsplash, y = 0 at the backsplash front face
// (positive toward the sink bowl), z = 0 at the tray bottom.

/* [Part] */
part = "assembly"; // [assembly, section, drawing, tray, basket, tray_print]
section_x = 12;    // cut plane for the "section" view (mm)

/* [Sink measurements] */
wall_height    = 75;  // backsplash height above the ledge (mm)
wall_top_depth = 20;  // backsplash top, front face to back edge (mm)
ledge_depth    = 60;  // ledge, backsplash face to sink bowl edge (mm)

/* [Hanging hooks] */
ledge_gap      = 3;   // air gap between tray bottom and ledge (mm)
hook_clearance = 1.0; // extra span over the backsplash top (mm)
hook_t         = 3;   // hook thickness (mm)
hook_w         = 25;  // width of each of the two hooks (mm)
back_leg_len   = 25;  // how far the hook drops behind the backsplash (mm)
back_leg_t     = 1.5; // back leg thickness, must fit in the gap behind (mm)
bend_chamfer   = 6;   // chamfer at tray back-bottom, clears the ledge bend radius (mm)

/* [Tray] */
width        = 150;  // overall width (mm)
front_margin = 2;    // tray front stays this far behind the bowl edge (mm)
tray_wall    = 2.4;  // tray side/front wall (mm)
back_t       = 3;    // back plate thickness (mm)
tray_h       = 18;   // tray wall height (mm)
floor_min    = 2;    // floor thickness at the front (mm)
floor_slope  = 3;    // floor slope toward the spout (deg)
rail_h       = 2;    // basket rails above the highest floor point (mm)
rail_w       = 2;    // rail width (mm)
rail_front_gap = 6;  // rails stop this far from the front wall (mm)
spout_w      = 30;   // spout channel inner width (mm)
spout_len    = 12;   // spout overhang beyond the tray front (mm)
spout_h      = 8;    // spout side wall height (mm)
spout_wall   = 2;    // spout side wall thickness (mm)

/* [Basket] */
fit_clearance = 0.5; // gap between basket and tray walls (mm)
total_h       = 140; // overall height, tray bottom to tall rim (mm)
small_total_h = 90;  // overall height at the small compartment rim (mm)
small_w       = 40;  // small compartment inner width (mm)
small_side    = "right"; // [left, right] side of the small compartment, seen from the front
ramp_w        = 20;  // width of the rim ramp from the low to the tall rim (mm)
basket_wall   = 2.4; // basket wall (mm)
basket_floor  = 2;   // basket floor (mm)
divider_t     = 2;   // divider thickness (mm)
corner_r      = 4;   // basket corner radius (mm)
hex_flat      = 6;   // hex hole size across flats (mm)
hex_web       = 2;   // web between holes (mm)
hole_margin   = 4;   // solid border around hole fields (mm)
top_band      = 10;  // solid band below the basket rim (mm)

$fn = 64;

// ---------- derived ----------
tray_d     = ledge_depth - front_margin;
z0         = wall_height - ledge_gap;       // hook seat height above tray bottom
inner_x0   = tray_wall;
inner_x1   = width - tray_wall;
inner_y0   = back_t;
inner_y1   = tray_d - tray_wall;
floor_back = floor_min + (inner_y1 - inner_y0) * tan(floor_slope);
rail_top   = floor_back + rail_h;           // basket sits here
basket_h   = total_h - rail_top;
basket_lo  = small_total_h - rail_top;     // basket height at the small compartment
basket_w   = inner_x1 - inner_x0 - 2 * fit_clearance;
basket_d   = inner_y1 - inner_y0 - 2 * fit_clearance;
eps        = 0.01;

// ---------- helpers ----------
module rounded_rect(w, d, r) {
    translate([r, r]) offset(r = r) square([w - 2 * r, d - 2 * r]);
}

// Extrude a 2D profile drawn in (y, z) along +x.
module extrude_x(len) {
    rotate([90, 0, 90]) linear_extrude(len) children();
}

// Flat-top hex holes filling [0,w] x [0,h]; skips columns near u-values in excl.
// Optional sloped ceiling: holes stay below v = top_a + top_b * u.
module hex_field(w, h, excl = [], ex_half = 0, top_a = 1e9, top_b = 0) {
    R  = hex_flat / sqrt(3);
    dv = hex_flat + hex_web;
    du = dv * sqrt(3) / 2;
    nu = max(1, floor((w - 2 * R) / du) + 1);
    nv = max(1, floor((h - hex_flat) / dv) + 1);
    u0 = (w - (nu - 1) * du) / 2;
    v0 = (h - (nv - 1) * dv - dv / 2) / 2;
    for (i = [0 : nu - 1], j = [-1 : nv])
        let (u = u0 + i * du, v = v0 + j * dv + (i % 2) * dv / 2)
        if (v >= hex_flat / 2 - eps && v <= h - hex_flat / 2 + eps
            && u >= R - eps && u <= w - R + eps
            && v + hex_flat / 2 <= top_a + top_b * u - abs(top_b) * R
            && len([for (e = excl) if (abs(u - e) < R + ex_half) 1]) == 0)
            translate([u, v]) circle(r = R, $fn = 6);
}

// ---------- tray ----------
module tray_inner_2d() {
    translate([inner_x0, inner_y0])
        rounded_rect(inner_x1 - inner_x0, inner_y1 - inner_y0, corner_r + fit_clearance);
}

module tray_outer_2d() {
    union() {
        offset(r = tray_wall) tray_inner_2d();
        square([width, inner_y0 + corner_r]);
    }
}

// Half-space above the sloped floor (descends toward +y).
module above_floor() {
    translate([-50, inner_y1, floor_min]) rotate([-floor_slope, 0, 0])
        translate([0, -300, 0]) cube([width + 100, 600, 300]);
}

module hook_profile() {
    s  = wall_top_depth + hook_clearance;   // inner span over the backsplash top
    a  = s / 2;
    tk = hook_t * sqrt(2);                  // vertical thickness of 45 deg segments
    polygon([
        [0, z0 - 5],
        [0, z0],
        [-a, z0 + a],                       // inner apex (45 deg both sides)
        [-s, z0],
        [-s, z0 - back_leg_len],
        [-s - back_leg_t, z0 - back_leg_len],
        [-s - back_leg_t, z0 + tk - back_leg_t],
        [-a, z0 + a + tk],                  // outer apex
        [back_t, z0 + tk - back_t],
        [back_t, z0 - 5]
    ]);
}

module tray() {
    difference() {
        union() {
            // tray body
            linear_extrude(tray_h) tray_outer_2d();
            // back plate up to the hook seat
            cube([width, back_t, z0]);
            // hooks at both ends
            for (x = [0, width - hook_w]) translate([x, 0, 0]) extrude_x(hook_w) hook_profile();
            // spout channel
            translate([width / 2 - spout_w / 2 - spout_wall, tray_d - eps, 0])
                cube([spout_w + 2 * spout_wall, spout_len + eps, spout_h]);
        }
        // inner cavity above the sloped floor
        intersection() {
            translate([0, 0, -1]) linear_extrude(tray_h + 2) tray_inner_2d();
            above_floor();
        }
        // spout opening through the front wall + channel
        intersection() {
            translate([width / 2 - spout_w / 2, inner_y1 - corner_r, -1])
                cube([spout_w, tray_wall + corner_r + spout_len + 1, spout_h + 2]);
            above_floor();
        }
        // clear the bend between ledge and backsplash
        translate([-1, 0, 0]) extrude_x(width + 2)
            polygon([[-1, -1], [bend_chamfer + 1, -1], [-1, bend_chamfer + 1]]);
    }
    // rails the basket rests on (water runs between them)
    rail_xs = [width / 2 - basket_w * 0.35, width / 2, width / 2 + basket_w * 0.35];
    intersection() {
        for (x = rail_xs)
            translate([x - rail_w / 2, inner_y0 - eps, 0])
                cube([rail_w, inner_y1 - inner_y0 - rail_front_gap, rail_top]);
        translate([0, 0, -1]) linear_extrude(rail_top + 1) tray_inner_2d();
    }
}

// ---------- basket ----------
// Small (low) compartment is built at low x; mirrored when it should be on the
// viewer's left (viewer faces -y, so their left is +x).
module basket() {
    if (small_side == "left") translate([basket_w, 0, 0]) mirror([1, 0, 0]) basket_raw();
    else basket_raw();
}

module basket_raw() {
    bw = basket_w; bd = basket_d; cr = corner_r; t = basket_wall;
    m  = hole_margin;
    xs = t + small_w;                    // divider left face
    xl = xs + divider_t;                 // divider right face
    lo_field = basket_lo - basket_floor - m - top_band;
    hi_field = basket_h  - basket_floor - m - top_band;
    k  = (basket_h - basket_lo) / ramp_w;      // rim ramp slope
    // ramp line: low rim at the divider, reaching the tall rim after ramp_w
    function ramp_z(x) = basket_lo + (x - xl) * k;
    band_v = top_band * sqrt(1 + k * k);       // keeps top_band measured square to the ramp

    // hole field of a wall spanning [u0, u1] (panel coords, u = x - cr),
    // kept below the ramp (and below the flat rims via h_field)
    module field(u0, u1, h_field, ramp = true) {
        translate([u0 + m, basket_floor + m])
            hex_field(u1 - u0 - 2 * m, h_field,
                      top_a = ramp ? ramp_z(u0 + m + cr) - band_v - basket_floor - m : 1e9,
                      top_b = ramp ? k : 0);
    }

    difference() {
        union() {
            // floor
            linear_extrude(basket_floor) difference() {
                rounded_rect(bw, bd, cr);
                translate([t + m, t + m])
                    hex_field(bw - 2 * (t + m), bd - 2 * (t + m),
                              [xs + divider_t / 2 - t - m], divider_t / 2 + hex_web);
            }
            // rounded corners
            linear_extrude(basket_h) intersection() {
                difference() {
                    rounded_rect(bw, bd, cr);
                    translate([t, t]) rounded_rect(bw - 2 * t, bd - 2 * t, max(cr - t, eps));
                }
                for (p = [[0, 0], [bw - cr, 0], [0, bd - cr], [bw - cr, bd - cr]])
                    translate(p - [eps, eps]) square(cr + 2 * eps);
            }
            // front and back walls (panel u = x - cr)
            for (y = [0, bd - t])
                translate([cr - eps, y + t, 0]) rotate([90, 0, 0]) linear_extrude(t)
                    difference() {
                        square([bw - 2 * cr + 2 * eps, basket_h]);
                        field(0, xs - cr, lo_field, ramp = false);
                        field(xl - cr, bw - 2 * cr, hi_field);
                    }
            // side walls: low one at x = 0, tall one at x = bw - t
            for (s = [[0, lo_field], [bw - t, hi_field]])
                translate([s[0], cr - eps, 0]) extrude_x(t) difference() {
                    square([bd - 2 * cr + 2 * eps, basket_h]);
                    field(0, bd - 2 * cr, s[1], ramp = false);
                }
        }
        // rim: low over the small compartment, short ramp, then flat tall rim
        translate([0, bd + 1, 0]) rotate([90, 0, 0]) linear_extrude(bd + 2)
            polygon([[-1, basket_lo], [xl, basket_lo], [xl + ramp_w, basket_h],
                     [bw + 1, basket_h], [bw + 1, basket_h + 50], [-1, basket_h + 50]]);
    }
    // divider, as tall as the small compartment
    translate([xs, t - eps, 0]) cube([divider_t, bd - 2 * t + 2 * eps, basket_lo]);
}

module basket_placed() {
    translate([inner_x0 + fit_clearance, inner_y0 + fit_clearance, rail_top]) basket();
}

// ---------- sink mock-up (visual only) ----------
module sink_mock() {
    L = width + 80;
    color("LightSteelBlue", 0.45) translate([-40, 0, -ledge_gap]) {
        translate([0, 0, -1]) cube([L, ledge_depth, 1]);                         // ledge
        translate([0, ledge_depth, -1]) rotate([-55, 0, 0]) cube([L, 40, 1]);    // bowl edge
        translate([0, -1, 0]) cube([L, 1, wall_height]);                         // backsplash face
        translate([0, -wall_top_depth, wall_height - 1]) cube([L, wall_top_depth, 1]); // top
        translate([0, -wall_top_depth, wall_height - 25]) cube([L, 1, 25]);      // back flange
    }
    color("WhiteSmoke", 0.5)
        translate([-40, -wall_top_depth - back_leg_t - 6, -ledge_gap - 1])
            cube([width + 80, 4, wall_height + 120]);                            // tiles
}

module assembly() {
    color("DimGray") tray();
    color("SteelBlue") basket_placed();
}

module cut() { translate([section_x - 500, -150, -100]) cube([500, 300, 400]); }

// ---------- dimensioned 2D drawing ----------
dim_ts = 3.6;  // label text size (mm)

// one decimal, Brazilian comma
function fmt(v) = let (r = round(v * 10) / 10, i = floor(r), d = round((r - i) * 10))
    d == 0 ? str(i) : str(i, ",", d);

module dim_h(x1, x2, y, label) {
    color("Black") linear_extrude(5) {
        translate([x1, y - 0.25]) square([x2 - x1, 0.5]);
        for (x = [x1, x2]) translate([x - 0.15, y - 2]) square([0.3, 4]);
        translate([(x1 + x2) / 2, y + 1.5])
            text(label, size = dim_ts, halign = "center", font = "Liberation Sans:style=Bold");
    }
}

module dim_v(z1, z2, x, label, left = true) {
    color("Black") linear_extrude(5) {
        translate([x - 0.25, z1]) square([0.5, z2 - z1]);
        for (z = [z1, z2]) translate([x - 2, z - 0.15]) square([4, 0.3]);
        translate([x + (left ? -1.5 : 1.5 + dim_ts), (z1 + z2) / 2]) rotate(90)
            text(label, size = dim_ts, halign = "center", font = "Liberation Sans:style=Bold");
    }
}

module line2d(p1, p2, w = 0.4) { hull() { translate(p1) circle(d = w, $fn = 8); translate(p2) circle(d = w, $fn = 8); } }

module label(p, s, size = 5) {
    color("Black") linear_extrude(5) translate(p) text(s, size = size, font = "Liberation Sans:style=Bold");
}

module drawing() {
    t  = basket_wall;
    bx = inner_x0 + fit_clearance;        // basket left/right gap to tray outside
    Bl = bx; Br = width - bx;
    zb = rail_top; zl = small_total_h; zh = total_h;
    xs = t + small_w; xl = xs + divider_t;
    sgn = small_side == "right";
    // view x (seen from the sink): small compartment on the right when sgn
    function V(v) = sgn ? v : width - v;

    // ---- front view ----
    label([0, zh + 30], "VISTA FRONTAL (olhando da pia)");
    // layers (extrusion height) keep nearer parts on top in the top-down render
    color("LightSteelBlue") linear_extrude(1) translate([-25, -ledge_gap - 1]) square([width + 50, 1]);
    color("Gainsboro") linear_extrude(1) {
        square([width, z0]);                                                        // back plate
        for (x = [0, width - hook_w]) translate([x, 0])
            square([hook_w, z0 + (wall_top_depth + hook_clearance) / 2 + hook_t * sqrt(2)]);
    }
    color("DimGray") linear_extrude(3) square([width, tray_h]);                     // tray
    color("SteelBlue") linear_extrude(2) polygon([for (p = [[Bl, zb], [Br, zb], [Br, zl], [Br - xl, zl],
                                                 [Br - xl - ramp_w, zh], [Bl, zh]]) [V(p[0]), p[1]]]);
    color("White") linear_extrude(2.5) for (v = [Br - xs, Br - xl])
        line2d([V(v), tray_h], [V(v), zl], 0.4);                                   // divider (hidden)

    dim_h(0, width, -14, str(width, " largura total"));
    dim_h(min(V(Br - t - small_w), V(Br - t)), max(V(Br - t - small_w), V(Br - t)), zl + 6,
          str(small_w, " int."));
    dim_h(min(V(Br - xl - ramp_w), V(Br - xl)), max(V(Br - xl - ramp_w), V(Br - xl)), zl + 18,
          str("rampa ", ramp_w));
    dim_h(min(V(Bl + t), V(Br - xl)), max(V(Bl + t), V(Br - xl)), zh + 6,
          str(fmt(basket_w - 2 * t - small_w - divider_t), " int."));
    dim_v(0, zh, sgn ? -8 : width + 8, str(zh, " total"), sgn);
    dim_v(0, zl, sgn ? width + 8 : -8, str(zl), !sgn);
    dim_v(-ledge_gap, 0, sgn ? width + 8 : -8, str(ledge_gap), !sgn);
    dim_v(0, tray_h, sgn ? -22 : width + 22, str(tray_h), sgn);

    // ---- side view (section through a hook), y toward the sink ----
    ox = width + 85;
    translate([ox, 0]) {
        label([-wall_top_depth - 10, zh + 30], "VISTA LATERAL (corte no gancho)");
        // sink
        color("LightSteelBlue") linear_extrude(1) {
            line2d([0, -ledge_gap], [0, z0], 1);
            line2d([0, z0], [-wall_top_depth, z0], 1);
            line2d([-wall_top_depth, z0], [-wall_top_depth, z0 - back_leg_len - 15], 1);
            line2d([0, -ledge_gap], [ledge_depth, -ledge_gap], 1);
            line2d([ledge_depth, -ledge_gap], [ledge_depth + 14, -ledge_gap - 20], 1);
        }
        // tray silhouette
        color("DimGray") linear_extrude(3) difference() {
            union() {
                square([back_t, z0]);
                square([tray_d, tray_h]);
                square([tray_d + spout_len, spout_h]);
                hook_profile();
            }
            polygon([[-1, -1], [bend_chamfer + 1, -1], [-1, bend_chamfer + 1]]);
        }
        // basket silhouette
        by = inner_y0 + fit_clearance;
        color("SteelBlue") linear_extrude(2) translate([by, zb]) square([basket_d, zh - zb]);
        color("White") linear_extrude(2.5) line2d([by, zl], [by + basket_d, zl], 0.4);

        s = wall_top_depth + hook_clearance;
        dim_h(-s, 0, z0 + s / 2 + hook_t * sqrt(2) + 6, str(fmt(s), " vão"));
        dim_h(by, by + basket_d, zh + 6, str(fmt(basket_d), " cesto"));
        dim_h(0, tray_d, -14, str(tray_d, " bandeja"));
        dim_h(0, tray_d + spout_len, -24, str(tray_d + spout_len, " com bico"));
        dim_h(0, ledge_depth, -34, str(ledge_depth, " prateleira"));
        dim_v(z0 - back_leg_len, z0, -s - back_leg_t - 6, str(back_leg_len, " perna"));
        dim_h(-s - back_leg_t, -s, z0 - back_leg_len - 6, fmt(back_leg_t));
        dim_v(-ledge_gap, z0, -s - back_leg_t - 20, str(wall_height, " parede"));
        dim_v(0, spout_h, tray_d + spout_len + 6, str(spout_h), false);
    }
    label([0, -52], str("Medidas em mm. Alturas a partir da base da bandeja, que fica ", ledge_gap,
                        " mm acima da prateleira. Paredes do cesto ", fmt(basket_wall), " mm."), 4);
}

// ---------- output ----------
if (part == "assembly") { assembly(); sink_mock(); }
else if (part == "section") {
    color("DimGray") difference() { tray(); cut(); }
    color("SteelBlue") difference() { basket_placed(); cut(); }
    difference() { sink_mock(); cut(); }
}
else if (part == "drawing") drawing();
else if (part == "tray") tray();
else if (part == "basket") basket();
else if (part == "tray_print") tray();   // printed upright, as modeled
