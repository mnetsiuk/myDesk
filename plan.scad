// Under-desk cable plan. Corner desk: walls at back (+Y) and left (-X).
// Positions: [x from LEFT desk edge, y from BACK edge, z from tabletop UNDERSIDE (up +)], mm.
// Everything lives in the back zone (y 0..170, between the back edge and the back rail) on screwed openGrid Full boards:
//   rows 0-4 (y 1..141): power bricks along x + strip in Underware Item Holders (build.sh), two lanes left of the clamp;
//                        shir cord spool for the laptop DC slack; DC cables go up over the back edge
//   row 5 (y 141..169):  Underware channel trunk to the strip
// Run ./build.sh first (holders are imported from build/). ASSUMED values are marked.
include <BOSL2/std.scad>       // parts.scad draws with BOSL2; its $-variables must exist at top level
include <desk.scad>
use <router_mount.scad>
use <parts.scad>

show_floor = true;               // off for views from below
show_walls = true;               // off for cut-away views from behind
show_items = true;               // off: boards only (sketches/boards.scad)
grid  = 28;                      // openGrid
g0    = [210, 1];                // grid origin: cell (0, 0) corner
board = 6.8;                     // openGrid Full
hold  = board + 6.48;            // Item Holder backer: the item's top face sits this far under the tabletop

clamp    = [[677.5, 0], [45, 55, 40]];          // monitor arm clamp at 700, lower jaw; height ASSUMED
// Held items lie along x in a ClamShell pair of Item Holders (build.sh): [[left face x, centre-line y], [length, width, thickness],
// holder name, AC end (0 left, 1 right), angled IEC plug [face width, face height, out of the brick]; the cord leaves it towards the trunk].
// x from the cell of the first holder snap (hx); y on a cell centre for an odd slot count, on a cell boundary for an even one (asserted).
function hx(L, k) = let(D = floor((L + 6.6 - 26) / grid) * grid) C(k, 0).x + grid / 2 - ((L - D + 6.6) / 2 - 3);  // Item_Holder ClamShell maths
mon_psu  = [[hx(114.5, 11), C(0, 1).y], [114.5, 51.6, 30], "monitor", 0, [21, 27, 30]];   // lane A left of the clamp: DC right, up by the clamp; C13 (user)
spk_psu  = [[hx(110, 11), C(0, 3).y + grid / 2], [110, 50, 30], "speaker", 1, [16, 21, 28]];  // lane B: DC left, round to the edge; ASSUMED brick (to be replaced), C5 (user)
lap_psu  = [[hx(154, 20), C(0, 2).y], [154, 73.5, 30], "laptop", 0, [21, 27, 30]];      // right of the clamp: AC left, DC right into the spool; C13 (user)
spool    = [26, 2, 35];                        // shir spool halves 2x2 (his default for power cords) at cell x 26, rows 0-1 and 3-4; post height
strip    = [[hx(360, 30), C(0, 2).y + grid / 2], [360, 90, 65], "strip"];          // Brennenstuhl Eco-Line 6-way, datasheet 360 x 90 x 65; sockets down, cord end left
rtr_psu  = [84.2, 38.2, 53, 24, 14];            // plug-in adapter (measured; plug offset and cord exit from the photo)
rtr_sock = 5;                                   // last strip socket; its body covers socket 4
rtr_slot = 39;                                  // trunk slot straight in front of its cord end
sock_a   = 135;                                 // 45 deg sockets (datasheet): plug cords leave towards -x +y (which diagonal: ASSUMED)
trunk    = [9, 32];                             // AC trunk: from cell 9, 4 x Open 8x, last row before the rail; right end open for the router DC
boards   = [[[0, 0], [9, 6]], [[9, 0], [7, 6]], [[16, 2], [3, 4]], [[19, 0], [12, 6]], [[31, 1], [12, 5]]];  // A B C D1 = build.sh, D2 = user's printed 12x5 (rows 1-5); none under the clamp
wall_y   = -20;                                 // ASSUMED: wall 20 mm behind the desk

function P(p) = [-800 + p.x, 400 - p.y, top_z + p.z];
function C(i, j) = [g0.x + i * grid, g0.y + j * grid];                     // plan xy of a cell corner
function plen(p, i = 0) = i >= len(p) - 1 ? 0 : norm(p[i + 1] - p[i]) + plen(p, i + 1);
function sock(i) = strip[0].x + strip_socket_x(i);
function end(b, far) = [b[0].x + (far ? b[1].x : 0), b[0].y, -hold - b[1].z / 2];   // item end-face centre
function ac(b) = let(s = b[3] ? 1 : -1, e = end(b, b[3] == 1)) [e.x + s * (b[4][2] - 6), e.y + b[4][0] / 2 + 3, e.z];   // AC cord out of the plug

