// Plan seen from BELOW (like lying under the desk, wall at the bottom of the image), labelled. Render:
// openscad -o topology.png --imgsize=3600,1700 --projection=o --camera=40,300,700,180,0,0,1560 topology.scad
include <../plan.scad>
show_floor = false;
show_walls = false;

module label(s, p, sz = 11, c = "Black", rot = 0) color(c) translate([-800 + p.x, 400 - p.y, top_z - 250]) mirror([0, 1, 0]) rotate(rot)
    text(s, size = sz, font = "DejaVu Sans:style=Bold", halign = "center", valign = "center");

label("роутер", [335, 145], 16);  label("лежить під балкою", [335, 120], 10);
label("БЖ колонки", [490, 63], 8, "White", 90);
label("адаптер роутера", [1385, 105], 8);
label("БЖ монітора", [770, 65], 8, "White", 90);
label("БЖ ноутбука", [990, 57], 9, "White");
label("подовжувач", [1355, 40], 9, "White");
label("канал Underware: живлення від БЖ → подовжувач, шнур подовжувача → розетка, кабель роутера", [900, 190], 10);
label("котушка: запас кабелю ноутбука", [868, 71], 7, "White", 90);
label("плити openGrid Full на шурупах; блоки й подовжувач у тримачах Item Holder на засувках Multiconnect", [930, 225], 9);
label("вниз по стіні: подовжувач → розетка, коаксіал, LAN → шафа", [400, -42], 10);
label("вгору за край: монітор (по кронштейну), колонка, ноутбук", [1000, -42], 10);
label("■ струбцина", [700, -62], 9);
