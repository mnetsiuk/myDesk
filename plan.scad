// Under-desk cable plan. Corner desk: walls at back (+Y) and left (-X).
// Positions: [x from LEFT desk edge, y from BACK edge, z from tabletop UNDERSIDE (up +)], mm.
// Everything lives in the back zone (y 0..170, between the back edge and the back rail) on screwed openGrid Full boards:
//   edge rows (y 1..85):  power bricks + strip in Underware Item Holders (build.sh), cables go up over the back edge
//   rail rows (y 85..169): Underware channel trunk to the strip; shir cord spool for the laptop DC slack
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
spool    = [22, 2, 35];                        // shir spool halves 2x2 (his default for power cords) at cell x 22, rows 0-1 and 3-4; post height
lap_psu  = [[885, row_c], [154, 73.5, 30], "laptop", "x"];                // too long to stand across; DC out left into the spool, AC right
strip    = [[1047, row_c], [350, 70, 60], "strip", "x"];                   // Brennenstuhl Eco-Line 6-way, sockets down; measure when bought
trunk    = [9, 34];                             // AC trunk: from cell 9, 34 cells, last row before the rail
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
translate([-800, 400, top_z]) clamp_vis_at();
module clamp_vis_at() translate([clamp[0].x, -clamp[0].y - clamp[1].y, -clamp[1].z]) clamp_vis(clamp[1]);
run(trunk, 5);
for (j = [0, 1]) translate(P([C(spool[0], j ? 3 : 2).x + (j ? spool[1] * grid : 0), C(0, j ? 3 : 2).y, -hold]))
    multmatrix(j ? [[-1, 0, 0, 0], [0, 0, -1, 0], [0, -1, 0, 0]] : [[1, 0, 0, 0], [0, 0, 1, 0], [0, -1, 0, 0]])
        color(printed()) import("build/spool_2x2.stl");          // flat sides face each other across row 2

// --- cables (echo prints each route length) ---
W  = wall_y + 8;            // between desk and wall
T  = C(0, 5).y + 14;        // trunk centre line
Tz = -board - 9;            // inside a channel
Rz = -board;                // router drawn one board lower
cable("strip cord -> wall", [end(strip, false), [1037, row_c, -hold - 30], [1035, 140, Tz], [1027, T, Tz], [470, T, Tz], [440, 140, Tz - 10], [400, 100, Tz - 12], [380, 30, -30], [370, W, -60], [362, W, -330], [360, W, -349]], "#1b1b1b", 7);
cable("coax wall -> router",  [[288, W, -504], [290, W, -150], [295, 10, -95 + Rz], [300, 30, -72 + Rz], [300, 50, -72 + Rz]], "#f4f4f4", 7);
cable("LAN router -> closet", [[350, 50, -72 + Rz], [350, 30, -72 + Rz], [345, W, -115], [340, W, -740], [300, W, -760], [60, W, -760]], "#3b82f6");
cable("router DC",  [[sock(5), row_c + 40, -hold - strip[1].z - 25], [sock(5) - 5, 120, -60], [sock(5) - 10, T + 4, Tz], [470, T + 4, Tz], [445, 140, Tz - 10], [420, 100, Tz - 12], [410, 40, -60 + Rz], [400, 32, -72 + Rz], [400, 50, -72 + Rz]], "#555", 4);
cable("speaker DC", [end(spk_psu, false), [spk_psu[0].x, W, -10], [spk_psu[0].x, W, 16], [440, 60, 40]], "#8e44ad", 4);
cable("speaker AC", [end(spk_psu, true), [spk_psu[0].x, 128, -28], [spk_psu[0].x + 3, T - 4, Tz], [1050, T - 4, Tz], [sock(0), 110, -90], [sock(0), 83, -hold - 86]], "#8e44ad", 5);
cable("monitor DC", [end(mon_psu, false), [mon_psu[0].x, W, -10], [740, W, 20], [712, W, 250]], "#d03a3a", 4);
cable("monitor AC", [end(mon_psu, true), [mon_psu[0].x, 132, -28], [mon_psu[0].x + 3, T, Tz], [1096, T, Tz], [sock(1), 110, -90], [sock(1), 83, -hold - 86]], "#d03a3a", 5);
// Laptop DC (measured 177 cm): out of the brick, N turns round the spool, up over the edge to the laptop.
lap_dc   = 1770;
laptop   = [780, 130, 360];   // ASSUMED: laptop on its stand: centre x, back edge y, width
lap_side = "right";           // DC socket on the right side, L-plug (user)
lap_port = [laptop[0] + (lap_side == "right" ? 1 : -1) * laptop[2] / 2, laptop[1] + 50, 80];  // L-plug, cord runs back along the side
cab_d    = 5.5;
sp_rp    = (spool[1] * grid - 28) / 2;                                   // post end radius: half its width
sp_c     = [C(spool[0], 0).x + spool[1] * grid / 2, [C(0, 2).y - (42 - sp_rp), C(0, 3).y + (42 - sp_rp)]];   // oval: x, end-arc centre ys (D post 42 deep)
sp_r     = sp_rp + cab_d / 2;                                             // cable centre line
sp_turn  = 2 * (sp_c[1][1] - sp_c[1][0]) + 2 * PI * sp_r;
function oval(s, z) = let(L = sp_c[1][1] - sp_c[1][0], q = s % sp_turn, x = sp_c[0], y0 = sp_c[1][0], y1 = sp_c[1][1])
    q < L ? [x + sp_r, y0 + q, z] :
    q < L + PI * sp_r ? let(a = (q - L) / sp_r * 180 / PI) [x + sp_r * cos(a), y1 + sp_r * sin(a), z] :
    q < 2 * L + PI * sp_r ? [x - sp_r, y1 - (q - L - PI * sp_r), z] :
    let(a = 180 + (q - 2 * L - PI * sp_r) / sp_r * 180 / PI) [x + sp_r * cos(a), y0 + sp_r * sin(a), z];
lap_in   = [end(lap_psu, false), [sp_c[0] + sp_r + 6, row_c, -hold - 15], oval(row_c - sp_c[1][0], -hold - 4)];
function lap_up(p) = [p, [sp_c[0] - sp_r - 5, 6, -20], [sp_c[0] - sp_r - 5, W, -10], [sp_c[0] - sp_r - 8, W, 16], [lap_port.x, 15, 30], [lap_port.x, lap_port.y - 40, lap_port.z], lap_port];
s0       = row_c - sp_c[1][0];                                            // where the cable lands on the oval
function wrap(n) = oval(s0 + n * sp_turn, -hold - 4 - n * cab_d);        // point after n turns
function turns(n) = (lap_dc - plen(lap_in) - plen(lap_up(wrap(n)))) / sp_turn;
lap_n    = turns(turns(turns(0)));                                        // exit point depends on n: iterate
assert(lap_n >= 1 && lap_n * cab_d <= spool[2], str("laptop DC: ", lap_n, " turns do not fit a ", spool[2], " mm post"));
echo(str("laptop DC: ", round(lap_n * 10) / 10, " turns on the spool"));
cable("laptop DC", concat(lap_in, [for (k = [0:ceil(lap_n * sp_turn / 8)]) wrap(min(k * 8 / sp_turn, lap_n))], lap_up(wrap(lap_n))), "#f07a2a", cab_d);
cable("laptop AC",  [end(lap_psu, true), [1044, row_c, -28], [1044, 100, -28], [1042, T + 4, Tz], [1230, T + 4, Tz], [sock(2), 110, -90], [sock(2), 83, -hold - 86]], "#f07a2a", 6);
