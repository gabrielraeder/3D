// Under-desk drawers v2.2 - drawers hanging from printed rails (no housing).
//
// v2.2: rail web 2.5 -> 4 mm (FEA: half the web stress, rail mouth deflection with a 2 kg
// drawer 70 % open 1.31 -> 0.58 mm). The web grows away from the slot: slot fit unchanged.
//
// Each drawer hangs from two rails screwed to the underside of the tabletop. The top of
// each drawer side wall turns inwards at 45 deg into an "arm" that slides in a 45 deg slot
// of the rail. The drawer bottom is a 150 x 210 x 3 mm MDF panel resting on a ledge.
//
//   - front drawer: opens to the front
//   - side drawers: open to the outer side edge of the desk
//
// The rail next to the leg column stays on the wood, just before the metal bracket (aba);
// the drawer passes under the bracket (everything there is >= 9 mm below the tabletop).
//
// Print: rails standing (rail length vertical, tooth end on the bed), drawers on their bottom.
// No supports anywhere.

/* [Part to render] */
// assembly | section | front_drawer | front_rails | side_drawer | side_rails | fit_test
part = "assembly";
// Drawer opening in the assembly view (0 = closed, 1 = fully open)
assembly_open = 0.6;

/* [Desk] */
space_width = 170;          // desk side edge to the leg column face (mm)
bracket_width = 25;         // metal bracket (aba) width from the column (mm)
bracket_drop = 7;           // bracket + bolt heads below the tabletop (mm)
bracket_end_gap = 60;       // free tabletop in front of / behind the bracket (mm)
desk_depth = 800;           // tabletop depth (mm)
rail_margin = 1;            // rail web to bracket edge (mm)
front_setback = 20;         // front drawer set back from the desk front edge (mm)
module_gap = 10;            // gap between drawers along the desk depth (mm)
side_count = 2;             // number of side drawers

/* [MDF bottom panel] */
panel_w = 150;              // panel short side (mm)
panel_l = 210;              // panel long side (mm)
panel_t = 3;                // panel thickness (mm)
panel_clear = 0.5;          // gap around the panel, each side (mm)

/* [Drawer] */
hang_depth = 110;           // tabletop to drawer bottom (mm)
wall = 1.6;                 // drawer side and back walls (mm)
front_t = 2.4;              // front panel (mm)
corner_r = 2;               // rounded vertical outer corners (hides the seam) (mm)
front_chamfer = 0.8;        // chamfer on the top edge of the front panel (mm)
ledge_w = 4;                // ledge that carries the MDF panel (mm)
ledge_t = 1.2;              // ledge thickness (mm)
top_gap = 1;                // front panel top to tabletop (mm)
grip_width = 40;            // finger notch width (mm)
grip_depth = 15;            // finger notch depth (mm)

/* [Rail and arm profile] */
arm_reach = 12;             // drawer wall outer face to rail web (mm)
top_clear = 9;              // highest slot part below the tabletop (bracket 7 + 2) (mm)
plate_t = 2.4;              // rail plates, measured across (mm)
arm_t = 2.0;                // drawer arm, measured across (mm)
slide_clear = 0.5;          // gap arm <-> rail plates, measured across (mm)
web_t = 4;                  // rail web (mm); v2.1 was 2.5
flange_w = 16;              // mounting flange width beyond the web (mm)
flange_t = 3;               // mounting flange thickness (mm)
tip_gap = 1;                // arm tip to rail web (mm)
lower_gap = 0.8;            // rail lower plate to drawer wall (mm)
rail_front = 3;             // rail starts this far behind the drawer front face (mm)

/* [Stop (detent)] */
// A short "tooth" at the rail entrance holds the drawer down when open; a bump on the
// arm catches the tooth so the drawer stops at max_open_ratio. A firm pull releases it.
max_open_ratio = 0.7;       // fraction of the drawer length that comes out
tooth_len = 30;             // tooth length at the rail entrance (mm)
tooth_lead = 4;             // lead-in ramp at the tooth entrance (mm)
bump_h = 1.0;               // bump height on the arm, measured across (mm)
entry_angle = 30;           // bump ramp on the insertion side (deg)
stop_angle = 45;            // bump ramp on the stop side (deg)

/* [Screws] */
screw_d = 3.8;              // hole for 3.5 mm countersunk wood screws (mm)
screw_head_d = 7.5;         // countersink diameter (mm)
screw_end = 15;             // first screw from each rail end (mm)

