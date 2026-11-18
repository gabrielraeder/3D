// Press-fit U clip for the bottom edge of a door, holding a round magnetic
// door stop/catch on one face of the door. No screws, no drilling.
//
// The item's wide disk sits in a pocket on the inner face of the front arm,
// clamped between the arm and the door; the ribbed body passes through a hole.
//
// Modeled in PRINT orientation: the U profile lies on the bed (XY plane) and
// the clip width runs along Z. Layers follow the U, so the arms flex within
// the strong XY plane. Horizontal holes use flat-topped teardrops (no supports).
//
// Axes: X = across the door thickness (door face at x = 0, door from x = 0 to
// door_t), Y = up the door (y = 0 is the underside of the clip), Z = along the
// door's bottom edge.

/* [Door] */
door_t      = 35;    // door thickness [mm]
floor_gap   = 5;     // gap between door bottom and floor (reference) [mm]

/* [Item dimensions] */
disk_d      = 50;    // wide black disk diameter (A) [mm]
disk_t      = 4;     // wide black disk thickness [mm] (estimated, measure!)
body_d      = 35;    // ribbed body diameter below the disk (B) [mm]
item_h      = 20;    // total item height (C) [mm] (reference only)

/* [Fit] */
clearance   = 0.3;   // radial gap around disk and body [mm]
clamp       = 0.3;   // disk protrudes this much past the arm to press on the door [mm]
fit_gap     = 0.2;   // extra opening at the U base so it slides on easily [mm]
grip        = 1.0;   // how far the grip ridge on the back arm reaches into the door [mm]
ridge_r     = 2.0;   // radius of the grip ridge [mm]
ridge_from_tip = 6;  // ridge center distance from the back arm tip [mm]
lead_in     = 1.5;   // 45 deg chamfer on arm tips for easy push-on [mm]

/* [Clip] */
width       = 62;    // clip width along the door edge [mm]
bridge_t    = 3;     // thickness under the door (must be < floor_gap) [mm]
front_t     = 2.4;   // front lip holding the disk [mm]
back_t      = 3;     // back arm thickness (the spring) [mm]
back_h      = 35;    // back arm height from clip underside [mm]
disk_margin = 2;     // gap between door bottom and disk edge [mm]
top_margin  = 5;     // material above the disk on the front arm [mm]
outer_chamfer = 1.5; // chamfer on the outer bottom corners [mm]
foot_inset  = 0.4;   // first-layer inset against elephant foot [mm]

/* [Test] */
test_fit    = false; // true = thin slice without the item holder, to test the grip
test_width  = 10;    // width of the test slice [mm]

/* [Quality] */
$fn = 128;

// Derived
pocket_depth = disk_t - clamp;
front_arm_t  = front_t + pocket_depth;
pocket_d     = disk_d + 2 * clearance;
hole_d       = body_d + 2 * clearance;
inner_gap    = door_t + fit_gap;
item_y       = bridge_t + disk_margin + pocket_d / 2;   // item center height
front_h      = item_y + pocket_d / 2 + top_margin;
clip_w       = test_fit ? test_width : width;
eps          = 0.01;

assert(bridge_t < floor_gap, "bridge_t must be smaller than floor_gap");

module profile() {
    difference() {
        union() {
            // Bridge under the door
            translate([-front_arm_t, 0]) square([front_arm_t + inner_gap + back_t, bridge_t]);
            // Front arm (item side)
            translate([-front_arm_t, 0]) square([front_arm_t, test_fit ? back_h : front_h]);
            // Back arm (spring)
            translate([inner_gap, 0]) square([back_t, back_h]);
            // Grip ridge on the inner face of the back arm
            intersection() {
                translate([inner_gap - grip + ridge_r, back_h - ridge_from_tip]) circle(r = ridge_r);
                translate([inner_gap - grip, 0]) square([grip + back_t, back_h]);
            }
        }
        // Lead-in chamfer on the back arm tip (inner edge)
        translate([inner_gap, back_h]) rotate(45) square(lead_in * sqrt(2), center = true);
        // Lead-in chamfer on the front arm tip (inner edge)
        translate([0, test_fit ? back_h : front_h]) rotate(45) square(lead_in * sqrt(2), center = true);
        // Outer bottom corner chamfers
        translate([-front_arm_t, 0]) rotate(45) square(outer_chamfer * sqrt(2), center = true);
        translate([inner_gap + back_t, 0]) rotate(45) square(outer_chamfer * sqrt(2), center = true);
    }
}

// Flat-topped teardrop extruded along +X, tip pointing +Z (print up)
module teardrop_x(d, len) {
    r = d / 2;
    rotate([0, 90, 0])
        linear_extrude(height = len)
            intersection() {
                hull() {
                    circle(d = d);
                    // local -x maps to global +z after rotate
                    polygon([[0, -r / sqrt(2)], [0, r / sqrt(2)], [-r * sqrt(2), 0]]);
                }
                translate([-r, -r]) square([2 * r, 2 * r]);   // flat top at r
            }
}

module clip() {
    difference() {
        union() {
            // First layer inset against elephant foot
            linear_extrude(height = foot_inset) offset(delta = -foot_inset) profile();
            translate([0, 0, foot_inset]) linear_extrude(height = clip_w - foot_inset) profile();
        }
        if (!test_fit) {
            // Pocket for the wide disk, open towards the door
            translate([-pocket_depth, item_y, clip_w / 2]) teardrop_x(pocket_d, pocket_depth + eps);
            // Through hole for the ribbed body
            translate([-front_arm_t - eps, item_y, clip_w / 2]) teardrop_x(hole_d, front_arm_t + 2 * eps);
        }
    }
}

clip();
