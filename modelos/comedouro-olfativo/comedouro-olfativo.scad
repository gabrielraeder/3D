// Sniff feeder (comedouro olfativo): printed body + lid
// The body holds two store-bought, heat-proof parts:
//   - a porcelain ramekin (or stainless bowl) at the bottom: warm treat / scent bait
//   - a stainless tuna-can strainer on top: perforated basket for kibble,
//     hanging by its rim + ears in a matching recess at the top of the body
// Only the store-bought parts touch the food; the printed parts are just holders.
// Print in PETG (warm food softens PLA).
// All dimensions in mm.

/* [What to render] */
part = "assembly";       // "assembly" (preview), "body" or "lid" (print orientation)

/* [Can strainer (store-bought) - 11.5 x 9.5 x 2.5 cm] */
strainer_cup_d = 92;     // basket outer diameter just below the rim (mm)
strainer_cup_h = 25;     // basket depth, rim underside to basket bottom (mm)
strainer_rim_d = 95;     // diameter of the round part of the rim (mm)
strainer_len = 115;      // overall length across both ears (mm)
strainer_ear_w = 60;     // width of the ears, measured across (mm)
strainer_rim_t = 1.5;    // rim / ear thickness, for the preview ghost (mm)
cup_clearance = 1.5;     // diametral clearance around the basket (mm)
rim_clearance = 1.5;     // gap around the rim + ears outline, per side (mm)
rim_recess = 2;          // depth of the recess the rim sits in (mm)

/* [Bowl (store-bought, heat-proof: porcelain ramekin or stainless)] */
bowl_d = 80;             // bowl top (rim) diameter (mm)
bowl_h = 45;             // bowl height (mm)
bowl_base_d = 76;        // bowl bottom diameter, for the locating ring (mm)
bowl_clearance = 1.0;    // diametral clearance around the bowl base (mm)
bowl_gap = 4;            // air gap between bowl rim and strainer bottom (mm)

/* [Body] */
wall_min = 8;            // wall beyond the ear tips (room for the finger pockets) (mm)
floor_t = 3;             // floor thickness (mm)
body_taper = 5;          // extra outer radius at the base vs the top (mm)
top_chamfer = 1.5;       // chamfer on the outer top edge (mm)
foot_chamfer = 0.5;      // first-layer (elephant foot) chamfer (mm)

/* [Bowl locating ring + thermal standoffs] */
locator_t = 2;           // ring wall thickness (mm)
locator_h = 8;           // ring height above the floor (mm)
standoff_h = 3;          // air gap under the bowl, reduces heat into the body (mm)
standoff_count = 3;      // number of small pads the bowl rests on
standoff_w = 4;          // pad width (mm)
standoff_len = 12;       // pad length, radial (mm)

/* [Bowl access slots (full height, hidden under the strainer ears)] */
slot_w = 20;             // slot width (mm)
slot_reach = 53;         // slot outer radius; keep it under the ears (mm)
slot_round = 5;          // corner radius (mm)

/* [Finger pockets at the ear tips (to lift the strainer)] */
finger_w = 20;           // pocket width (mm)
finger_in = 6;           // how far the pocket goes under the ear (mm)
finger_out = 5;          // how far the pocket goes past the ear tip (mm)
finger_depth = 6;        // pocket depth below the rim seat (mm)

/* [Anti-slip pad pockets (bottom)] */
pad_count = 4;           // number of pockets for adhesive rubber bumpers (0 = none)
pad_d = 10.4;            // pocket diameter: bumper diameter + 0.4 (mm)
pad_depth = 1.0;         // pocket depth (mm)
pad_inset = 5;           // distance from pocket edge to body edge (mm)

/* [Lid] */
lid_t = 3;               // top plate thickness (mm)
lid_skirt_h = 10;        // skirt height, slides over the body (mm)
lid_wall = 2.4;          // skirt wall thickness (mm)
lid_clearance = 0.4;     // diametral clearance skirt vs body (mm)
lid_brim = 3;            // top plate overhang past the skirt, finger grip (mm)
lid_chamfer = 0.5;       // first-layer chamfer (lid prints upside down) (mm)

