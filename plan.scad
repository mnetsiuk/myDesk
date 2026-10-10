// Under-desk cable plan. Corner desk: walls at back (+Y) and left (-X).
// Positions: [x from LEFT desk edge, y from BACK edge, z from tabletop UNDERSIDE (up +)], mm.
// Back zone (y 0..170, behind the back rail): router, bricks, strip, Underware trunk.
// Coil bay (y 200..335, between rails): excess cable on openGrid, hidden by the rails.
// ASSUMED values are marked; replace with measurements.
include <BOSL2/std.scad>       // parts.scad draws with BOSL2; its $-variables must exist at top level
include <desk.scad>
use <router_mount.scad>
use <brick_holder.scad>
use <parts.scad>

show_floor = true;               // off for views from below
show_walls = true;               // off for cut-away views from behind
grid   = 28;                     // openGrid

clamp    = [[677.5, 0], [45, 55, 40]];          // monitor arm clamp at 700, lower jaw; height ASSUMED
rtr_psu  = [[466, 20], [80, 54, 33.3]];
mon_psu  = [[732, 20], [114.5, 51.6, 30]];      // next to the clamp: its DC cable is short
lap_psu  = [[870, 20], [154, 73.5, 30]];
spk_psu  = [[1044, 20], [110, 50, 30]];         // ASSUMED: speaker brick, will be replaced
strip    = [[475, 95], [350, 70, 60]];          // Brennenstuhl Eco-Line 6-way, sockets down; measure when bought
trunk    = [[830, 130], 12];                    // Underware channel: strip -> laptop + speaker AC
bay      = [[470, 210], [20, 4]];               // openGrid tiles for cable hanks
wall_y   = -20;                                 // ASSUMED: wall 20 mm behind the desk

function P(p) = [-800 + p.x, 400 - p.y, top_z + p.z];
function plen(p, i = 0) = i >= len(p) - 1 ? 0 : norm(p[i + 1] - p[i]) + plen(p, i + 1);
function sock(i) = strip[0].x + strip_socket_x(i);                         // socket centre x
function face(b, right) = [b[0].x + (right ? b[1].x : 0), b[0].y + b[1].y / 2, -b[1].z / 2];  // brick end-face centre
function out(p, dx) = p + [dx, 0, 0];

// Place a part's local box [0..s] under the tabletop at plan position p.
module at(p, s) translate([-800 + p.x, 400 - p.y - s.y, top_z - s.z]) children();
module brick(b) {
    at(b[0], b[1]) brick_vis(b[1]);
    for (a = [0.15, 0.85]) color(printed()) translate([-800 + b[0].x + a * b[1].x - 7.5, 400 - b[0].y + 1, top_z]) rotate([0, 0, -90]) strap(b[1]);
}
module cable(name, pts, c, d = 6) { echo(str(name, ": ", round(plen(pts) / 10), " cm")); cable_vis([for (p = pts) P(p)], c, d); }
module plug(i, spin = 0) translate(P([sock(i), strip[0].y + strip[1].y / 2, -strip[1].z])) rotate([0, 0, spin]) plug_vis();
module coil(p, d, c) translate(P(p)) coil_vis(d, c);

// --- room ---
desk();
if (show_walls) color("#ecebe7") translate([-800, 400 - wall_y, 0]) cube([1600, 20, 1100]);      // back wall
if (show_walls) color("#ecebe7") translate([-820, -400, 0]) cube([20, 820 - wall_y, 1100]);      // left wall
if (show_floor) color("#c9a27a") translate([-800, -700, -2]) cube([1600, 1120 - wall_y, 2]);
color("#f2f2ef") translate([-800 + 20, 400 - wall_y - 12, 0]) cylinder(d = 22, h = 760, $fn = 24);           // heating pipes, ASSUMED
color("#f2f2ef") translate([-800, 400 - wall_y - 12, 720]) rotate([0, 90, 0]) cylinder(d = 22, h = 180, $fn = 24);
translate([-800 + 250, 400 - wall_y - 8, 200]) {                                // wall box: TAE + coax | 3 x Schuko, ASSUMED x 250..400
    color("#f7f7f5") cube([150, 8, 250]);
    color("#cfcfcc") for (z = [45, 125, 205]) translate([110, -0.5, z]) rotate([-90, 0, 0]) cylinder(d = 40, h = 1, $fn = 32);
    color("#cfcfcc") translate([38, -0.5, 60]) rotate([-90, 0, 0]) cylinder(d = 30, h = 1, $fn = 32);
}

