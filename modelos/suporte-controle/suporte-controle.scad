// Under-desk controller hook (universal)
// The controller (or its controller-shaped case) rests face up on an arm.
// Near the neck the arm is wide and supports the controller body, so it can't
// tip sideways; towards the tip it narrows so it fits the gap between the
// grips. The arm is tilted up, so the controller slides back against the
// neck, and its tip curves up (constant thickness) to keep it from sliding out.
// A cable slot runs open from the arm tip, along the middle of the arm, into
// a window in the neck, so a charging cable can stay plugged in.
// Windows in the neck and plate save filament.
// Mounted with wood screws and/or double-sided tape.
//
// Modeling frame ("use"): X = depth from the back of the neck, Y = vertical,
// Z = width. The side profile is drawn in XY and extruded along Z.
// Print frame: standing on the back face of the neck (X becomes print Z).

/* [Fit] */
tip_width       = 36;  // mm, narrow part of the arm, must fit between the grips
support_width   = 80;  // mm, wide part of the arm near the neck (also neck/plate width)
support_length  = 30;  // mm, length of the full-width part, measured from the neck front face
taper_length    = 38;  // mm, length of the smooth S-curve from full width down to tip_width
                       // (support_length + taper_length ~ controller body depth before the grips, ~60 mm)
taper_steps     = 48;  // segments used to draw the curve
clearance       = 95;  // mm, free height between arm top and plate underside (at the neck)
inner_length    = 85;  // mm, usable arm length from neck to the start of the lip bend
arm_angle       = 12;  // deg, upward tilt of the arm (controller slides back to the neck)

/* [Structure] */
arm_thickness   = 8;   // mm
neck_thickness  = 7;   // mm
plate_thickness = 6;   // mm
lip_angle       = 45;  // deg from horizontal (in use) of the curved-up tip; keep <= 45 to print without support
lip_bend_r      = 10;  // mm, inner radius of the bend
lip_length      = 20;  // mm, straight part of the tip after the bend

/* [Mounting plate] */
plate_front   = 75;    // mm, plate length in front of the neck
screw_d       = 4.5;   // mm, shaft hole (4 mm wood screw + clearance)
screw_head_d  = 8.5;   // mm, countersink diameter (90 deg head)
screw_x       = 64;    // mm, screw position along X (beside the narrowing arm)
screw_spacing = 64;    // mm, distance between the two screws across the width
                       // (the screw head and driver must clear the arm below; check if the taper changes)

/* [Windows (filament saving)] */
neck_window_border  = 12; // mm, solid frame left on each side of the neck window
neck_window_margin  = 0;  // mm, extra solid band above/below the neck window (beyond the fillets)
neck_window_round   = 6;  // mm, corner radius of the neck window
slot_join_round     = 6;  // mm, rounding where the cable slot meets the neck window
plate_window_start  = 20; // mm, X where the plate window starts
plate_window_end    = 30; // mm, X where the straight part of the plate window ends
plate_window_width  = 36; // mm
window_tip_ratio    = 0.9; // pointed end length / width (keeps the hole top printable)

/* [Cable slot] */
cable_slot_width    = 16; // mm, open slot from the arm tip into the neck window (USB-C plug fits)

/* [Finish] */
arm_edge_r    = 3;     // mm, rounding of the long edges of the arm prongs
arm_sample    = 2;     // mm, sampling step along the arm for the rounded sweep
arm_edge_ramp = 14;    // mm, length over which the edge rounding grows after the neck fillet
fillet_r      = 8;     // mm, inner corner fillets
round_r       = 2;     // mm, outer corner rounding
chamfer       = 0.6;   // mm, chamfer on the side faces' edges
chamfer_steps = 3;     // number of steps approximating the chamfer
foot_chamfer  = 0.6;   // mm, elephant foot chamfer on the print base
$fn = 64;

/* [Preview] */
orientation     = "print"; // "print" or "use"
show_controller = false;   // ghost controller for the "use" preview

// ---- derived ----
total_height = arm_thickness + clearance + plate_thickness;
lip_start    = neck_thickness + inner_length;          // along the arm
lip_bend     = lip_angle - arm_angle;                  // bend relative to the arm
bend_rc      = lip_bend_r + arm_thickness / 2;         // centerline radius of the bend
arm_length   = lip_start + bend_rc * sin(lip_bend) + lip_length * cos(lip_bend)
               + arm_thickness;                        // along the arm (generous)
arm_reach_y  = arm_length * sin(arm_angle) + arm_thickness + lip_length + lip_bend_r;
taper_start  = neck_thickness + support_length;
taper_end    = taper_start + taper_length;
eps = 0.01;

// Centerline of the arm in its own frame (u along the arm, v up from its
// bottom) as [point, direction angle]: straight, bend up, straight tip
function arm_path() =
    let (t2 = arm_thickness / 2,
         c  = [lip_start, t2 + bend_rc],               // bend center
         n  = max(2, ceil(lip_bend / 5)),
         arc = [for (i = [0 : n]) let (a = lip_bend * i / n)
                  [[c[0] + bend_rc * sin(a), c[1] - bend_rc * cos(a)], a]],
         e  = arc[n][0])
    concat(
        [[[0, t2], 0]],
        arc,
        [[[e[0] + lip_length * cos(lip_bend), e[1] + lip_length * sin(lip_bend)], lip_bend]]
    );