/* [Preview] */
show_parts = true;       // show the bowl and strainer as ghosts (assembly only)
show_lid = true;         // show the lid (assembly only)
lid_lift = 25;           // lift the lid in the assembly view (mm)
cutaway = false;         // cut the assembly in half to see inside

/* [Quality] */
$fn = 128;

// ---------- derived values ----------
r_hole = (strainer_cup_d + cup_clearance) / 2;            // basket hole / chamber radius
bowl_z = floor_t + standoff_h;                             // bowl bottom height
seat_z = bowl_z + bowl_h + bowl_gap + strainer_cup_h;      // rim seat height
total_h = seat_z + rim_recess;
ear_tip_x = strainer_len / 2 + rim_clearance;              // end of the ear recess
r_out_top = ear_tip_x + wall_min;
r_out_base = r_out_top + body_taper;
r_loc_in = (bowl_base_d + bowl_clearance) / 2;

assert(bowl_d < 2 * r_hole - 2, "Bowl does not fit through the strainer hole");
assert(ear_tip_x + finger_out < r_out_top - 2, "Finger pocket too close to the outer wall");
assert(2 * (r_out_base + lid_wall + lid_brim) <= 250, "Larger than the A1 build plate margin");

// outer radius of the tapered body wall at height z
function r_out_at(z) = r_out_base + (r_out_top - r_out_base) * z / total_h;

// ---------- outlines ----------
// Strainer rim + ears seen from above (round rim + elliptical ear lobe)
module strainer_outline() {
    union() {
        circle(d = strainer_rim_d);
        resize([strainer_len, strainer_ear_w]) circle(d = 10);
    }
}

module rounded_rect(x0, x1, w, r) {
    translate([x0, -w / 2])
        offset(r = r) offset(delta = -r) square([x1 - x0, w]);
}

// ---------- body ----------
module body_shell() {
    eps = 0.01;
    union() {
        cylinder(r1 = r_out_base - foot_chamfer, r2 = r_out_at(foot_chamfer),
                 h = foot_chamfer + eps);
        translate([0, 0, foot_chamfer])
            cylinder(r1 = r_out_at(foot_chamfer), r2 = r_out_at(total_h - top_chamfer),
                     h = total_h - top_chamfer - foot_chamfer);
        translate([0, 0, total_h - top_chamfer - eps])
            cylinder(r1 = r_out_at(total_h - top_chamfer), r2 = r_out_top - top_chamfer,
                     h = top_chamfer + eps);
    }
}

module locator_ring() {
    translate([0, 0, floor_t - 0.01])
        difference() {
            cylinder(r = r_loc_in + locator_t, h = locator_h + 0.01);
            translate([0, 0, -1]) cylinder(r = r_loc_in, h = locator_h + 2);
        }
}

// Small radial pads: the bowl touches the body only here (less heat transfer)
module standoffs() {
    for (i = [0 : standoff_count - 1])
        rotate([0, 0, i * 360 / standoff_count])
            translate([r_loc_in - 1 - standoff_len, -standoff_w / 2, floor_t - 0.01])
                cube([standoff_len, standoff_w, standoff_h + 0.01]);
}

module rim_recess_cut() {
    translate([0, 0, seat_z])
        linear_extrude(height = rim_recess + 1)
            offset(delta = rim_clearance) strainer_outline();
}

// Vertical finger slots beside the bowl, under the ears (x axis)
module access_slots() {
    for (s = [0, 180])
        rotate([0, 0, s])
            translate([0, 0, floor_t])
                linear_extrude(height = total_h)
                    rounded_rect(r_hole - 5, slot_reach, slot_w, slot_round);
}

// Shallow pockets at the ear tips to get a finger under the strainer ears
module finger_pockets() {
    for (s = [0, 180])
        rotate([0, 0, s])
            translate([0, 0, seat_z - finger_depth])
                linear_extrude(height = finger_depth + rim_recess + 1)
                    rounded_rect(ear_tip_x - rim_clearance - finger_in,
                                 ear_tip_x + finger_out, finger_w, 3);
}

