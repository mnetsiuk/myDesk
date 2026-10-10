// Under-desk cable plan. Corner desk: walls at back (+Y) and left (-X).
// Positions: [x from LEFT desk edge, y from BACK edge, z from tabletop UNDERSIDE (up +)], mm.
// Everything lives in the back zone (y 0..170, between the back edge and the back rail) on screwed openGrid Full boards:
//   edge rows (y 1..85):  power bricks + strip in Underware Item Holders (build.sh), cables go up over the back edge
//   rail rows (y 85..169): Underware hooks for slack, Underware channel trunk to the strip
// Run ./build.sh first (holders are imported from build/). ASSUMED values are marked.
include <BOSL2/std.scad>       // parts.scad draws with BOSL2; its $-variables must exist at top level
include <desk.scad>
use <router_mount.scad>
use <parts.scad>

show_floor = true;               // off for views from below
show_walls = true;               // off for cut-away views from behind
grid  = 28;                      // openGrid
g0    = [210, 1];                // grid origin: cell (0, 0) corner
board = 6.8;                     // openGrid Full
hold  = board + 6.48;            // Item Holder backer: the item's top face sits this far under the tabletop
row_c = g0.y + 2 * grid;         // edge-row item centre: on a cell boundary for the 2 Multiconnect slots

clamp    = [[677.5, 0], [45, 55, 40]];          // monitor arm clamp at 700, lower jaw; height ASSUMED
// items: [[x start, y centre], [length, width, thickness], holder name]
rtr_psu  = [[466, row_c], [80, 54, 33.3], "router_psu"];
spk_psu  = [[556, row_c], [110, 50, 30], "speaker"];          // ASSUMED: speaker brick, will be replaced
mon_psu  = [[745, row_c], [114.5, 51.6, 30], "monitor"];      // first free spot right of the clamp: short DC cable
lap_psu  = [[876, row_c], [154, 73.5, 30], "laptop"];
strip    = [[1050, row_c], [350, 70, 60], "strip"];            // Brennenstuhl Eco-Line 6-way, sockets down; measure when bought
trunk    = [9, 34];                             // Underware channel: from cell 9, 34 cells, in the last row before the rail
boards   = [[[0, 0], [9, 6]], [[9, 0], [7, 6]], [[16, 2], [3, 4]], [[19, 0], [25, 6]]];  // [cell, size]; none under the clamp
wall_y   = -20;                                 // ASSUMED: wall 20 mm behind the desk

function P(p) = [-800 + p.x, 400 - p.y, top_z + p.z];
function C(i, j) = [g0.x + i * grid, g0.y + j * grid];                     // plan xy of a cell corner
function plen(p, i = 0) = i >= len(p) - 1 ? 0 : norm(p[i + 1] - p[i]) + plen(p, i + 1);
function sock(i) = strip[0].x + strip_socket_x(i);
function end(b, right) = [b[0].x + (right ? b[1].x : 0), b[0].y, -hold - b[1].z / 2];   // item end-face centre

// Item hanging in its two Item Holders (one per end, cups facing each other).
module held(b) {
    translate(P([b[0].x, b[0].y + b[1].y / 2, -hold - b[1].z])) children();
    for (r = [0, 1]) translate(P([b[0].x + r * b[1].x, b[0].y, -hold]))
        multmatrix(r ? [[0, 0, -1, 0], [1, 0, 0, 0], [0, -1, 0, 0]] : [[0, 0, 1, 0], [-1, 0, 0, 0], [0, -1, 0, 0]])
            color(printed()) import(str("build/holder_", b[2], ".stl"));
}
module cable(name, pts, c, d = 6) { echo(str(name, ": ", round(plen(pts) / 10), " cm")); cable_vis([for (p = pts) P(p)], c, d); }
module plug(i) translate(P([sock(i), strip[0].y, -hold - strip[1].z])) rotate([0, 0, 180]) plug_vis();   // cord towards the trunk

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

// --- openGrid boards (screwed to the tabletop) ---
for (b = boards) translate(P([C(b[0].x, b[0].y).x, C(b[0].x, b[0].y).y + b[1].y * grid, 0])) tiles_vis(b[1].x, b[1].y);

