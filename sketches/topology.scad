// Plan seen from BELOW (like lying under the desk, wall at the bottom of the image), labelled. Render:
// openscad -o topology.png --imgsize=3600,2000 --projection=o --camera=-130,250,700,180,0,0,1450 topology.scad
include <../plan.scad>
show_floor = false;
show_walls = false;

module label(s, p, sz = 11, c = "Black") color(c) translate([-800 + p.x, 400 - p.y, top_z - 250]) mirror([0, 1, 0])
    text(s, size = sz, font = "DejaVu Sans:style=Bold", halign = "center", valign = "center");

label("роутер", [335, 145], 16);  label("лежить під балкою", [335, 120], 10);
label("БЖ роутера", [506, 47], 8, "White");
label("БЖ монітора", [789, 46], 9, "White");
label("БЖ ноутбука", [947, 57], 10, "White");
label("БЖ колонки", [1099, 45], 9, "White");
label("подовжувач, розетки вниз", [650, 112], 10, "White");
label("Underware: живлення ноутбука і колонки", [998, 175], 9);
label("запас кабелів петлями на плитках openGrid", [740, 362]);
label("(між балками, збоку не видно)", [740, 345], 9);
label("вниз по стіні: подовжувач → розетка, коаксіал, LAN → шафа", [420, -42], 10);
label("вгору за край стола: монітор (по кронштейну), ноутбук, колонка", [950, -42], 10);
label("↓ стіна", [650, -65], 10);