module pad_pockets() {
    if (pad_count > 0)
        for (i = [0 : pad_count - 1])
            rotate([0, 0, 45 + i * 360 / pad_count])
                translate([r_out_base - pad_inset - pad_d / 2, 0, -1])
                    cylinder(d = pad_d, h = pad_depth + 1, $fn = 48);
}

module body() {
    difference() {
        union() {
            body_shell();
            locator_ring();
            standoffs();
        }
        // bowl chamber + basket hole (straight, no overhangs)
        translate([0, 0, floor_t]) cylinder(r = r_hole, h = total_h);
        rim_recess_cut();
        access_slots();
        finger_pockets();
        pad_pockets();
    }
}

// ---------- lid (modelled in its installed position) ----------
// Cap: top plate resting on the body top + skirt that follows the body taper.
module lid_installed() {
    c = lid_clearance / 2;
    z0 = total_h - lid_skirt_h;
    r_in_bot = r_out_at(z0) + c;
    r_in_top = r_out_top + c;
    r_plate = r_out_at(z0) + c + lid_wall + lid_brim;
    union() {
        // skirt
        translate([0, 0, z0])
            difference() {
                cylinder(r1 = r_in_bot + lid_wall, r2 = r_in_top + lid_wall, h = lid_skirt_h + 0.01);
                translate([0, 0, -0.01])
                    cylinder(r1 = r_in_bot, r2 = r_in_top, h = lid_skirt_h + 0.03);
            }
        // top plate (its top edge touches the bed when printed, hence the chamfer)
        translate([0, 0, total_h]) {
            cylinder(r = r_plate, h = lid_t - lid_chamfer);
            translate([0, 0, lid_t - lid_chamfer - 0.01])
                cylinder(r1 = r_plate, r2 = r_plate - lid_chamfer, h = lid_chamfer + 0.01);
        }
    }
}

module lid_print() {
    translate([0, 0, total_h + lid_t]) rotate([180, 0, 0]) lid_installed();
}

// ---------- ghosts of the store-bought parts (preview only) ----------
module ghost_bowl() {
    color("white", 0.95)
        translate([0, 0, bowl_z])
            difference() {
                cylinder(d1 = bowl_base_d, d2 = bowl_d, h = bowl_h);
                translate([0, 0, 2])
                    cylinder(d1 = bowl_base_d - 6, d2 = bowl_d - 6, h = bowl_h);
            }
}

module ghost_strainer() {
    hole_d = 4;
    pitch = 7.5;
    color("lightsteelblue", 0.95) {
        translate([0, 0, seat_z])
            linear_extrude(height = strainer_rim_t)
                difference() {
                    strainer_outline();
                    circle(d = strainer_cup_d - 2);
                }
        translate([0, 0, seat_z - strainer_cup_h])
            difference() {
                cylinder(d = strainer_cup_d, h = strainer_cup_h);
                translate([0, 0, 1]) cylinder(d = strainer_cup_d - 2, h = strainer_cup_h);
                for (x = [-strainer_cup_d / 2 : pitch : strainer_cup_d / 2],
                     y = [-strainer_cup_d / 2 : pitch : strainer_cup_d / 2])
                    if (norm([x, y]) < strainer_cup_d / 2 - 8)
                        translate([x, y, -1]) cylinder(d = hole_d, h = 3, $fn = 16);
            }
    }
}

module assembly() {
    color("dimgray") body();
    if (show_parts) {
        ghost_bowl();
        ghost_strainer();
    }
    if (show_lid)
        color("slategray") translate([0, 0, lid_lift]) lid_installed();
}

// ---------- output ----------
if (part == "body") body();
else if (part == "lid") lid_print();
else if (cutaway)
    difference() {
        assembly();
        translate([-200, -400, -1]) cube([400, 400, 400]);
    }
else assembly();

echo(str("Body: Ø", 2 * r_out_base, " mm (base) x ", total_h,
         " mm tall; basket hole Ø", 2 * r_hole,
         "; lid Ø", 2 * (r_out_at(total_h - lid_skirt_h) + lid_clearance / 2 + lid_wall + lid_brim),
         "; closed height ", total_h + lid_t));