// Item hanging in its ClamShell pair of Item Holders, plus its angled IEC plug.
module held(b) translate(P([b[0].x, b[0].y, 0])) {
    n = floor((b[1].y + 5) / grid);                                        // holder slots across: (width + 1 slop + 2 walls) / grid
    assert((b[0].y - g0.y - (n % 2) * grid / 2) % grid == 0, str(b[2], ": ", n, " holder slots need y on a cell ", n % 2 ? "centre" : "boundary"));
    translate([0, -b[1].y / 2, -hold - b[1].z]) children();
    translate([0, 0, -hold]) multmatrix([[0, 0, 1, 0], [-1, 0, 0, 0], [0, -1, 0, 0]]) color(printed()) import(str("build/holder_", b[2], ".stl"));
    if (len(b) > 4) translate([b[3] * b[1].x, 0, -hold - b[1].z / 2]) mirror([b[3] ? 0 : 1, 0, 0]) iec_vis(b[4]);
}
module run(r, row) for (k = [0:ceil(r[1] / 8) - 1]) translate(P([C(r[0] + k * 8, row).x, C(0, row).y + grid / 2, -3.4])) uw_channel(min(8, r[1] - k * 8), open = true);
module cable(name, pts, c, d = 6) if (show_items) { echo(str(name, ": ", round(plen(pts) / 10), " cm")); cable_vis([for (p = pts) P(p)], c, d); }
module plug(i) translate(P([sock(i), strip[0].y, -hold - strip[1].z])) rotate([0, 0, sock_a]) plug_vis();
function pc(i) = [sock(i) - 18, strip[0].y + 18, -hold - strip[1].z - 26];   // angled Schuko plug: where its cord leaves

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
module clamp_vis_at() translate([clamp[0].x, -clamp[0].y - clamp[1].y, -clamp[1].z]) clamp_vis(clamp[1]);
translate([-800, 400, top_z]) clamp_vis_at();
if (show_items) {
// TODO: router cheeks still have screw flanges; to move onto Multiconnect, drawn one board lower for now.
translate([-800 + 219, 400, top_z - board]) mirror([0, 1, 0]) { color(printed()) pair(); router_ghost(); }
held(spk_psu) brick_vis(spk_psu[1]);
held(mon_psu) brick_vis(mon_psu[1]);
held(lap_psu) brick_vis(lap_psu[1]);
held(strip) strip_vis(strip[1]);
for (i = [0:2]) plug(i);
translate(P([sock(rtr_sock), strip[0].y, -hold - strip[1].z])) rotate([0, 0, sock_a]) wart_vis(rtr_psu);   // long end and cord towards the trunk (user)
run(trunk, 5);
for (j = [0, 1]) translate(P([C(spool[0], j ? 3 : 2).x + (j ? spool[1] * grid : 0), C(0, j ? 3 : 2).y, -hold]))
    multmatrix(j ? [[-1, 0, 0, 0], [0, 0, -1, 0], [0, -1, 0, 0]] : [[1, 0, 0, 0], [0, 0, 1, 0], [0, -1, 0, 0]])
        color(printed()) import("build/spool_2x2.stl");          // flat sides face each other across row 2
}

// --- cables (echo prints each route length) ---
W  = wall_y + 8;            // between desk and wall
T  = C(0, 5).y + 14;        // trunk centre line
Tz = -board - 9;            // inside a channel
Rz = -board;                // router drawn one board lower
// Cord through the trunk's front wall at cell boundary i: Open channels have slots at inner boundaries only.
function slot(i) = assert(i > trunk[0] && i < trunk[0] + trunk[1] && (i - trunk[0]) % 8 != 0, str("no slot at boundary ", i))
    [C(i, 5).x, C(0, 5).y, Tz];
cable("strip cord -> wall", [end(strip, false) + [-8, 0, 20], [strip[0].x - 25, strip[0].y + 20, -hold - 14], slot(29), [C(29, 0).x - 12, T, Tz], [470, T, Tz], [440, 140, Tz - 10], [400, 100, Tz - 12], [380, 30, -30], [370, W, -60], [362, W, -330], [360, W, -349]], "#1b1b1b", 7);
cable("coax wall -> router",  [[288, W, -504], [290, W, -150], [295, 10, -95 + Rz], [300, 30, -72 + Rz], [300, 50, -72 + Rz]], "#f4f4f4", 7);
cable("LAN router -> closet", [[350, 50, -72 + Rz], [350, 30, -72 + Rz], [345, W, -115], [340, W, -740], [300, W, -760], [60, W, -760]], "#3b82f6");
// Router DC (measured 151 cm): straight into the trunk slot in front of the adapter, the slack Z-folded right there
// (3 passes, s = fold length), out of the trunk's left end to the router.
rtr_dc   = 1510;
function rtr_route(s) = let(xb = C(rtr_slot, 0).x - 6) [
    let(d = (rtr_psu.x - rtr_psu[3] + 6) / sqrt(2)) [sock(rtr_sock) - d, strip[0].y + d, -hold - strip[1].z - rtr_psu[4]],
    [C(rtr_slot, 0).x - 6, 128, -45], slot(rtr_slot),
    [xb, T - 6, Tz], [xb - s, T - 6, Tz], [xb - s, T, Tz], [xb, T, Tz], [xb, T + 4, Tz],
    [470, T + 4, Tz], [445, 140, Tz - 10], [420, 100, Tz - 12], [410, 40, -60 + Rz], [400, 32, -72 + Rz], [400, 50, -72 + Rz]];