// Arm + curved-up tip with constant thickness (no solid lip)
module arm_2d() {
    path = arm_path();
    t2 = arm_thickness / 2;
    top    = [for (p = path) p[0] + t2 * [-sin(p[1]), cos(p[1])]];
    bottom = [for (p = path) p[0] - t2 * [-sin(p[1]), cos(p[1])]];
    polygon(concat(top, [for (i = [len(bottom) - 1 : -1 : 0]) bottom[i]]));
}

module raw_profile() {
    union() {
        rotate(arm_angle) arm_2d();                              // tilted arm
        square([neck_thickness, total_height]);                  // neck
        translate([0, total_height - plate_thickness])
            square([plate_front, plate_thickness]);              // plate
    }
}

module profile() {
    // round convex corners, then fillet concave corners
    offset(r = -fillet_r) offset(delta = fillet_r)
        offset(r = round_r) offset(delta = -round_r)
            raw_profile();
}

module extruded_profile() {
    step = chamfer / chamfer_steps;
    union() {
        for (i = [0 : chamfer_steps - 1]) {
            inset = chamfer - i * step;
            translate([0, 0, i * step])
                linear_extrude(step + eps) offset(delta = -inset) profile();
            translate([0, 0, support_width - (i + 1) * step])
                linear_extrude(step + eps) offset(delta = -inset) profile();
        }
        translate([0, 0, chamfer])
            linear_extrude(support_width - 2 * chamfer) profile();
    }
}

// Maps a 2D shape drawn in (X, Z) onto the XZ plane, extruded along +Y
module xz_extrude(h) {
    rotate([90, 0, 0]) mirror([0, 0, 1]) linear_extrude(h) children();
}

// Inset of one arm side at depth x: 0 on the wide part, growing along a
// cosine S-curve to (support_width - tip_width) / 2 at the end of the taper
function side_inset(x) =
    let (side = (support_width - tip_width) / 2,
         t = min(1, max(0, (x - taper_start) / taper_length)))
    side * (1 - cos(180 * t)) / 2;

// ---- rounded arm (sweep of rounded cross-sections along the arm) ----

function rot2(p, a) = [p[0] * cos(a) - p[1] * sin(a), p[0] * sin(a) + p[1] * cos(a)];

// Dense centerline samples [point, angle] in the arm frame
function arm_samples() =
    let (t2 = arm_thickness / 2,
         ns = ceil(lip_start / arm_sample),
         straight = [for (i = [0 : ns]) [[lip_start * i / ns, t2], 0]],
         c  = [lip_start, t2 + bend_rc],
         nb = max(2, ceil(lip_bend / 5)),
         arc = [for (i = [1 : nb]) let (a = lip_bend * i / nb)
                  [[c[0] + bend_rc * sin(a), c[1] - bend_rc * cos(a)], a]],
         e  = arc[nb - 1][0],
         nt = ceil(lip_length / arm_sample),
         tip = [for (i = [1 : nt]) let (d = lip_length * i / nt)
                  [[e[0] + d * cos(lip_bend), e[1] + d * sin(lip_bend)], lip_bend]])
    concat(straight, arc, tip);

// Thin rounded-rectangle cross-section of one prong at a sample
// (side = +1 / -1: which side of the cable slot)
module prong_section(s, side) {
    p  = rot2(s[0], arm_angle);
    hw = support_width / 2 - side_inset(p[0]);
    z0 = side > 0 ? support_width / 2 + cable_slot_width / 2 : support_width / 2 - hw;
    z1 = side > 0 ? support_width / 2 + hw : support_width / 2 - cable_slot_width / 2;
    // edge radius grows from ~0 (matching the square fillet zone) to arm_edge_r
    u0 = neck_thickness + fillet_r + 1;
    k  = min(1, max(0, (s[0][0] - u0) / arm_edge_ramp));
    r  = 0.3 + (arm_edge_r - 0.3) * (1 - cos(180 * k)) / 2;
    t2 = arm_thickness / 2;
    translate([p[0], p[1], 0]) rotate([0, 0, s[1] + arm_angle])
        hull() for (yy = [-t2 + r, t2 - r], zz = [z0 + r, z1 - r])
            translate([0, yy, zz]) rotate([0, 90, 0])
                cylinder(r = r, h = 0.02, center = true, $fn = 24);
}

module rounded_arm() {
    s = arm_samples();
    for (side = [-1, 1], i = [0 : len(s) - 2])
        hull() {
            prong_section(s[i], side);
            prong_section(s[i + 1], side);
        }
}

// Region of the square-edged arm that the rounded arm replaces
// (everything past the neck/arm fillet and below the plate)
module arm_zone() {
    translate([neck_thickness + fillet_r + 1, -20, -1])
        cube([arm_length + 50, total_height - plate_thickness - 1 + 20, support_width + 2]);
}

