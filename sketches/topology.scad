// Plan seen from BELOW (like lying under the desk, wall at the bottom of the image), labelled. Render:
// openscad -o topology.png --imgsize=1800,1000 --projection=o --camera=-180,240,700,180,0,0,1350 topology.scad
include <../plan.scad>

module label(s, p, sz = 11, c = "Black") color(c) translate([-800 + p.x, 400 - p.y, top_z - 250]) mirror([0, 1, 0])
    text(s, size = sz, font = "DejaVu Sans", halign = "center", valign = "center");

label("роутер", [335, 145], 16);  label("(під балкою)", [335, 120], 11);
label("БЖ роутера", [502, 47], 8, "White");
label("БЖ колонки", [607, 45], 9, "White");
label("БЖ монітора", [784, 46], 9, "White");
label("БЖ ноутбука", [934, 57], 10, "White");
label("подовжувач, розетки вниз", [635, 130], 11);
label("Underware", [913, 144], 10, "White");
label("петлі запасу кабелів на openGrid", [740, 362]);
label("(між балками, збоку не видно)", [740, 345], 9);
label("↓ стіна        ■ чорний = струбцина", [620, -62], 10);
label("по стіні вниз: живлення, коаксіал, LAN", [330, -40], 10);
label("вгору: монітор (по кронштейну), колонка, ноутбук", [850, -40], 10);
