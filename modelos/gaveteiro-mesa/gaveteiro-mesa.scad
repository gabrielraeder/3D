// Under-desk drawer system - mounts under the tabletop, left of the desk leg.
// Three independent modules screwed to the underside of the tabletop:
//   - front module: opens to the front, two stacked drawers (thin + tall)
//   - two side modules: open to the outer side edge of the desk, one tall drawer each
//
// The modules reach the leg column. On the column side the top is recessed so it slides
// under the black metal bracket (aba) that holds the tabletop. Where the bracket does not
// reach (front and back ends of the desk) an end block fills the recess and takes a screw.
//
// Housings print standing on their back wall (opening facing up): no supports.
// Drawers print on their bottom: no supports.
//
// Usage: set `part` (or override with -D "part=\"front_housing\"") and export STL.

/* [Part to render] */
// assembly | front_module | front_housing | front_drawer_thin | front_drawer_tall |
// side_housing | side_housing_back | side_drawer
part = "assembly";
// Drawer opening in the assembly view (0 = closed, 1 = fully open)
assembly_open = 0.45;

/* [Space under the desk] */
space_width = 170;          // desk side edge to the leg column face (mm)
column_clearance = 2;       // gap between the modules and the leg column (mm)
body_height = 110;          // housing height below the mounting platform (mm)
desk_depth = 800;           // tabletop depth, front to back (mm)
front_setback = 20;         // front module set back from the desk front edge (mm)
module_gap = 5;             // gap between neighbouring modules (mm)

/* [Leg bracket (aba)] */
bracket_width = 25;         // how far the bracket reaches from the column towards the edge (mm)
bracket_drop = 7;           // lowest point of bracket + bolt heads below the tabletop (mm)
bracket_end_gap = 60;       // free tabletop in front of and behind the bracket (mm)
bracket_clearance = 1;      // vertical gap under the bracket (mm)
bracket_margin = 2;         // horizontal gap to the bracket edge (mm)
end_block_margin = 5;       // gap between an end block and the bracket end (mm)

/* [Front module] */
front_depth = 240;          // housing depth along the pull direction (mm)
thin_slot_height = 30;      // slot height of the thin top drawer (mm); tall drawer takes the rest
thin_dividers = 2;          // lengthwise dividers in the thin drawer (pens, small parts)
tall_dividers = 0;          // lengthwise dividers in the tall front drawer

/* [Side modules] */
side_count = 2;             // number of side modules behind the front module
side_length = 250;          // module length along the desk depth (mm), <= 250 to fit the bed
side_dividers = 0;          // dividers in each side drawer (parallel to the pull direction)

/* [Housing walls] */
top_t = 2.4;                // ceiling plate under the mounting platform (mm)
wall_t = 2.0;               // side walls, platform walls and ribs (mm)
back_t = 1.6;               // back wall (mm)
floor_t = 1.6;              // bottom (mm)
shelf_t = 1.2;              // shelf between stacked drawers (mm)

/* [Lightening windows] */
// Elongated windows with 45 deg pointed ends along the pull direction (vertical when
// printing), cut in side walls, floor, shelf and ceiling to save filament.
lighten = true;             // cut the windows
win_border = 7;             // solid border around each window field (mm)
win_bar = 5;                // bar between neighbouring windows (mm)
win_max_len = 100;          // max window length along the pull direction (mm)
win_max_w = 60;             // max window width (mm)
win_min_w = 12;             // skip fields narrower than this (mm)
back_frame = 10;            // border of the back wall frame (mm)

/* [Drawers] */
drawer_wall = 1.2;          // drawer side/back walls (mm)
drawer_floor = 1.2;         // drawer bottom (mm)
drawer_front_t = 2.4;       // drawer front panel (mm)
divider_t = 1.2;            // divider thickness (mm)
side_gap = 1.2;             // gap drawer wall <-> housing wall (room for the stop mechanism) (mm)
guide_rib = 0.8;            // guide rib on top of drawer sides, leaves side_gap - guide_rib of play (mm)
guide_rib_h = 4;            // guide rib height (mm)
top_gap = 0.6;              // gap above the drawer (mm)
back_gap = 0.5;             // gap behind the closed drawer (mm)
front_play = 0.4;           // gap between front panel and housing opening, each side (mm)
grip_width = 40;            // finger notch width in the front panel (mm)
grip_depth = 14;            // finger notch depth from the top edge (mm)

