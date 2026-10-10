// Under-desk cable plan. Walls: back (+Y) and left (-X).
// All positions: x from LEFT desk edge, y from BACK (wall) edge, mm. Items hang from the tabletop underside.
// ASSUMED values are marked; replace with measurements.
include <desk.scad>

grid   = 28;    // openGrid
tile_t = 4;     // openGrid Lite (Full = 6.8)
ch_h   = 22;    // Underware monokini channel, min total height

clamp_x   = 700;   // monitor arm clamp centre (700 from left edge; edge or centre? verify on photo)
clamp_sz  = [45, 55, 40];               // lower jaw 45 wide x 55 deep; height ASSUMED
mon_psu   = [114.5, 51.6, 30];
lap_psu   = [154, 73.5, 30];
strip     = [300, 55, 40];              // ASSUMED: 5-way Schuko strip

// Box hanging under the top: p = [x from left, y from back], s = [along X, along Y, height].
module under(p, s, c) color(c) translate([-800 + p.x, 400 - p.y - s.y, top_z - s.z]) cube(s);

desk(show_top = false);
color("White", 0.3) translate([-800, 400, 0]) cube([1600, 20, 1000]);    // back wall
color("White", 0.3) translate([-820, -400, 0]) cube([20, 820, 1000]);    // left wall

under([clamp_x - clamp_sz.x/2, 0], clamp_sz, "Black");
under([clamp_x + clamp_sz.x/2 + 5, 5], mon_psu, "Red");                // as close to the clamp as it gets
under([clamp_x + clamp_sz.x/2 + mon_psu.x + 15, 5], lap_psu, "OrangeRed");
under([clamp_x - clamp_sz.x/2 - strip.x - 10, 5], strip, "Orange");

// Main run: one Lite tile row + 1-unit channel, behind the back rail, left corner -> laptop PSU.
run = [50, 100];  run_n = 40;          // 40 x 28 = 1120 mm
under(run, [run_n * grid, grid, tile_t], "Gold");
under(run + [0, 0.8], [run_n * grid, grid - 1.6, tile_t + ch_h], "SlateBlue");
