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
strip    = [[hx(340, 30), C(0, 3).y], [340, 58, 48], "strip"];                     // Brennenstuhl Eco-Line 6-way, 340 x 58 x 48 (seller's drawing; datasheet says 360 x 90 x 65); sockets down, cord end left
rtr_psu  = [84.2, 38.2, 53, 24, 14];            // plug-in adapter (measured; plug offset and cord exit from the photo)
rtr_sock = 4;                                   // its body covers socket 3; in socket 5 it hits the right holder's lip
rtr_slot = 38;                                  // trunk slot straight in front of its cord end
sock_a   = 135;                                 // 45 deg sockets (datasheet): plug cords leave towards -x +y (which diagonal: ASSUMED)
trunk    = [10, 31];                            // AC trunk, last row before the rail: Open 7x + 3 x Open 8x, joints 17/25/33. Cell 9 stays free:
                                                // the cords leaving the left end drop there below the router cheek's window top. Right end open.
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
function seg1(r) = r[1] - 8 * (ceil(r[1] / 8) - 1);    // channel run of Open 8x segments, the short one first
module run(r, row) for (k = [0:ceil(r[1] / 8) - 1]) translate(P([C(r[0] + (k ? seg1(r) + 8 * (k - 1) : 0), row).x, C(0, row).y + grid / 2, -3.4]))
    uw_channel(k ? 8 : seg1(r), open = true);
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
// Router in its cheeks on Multiconnect (router_mount.scad): board A cells 0-8, outer faces on its edges (x 210 and 462).
translate([-800 + 210 + 5, 400, top_z]) mirror([0, 1, 0]) { color(printed()) pair(); router_ghost(); }
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
// Cord through the trunk's front wall at cell boundary i: Open channels have slots at inner boundaries only.
function slot(i) = assert(i > trunk[0] && i < trunk[0] + trunk[1] && (i - trunk[0] - seg1(trunk)) % 8 != 0, str("no slot at boundary ", i))
    [C(i, 5).x, C(0, 5).y, Tz];
// Strip cord (1.5 m): out of the trunk's left end, over the router, down behind it and the wall into the LOWEST wall socket
// (user: no coil). The rest hangs as a loop d mm below that socket.
rtr_back   = 80;                                                     // router back face y (router_mount.scad: port_gap)
strip_cord = 1500;
sock_wall  = [360, -519];                                            // lowest Schuko of the wall box: x, z (245 mm above the floor)
function strip_route(d) = [end(strip, false) + [-8, 0, 20], [strip[0].x - 25, strip[0].y + 20, -hold - 14], slot(29), [C(29, 0).x - 12, T, Tz],
    [C(trunk[0], 0).x + 6, T, Tz], [C(trunk[0], 0).x - 12, 150, Tz - 6], [455, 144, Tz - 9], [440, 140, Tz - 10], [400, 100, Tz - 12],
    [380, 30, -30], [372, W, -60], [372, W, sock_wall[1] - d], [sock_wall[0], W, sock_wall[1] - d], [sock_wall[0], W, sock_wall[1]]];
strip_drop = (strip_cord - plen(strip_route(0))) / 2;               // both drop runs are vertical: length grows by exactly 2 d
assert(strip_drop >= 0 && sock_wall[1] - strip_drop > -top_z + 30, str("strip cord: a ", round(strip_drop), " mm loop below the socket"));
echo(str("strip cord: the rest hangs ", round(strip_drop / 10), " cm below the lowest wall socket"));
cable("strip cord -> wall", strip_route(strip_drop), "#1b1b1b", 7);
cable("coax wall -> router",  [[288, W, -504], [290, W, -150], [295, 10, -95], [300, 40, -72], [300, rtr_back, -72]], "#f4f4f4", 7);
cable("LAN router -> closet", [[350, rtr_back, -72], [350, 40, -72], [345, W, -115], [340, W, -740], [300, W, -760], [60, W, -760]], "#3b82f6");
// Router DC (measured 151 cm): straight into the trunk slot in front of the adapter, the slack Z-folded right there
// (3 passes, s = fold length), out of the trunk's left end to the router.
rtr_dc   = 1510;
function rtr_route(s) = let(xb = C(rtr_slot, 0).x - 6) [
    let(d = rtr_psu.x - rtr_psu[3] + 6) [sock(rtr_sock) - d * sin(sock_a), strip[0].y - d * cos(sock_a), -hold - strip[1].z - rtr_psu[4]],
    [C(rtr_slot, 0).x - 6, 128, -45], slot(rtr_slot),
    [xb, T - 6, Tz], [xb - s, T - 6, Tz], [xb - s, T, Tz], [xb, T, Tz], [xb, T + 4, Tz],
    [C(trunk[0], 0).x + 6, T + 4, Tz], [C(trunk[0], 0).x - 12, 154, Tz - 6], [455, 148, Tz - 9], [445, 140, Tz - 10], [420, 100, Tz - 12], [412, rtr_back - 6, -36], [400, rtr_back - 18, -72], [400, rtr_back, -72]];