// Removes the arm's sides beyond the wide support area (top view taper)
module arm_side_cutters() {
    side = (support_width - tip_width) / 2;
    curve = [for (i = [0 : taper_steps])
                let (x = taper_start + taper_length * i / taper_steps)
                [x, side_inset(x)]];
    for (m = [0, 1])
        translate([0, 0, m * support_width]) mirror([0, 0, m])
            translate([0, -1, 0]) xz_extrude(arm_reach_y + 4)
                polygon(concat(
                    [[taper_start, -1]],
                    curve,
                    [[arm_length + 10, side], [arm_length + 10, -1]]
                ));
}

// Slot shape along +X, centered on Z = 0, with a pointed +X end (print up)
module pointed_slot_2d(x0, x1, w) {
    polygon([
        [x0, -w / 2], [x1, -w / 2],
        [x1 + w * window_tip_ratio, 0],
        [x1, w / 2], [x0, w / 2]
    ]);
}

// Neck window joined to the cable slot, with the junction corners rounded
// (drawn in the neck plane: local x = -Z, local y = Y)
module neck_window() {
    y0 = arm_thickness + neck_thickness * tan(arm_angle) + fillet_r + neck_window_margin;
    y1 = total_height - plate_thickness - fillet_r - neck_window_margin;
    z0 = neck_window_border;
    z1 = support_width - neck_window_border;
    r  = neck_window_round;
    zc = support_width / 2;
    translate([-1, 0, 0]) rotate([0, 90, 0])     // local x -> -Z, y -> Y, z -> X
        linear_extrude(neck_thickness + fillet_r + slot_join_round + 1) // through the fillet zone
            offset(r = -slot_join_round) offset(delta = slot_join_round)
                union() {
                    hull() for (y = [y0 + r, y1 - r], z = [z0 + r, z1 - r])
                        translate([-z, y]) circle(r = r);
                    translate([-zc - cable_slot_width / 2, -20])
                        square([cable_slot_width, y0 + r + 20]);
                }
}

module plate_window() {
    translate([0, total_height - plate_thickness - 1, support_width / 2])
        xz_extrude(plate_thickness + 2)
            pointed_slot_2d(plate_window_start, plate_window_end, plate_window_width);
}

// Open slot along the middle of the arm: from the tip (through the lip),
// through the arm/neck corner and up into the neck window, so a charging
// cable can be dropped in from the front without unplugging it.
module cable_slot() {
    reach_v = arm_thickness + lip_length + lip_bend_r; // covers the tip and merges with the neck window
    rotate([0, 0, arm_angle])
        translate([-neck_thickness - 5, -5, support_width / 2 - cable_slot_width / 2])
            cube([arm_length + neck_thickness + 15, reach_v + 5, cable_slot_width]);
}

// 2D teardrop with its tip toward local +X (print up)
module teardrop_2d(d) {
    circle(d = d);
    rotate(-45) square(d / 2);
}

// Screw hole along +Y, countersunk on the lower face of the plate
module screw_hole() {
    cs_depth = (screw_head_d - screw_d) / 2;
    translate([0, total_height - plate_thickness, 0]) {
        translate([0, -1, 0]) xz_extrude(plate_thickness + 2) teardrop_2d(screw_d);
        hull() {
            translate([0, -1, 0]) xz_extrude(1 + eps) teardrop_2d(screw_head_d);
            translate([0, cs_depth, 0]) xz_extrude(eps) teardrop_2d(screw_d);
        }
    }
}

// 45 deg chamfer along the two Y edges of the back face (print base)
module foot_chamfer_cutters() {
    for (z = [0, support_width])
        translate([0, -1, z]) xz_extrude(total_height + 2)
            rotate(45) square(foot_chamfer * sqrt(2), center = true);
}

module hook() {
    union() {
        difference() {
            extruded_profile();
            arm_side_cutters();
            neck_window();
            plate_window();
            cable_slot();
            arm_zone();
            for (s = [-1, 1])
                translate([screw_x, 0, support_width / 2 + s * screw_spacing / 2])
                    screw_hole();
            foot_chamfer_cutters();
        }
        rounded_arm();
    }
}

// Rough generic controller, only for visual checks (use orientation)
module ghost_controller() {
    rotate([0, -arm_angle, 0])
    color("gray", 0.35) translate([neck_thickness + 3, -support_width / 2, arm_thickness]) {
        translate([0, -75, 0]) cube([55, 150, 30]);
        for (s = [-1, 1]) hull() {
            translate([25, s * 52, 12]) sphere(r = 22);
            translate([100, s * 48, -10]) sphere(r = 18);
        }
        for (p = [[25, -30], [45, 25]])
            translate([p[0], p[1], 30]) cylinder(d = 20, h = 30);
    }
}

if (orientation == "use") {
    rotate([90, 0, 0]) hook();
    if (show_controller) %ghost_controller();
} else {
    rotate([0, -90, 0]) hook();   // stand on the neck's back face
}