/* [Truss joining a rail pair] */
// The rail pair prints standing (rail length vertical): a bottom bar plus 45 deg zigzag
// struts, all flush with the tabletop, keep both rails at the right spacing.
bar_w = 10;                 // bottom bar width (mm)
strut_w = 8;                // zigzag strut width (mm)
bar_t = 2;                  // bar / strut thickness, flush with the tabletop (mm)
bar_overlap = 5;            // overlap onto each rail flange (mm)

rail_clear = 2;             // back wall top below the lowest rail point (mm)

/* [Print] */
foot_chamfer = 0.4;         // elephant foot chamfer (mm)
$fn = 48;

eps = 0.01;
s2 = sqrt(2);

// ---------------------------------------------------------------- derived values

// Profile lines v = c - u (u: towards the drawer wall, v: up, 0 = tabletop).
c_top     = -top_clear;
c_up_bot  = c_top - plate_t * s2;
c_arm_top = c_up_bot - slide_clear * s2;
c_arm_bot = c_arm_top - arm_t * s2;
c_low_top = c_arm_bot - slide_clear * s2;
c_low_bot = c_low_top - plate_t * s2;
u_low = arm_reach - wall - lower_gap;        // lower plate reach
u_up  = arm_reach - 3;                       // tooth reach
rail_bottom = c_low_bot - u_low;             // lowest rail point (v)
wall_top = hang_depth + c_arm_top - arm_reach;          // side wall top (drawer z)
clear_top = hang_depth + rail_bottom - rail_clear;      // back wall top, under the rails

inner_w = panel_w + 2 * panel_clear;
inner_l = panel_l + 2 * panel_clear;

// Front drawer: panel short side across. Side drawers: panel long side across.
front_W = inner_w + 2 * wall;
front_L = inner_l + front_t + wall;
side_W = inner_l + 2 * wall;
side_L = inner_w + front_t + wall;

rail_x_max = space_width - bracket_width - rail_margin;  // rail web next to the bracket
front_rail_len = front_L - rail_front - 2;
side_rail_len = min(side_L - rail_front - 2, rail_x_max - 1 - rail_front);

// ---------------------------------------------------------------- 2D profile helpers

// Band between lines v = c1 - u and v = c2 - u (c1 > c2), for u in [u0, u1].
module band(c1, c2, u0, u1) {
    polygon([[u0, c1 - u0], [u1, c1 - u1], [u1, c2 - u1], [u0, c2 - u0]]);
}

module rail_2d() {
    translate([-web_t - flange_w, -flange_t]) square([web_t + flange_w, flange_t]);   // flange
    translate([-web_t, c_low_bot]) square([web_t, -c_low_bot]);                     // web
    band(c_low_top, c_low_bot, -eps, u_low);                                        // lower plate
}

module tooth_2d(thin = 0) {
    band(c_top, c_up_bot + thin * s2, -eps, u_up);
}

// Drawer arm: 45 deg band from the wall top to the tip, with a flat top at the tip
// (a sharp tip would print as thin slivers that curl up).
u_cut = arm_t * s2 + tip_gap;                // where the flat tip meets the arm top face
v_cut = c_arm_bot - tip_gap;                 // flat tip height (v)
module arm_2d() {
    polygon([[tip_gap, v_cut], [u_cut, v_cut], [arm_reach, c_arm_top - arm_reach],
             [arm_reach, c_arm_bot - arm_reach]]);
}

// Teardrop pointing to +y (up when the rail prints standing).
module teardrop_up(d) {
    r = d / 2;
    hull() {
        circle(r = r);
        polygon([[-r * cos(45), r * sin(45)], [0, r * s2], [r * cos(45), r * sin(45)]]);
    }
}

// Extrude a 2D (u, v) profile along +y over [y0, y1]; u -> x, v -> z.
module along_y(y0, y1) {
    translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();
}

// ---------------------------------------------------------------- rail

function screw_ys(len) = len > 150
    ? [screw_end, len / 2, len - screw_end]
    : [screw_end, len - screw_end];

// Rail in its own frame: web inner face at x = 0, slot opens towards +x, entrance at y = 0,
// tabletop at z = 0 (the rail hangs below it).
module rail(len) {
    difference() {
        union() {
            along_y(0, len) rail_2d();
            // tooth with a lead-in ramp at the entrance
            hull() {
                along_y(0, eps) tooth_2d(bump_h + slide_clear);
                along_y(tooth_lead, tooth_lead + eps) tooth_2d();
            }
            along_y(tooth_lead, tooth_len) tooth_2d();
        }
        for (y = screw_ys(len)) translate([-web_t - flange_w / 2, y, 0]) {
            translate([0, 0, -flange_t - 1]) linear_extrude(flange_t + 2) teardrop_up(screw_d);
            translate([0, 0, -flange_t - eps])
                linear_extrude((screw_head_d - screw_d) / 2, scale = screw_d / screw_head_d)
                    teardrop_up(screw_head_d);
        }
    }
}

