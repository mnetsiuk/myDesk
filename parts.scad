// Visual stand-ins for plan.scad renders (not for printing). Each part is drawn in its own box
// [0..s.x] x [0..s.y] x [0..s.z]; plan.scad places that box under the tabletop.
include <BOSL2/std.scad>
use <lib/QuackWorks/openGrid/openGrid.scad>

PRINTED = "#7385e6";   // everything we print
function printed() = PRINTED;
DARK    = "#232426";

module brick_vis(s) color(DARK) {
    cuboid(s, rounding = 4, anchor = BOT + LEFT + FRONT);
    for (x = [-9, s.x - 1]) translate([x, s.y / 2, s.z / 2]) yrot(90) cylinder(d = 8, h = 10, $fn = 16);  // strain reliefs
}

// Brennenstuhl Eco-Line lying upside down: sockets on the bottom face (z = 0), cord + switch at x = 0.
module strip_vis(s, n = 6) {
    module slab(w, z) translate([0, (s.y - w) / 2, z]) linear_extrude(1) offset(r = 8) offset(delta = -8) square([s.x, w]);
    color("#2b2c2e") difference() {
        hull() { slab(s.y - 18, 0); slab(s.y, s.z - 1); }
        for (i = [0:n - 1]) translate([80 + i * 46, s.y / 2, -1]) cylinder(d = 38, h = 16, $fn = 40);
    }
    color("#3fbf5f") translate([30, s.y / 2 - 10, -2]) cube([18, 20, 3]);                       // switch
    color(DARK) translate([-12, s.y / 2, s.z / 2]) yrot(90) cylinder(d = 9, h = 13, $fn = 16);    // cord
}
function strip_socket_x(i) = 80 + i * 46;

// Angled Schuko plug in a downward socket; local origin = socket face centre, cord leaves along +y.
module plug_vis() color(DARK) {
    translate([0, 0, -16]) cylinder(d = 36, h = 30, $fn = 40);
    hull() { translate([0, 0, -30]) cylinder(d = 30, h = 14, $fn = 32); translate([0, 22, -26]) xrot(-90) cylinder(d = 12, h = 4, $fn = 16); }
}

// Plug-in adapter in a downward socket (Europlug base sits in the socket recess); origin = socket face centre.
// s = [length (along y), thickness, out of the socket, plug centre from the -y end, cord below the socket face]; DC cord out of the +y end.
module wart_vis(s) color("#ececea") {
    translate([0, -s[3], 0]) cuboid([s.y, s.x, s.z], rounding = 3, anchor = TOP + FRONT);
    translate([0, s.x - s[3] - 1, -s[4]]) xrot(-90) cylinder(d = 5, h = 12, $fn = 12);         // strain relief
}

module clamp_vis(s) color("#141414") {
    translate([0, 0, s.z - 12]) cuboid([s.x, s.y, 12], rounding = 3, anchor = BOT + LEFT + FRONT);
    translate([s.x / 2, s.y / 2, 0]) { cylinder(d = 10, h = s.z, $fn = 20); cylinder(d = 36, h = 8, $fn = 6); }
}

// Smooth cable through world points.
function _j(p, i, j) = min(j, 0.45 * norm(p[i] - p[i - 1]), 0.45 * norm(p[i + 1] - p[i]));
module cable_vis(pts, c, d = 6, j = 18)
    color(c) path_sweep(circle(d = d, $fn = 10),
        len(pts) < 3 ? pts : round_corners(pts, method = "smooth", closed = false,
                                           joint = [0, for (i = [1:len(pts) - 2]) _j(pts, i, j), 0]));

// Hank of excess cable (three loops + velcro), top at z = 0, centred.
module coil_vis(d, c, cd = 5) {
    color(c) for (k = [0:2]) translate([k * 2.5, k * 2, -cd / 2 - k * cd * 0.9]) rotate_extrude($fn = 40) translate([d / 2, 0]) circle(d = cd, $fn = 10);
    color(DARK) translate([d / 2 - 6, -6, -3 * cd - 1]) cube([12, 12, 3 * cd + 1]);         // velcro tie
    color(PRINTED) translate([d / 2 - 8, -8, -1]) cube([16, 16, 1]);                         // clip on the tile
}

// openGrid Full board, n x m cells, top at z = 0 (6.8 mm thick).
module tiles_vis(n, m) color("#dcdcda") intersection() {          // the library needs >= 2 cells per side
    openGrid(Board_Width = max(n, 2), Board_Height = max(m, 2), Tile_Thickness = 6.8, anchor = TOP + LEFT + FRONT);
    translate([0, 0, -10]) cube([n * 28, m * 28, 10]);
}

// Vendored Underware for openGrid parts (lib/underware-opengrid), normalised: grips up with their tips at z = 0.
// Place them 3.4 mm under the board's top face so the grips sit inside a 6.8 mm board.
UW = "lib/underware-opengrid/";
// Straight channel, n cells (1..8) along +x from x = 0, centred on y = 0.
// open: "Open" variant (n >= 2), a cord slot ~13 wide x 14 deep in both walls at every inner cell boundary.
module uw_channel(n, open = false) color(PRINTED) translate([0, 0, -22]) rotate([0, 0, -90]) translate([-30 * (n - 1), 28, 0])
    import(str(UW, "3mf/openGrid Underware ", open ? "Open " : "", n, "x Channel.3mf"));
// Double-sided cable hook, 2 cells wide, centred.
module uw_hook2() color(PRINTED) translate([0, 7.3, -28]) import(str(UW, "stl/openGrid Underware Hook - Double-Sided 2W 10mm Cable.stl"));
