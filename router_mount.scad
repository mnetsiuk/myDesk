// PYUR router hanger, option A: router lies flat UNDER the back frame rail, ports facing the wall.
// Two side cheeks screwed into the tabletop underside; the router slides in from the front onto their ledges.
// Local coords: y = depth from desk back edge, z = 0 at tabletop underside (down is negative), x across the router.
// Export: openscad -D 'part="left"' -o cheek_left.stl router_mount.scad   (and "right"); printed flat, no supports.

part = "pair";             // pair | left | right

r        = [230, 190, 50]; // router W x D x H lying flat, W includes the stand
stand    = [10, 75.5];     // fixed full-depth stand at the LEFT end: thickness along W (only drawn), height lying flat
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
zt = -rail_h - gap;                         // stand top: the highest point of the router
zbt = zt - (stand.y - r.z) / 2;             // body top
zl = zt - stand.y - clr;                    // left ledge, under the stand
zr = zbt - r.z - clr;                       // right ledge, under the body

assert(zt < -rail_h, "router must clear the rail");
assert(screws_y[len(screws_y) - 1] + 4 < rail_y, "flange screws must stay behind the rail");
assert(yf + t <= 360, "cheek longer than the Prusa XL bed");

module window(a, b, r = 5) translate(a) offset(r = r) offset(delta = -r) square(b - a);

// Left cheek; the router sits on the +x side starting at x = clr.
module cheek(zb) {
    profile = [[0, 0], [rail_y - 4, 0], [rail_y - 4, -rail_h - 2], [yf + t, -rail_h - 2], [yf + t, zb - t], [0, zb - t]];
    translate([-t, 0, 0]) rotate([90, 0, 90]) linear_extrude(t) difference() {      // plate in YZ, rounded corners
        offset(r = 3) offset(delta = -3) offset(r = -3) offset(delta = 3) polygon(profile);
        window([10, zb + 4], [yb - 8, -14]);                                       // cables pass behind the router
        window([yb + 12, zb + 8], [rail_y - 16, -16]);                             // lightening
        window([rail_y + 8, zb + 8], [yf - 12, -rail_h - 10]);
    }
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

module pair() { cheek(zl); translate([r.x + 2 * clr, 0, 0]) mirror([1, 0, 0]) cheek(zr); }
module rbox(p, s, rr = 5) translate(p) hull() for (x = [rr, s.x - rr], y = [rr, s.y - rr], z = [rr, s.z - rr]) translate([x, y, z]) sphere(rr, $fn = 16);
module router_ghost() {                                                  // PYUR router, visual only
    x0 = clr + stand.x;
    color("#f5f5f3") rbox([x0, yb, zbt - r.z], [r.x - stand.x, r.y, r.z]);
    color("#cfd0d0") for (z = [zbt - r.z - 0.3, zbt - 0.7]) translate([x0 + 20, yb + 15, z]) cube([r.x - stand.x - 40, r.y - 30, 1]);  // grilles
    color("#e6e6e4") hull() { translate([clr, yb, zt - stand.y]) cube([2, r.y, stand.y]); translate([x0, yb, zbt - r.z]) cube([0.1, r.y, r.z]); }
    color("#5ad15a") for (i = [0:3]) translate([x0 + 60 + i * 40, yf - 0.5, zbt - r.z / 2]) rotate([-90, 0, 0]) cylinder(d = 3, h = 1, $fn = 12);
}

module flat(zb) translate([0, 0, t]) rotate([0, -90, 0]) cheek(zb);   // plate on the bed

if (part == "pair") { color("#7385e6") pair(); router_ghost(); }
if (part == "left") flat(zl);
if (part == "right") mirror([0, 1, 0]) flat(zr);
echo(router_bottom = zl, rail_clearance = -rail_h - zt);
