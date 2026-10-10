// PYUR router hanger, option A: router lies flat UNDER the back frame rail, ports facing the wall.
// Two side cheeks screwed into the tabletop underside; the router slides in from the front onto their ledges.
// Local coords: y = depth from desk back edge, z = 0 at tabletop underside (down is negative), x across the router.
// Export: openscad -D 'part="left"' -o cheek_left.stl router_mount.scad   (and "right"); printed flat, no supports.

part = "pair";             // pair | left | right

r        = [230, 190, 50]; // router W x D x H, lying flat, stand removed
rail_y   = 170;            // back rail front-to-back: 170..200 from the back edge
rail_h   = 30;
gap      = 4;              // router top below the rail
port_gap = 50;             // room for coax / LAN / power plugs between router back and desk edge
clr      = 1;              // side + height clearance
t        = 5;              // wall thickness
ledge    = 15;             // how far the ledge reaches under the router
flange_w = 18;
screws_y = [15, 85, 155];  // 3.5 mm wood screws, <= 12 mm long into the tabletop

yb = port_gap;  yf = port_gap + r.y;
zt = -rail_h - gap;  zb = zt - r.z - clr;

assert(zt < -rail_h, "router must clear the rail");
assert(screws_y[len(screws_y) - 1] + 4 < rail_y, "flange screws must stay behind the rail");
assert(yf + t <= 256, "cheek longer than a 256 mm bed");

// Left cheek; the router sits on the +x side starting at x = clr.
module cheek() {
    profile = [[0, 0], [rail_y - 4, 0], [rail_y - 4, -rail_h - 2], [yf + t, -rail_h - 2], [yf + t, zb - t], [0, zb - t]];
    translate([-t, 0, 0]) rotate([90, 0, 90]) linear_extrude(t) polygon(profile);   // plate in YZ
    translate([0, yb - 3, zb - t]) cube([ledge, yf + t - yb + 3, t]);                // ledge
    translate([0, yb - 3, zb]) cube([ledge, 3, 4]);                                  // back stop
    translate([0, yf + 1, zb]) cube([ledge, t - 1, 2]);                              // front bump, lift 2 mm to slide out
    difference() {                                                                   // flange, screwed up into the top
        translate([0, 0, -t]) cube([flange_w, rail_y - 4, t]);
        for (y = screws_y) translate([flange_w / 2, y, -t - 0.01]) {
            cylinder(d = 3.8, h = t + 1, $fn = 24);
            cylinder(d1 = 7.5, d2 = 3.8, h = 2, $fn = 24);                         // countersink
        }
    }
}

module pair() { cheek(); translate([r.x + 2 * clr, 0, 0]) mirror([1, 0, 0]) cheek(); }
module router_ghost() color("WhiteSmoke", 0.6) translate([clr, yb, zt - r.z]) cube(r);

module flat() translate([0, 0, t]) rotate([0, -90, 0]) cheek();   // plate on the bed

if (part == "pair") { color("SlateBlue") pair(); router_ghost(); }
if (part == "left") flat();
if (part == "right") mirror([0, 1, 0]) flat();
