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
// items: [[x, y], [length, width, thickness], holder name, dir, (cups: [0, 1] = both ends)]
//   dir "x": along the edge, [x, y] = left end, y on the item centre line
//   dir "y": across the zone, [x, y] = edge-side end, x on the centre line; AC in from the trunk, DC out at the edge
rtr_psu  = [80, 54, 33.3];                      // plug-in adapter: sits straight in strip socket 5
spk_psu  = [[g0.x + 10 * grid, 8], [110, 50, 30], "speaker", "y"];        // ASSUMED: speaker brick, will be replaced
mon_psu  = [[g0.x + 20 * grid, 8], [114.5, 51.6, 30], "monitor", "y"];    // first slot centre right of the clamp
lap_psu  = [[809, row_c], [154, 73.5, 30], "laptop", "x"];                // too long to stand across; AC in left, DC out right
strip    = [[980, row_c], [350, 70, 60], "strip", "x"];                   // Brennenstuhl Eco-Line 6-way, sockets down; measure when bought
coilbox  = [[1340, g0.y + 2.5 * grid], [95, 95, 22], "coil", "x", [1]];  // one cup, open towards the slack run: pocket for the hank
trunk    = [9, 31];                             // AC trunk: from cell 9, 31 cells, last row before the rail
slack    = [22, 18];                            // slack run: laptop DC out and back, row 4
boards   = [[[0, 0], [9, 6]], [[9, 0], [7, 6]], [[16, 2], [3, 4]], [[19, 0], [26, 6]]];  // [cell, size]; none under the clamp
wall_y   = -20;                                 // ASSUMED: wall 20 mm behind the desk

function P(p) = [-800 + p.x, 400 - p.y, top_z + p.z];
function C(i, j) = [g0.x + i * grid, g0.y + j * grid];                     // plan xy of a cell corner
function plen(p, i = 0) = i >= len(p) - 1 ? 0 : norm(p[i + 1] - p[i]) + plen(p, i + 1);
function sock(i) = strip[0].x + strip_socket_x(i);
function end(b, far) = let(d = far ? b[1].x : 0)                           // item end-face centre
    b[3] == "y" ? [b[0].x, b[0].y + d, -hold - b[1].z / 2] : [b[0].x + d, b[0].y, -hold - b[1].z / 2];

// Item hanging in its two Item Holders (one per end, cups facing each other).
module held(b) translate(P([b[0].x, b[0].y, 0])) rotate([0, 0, b[3] == "y" ? -90 : 0]) {
    translate([0, -b[1].y / 2, -hold - b[1].z]) children();
    for (r = len(b) > 4 ? b[4] : [0, 1]) translate([r * b[1].x, 0, -hold])
        multmatrix(r ? [[0, 0, -1, 0], [1, 0, 0, 0], [0, -1, 0, 0]] : [[0, 0, 1, 0], [-1, 0, 0, 0], [0, -1, 0, 0]])
            color(printed()) import(str("build/holder_", b[2], ".stl"));
}
module run(r, row) for (k = [0:ceil(r[1] / 8) - 1]) translate(P([C(r[0] + k * 8, row).x, C(0, row).y + grid / 2, -3.4])) uw_channel(min(8, r[1] - k * 8));
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
held(spk_psu) brick_vis(spk_psu[1]);
held(mon_psu) brick_vis(mon_psu[1]);
held(lap_psu) brick_vis(lap_psu[1]);
held(strip) strip_vis(strip[1]);
for (i = [0:2]) plug(i);
translate(P([sock(5), strip[0].y, -hold - strip[1].z])) wart_vis(rtr_psu);   // router adapter, body along y so socket 4 stays free
held(coilbox);
translate([-800, 400, top_z]) clamp_vis_at();
module clamp_vis_at() translate([clamp[0].x, -clamp[0].y - clamp[1].y, -clamp[1].z]) clamp_vis(clamp[1]);
run(trunk, 5);
run(slack, 4);

