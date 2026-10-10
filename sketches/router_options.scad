// Side section through the back of the desk (wall on the left). 0 = tabletop underside, mm.
// Render: openscad -o router_options.png --imgsize=1600,700 --projection=o --viewall --autocenter router_options.scad
font = "DejaVu Sans";
module t(s, p, sz = 9, c = "Black") color(c) translate(p) text(s, size = sz, font = font);
module box(p, s, c) color(c) translate(p) square(s);

module desk_section() {
    box([-20, -260], [20, 300], "Gainsboro");   t("стіна", [-18, -280]);
    box([0, 0], [400, 16], "BurlyWood");        t("стільниця", [220, 22]);
    box([170, -30], [30, 30], "DimGray");       t("балка рами", [205, -20], 8);
    box([335, -30], [30, 30], "DimGray");
    color("Red") { box([0, 40], [170, 1.2]); box([0, 34], [1.2, 12]); box([169, 34], [1.2, 12]); }
    t("170", [70, 45], 10, "Red");
}

module router(p, s, label) { box(p, s, "LightSteelBlue"); t(label, p + [4, s.y/2 - 4], 8); }

// A: flat, 190 deep -> passes under the rail
desk_section();
t("А: плиском під балкою", [0, 80], 14);
router([5, -84], [190, 50], "роутер 190 × 50");
color("SlateBlue") { box([0, -88], [215, 4]); box([211, -88], [4, 88]); box([5, -88], [4, 88]); }  // U-bracket
t("низ: −84 мм", [220, -84], 9, "Red");

// B: on its long narrow edge, fits in front of the rail
translate([520, 0]) {
    desk_section();
    t("Б: на вузькій грані", [0, 80], 14);
    router([10, -194], [50, 190], "");
    t("роутер", [64, -100], 9); t("50 × 190", [64, -114], 9);
    t("порти вниз", [5, -212], 8);
    t("низ: −194 мм", [64, -194], 9, "Red");
}
