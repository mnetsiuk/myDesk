// Under-desk cable plan. Corner desk: walls at back (+Y) and left (-X).
// Positions: [x from LEFT desk edge, y from BACK edge, z from tabletop UNDERSIDE (up +)], mm.
// Back zone (y 0..170, behind the back rail): router, bricks, strip. Coil bay (y 200..335, between rails): excess cable.
// ASSUMED values are marked; replace with measurements.
include <desk.scad>
use <router_mount.scad>
use <brick_holder.scad>

grid   = 28;    // openGrid
tile_t = 4;     // openGrid Lite (Full = 6.8)
ch_h   = 22;    // Underware monokini channel, min total height

clamp_x  = 700;                  // monitor arm clamp centre
clamp_sz = [45, 55, 40];         // lower jaw; height ASSUMED
rtr_psu  = [80, 54, 33.3];
mon_psu  = [114.5, 51.6, 30];
lap_psu  = [154, 73.5, 30];
spk_psu  = [110, 50, 30];        // ASSUMED: speaker brick, will be replaced
strip    = [350, 70, 60];        // Brennenstuhl Eco-Line 6-way (listing: 350x70x60, datasheet 360x80x60); measure when bought
sock_x   = [for (i = [0:5]) 540 + i * 46];   // ASSUMED socket centres; cord + switch at the left end

function P(p) = [-800 + p.x, 400 - p.y, top_z + p.z];
function plen(p, i = 0) = i >= len(p) - 1 ? 0 : norm(p[i + 1] - p[i]) + plen(p, i + 1);

// Box hanging under the top: p = [x, y], s = [along X, along Y, height].
module under(p, s, c, a = 1) color(c, a) translate([-800 + p.x, 400 - p.y - s.y, top_z - s.z]) cube(s);
// Brick in two brick_holder straps (length along X).
module held(p, s, c) {
    under(p, s, c);
    for (a = [0.15, 0.85]) color("SlateBlue") translate([-800 + p.x + a * s.x - 7.5, 400 - p.y + 1, top_z]) rotate([0, 0, -90]) strap(s);
}
module cable(name, pts, c, d = 6) {
    echo(str(name, ": ", round(plen(pts) / 10), " cm"));
    color(c) for (i = [0:len(pts) - 2]) hull() { translate(P(pts[i])) sphere(d = d, $fn = 8); translate(P(pts[i + 1])) sphere(d = d, $fn = 8); }
}
module coil(p, d, c) color(c) translate(P(p)) rotate_extrude($fn = 32) translate([d / 2, 0]) circle(d = 14, $fn = 12);

desk(show_top = false);
color("White", 0.3) translate([-800, 410, 0]) cube([1600, 20, 1000]);    // back wall (10 mm gap behind the desk, ASSUMED)
color("White", 0.3) translate([-820, -400, 0]) cube([20, 830, 1000]);    // left wall
color("Ivory") translate([-800, 395, 720]) rotate([0, 90, 0]) cylinder(d = 20, h = 180);  // ASSUMED: heating pipe at back-left corner
color("LightGray") translate([-800 + 250, 410, 200]) cube([150, 15, 250]);  // ASSUMED: wall sockets + TAE + coax, x 250..400

// --- hardware ---
translate([-800 + 219, 400, top_z]) mirror([0, 1, 0]) { color("SlateBlue") pair(); router_ghost(); }   // router, x 214..456
held([462, 20], rtr_psu, "Gray");
held([552, 20], spk_psu, "Purple");
under([clamp_x - clamp_sz.x / 2, 0], clamp_sz, "Black");
held([727, 20], mon_psu, "Red");                     // short DC cable: right next to the clamp
held([857, 20], lap_psu, "OrangeRed");
under([460, 95], strip, "Orange");                   // flat, sockets DOWN
under([815, 130], [7 * grid, grid, tile_t], "Gold");                         // Underware run for the laptop AC cord
under([815, 130.8], [7 * grid, grid - 1.6, tile_t + ch_h], "SlateBlue");
under([470, 210], [20 * grid, 4 * grid, tile_t], "Gold", 0.35);                    // coil bay: openGrid tiles, hidden by the rails

// --- cables (echo prints each route length) ---
W = -10;   // wall plane, y
cable("strip -> wall socket", [[460, 130, -30], [455, 60, -45], [440, 30, -55], [330, W, -90], [330, W, -380]], "Black", 7);
cable("coax wall -> router",  [[290, W, -470], [290, W, -100], [300, 25, -80], [300, 48, -75]], "White", 7);
cable("LAN router -> closet", [[350, 48, -75], [350, 20, -85], [355, W, -110], [355, W, -720]], "DodgerBlue");
cable("router AC",   [[sock_x[0], 130, -75], [540, 85, -60], [542, 60, -20]], "DimGray", 5);
cable("router DC",   [[462, 47, -16], [452, 30, -45], [400, 30, -70], [380, 48, -72]], "DimGray", 4);
cable("speaker AC",  [[sock_x[1], 130, -75], [630, 90, -30], [662, 45, -16]], "Purple", 5);
cable("speaker DC",  [[552, 45, -16], [540, W + 5, -10], [330, W + 5, -5], [330, W + 5, 16], [330, 60, 40]], "Purple", 4);
cable("monitor AC",  [[sock_x[2], 130, -75], [720, 100, -35], [841, 46, -16]], "Red", 5);
cable("monitor DC",  [[727, 46, -16], [712, W + 5, -10], [712, W + 5, 250]], "Red", 4);
cable("laptop AC",   [[sock_x[3], 130, -75], [790, 144, -20], [1000, 144, -20], [1011, 80, -16]], "OrangeRed", 6);
cable("laptop DC",   [[857, 57, -16], [845, W + 5, -10], [830, W + 5, 16], [815, 120, 45], [800, 230, 70]], "OrangeRed", 5);
cable("DP -> USB-C", [[650, 260, 60], [700, 150, 40], [705, 30, 100], [705, 30, 250], [760, 120, 380]], "Teal", 5);   // on the desk, along the arm

// Excess of fixed cables: figure-8 / loops + velcro, parked in the coil bay.
coil([530, 265, -16], 110, "Black");      // strip cord
coil([665, 265, -16], 90, "DimGray");     // router DC
coil([790, 265, -16], 90, "Purple");      // speaker DC
coil([930, 265, -16], 110, "OrangeRed");  // laptop DC
