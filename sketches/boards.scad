// openGrid board layout seen from BELOW (wall at the bottom), boards only. Render:
// openscad -o boards.png --imgsize=3600,1500 --projection=o --camera=0,300,700,180,0,0,1500 boards.scad
include <../plan.scad>
show_floor = false;
show_walls = false;
show_items = false;

module label(s, p, sz = 14, c = "Black") color(c) translate([-800 + p.x, 400 - p.y, top_z - 250]) mirror([0, 1, 0])
    text(s, size = sz, font = "DejaVu Sans:style=Bold", halign = "center", valign = "center");

// [name, screws] in the order of `boards`
names = [["A", 6], ["B", 4], ["C", 4], ["D1", 8], ["D2", 8]];
for (k = [0:len(boards) - 1]) let(b = boards[k], c = C(b[0].x, b[0].y) + [b[1].x, b[1].y] * grid / 2) {
    label(str(names[k][0], "  ", b[1].x, "×", b[1].y), [c.x, c.y + 10], 16);
    label(str(names[k][1], " шурупів"), [c.x, c.y - 14], 11);
    if (k < len(boards) - 1) color("Red") translate(P([C(b[0].x + b[1].x, 0).x, C(0, b[0].y).y + b[1].y * grid / 2, -60])) cube([2, b[1].y * grid, 1], center = true);  // seam
}
label("роутер (під ним плита A для щік)", [335, 185], 10);
label("■ струбцина: тут плити немає", [700, -25], 10);
label("червоне: стики плит, з'єднувачі openGrid Connector", [900, -50], 10);