/* [Drawer stop (detent)] */
// A flexible arm at the rear of each drawer side carries a bump that catches a ridge
// inside the housing, so the drawer does not fall out. A firm pull releases it.
max_open_ratio = 0.75;      // how far the drawer opens before the stop (fraction of its length)
arm_length = 40;            // flexible arm length (mm)
arm_height = 8;             // flexible arm height (mm)
arm_slot = 1.2;             // slot that frees the arm (mm)
ridge_h = 0.9;              // ridge protrusion from the housing wall (mm)
bump_h = 1.0;               // bump protrusion from the drawer wall (mm)
entry_angle = 30;           // ramp angle on the insertion side (deg)
stop_angle = 45;            // ramp angle on the stop side (deg, keep <= 45 for printing)

/* [Mounting] */
screw_d = 4.0;              // screw clearance hole, for 3.5 mm countersunk wood screws (mm)
screw_head_d = 7.5;         // countersink diameter (mm)
boss_d = 11;                // screw boss in the mounting platform (mm)
access_d = 10;              // access hole in shelf/floor to reach the screws with a screwdriver (mm)
screw_inset = 12;           // screw distance from the platform walls (mm)
screw_inset_y = 25;         // screw distance from the front opening (mm)

/* [Print] */
foot_chamfer = 0.5;         // chamfer on bed-side edges against elephant foot (mm)
$fn = 48;

eps = 0.01;

// ---------------------------------------------------------------- derived values

module_width = space_width - column_clearance;               // housing width (mm)
mount_h = bracket_drop + bracket_clearance;                  // platform height (mm)
module_height = body_height + mount_h;                       // tabletop to bottom face (mm)
recess_w = module_width - (space_width - bracket_width - bracket_margin);  // recess width (mm)
front_block_len = bracket_end_gap - front_setback - end_block_margin;
back_module_end = front_setback + front_depth + side_count * (module_gap + side_length);
back_block_len = bracket_end_gap - (desk_depth - back_module_end) - end_block_margin;

// ---------------------------------------------------------------- helpers

function sum(v, i = 0) = i >= len(v) ? 0 : v[i] + sum(v, i + 1);
function sub(v, n) = [for (i = [0 : 1 : n - 1]) v[i]];

// Slot heights (top to bottom) for each module type.
function front_slots() = [thin_slot_height,
                          body_height - top_t - floor_t - shelf_t - thin_slot_height];
function side_slots() = [body_height - top_t - floor_t];

// Bottom z of slot i (housing coordinates, z = 0 at the bottom face).
function slot_z(slots, i) =
    body_height - top_t - sum(sub(slots, i + 1)) - i * shelf_t;

// Teardrop pointing to -Y (= up when the housing prints standing on its back wall).
module teardrop2d(d) {
    r = d / 2;
    hull() {
        circle(r = r);
        polygon([[-r * cos(45), -r * sin(45)], [0, -r * sqrt(2)], [r * cos(45), -r * sin(45)]]);
    }
}

// Box with a chamfer on the edges of its +Y face (bed face of the housing).
module box_chamfer_back(size, c) {
    hull() {
        cube([size.x, size.y - c, size.z]);
        translate([c, 0, c]) cube([size.x - 2 * c, size.y, size.z - 2 * c]);
    }
}

// Box with a chamfer on the bottom edges (bed face of the drawer).
module box_chamfer_bottom(size, c) {
    hull() {
        translate([0, 0, c]) cube([size.x, size.y, size.z - c]);
        translate([c, c, 0]) cube([size.x - 2 * c, size.y - 2 * c, size.z]);
    }
}

// Triangular ramp profile in the (protrusion, y) plane, extruded along z.
// Apex at y = 0; the -y face uses angle a_neg, the +y face uses angle a_pos.
module ramp(h, a_neg, a_pos, height) {
    linear_extrude(height)
        polygon([[0, -h / tan(a_neg)], [h, 0], [0, h / tan(a_pos)]]);
}

