// Door mount ring for a round magnetic door stop/catch.
// The ring clamps the item's wide disk against the door and is fixed with screws
// (or glued/taped using its larger back area).
//
// Modeled in PRINT orientation: front face (z = 0) on the bed,
// door-side face (z = plate_t) on top, with the disk pocket opening upwards.

/* [Item dimensions] */
disk_d     = 50;    // wide black disk diameter (A) [mm]
disk_t     = 4;     // wide black disk thickness [mm] (estimated, measure!)
body_d     = 35;    // ribbed body diameter below the disk (B) [mm]
item_h     = 20;    // total item height (C) [mm] (reference only)

/* [Fit] */
clearance  = 0.3;   // radial gap around disk and body [mm]
clamp      = 0.3;   // pocket is this much shallower than disk_t so screws clamp it [mm]

/* [Ring] */
plate_d    = 80;    // outer diameter of the mount ring [mm]
front_t    = 2.4;   // thickness of the front lip that holds the disk [mm]
edge_chamfer  = 1.5; // 45 deg chamfer on the front outer edge (also elephant foot) [mm]
hole_chamfer  = 0.6; // chamfer on the front edge of the body hole [mm]

/* [Screws] */
screw_count = 3;    // number of screw holes
screw_pcd_r = 33;   // radius of the screw hole circle [mm]
screw_d     = 4.0;  // screw clearance hole (for 3.5 mm wood screws) [mm]
head_d      = 7.5;  // countersink diameter at the front face [mm]

/* [Quality] */
$fn = 128;

// Derived
pocket_d     = disk_d + 2 * clearance;
pocket_depth = disk_t - clamp;
plate_t      = front_t + pocket_depth;
hole_d       = body_d + 2 * clearance;
eps          = 0.01;

module ring_body() {
    // Outer shape with chamfered front (bed) edge
    hull() {
        translate([0, 0, edge_chamfer])
            cylinder(d = plate_d, h = plate_t - edge_chamfer);
        cylinder(d = plate_d - 2 * edge_chamfer, h = edge_chamfer);
    }
}

module screw_hole() {
    // Countersink opens at the front face (bed side); 45 deg cone prints fine
    translate([0, 0, -eps]) {
        cylinder(d = screw_d, h = plate_t + 2 * eps);
        cylinder(d1 = head_d, d2 = screw_d, h = (head_d - screw_d) / 2);
    }
}

difference() {
    ring_body();

    // Pocket for the wide disk (open on the door side)
    translate([0, 0, front_t])
        cylinder(d = pocket_d, h = pocket_depth + eps);

    // Through hole for the ribbed body
    translate([0, 0, -eps])
        cylinder(d = hole_d, h = plate_t + 2 * eps);

    // Chamfer on the front edge of the body hole
    translate([0, 0, -eps])
        cylinder(d1 = hole_d + 2 * hole_chamfer, d2 = hole_d, h = hole_chamfer);

    // Screw holes, evenly spaced
    for (i = [0 : screw_count - 1])
        rotate([0, 0, 90 + i * 360 / screw_count])
            translate([screw_pcd_r, 0, 0])
                screw_hole();
}