// ---------------------------------------------------------------- drawer

function bump_y(L) = rail_front + tooth_len + max_open_ratio * L;

// Stop bump on the arm top face at y = yb (rail-local u/v frame, extruded along y).
module arm_bump(yb) {
    u0 = u_cut + 0.5;
    u1 = u_up - 1;
    module slice(y, h) along_y(y, y + eps) band(c_arm_top + h * s2, c_arm_top - eps, u0, u1);
    hull() { slice(yb - bump_h / tan(stop_angle), eps); slice(yb, bump_h); }
    hull() { slice(yb, bump_h); slice(yb + bump_h / tan(entry_angle), eps); }
}

// Arm on the +x side of a drawer of width W, in drawer coordinates (bottom at z = 0).
module arm_right(W, L) {
    translate([W - arm_reach, 0, hang_depth]) {
        along_y(0, L) arm_2d();
        arm_bump(bump_y(L));
    }
}

// Rail pair of a drawer joined by a truss (one printed part, sets spacing and parallelism).
// Drawer coordinates: tabletop at z = hang_depth, rails start at y = rail_front.
module drawer_rails(W, len) {
    x0 = arm_reach + web_t + flange_w - bar_overlap;     // truss edge on the left flange
    x1 = W - x0;                                         // truss edge on the right flange
    xs = x0 + strut_w / 2;                               // strut end on the left
    xm = W / 2;
    d = xm - xs;                                         // 45 deg: rise = run
    module node(x, y) translate([x, y]) square(strut_w, center = true);
    translate([0, rail_front, hang_depth]) {
        translate([W - arm_reach, 0, 0]) rail(len);
        translate([arm_reach, 0, 0]) mirror([1, 0, 0]) rail(len);
        // truss, flush with the tabletop
        translate([0, 0, -bar_t]) linear_extrude(bar_t) intersection() {
            union() {
                translate([x0, 0]) square([x1 - x0, bar_w]);                    // bottom bar
                // diamonds: centre -> both rails -> centre -> ...
                for (k = [0 : 1 : ceil(len / (2 * d))]) {
                    yc = bar_w / 2 + 2 * k * d;
                    for (xe = [xs, W - xs]) {
                        hull() { node(xm, yc); node(xe, yc + d); }
                        hull() { node(xe, yc + d); node(xm, yc + 2 * d); }
                    }
                }
            }
            translate([x0, 0]) square([x1 - x0, len]);
        }
    }
}

// Outer envelope of a drawer: rounded vertical corners, elephant-foot chamfer at the base.
module drawer_clip(W, L, H) {
    module footprint(inset) {
        offset(r = corner_r) offset(delta = -corner_r - inset) square([W, L]);
    }
    hull() {
        linear_extrude(eps) footprint(foot_chamfer);
        translate([0, 0, foot_chamfer]) linear_extrude(H + 1) footprint(0);
    }
}

// Drawer: front face at y = 0, bottom at z = 0, x in [0, W].
module drawer(W, L) {
    H = hang_depth - top_gap;
    notch = min(grip_depth, H / 3);
    intersection() {
    drawer_clip(W, L, H);
    difference() {
        union() {
            // ledge ring carrying the MDF panel
            difference() {
                hull() {
                    translate([foot_chamfer, foot_chamfer, 0])
                        cube([W - 2 * foot_chamfer, L - 2 * foot_chamfer, ledge_t]);
                    translate([0, 0, foot_chamfer]) cube([W, L, ledge_t - foot_chamfer]);
                }
                translate([wall + ledge_w, front_t + ledge_w, -1])
                    cube([W - 2 * wall - 2 * ledge_w, L - front_t - wall - 2 * ledge_w, ledge_t + 2]);
            }
            // side walls (up to the arms)
            for (x = [0, W - wall]) translate([x, 0, 0]) cube([wall, L, wall_top]);
            // back wall, kept under the rails
            translate([0, L - wall, 0]) cube([W, wall, clear_top]);
            // front panel, up to just under the tabletop: hides the rails
            cube([W, front_t, H]);
            // arms
            arm_right(W, L);
            translate([W, 0, 0]) mirror([1, 0, 0]) arm_right(W, L);
        }
        // finger notch at the top of the front panel
        translate([W / 2, -1, H - notch])
            rotate([-90, 0, 0]) linear_extrude(front_t + 2)
                hull() {
                    translate([-grip_width / 2 + notch / 2, -notch / 2]) circle(d = notch);
                    translate([grip_width / 2 - notch / 2, -notch / 2]) circle(d = notch);
                    translate([-grip_width / 2, -notch - 1]) square([grip_width, 1]);
                }
        // chamfer on the top front edge
        translate([-1, 0, 0]) multmatrix([[0, 0, 1, 0], [1, 0, 0, 0], [0, 1, 0, 0]])
            linear_extrude(W + 2)
                polygon([[-1, H - front_chamfer - 1], [-1, H + 1], [front_chamfer + 1, H + 1]]);
    }
    }
}