// --- hardware ---
translate([-800 + 219, 400, top_z]) mirror([0, 1, 0]) { color(printed()) pair(); router_ghost(); }   // router, x 214..456
brick(rtr_psu);  brick(mon_psu);  brick(lap_psu);  brick(spk_psu);
at(clamp[0], clamp[1]) clamp_vis(clamp[1]);
at(strip[0], strip[1]) strip_vis(strip[1]);
plug(0);  plug(3);  plug(4, -90);  plug(5, -90);
at(trunk[0], [trunk[1] * grid, grid, 0]) { tiles_vis(trunk[1], 1); channel_vis(trunk[1]); }
at(bay[0], [bay[1].x * grid, bay[1].y * grid, 0]) tiles_vis(bay[1].x, bay[1].y);

// --- cables (echo prints each route length) ---
W = wall_y + 8;   // cables run here, between desk and wall
cable("strip -> wall socket", [[462, 130, -30], [461, 110, -30], [461, 60, -40], [459, 30, -50], [445, 22, -55], [390, 10, -90], [370, W, -120], [362, W, -330], [360, W, -349]], "#1b1b1b", 7);
cable("coax wall -> router",  [[288, W, -504], [290, W, -150], [295, 10, -90], [300, 30, -72], [300, 50, -72]], "#f4f4f4", 7);
cable("LAN router -> closet", [[350, 50, -72], [350, 30, -72], [345, W, -110], [340, W, -740], [300, W, -760], [60, W, -760]], "#3b82f6");
cable("router AC",  [[sock(0), 104, -86], [552, 80, -70], [553, 55, -30], [556, 47, -17], face(rtr_psu, true)], "#555", 5);
cable("router DC",  [face(rtr_psu, false), [461, 47, -17], [460, 30, -35], [448, 26, -50], [420, 26, -65], [400, 32, -72], [400, 50, -72]], "#555", 4);
cable("monitor AC", [[sock(3), 104, -86], [720, 88, -80], [850, 80, -50], [858, 50, -18], face(mon_psu, true)], "#d03a3a", 5);
cable("monitor DC", [face(mon_psu, false), [726, 45, -15], [726, 10, -15], [726, W, -8], [720, W, 20], [712, W, 250]], "#d03a3a", 4);
cable("laptop AC",  [[sock(4) + 26, 130, -86], [778, 128, -96], [800, 126, -96], [822, 138, -50], [840, 144, -14], [1020, 144, -14], [1036, 110, -15], out(face(lap_psu, true), 12), face(lap_psu, true)], "#f07a2a", 6);
cable("laptop DC",  [face(lap_psu, false), [860, 57, -15], [858, W, -8], [855, W, 20], [850, 30, 35], [800, 230, 70]], "#f07a2a", 5);
cable("speaker AC", [[sock(5) + 26, 130, -86], [825, 135, -60], [840, 150, -14], [1160, 150, -14], [1175, 100, -15], out(face(spk_psu, true), 14), face(spk_psu, true)], "#8e44ad", 5);
cable("speaker DC", [face(spk_psu, false), [1034, 45, -15], [1034, W, -8], [1030, W, 20], [1000, 15, 20], [600, 15, 20], [520, 90, 40]], "#8e44ad", 4);

// Excess of fixed cables: loops + velcro, clipped to the bay tiles.
coil([540, 266, -4], 100, "#1b1b1b");  // strip cord
coil([670, 266, -4], 90, "#555");      // router DC
coil([800, 266, -4], 100, "#f07a2a");  // laptop DC
coil([930, 266, -4], 90, "#8e44ad");   // speaker DC