// Prism between z0 and z1 whose y-extent shrinks from [y0, y1a] at z0 to [y0, y1b] at z1
// (a 45 deg face on +y when y1a - y1b = z1 - z0: printable when +y points to the bed).
module slant_block(x0, x1, y0, y1a, y1b, z0, z1) {
    hull() {
        translate([x0, y0, z0]) cube([x1 - x0, y1a - y0, eps]);
        translate([x0, y0, z1 - eps]) cube([x1 - x0, y1b - y0, eps]);
    }
}

// ---------------------------------------------------------------- drawer geometry

function drawer_w(W)  = W - 2 * wall_t - 2 * side_gap;   // body width
function drawer_l(D)  = D - back_t - back_gap;           // length
function drawer_h(sh) = sh - top_gap;                    // height
function arm_free_y(D) = drawer_l(D) - drawer_wall - 2 - arm_length;
// Ridge position (housing y of the apex) so the drawer opens max_open_ratio of its length.
function ridge_y(D) = max(drawer_front_t + 8,
                          arm_free_y(D) + 1 + bump_h / tan(stop_angle) + ridge_h / tan(stop_angle)
                          - max_open_ratio * drawer_l(D));

// Drawer in its own coordinates: front face at y = 0, bottom at z = 0, body x in [0, w].
module drawer(W, D, slot_h, dividers) {
    w = drawer_w(W);
    l = drawer_l(D);
    h = drawer_h(slot_h);
    front_extra = side_gap - front_play;           // front panel overhangs the body sides
    y_free = arm_free_y(D);
    notch_d = min(grip_depth, h * 0.5);

    difference() {
        union() {
            // body
            difference() {
                box_chamfer_bottom([w, l, h], foot_chamfer);
                translate([drawer_wall, drawer_front_t, drawer_floor])
                    cube([w - 2 * drawer_wall, l - drawer_front_t - drawer_wall, h]);
            }
            // front panel, wider than the body to hide the side gap
            translate([-front_extra, 0, 0])
                box_chamfer_bottom([w + 2 * front_extra, drawer_front_t, h], foot_chamfer);
            // guide ribs on top of the side walls (45 deg underside)
            for (s = [0, 1])
                translate([s * w, 0, h]) mirror([s, 0, 0])
                    rotate([-90, 0, 0]) linear_extrude(l)
                        polygon([[0, 0], [-guide_rib, 0], [-guide_rib, guide_rib_h],
                                 [0, guide_rib_h + guide_rib]]);
            // dividers, parallel to the pull direction
            if (dividers > 0)
                for (i = [1 : dividers])
                    translate([drawer_wall + i * (w - 2 * drawer_wall) / (dividers + 1) - divider_t / 2,
                               drawer_front_t - eps, 0])
                        cube([divider_t, l - drawer_front_t - drawer_wall + 2 * eps, h - 2]);
            // stop bumps on the free end of the arms
            for (s = [0, 1])
                translate([s * w, y_free + 1 + bump_h / tan(stop_angle), 0])
                    mirror([s, 0, 0]) mirror([1, 0, 0])
                        ramp(bump_h, stop_angle, entry_angle, arm_height);
        }
        // finger notch in the front panel
        translate([w / 2, -1, h - notch_d])
            rotate([-90, 0, 0]) linear_extrude(drawer_front_t + 2)
                hull() {
                    translate([-grip_width / 2 + notch_d / 2, -notch_d / 2]) circle(d = notch_d);
                    translate([grip_width / 2 - notch_d / 2, -notch_d / 2]) circle(d = notch_d);
                    translate([-grip_width / 2, -notch_d - 1]) square([grip_width, 1]);
                }
        // free the flexible arms: front slot, top slot, and gap to the floor
        for (s = [0, 1])
            translate([s * w, 0, 0]) mirror([s, 0, 0]) {
                translate([-guide_rib - 1, y_free - arm_slot, -1])
                    cube([drawer_wall + guide_rib + 1 + eps, arm_slot, arm_height + arm_slot + 1]);
                translate([-guide_rib - 1, y_free - arm_slot, arm_height])
                    cube([drawer_wall + guide_rib + 1 + eps, arm_length + arm_slot, arm_slot]);
                translate([drawer_wall - eps, y_free - arm_slot, -1])
                    cube([arm_slot, arm_length + arm_slot, drawer_floor + 1 + eps]);
            }
    }
}