// ---------------------------------------------------------------- fit test

// Short rail + short drawer wall with arm and stop bump, to check the slide and the stop
// before printing a full drawer. Slide the coupon into the rail from the tooth end.
test_len = 50;

module fit_test() {
    // rail, printed standing like the real rails (tooth end on the bed)
    rail_standing() rail(test_len);
    // coupon: drawer wall + arm, standing on a small foot (same orientation as the drawer)
    v0 = c_arm_top - arm_reach - 20;                     // wall bottom (v)
    translate([45, 0, -v0]) {
        along_y(0, test_len) {
            arm_2d();
            translate([arm_reach - wall, v0]) square([wall, c_arm_top - arm_reach - v0]);
            translate([arm_reach - 8, v0]) square([16, 2]);
        }
        arm_bump(test_len - 10);
    }
}

// MDF panel (for the assembly view only).
module panel(W, L) {
    color("Tan") translate([wall + panel_clear, front_t + panel_clear, ledge_t])
        cube([W - 2 * wall - 2 * panel_clear, L - front_t - wall - 2 * panel_clear, panel_t]);
}

// ---------------------------------------------------------------- assembly

front_x_right = rail_x_max + arm_reach;      // front drawer right outer face
front_x0 = front_x_right - front_W;

module front_frame() { translate([front_x0, front_setback, -hang_depth]) children(); }

function side_y0(k) = front_setback + front_L + module_gap + k * (side_W + module_gap);
module side_frame(k) { translate([0, side_y0(k) + side_W, -hang_depth]) rotate([0, 0, -90]) children(); }

module drawer_set(W, L, rail_len, open) {
    color("WhiteSmoke") drawer_rails(W, rail_len);
    translate([0, -open * max_open_ratio * L, 0]) {
        color("SteelBlue") drawer(W, L);
        panel(W, L);
    }
}

module context() {
    %translate([-30, -10, 0]) cube([space_width + 230, desk_depth + 10, 25]);
    color("DimGray") translate([space_width - bracket_width, bracket_end_gap, -bracket_drop])
        cube([bracket_width + 60, desk_depth - 2 * bracket_end_gap, bracket_drop]);
    color("DimGray") translate([space_width, desk_depth / 2 - 35, -300]) cube([60, 70, 300]);
}

module assembly() {
    context();
    front_frame() drawer_set(front_W, front_L, front_rail_len, assembly_open);
    for (k = [0 : side_count - 1])
        side_frame(k) drawer_set(side_W, side_L, side_rail_len, k == 0 ? assembly_open : 0);
}

// Cross-section through the front drawer (closed), seen from the front.
module section() {
    intersection() {
        union() {
            front_frame() drawer_set(front_W, front_L, front_rail_len, 0);
            translate([-10, 0, 0]) cube([space_width + 70, desk_depth, 18]);
            color("DimGray") translate([space_width - bracket_width, 0, -bracket_drop])
                cube([bracket_width + 40, desk_depth, bracket_drop]);
            color("DimGray") translate([space_width, 0, -130]) cube([40, desk_depth, 130]);
        }
        translate([-20, 120, -150]) cube([space_width + 100, 2, 200]);
    }
}

// ---------------------------------------------------------------- print orientation

// Rails print standing: rail length vertical, entrance (tooth end) on the bed. The profile
// is then a plain 2D layer: no overhangs, smooth and accurate sliding faces.
// Input frame: rail entrance at y = 0, tabletop at z = 0.
module rail_standing() {
    rotate([90, 0, 0]) children();
}

module rails_print(W, len) {
    rail_standing() translate([0, -rail_front, -hang_depth]) drawer_rails(W, len);
}

if (part == "assembly") assembly();
else if (part == "section") section();
else if (part == "front_drawer") drawer(front_W, front_L);
else if (part == "front_rails") rails_print(front_W, front_rail_len);
else if (part == "side_drawer") drawer(side_W, side_L);
else if (part == "side_rails") rails_print(side_W, side_rail_len);
else if (part == "fit_test") fit_test();