rtr_fold = (rtr_dc - plen(rtr_route(0))) / 2;     // each fold pass is horizontal: length grows by exactly 2 s
assert(rtr_fold >= 0 && C(rtr_slot, 0).x - 6 - rtr_fold > C(29, 0).x + 8,    // fold stays right of the strip cord entry (29): <= 4 cords + fold, ~42 %
       str("router DC: a ", round(rtr_fold), " mm fold does not fit between slots 29 and ", rtr_slot));
echo(str("router DC: ", round(2 * rtr_fold / 10), " cm slack Z-folded in the trunk (", round(rtr_fold / 10), " cm folds)"));
cable("router DC", rtr_route(rtr_fold), "#555", 4);
// Speaker DC: out of the brick's left end, between the router and the monitor plug to the edge, up to the speaker on the desk.
cable("speaker DC", [end(spk_psu, false) - [8, 0, 0], [478, spk_psu[0].y, -26], [472, 40, -24], [470, W, -10], [470, W, 16], [440, 60, 40]], "#8e44ad", 4);
cable("speaker AC", [ac(spk_psu), [ac(spk_psu).x, 125, -24], slot(16), [670, T - 4, Tz], [C(32, 0).x - 12, T - 4, Tz], slot(32), [pc(0).x - 6, 120, -60], pc(0)], "#8e44ad", 5);
// Monitor DC: up behind the clamp, hidden in the arm's cable channels, into the socket on the monitor back (user). Under-desk part only.
mon_dc = 990;                                                                                 // measured
mon_in = [end(mon_psu, true) + [8, 0, 0], [652, 14, -20], [662, W, -8], [680, W, 20]];      // to the desk top by the clamp
assert(mon_dc - plen(mon_in) >= 300, "monitor DC: less than the ~30 cm needed above the desk");
echo(str("monitor DC: ", round((mon_dc - plen(mon_in)) / 10), " cm left above the desk (~30 needed)"));
cable("monitor DC", concat(mon_in, [[700, W, 250]]), "#d03a3a", 4);
cable("monitor AC", [ac(mon_psu), [ac(mon_psu).x, 80, -24], slot(11), [C(11, 0).x + 12, T, Tz], [C(34, 0).x - 12, T, Tz], slot(34), [pc(1).x - 6, 120, -60], pc(1)], "#d03a3a", 5);
// Laptop DC (measured 177 cm): out of the brick, N turns round the spool, up over the edge to the laptop.
lap_dc   = 1770;
laptop   = [780, 130, 360];   // ASSUMED: laptop on its stand: centre x, back edge y, width
lap_side = "right";           // DC socket on the right side, L-plug (user)
lap_port = [laptop[0] + (lap_side == "right" ? 1 : -1) * laptop[2] / 2, laptop[1] + 50, 80];  // L-plug, cord runs back along the side
cab_d    = 5.5;
// shir's post is an hourglass (measured on build/spool_2x2.stl): a 28 x 42 core (rounding 14 = half a cell) with concave r 13.5
// fillets to the board and to the end flange (generator: Spool_Fillet = 14 - 0.5), only 8 mm straight. The turns lie in one layer
// along that valley from sp_y0 under the board (first turn, nearest the trunk wall at y 141.8) towards the flange; a turn's radius
// grows as it climbs a fillet. Real cable piles up instead and takes less of the valley, so this is the safe side.
sp_core  = grid / 2;
sp_fil   = sp_core - 0.5;
sp_a     = sp_fil - cab_d / 2 - 0.5;                                     // cable centre line on a fillet: concentric arc, 0.5 clearance
sp_y0    = 6;
sp_c     = [C(spool[0], 0).x + spool[1] * grid / 2, [C(0, 2).y - 2 * sp_core, C(0, 3).y + 2 * sp_core]];   // oval: x, end-arc centre ys (core arcs 28 from the flat sides)
sp_s     = [sp_a * asin((sp_fil - sp_y0) / sp_a) * PI / 180, spool[2] - 2 * sp_fil,                   // valley for cable centres: board fillet from sp_y0 |
            sp_a * acos((sp_fil + cab_d / 2 - sp_core) / sp_a) * PI / 180];                             // straight | flange fillet while the cable stays inside the flange
sp_turn  = 2 * (sp_c[1][1] - sp_c[1][0]) + 2 * PI * (sp_core + sp_fil - sp_a);                         // a turn in the valley bottom
function sp_pos(n) = let(s = n * cab_d)                                   // turn n: [depth under the board, cable centre beyond the core]
    s < sp_s[0] ? let(t = (sp_s[0] - s) / sp_a * 180 / PI) [sp_fil - sp_a * sin(t), sp_fil - sp_a * cos(t)] :
    s < sp_s[0] + sp_s[1] ? [sp_fil + s - sp_s[0], sp_fil - sp_a] :
    let(t = (s - sp_s[0] - sp_s[1]) / sp_a * 180 / PI) [spool[2] - sp_fil + sp_a * sin(t), sp_fil - sp_a * cos(t)];