rtr_fold = (rtr_dc - plen(rtr_route(0))) / 2;     // each fold pass is horizontal: length grows by exactly 2 s
assert(rtr_fold >= 0 && C(rtr_slot, 0).x - 6 - rtr_fold > C(29, 0).x + 8,    // fold stays right of the strip cord entry (29): <= 4 cords + fold, ~42 %
       str("router DC: a ", round(rtr_fold), " mm fold does not fit between slots 29 and ", rtr_slot));
echo(str("router DC: ", round(2 * rtr_fold / 10), " cm slack Z-folded in the trunk (", round(rtr_fold / 10), " cm folds)"));
cable("router DC", rtr_route(rtr_fold), "#555", 4);
// Speaker DC: out of the brick's left end, between the router and the monitor plug to the edge, up to the speaker on the desk.
cable("speaker DC", [end(spk_psu, false) - [8, 0, 0], [478, spk_psu[0].y, -26], [472, 40, -24], [470, W, -10], [470, W, 16], [440, 60, 40]], "#8e44ad", 4);
cable("speaker AC", [ac(spk_psu), [ac(spk_psu).x, 125, -24], slot(16), [670, T - 4, Tz], [C(32, 0).x - 12, T - 4, Tz], slot(32), [pc(0).x - 6, 120, -60], pc(0)], "#8e44ad", 5);
// Monitor DC: up behind the clamp, hidden in the arm's cable channels, into the socket on the monitor back (user). Under-desk part only.
cable("monitor DC", [end(mon_psu, true) + [8, 0, 0], [652, 14, -20], [662, W, -8], [680, W, 20], [700, W, 250]], "#d03a3a", 4);
cable("monitor AC", [ac(mon_psu), [ac(mon_psu).x, 80, -24], slot(10), [C(10, 0).x + 12, T, Tz], [C(34, 0).x - 12, T, Tz], slot(34), [pc(1).x - 6, 120, -60], pc(1)], "#d03a3a", 5);
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
s0       = (sp_c[1][1] - sp_c[1][0]) + PI * sp_r + (sp_c[1][1] - lap_psu[0].y);   // the cable lands on the oval's left side (brick on the left)
lap_in   = [end(lap_psu, true) + [8, 0, 0], [sp_c[0] - sp_r - 6, lap_psu[0].y, -hold - 15], oval(s0, -hold - 4)];
function lap_up(p) = [p, [sp_c[0] - sp_r - 5, 6, -20], [sp_c[0] - sp_r - 5, W, -10], [sp_c[0] - sp_r - 8, W, 16], [lap_port.x, 15, 30], [lap_port.x, lap_port.y - 40, lap_port.z], lap_port];
function wrap(n) = oval(s0 + n * sp_turn, -hold - 4 - n * cab_d);        // point after n turns
function turns(n) = (lap_dc - plen(lap_in) - plen(lap_up(wrap(n)))) / sp_turn;
lap_n    = turns(turns(turns(0)));                                        // exit point depends on n: iterate
assert(lap_n >= 1 && lap_n * cab_d <= spool[2], str("laptop DC: ", lap_n, " turns do not fit a ", spool[2], " mm post"));
echo(str("laptop DC: ", round(lap_n * 10) / 10, " turns on the spool"));
cable("laptop DC", concat(lap_in, [for (k = [0:ceil(lap_n * sp_turn / 8)]) wrap(min(k * 8 / sp_turn, lap_n))], lap_up(wrap(lap_n))), "#f07a2a", cab_d);
cable("laptop AC",  [ac(lap_psu), [ac(lap_psu).x, 110, -24], slot(19), [C(19, 0).x + 12, T + 4, Tz], [C(36, 0).x - 12, T + 4, Tz], slot(36), [pc(2).x - 6, 120, -60], pc(2)], "#f07a2a", 6);