// ---------------------------------------------------------------- mounting platform
//
// Housing coordinates: opening at y = 0, back wall at y = D, platform top (tabletop) at
// z = module_height. The recess for the bracket is on the column side:
//   recess_axis = "x": strip x in [W - recess_w, W]  (front module, opens to the front)
//   recess_axis = "y": strip y in [D - recess_w, D]  (side modules, back wall at the column)

// Outer envelope of the platform. On a "y" recess its column-side face is slanted 45 deg
// so it prints without support (that face points to the bed).
module platform_envelope(W, D, axis) {
    z0 = body_height;
    if (axis == "x")
        translate([0, 0, z0]) cube([W - recess_w, D, mount_h]);
    else
        slant_block(0, W, 0, D - recess_w, D - recess_w - mount_h, z0, module_height);
}

function platform_xs(W, axis) = axis == "x"
    ? [wall_t + screw_inset, W - recess_w - wall_t - screw_inset]
    : (W > 200 ? [wall_t + screw_inset, W / 2, W - wall_t - screw_inset]
               : [wall_t + screw_inset, W - wall_t - screw_inset]);
function platform_ys(D, axis) = axis == "x"
    ? [screw_inset_y, D - back_t - screw_inset_y]
    : [screw_inset_y, D - recess_w - mount_h - wall_t - screw_inset];

// End block filling the recess where the bracket does not reach; returns its screw position.
function end_block_screw(W, D, axis, block_len) = axis == "x"
    ? [W - recess_w / 2, (block_len - mount_h) / 2]
    : [block_len / 2, D - recess_w / 2];

module end_block(W, D, axis, block_len) {
    if (axis == "x")   // at the front opening, +y face slanted 45 deg
        slant_block(W - recess_w - eps, W, 0, block_len, block_len - mount_h,
                    body_height - eps, module_height);
    else               // at x = 0, reaching the back wall (bed face)
        translate([0, D - recess_w - mount_h - wall_t, body_height - eps])
            cube([block_len, recess_w + mount_h + wall_t, mount_h + eps]);
}

// Hollow platform: perimeter walls, ribs through the screw columns and screw bosses.
module platform(W, D, axis) {
    Wf = axis == "x" ? W - recess_w : W;
    z0 = body_height - eps;
    intersection() {
        platform_envelope(W, D, axis);
        union() {
            // front wall, thickened with a 45 deg inner face (it is the top when printing)
            slant_block(0, Wf, 0, wall_t + mount_h, wall_t, z0, module_height);
            // side walls
            translate([0, 0, z0]) cube([wall_t, D, mount_h + eps]);
            translate([Wf - wall_t, 0, z0]) cube([wall_t, D, mount_h + eps]);
            // ribs along the pull direction (vertical when printing)
            for (x = platform_xs(W, axis))
                translate([x - wall_t / 2, 0, z0]) cube([wall_t, D, mount_h + eps]);
            // screw bosses, teardrop towards +y so they print without support
            for (x = platform_xs(W, axis), y = platform_ys(D, axis))
                translate([x, y, z0]) linear_extrude(mount_h + eps)
                    rotate(180) teardrop2d(boss_d);
        }
    }
    // back / column-side wall: the envelope's +y skin
    difference() {
        platform_envelope(W, D, axis);
        translate([0, -wall_t, 0]) platform_envelope(W, D, axis);
    }
}

// Countersunk screw hole through ceiling plate and platform, plus screwdriver access below.
module screw_cut(x, y) {
    translate([x, y, 0]) {
        translate([0, 0, body_height - top_t - 1]) linear_extrude(top_t + mount_h + 2)
            teardrop2d(screw_d);
        translate([0, 0, body_height - top_t - eps])
            linear_extrude((screw_head_d - screw_d) / 2, scale = screw_d / screw_head_d)
                teardrop2d(screw_head_d);
        translate([0, 0, -1]) linear_extrude(body_height - top_t + 1) teardrop2d(access_d);
    }
}