function oval(f, n) = let(L = sp_c[1][1] - sp_c[1][0], p = sp_pos(n), r = sp_core + p[1], q = (f - floor(f)) * (2 * L + 2 * PI * r),
                          x = sp_c[0], y0 = sp_c[1][0], y1 = sp_c[1][1], z = -hold - p[0])   // f: fraction of a turn, n: turn for radius and depth
    q < L ? [x + r, y0 + q, z] :
    q < L + PI * r ? let(a = (q - L) / r * 180 / PI) [x + r * cos(a), y1 + r * sin(a), z] :
    q < 2 * L + PI * r ? [x - r, y1 - (q - L - PI * r), z] :
    let(a = 180 + (q - 2 * L - PI * r) / r * 180 / PI) [x + r * cos(a), y0 + r * sin(a), z];
f0       = let(L = sp_c[1][1] - sp_c[1][0], r = sp_core + sp_pos(0)[1]) (L + PI * r + (sp_c[1][1] - lap_psu[0].y)) / (2 * L + 2 * PI * r);   // the cable lands on the oval's left side (brick on the left)
function wrap(n) = oval(f0 + n, n);                                      // point after n turns
lap_in   = [end(lap_psu, true) + [8, 0, 0], [wrap(0).x - 6, lap_psu[0].y, -hold - 15], wrap(0)];
function lap_up(p) = let(x = sp_c[0] + (p.x < sp_c[0] ? -1 : 1) * (2 * sp_core + 3))     // up on the side the last turn ends on, outside the flange
    [p, [x, 6, -20], [x, W, -10], [x, W, 16], [lap_port.x, 15, 30], [lap_port.x, lap_port.y - 40, lap_port.z], lap_port];
function wound(n) = [for (k = [0:ceil(n * sp_turn / 8)]) wrap(min(k * 8 / sp_turn, n))];
function turns(n, i = 0) = i == 4 ? n : turns(n + (lap_dc - plen(lap_in) - plen(wound(n)) - plen(lap_up(wrap(n)))) / sp_turn, i + 1);   // exit point and turn radii depend on n: iterate
lap_n    = turns(0);
sp_cap   = (sp_s[0] + sp_s[1] + sp_s[2]) / cab_d;                         // turns that fit in one layer
assert(lap_n >= 1 && lap_n <= sp_cap, str("laptop DC: ", lap_n, " turns do not fit the spool valley (", round(sp_cap * 10) / 10, ")"));
echo(str("laptop DC: ", round(lap_n * 10) / 10, " turns on the spool (", round(sp_cap * 10) / 10, " fit)"));
cable("laptop DC", concat(lap_in, wound(lap_n), lap_up(wrap(lap_n))), "#f07a2a", cab_d);
// Laptop AC: a 1 m cord (angled at both ends only comes in 0.5 or 1 m, user). No fold inside the trunk: a 6.6 mm cord turning back
// in its 22.4 mm width bends at r ~1.2 D, H05VV-F datasheets want >= 3-4 D. It runs on past exit 36, out of the trunk's open right end,
// turns down (r ~3.5 D) and comes back to its plug just above the router adapter (top at -61); the loop ends s mm past the trunk end.
lap_ac   = 1000;
lap_xe   = C(trunk[0] + trunk[1], 0).x;                            // trunk's right end
lap_zr   = -56;                                                    // return run
function lap_ac_route(s) = [ac(lap_psu), [ac(lap_psu).x, 110, -24], slot(19), [C(19, 0).x + 12, T + 4, Tz],
    [lap_xe + s, T + 4, Tz], [lap_xe + s + 20, T - 8, (Tz + lap_zr) / 2], [lap_xe + s, T - 20, lap_zr], [pc(2).x + 30, T - 20, lap_zr], pc(2)];
lap_loop = (lap_ac - plen(lap_ac_route(0))) / 2;                   // both runs are along x: length grows by exactly 2 s
assert(lap_loop >= 0, str("laptop AC: the route needs ", round(plen(lap_ac_route(0)) / 10), " cm, more than the 1 m cord"));
echo(str("laptop AC: route via exit 36 ", round(plen([ac(lap_psu), [ac(lap_psu).x, 110, -24], slot(19), [C(19, 0).x + 12, T + 4, Tz],
    [C(36, 0).x - 12, T + 4, Tz], slot(36), [pc(2).x - 6, 120, -60], pc(2)]) / 10), " cm; the 1 m cord loops out of the trunk's right end, ",
    round(lap_loop / 10), " cm past it"));
cable("laptop AC", lap_ac_route(lap_loop), "#f07a2a", 6);
