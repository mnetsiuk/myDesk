// Under-desk cable plan. Corner desk: walls at back (+Y) and left (-X).
// Positions: x from LEFT desk edge, y from BACK (wall) edge, mm. Items hang from the tabletop underside.
// Back zone between back frame rail and back edge: y 0..170, free along the whole length.
// ASSUMED values are marked; replace with measurements.
include <desk.scad>
use <router_mount.scad>

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

// Box hanging under the top: p = [x from left, y from back], s = [along X, along Y, height].
module under(p, s, c) color(c) translate([-800 + p.x, 400 - p.y - s.y, top_z - s.z]) cube(s);

desk(show_top = false);
color("White", 0.3) translate([-800, 400, 0]) cube([1600, 20, 1000]);    // back wall
color("White", 0.3) translate([-820, -400, 0]) cube([20, 820, 1000]);    // left wall
color("Ivory") translate([-800, 385, 720]) rotate([0, 90, 0]) cylinder(d = 20, h = 180);  // ASSUMED: heating pipe at back-left corner
color("LightGray") translate([-800 + 250, 400, 200]) cube([150, 15, 250]);  // ASSUMED: wall sockets + TAE + coax, x 250..400

// PYUR router lies flat under the back rail in router_mount.scad cheeks, x 214..456 from left.
translate([-800 + 219, 400, top_z]) mirror([0, 1, 0]) { color("SlateBlue") pair(); router_ghost(); }
under([460, 5], rtr_psu, "Gray");
under([clamp_x - clamp_sz.x/2, 0], clamp_sz, "Black");
under([clamp_x + clamp_sz.x/2 + 5, 5], mon_psu, "Red");                  // short DC cable: right next to the clamp
under([clamp_x + clamp_sz.x/2 + mon_psu.x + 15, 5], lap_psu, "OrangeRed");
under([550, 5], spk_psu, "Purple");
under([460, 95], strip, "Orange");                                       // flat, sockets DOWN; plugs add ~40 mm below

// AC cords strip -> monitor/laptop bricks: one Lite tile row + 1-unit channel.
run = [815, 130];  run_n = 7;           // 7 x 28 = 196 mm, strip end -> laptop brick
under(run, [run_n * grid, grid, tile_t], "Gold");
under(run + [0, 0.8], [run_n * grid, grid - 1.6, tile_t + ch_h], "SlateBlue");
