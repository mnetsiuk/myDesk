// Under-desk cable plan. Corner desk: walls at back (+Y) and left (-X).
// Positions: x from LEFT desk edge, y from BACK (wall) edge, mm. Items hang from the tabletop underside.
// Back zone between back frame rail and back edge: y 0..170, free along the whole length.
// ASSUMED values are marked; replace with measurements.
include <desk.scad>

grid   = 28;    // openGrid
tile_t = 4;     // openGrid Lite (Full = 6.8)
ch_h   = 22;    // Underware monokini channel, min total height

clamp_x  = 700;                  // monitor arm clamp centre
clamp_sz = [45, 55, 40];         // lower jaw; height ASSUMED
router   = [170, 50, 200];       // ASSUMED: PYUR (cbn) router W x D x H, hung upright, ports on its left side
mon_psu  = [114.5, 51.6, 30];
lap_psu  = [154, 73.5, 30];
spk_psu  = [110, 50, 30];        // ASSUMED: Onyx Studio 5 brick
strip    = [300, 55, 40];        // ASSUMED: 5-way Schuko strip, not bought yet

// Box hanging under the top: p = [x from left, y from back], s = [along X, along Y, height].
module under(p, s, c) color(c) translate([-800 + p.x, 400 - p.y - s.y, top_z - s.z]) cube(s);

desk(show_top = false);
color("White", 0.3) translate([-800, 400, 0]) cube([1600, 20, 1000]);    // back wall
color("White", 0.3) translate([-820, -400, 0]) cube([20, 820, 1000]);    // left wall
color("Ivory") translate([-800, 385, 720]) rotate([0, 90, 0]) cylinder(d = 20, h = 180);  // ASSUMED: heating pipe at back-left corner
color("LightGray") translate([-800 + 250, 400, 200]) cube([150, 15, 250]);  // ASSUMED: wall sockets + TAE + coax, x 250..400

under([220, 15], router, "WhiteSmoke");                                   // above the coax socket, clear of the pipe
under([clamp_x - clamp_sz.x/2, 0], clamp_sz, "Black");
under([clamp_x + clamp_sz.x/2 + 5, 5], mon_psu, "Red");                  // short DC cable: right next to the clamp
under([clamp_x + clamp_sz.x/2 + mon_psu.x + 15, 5], lap_psu, "OrangeRed");
under([450, 70], spk_psu, "Purple");                                      // under the speaker
under([clamp_x - clamp_sz.x/2 - strip.x - 10, 125], [strip.x, 40, strip.y], "Orange");  // on its side, plugs face the wall

// AC cords strip -> monitor/laptop bricks: one Lite tile row + 1-unit channel.
run = [670, 130];  run_n = 12;          // 12 x 28 = 336 mm, strip end -> laptop brick
under(run, [run_n * grid, grid, tile_t], "Gold");
under(run + [0, 0.8], [run_n * grid, grid - 1.6, tile_t + ch_h], "SlateBlue");