// --- hardware ---
// TODO: router cheeks still have screw flanges; to move onto Multiconnect, drawn one board lower for now.
translate([-800 + 219, 400, top_z - board]) mirror([0, 1, 0]) { color(printed()) pair(); router_ghost(); }
held(rtr_psu) brick_vis(rtr_psu[1]);
held(spk_psu) brick_vis(spk_psu[1]);
held(mon_psu) brick_vis(mon_psu[1]);
held(lap_psu) brick_vis(lap_psu[1]);
held(strip) strip_vis(strip[1]);
for (i = [0:3]) plug(i);
translate([-800, 400, top_z]) clamp_vis_at();
module clamp_vis_at() translate([clamp[0].x, -clamp[0].y - clamp[1].y, -clamp[1].z]) clamp_vis(clamp[1]);
for (k = [0:4]) translate(P([C(trunk[0] + k * 8, 5).x, C(0, 5).y + grid / 2, -3.4])) uw_channel(k < 4 ? 8 : trunk[1] - 32);
for (x = [506, 611, 953]) translate(P([x, C(0, 4).y + grid / 2, -3.4])) uw_hook2();    // slack hooks for router / speaker / laptop DC

// --- cables (echo prints each route length) ---
W  = wall_y + 8;       // between desk and wall
T  = C(0, 5).y + 14;   // trunk centre line
Tz = -board - 9;       // inside the trunk
Rz = -board;           // router drawn one board lower
cable("strip cord -> wall", [end(strip, false), [1040, row_c, -hold - 30], [1040, 140, Tz], [1030, T, Tz], [470, T, Tz], [440, 140, Tz - 10], [400, 100, Tz - 12], [380, 30, -30], [370, W, -60], [362, W, -330], [360, W, -349]], "#1b1b1b", 7);
cable("coax wall -> router",  [[288, W, -504], [290, W, -150], [295, 10, -95 + Rz], [300, 30, -72 + Rz], [300, 50, -72 + Rz]], "#f4f4f4", 7);
cable("LAN router -> closet", [[350, 50, -72 + Rz], [350, 30, -72 + Rz], [345, W, -115], [340, W, -740], [300, W, -760], [60, W, -760]], "#3b82f6");
cable("router DC",  [end(rtr_psu, false), [461, row_c, -30], [461, 40, -30], [452, 26, -45], [420, 26, -60 + Rz], [400, 32, -72 + Rz], [400, 50, -72 + Rz]], "#555", 4);
cable("router AC",  [end(rtr_psu, true), [551, row_c, -30], [551, 100, -30], [553, T - 5, Tz], [1120, T, Tz], [sock(0), 110, -90], [sock(0), 83, -hold - 86]], "#555", 5);
cable("speaker DC", [end(spk_psu, false), [552, row_c, -28], [552, 20, -20], [552, W, -10], [552, W, 16], [520, 60, 40]], "#8e44ad", 4);
cable("speaker AC", [end(spk_psu, true), [671, row_c, -28], [672, 100, -28], [675, T, Tz], [1165, T, Tz], [sock(1), 110, -90], [sock(1), 83, -hold - 86]], "#8e44ad", 5);
cable("monitor DC", [end(mon_psu, false), [738, row_c, -28], [730, 25, -20], [728, W, -10], [720, W, 20], [712, W, 250]], "#d03a3a", 4);
cable("monitor AC", [end(mon_psu, true), [868, row_c, -28], [868, 100, -28], [870, T, Tz], [1210, T, Tz], [sock(2), 110, -90], [sock(2), 83, -hold - 86]], "#d03a3a", 5);
cable("laptop DC",  [end(lap_psu, false), [871, row_c, -28], [871, 20, -20], [868, W, -10], [865, W, 16], [850, 30, 35], [800, 230, 70]], "#f07a2a", 5);
cable("laptop AC",  [end(lap_psu, true), [1038, row_c, -28], [1040, 100, -28], [1044, T, Tz], [1255, T, Tz], [sock(3), 110, -90], [sock(3), 83, -hold - 86]], "#f07a2a", 6);