// --- cables (echo prints each route length) ---
W  = wall_y + 8;            // between desk and wall
T  = C(0, 5).y + 14;        // trunk centre line
S  = C(0, 4).y + 14;        // slack run centre line
Tz = -board - 9;            // inside a channel
Rz = -board;                // router drawn one board lower
K  = [coilbox[0].x + 50, coilbox[0].y, -hold - 11];                       // hank centre
cable("strip cord -> wall", [end(strip, false), [970, row_c, -hold - 30], [968, 140, Tz], [960, T, Tz], [470, T, Tz], [440, 140, Tz - 10], [400, 100, Tz - 12], [380, 30, -30], [370, W, -60], [362, W, -330], [360, W, -349]], "#1b1b1b", 7);
cable("coax wall -> router",  [[288, W, -504], [290, W, -150], [295, 10, -95 + Rz], [300, 30, -72 + Rz], [300, 50, -72 + Rz]], "#f4f4f4", 7);
cable("LAN router -> closet", [[350, 50, -72 + Rz], [350, 30, -72 + Rz], [345, W, -115], [340, W, -740], [300, W, -760], [60, W, -760]], "#3b82f6");
cable("router DC",  [[sock(5), row_c + 40, -hold - strip[1].z - 25], [sock(5) - 5, 120, -60], [sock(5) - 10, T + 4, Tz], [470, T + 4, Tz], [445, 140, Tz - 10], [420, 100, Tz - 12], [410, 40, -60 + Rz], [400, 32, -72 + Rz], [400, 50, -72 + Rz]], "#555", 4);
cable("speaker DC", [end(spk_psu, false), [spk_psu[0].x, W, -10], [spk_psu[0].x, W, 16], [440, 60, 40]], "#8e44ad", 4);
cable("speaker AC", [end(spk_psu, true), [spk_psu[0].x, 128, -28], [spk_psu[0].x + 3, T - 4, Tz], [1050, T - 4, Tz], [sock(0), 110, -90], [sock(0), 83, -hold - 86]], "#8e44ad", 5);
cable("monitor DC", [end(mon_psu, false), [mon_psu[0].x, W, -10], [740, W, 20], [712, W, 250]], "#d03a3a", 4);
cable("monitor AC", [end(mon_psu, true), [mon_psu[0].x, 132, -28], [mon_psu[0].x + 3, T, Tz], [1096, T, Tz], [sock(1), 110, -90], [sock(1), 83, -hold - 86]], "#d03a3a", 5);
// Laptop DC (measured 177 cm): out along the slack run, one loop in the pocket, back, up to the laptop.
lap_dc   = 1770;
lap_port = [800, 230, 70];  // ASSUMED: DC socket at the back of the laptop, on the stand
lap_out  = [end(lap_psu, true), [972, row_c, -28], [975, S - 5, Tz], [1335, S - 5, Tz], [1350, K.y + 10, K.z]];
lap_back = [[1350, K.y - 10, K.z], [1345, S + 5, Tz], [805, S + 5, Tz], [797, row_c + 10, -28], [797, W, -10], [795, W, 16], [800, 30, 35], lap_port];
lap_r    = (lap_dc - plen(lap_out) - plen(lap_back)) / (2 * PI);   // what is left goes into one loop around K
assert(lap_r * 2 >= 50 && lap_r * 2 <= 90, str("laptop DC loop ", round(lap_r * 2), " mm does not fit the pocket (50..90): move the pocket or the brick"));
echo(str("laptop DC: hank loop diameter ", round(lap_r * 2), " mm"));
cable("laptop DC", concat(lap_out, [for (a = [180:-30:-180]) K + lap_r * [cos(a), sin(a), 0]], lap_back), "#f07a2a", 5);
cable("laptop AC",  [end(lap_psu, false), [800, row_c, -28], [800, 100, -28], [803, T + 4, Tz], [1142, T + 4, Tz], [sock(2), 110, -90], [sock(2), 83, -hold - 86]], "#f07a2a", 6);
