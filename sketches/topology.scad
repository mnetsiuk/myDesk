// Plan seen from BELOW (like lying under the desk, wall at the bottom of the image), labelled. Render:
// openscad -o topology.png --imgsize=3600,1700 --projection=o --camera=0,300,700,180,0,0,1480 topology.scad
include <../plan.scad>
show_floor = false;
show_walls = false;

module label(s, p, sz = 11, c = "Black") color(c) translate([-800 + p.x, 400 - p.y, top_z - 250]) mirror([0, 1, 0])
    text(s, size = sz, font = "DejaVu Sans:style=Bold", halign = "center", valign = "center");

label("роутер", [335, 145], 16);  label("лежить під балкою", [335, 120], 10);
label("БЖ колонки", [525, 57], 8, "White");
label("адаптер роутера", [1370, 122], 8);
label("БЖ монітора", [802, 57], 8, "White");
label("БЖ ноутбука", [953, 57], 9, "White");
label("подовжувач", [1340, 40], 9, "White");
label("канал Underware: живлення від БЖ → подовжувач, шнур подовжувача → розетка", [930, 190], 10);
label("гачки Underware для запасу кабелів", [780, 127], 8);
label("плити openGrid Full на шурупах; блоки й подовжувач у тримачах Item Holder на засувках Multiconnect", [930, 225], 9);
label("вниз по стіні: подовжувач → розетка, коаксіал, LAN → шафа", [400, -42], 10);
label("вгору за край: монітор (по кронштейну), колонка, ноутбук", [1000, -42], 10);
label("■ струбцина", [700, -62], 9);