// ---------------------------------------------------------------- lightening windows

// Elongated hexagon in (u, v): pointed 45 deg ends along u.
module lozenge(len, w) {
    polygon([[0, w / 2], [w / 2, 0], [len - w / 2, 0], [len, w / 2], [len - w / 2, w], [w / 2, w]]);
}

// Grid of lozenges filling u in [u0, u1], v in [v0, v1] (2D).
module window_field(u0, u1, v0, v1) {
    L = u1 - u0;
    V = v1 - v0;
    if (L >= win_min_w && V >= win_min_w) {
        n = max(1, ceil((L + win_bar) / (win_max_len + win_bar)));
        m = max(1, ceil((V + win_bar) / (win_max_w + win_bar)));
        len = (L - (n - 1) * win_bar) / n;
        w = min((V - (m - 1) * win_bar) / m, len);
        for (i = [0 : n - 1], j = [0 : m - 1])
            translate([u0 + i * (len + win_bar), v0 + j * (w + win_bar)]) lozenge(len, w);
    }
}

// Window field cut through a horizontal plate (u = y, v = x) between z0 and z1.
module windows_z(x0, x1, y0, y1, z0, z1) {
    translate([0, 0, z0 - 1]) multmatrix([[0, 1, 0, 0], [1, 0, 0, 0], [0, 0, 1, 0]])
        linear_extrude(z1 - z0 + 2) window_field(y0, y1, x0, x1);
}

// Window field cut through both side walls (u = y, v = z).
module windows_x(W, y0, y1, z0, z1) {
    translate([-1, 0, 0]) multmatrix([[0, 0, 1, 0], [1, 0, 0, 0], [0, 1, 0, 0]])
        linear_extrude(W + 2) window_field(y0, y1, z0, z1);
}

// Ceiling windows between the platform ribs (bosses sit on the ribs).
module ceiling_windows(W, D, axis) {
    Wf = axis == "x" ? W - recess_w : W;
    cols = concat([0], platform_xs(W, axis), [Wf]);
    inset = boss_d / 2 + 1;
    y0 = wall_t + mount_h + win_bar;
    y1 = axis == "x" ? D - back_t - win_bar : D - recess_w - wall_t - win_bar;
    for (i = [0 : len(cols) - 2])
        windows_z(cols[i] + inset, cols[i + 1] - inset, y0, y1,
                  body_height - top_t, body_height);
}

module housing_windows(W, D, slots, axis) {
    y0 = win_border;
    y1 = D - back_t - win_border;
    // floor and shelves
    windows_z(wall_t + win_border, W - wall_t - win_border, y0, y1, 0, floor_t);
    for (i = [1 : 1 : len(slots) - 1])
        windows_z(wall_t + win_border, W - wall_t - win_border, y0, y1,
                  slot_z(slots, i - 1) - shelf_t, slot_z(slots, i - 1));
    // side walls: keep the band where the stop bump runs, and solid wall around the ridge
    for (i = [0 : len(slots) - 1])
        windows_x(W, max(y0, ridge_y(D) + ridge_h / tan(stop_angle) + win_bar), y1,
                  slot_z(slots, i) + arm_height + 2,
                  slot_z(slots, i) + slots[i] - 4);
    ceiling_windows(W, D, axis);
    // back wall becomes a frame (still the stop for the closed drawer)
    translate([wall_t + back_frame, D - back_t - 1, floor_t + back_frame])
        cube([W - 2 * wall_t - 2 * back_frame, back_t + 2,
              body_height - top_t - floor_t - 2 * back_frame]);
}

// ---------------------------------------------------------------- housing

// block_len = 0: no end block.
module housing(W, D, slots, axis, block_len = 0) {
    screws = concat(
        [for (x = platform_xs(W, axis), y = platform_ys(D, axis)) [x, y]],
        block_len > 0 ? [end_block_screw(W, D, axis, block_len)] : []);
    difference() {
        union() {
            box_chamfer_back([W, D, body_height], foot_chamfer);
            platform(W, D, axis);
            if (block_len > 0) end_block(W, D, axis, block_len);
        }
        // drawer slots
        for (i = [0 : len(slots) - 1])
            translate([wall_t, -1, slot_z(slots, i)])
                cube([W - 2 * wall_t, D - back_t + 1, slots[i]]);
        for (p = screws) screw_cut(p.x, p.y);
        if (lighten) housing_windows(W, D, slots, axis);
    }
    // stop ridges on both side walls of every slot
    for (i = [0 : len(slots) - 1], s = [0, 1])
        translate([s * W, ridge_y(D), slot_z(slots, i)])
            mirror([s, 0, 0]) translate([wall_t, 0, 0])
                ramp(ridge_h, entry_angle, stop_angle, arm_height);
}

// Drawer placed inside its housing slot, opened by `open` (0..1).
module drawer_in_slot(W, D, slots, i, dividers, open) {
    translate([wall_t + side_gap, -open * max_open_ratio * drawer_l(D), slot_z(slots, i)])
        drawer(W, D, slots[i], dividers);
}

// ---------------------------------------------------------------- modules

module front_housing() {
    housing(module_width, front_depth, front_slots(), "x", front_block_len);
}

module side_housing(back = false) {
    housing(side_length, module_width, side_slots(), "y", back ? back_block_len : 0);
}

module front_module(open = 0) {
    color("WhiteSmoke") front_housing();
    color("SteelBlue") drawer_in_slot(module_width, front_depth, front_slots(), 0, thin_dividers, open);
    color("SteelBlue") drawer_in_slot(module_width, front_depth, front_slots(), 1, tall_dividers, open * 0.6);
}

module side_module(open = 0, back = false) {
    color("WhiteSmoke") side_housing(back);
    color("SteelBlue") drawer_in_slot(side_length, module_width, side_slots(), 0, side_dividers, open);
}

// World: X across the desk (outer edge at x = 0, leg column at x = space_width), Y front to
// back, z = 0 at the underside of the tabletop.
module assembly() {
    // tabletop (transparent), bracket and leg column for context
    %translate([-30, -10, 0]) cube([space_width + 230, desk_depth + 10, 25]);
    color("DimGray") translate([space_width - bracket_width, bracket_end_gap, -bracket_drop])
        cube([bracket_width + 60, desk_depth - 2 * bracket_end_gap, bracket_drop]);
    color("DimGray") translate([space_width, desk_depth / 2 - 35, -300]) cube([60, 70, 300]);

    // orientation labels, readable from below
    color("Black") translate([space_width / 2, -45, -module_height]) mirror([0, 1, 0])
        linear_extrude(1) text("FRENTE", size = 22, halign = "center", valign = "center");
    color("Black") translate([-45, desk_depth / 2, -module_height]) rotate([0, 0, 90]) mirror([0, 1, 0])
        linear_extrude(1) text("LATERAL", size = 22, halign = "center", valign = "center");
    color("Black") translate([space_width + 120, desk_depth / 2, -module_height]) rotate([0, 0, 90]) mirror([0, 1, 0])
        linear_extrude(1) text("PE DA MESA", size = 22, halign = "center", valign = "center");

    translate([0, front_setback, -module_height]) front_module(assembly_open);
    for (k = [0 : side_count - 1]) {
        y0 = front_setback + front_depth + module_gap + k * (side_length + module_gap);
        translate([0, y0 + side_length, -module_height])
            rotate([0, 0, -90]) side_module(k == 0 ? assembly_open : 0, k == side_count - 1);
    }
}

// ---------------------------------------------------------------- print orientation

// Housing standing on its back wall, opening up.
module print_standing(D) {
    translate([0, 0, D]) rotate([-90, 0, 0]) children();
}

if (part == "assembly") assembly();
else if (part == "front_module") front_module(assembly_open);
else if (part == "front_housing") print_standing(front_depth) front_housing();
else if (part == "front_drawer_thin") drawer(module_width, front_depth, front_slots()[0], thin_dividers);
else if (part == "front_drawer_tall") drawer(module_width, front_depth, front_slots()[1], tall_dividers);
else if (part == "side_housing") print_standing(module_width) side_housing(false);
else if (part == "side_housing_back") print_standing(module_width) side_housing(true);
else if (part == "side_drawer") drawer(side_length, module_width, side_slots()[0], side_dividers);
