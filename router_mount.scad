// PYUR router hanger: router lies flat UNDER the back frame rail, ports facing the wall.
// Two side cheeks hang from the openGrid board on Multiconnect (one slot per grid row, slots along x, Item Holder's back module);
// the router slides in from the front onto their ledges.
// Mounting: snaps in the board, cheek pushed up 14 mm inward of its place (snaps enter the half on-ramps at its outer edge),
// slid 14 mm outward onto the stops. The router between the cheeks then stops them sliding back: they cannot come off.
// Local coords: y = depth from desk back edge, z = 0 at tabletop underside (down is negative), x across the router (0 = left cheek's inner face).
// Export: openscad -D 'part="left"' -o cheek_left.stl router_mount.scad   (and "right"); printed flat on the outer face, no supports.
include <BOSL2/std.scad>                                  // the Item Holder's back module draws with BOSL2
use <lib/QuackWorks/Underware/Underware_Item_Holder.scad> // multiconnectBack(): Multiconnect v2 slots with half-offset on-ramps

part = "pair";             // pair | left | right

r        = [230, 190, 50]; // router W x D x H lying flat, W includes the stand
stand    = [10, 75.5];     // fixed full-depth stand at the LEFT end: thickness along W (only drawn), height lying flat
rail_y   = 170;            // back rail front-to-back: 170..200 from the back edge
rail_h   = 30;
gap      = 4;              // router top below the rail
port_gap = 80;             // room for coax / LAN / power plugs between router back and desk edge: a straight F plug (~25) + RG6 bend (r ~35), RJ45 boot (~40) + bend
clr      = 1;              // height clearance
grid     = 28;             // openGrid
board    = 6.8;            // openGrid Full under the tabletop
rows     = 6;              // Multiconnect slots per cheek: one per grid row, y 1..169
cs       = 6;              // side room: 230 + 2 cs + 2 t = 9 cells, so both outer faces sit on cell edges; pads take it up to 1 mm
t        = 5;              // cheek plate thickness
ledge    = 15;             // how far the ledge reaches under the router

yb = port_gap;  yf = port_gap + r.y;
zt = -rail_h - gap;                         // stand top: the highest point of the router
zbt = zt - (stand.y - r.z) / 2;             // body top
zl = zt - stand.y - clr;                    // left ledge, under the stand
zr = zbt - r.z - clr;                       // right ledge, under the body

assert(zt < -rail_h, "router must clear the rail");
assert((r.x + 2 * cs + 2 * t) % grid == 0, "cheek outer faces must sit on cell edges (slot stop = cell centre)");
assert(1 + rows * grid < rail_y, "Multiconnect back must stay behind the rail");
assert(yf + t <= 360, "cheek longer than the Prusa XL bed");

module window(a, b, r = 5) translate(a) offset(r = r) offset(delta = -r) square(b - a);

// Left cheek; the router sits on the +x side starting at x = clr.
module cheek(zb) {
    top = -board - 3;                                                                // into the Multiconnect back
    profile = [[0, top], [rail_y - 4, top], [rail_y - 4, -rail_h - 2], [yf + t, -rail_h - 2], [yf + t, zb - t], [0, zb - t]];
    translate([-t, 0, 0]) rotate([90, 0, 90]) linear_extrude(t) difference() {      // plate in YZ, rounded corners
        offset(r = 3) offset(delta = -3) offset(r = -3) offset(delta = 3) polygon(profile);
        window([10, zb + 4], [yb - 8, -14]);                                       // cables pass behind the router
        window([yb + 12, zb + 8], [rail_y - 16, -16]);                             // lightening
        window([rail_y + 8, zb + 8], [yf - 12, -rail_h - 10]);
    }
    translate([0, yb - 3, zb - t]) cube([ledge, yf + t - yb + 3, t]);                // ledge
    translate([0, yb - 3, zb]) cube([ledge, 3, 4]);                                  // back stop
    translate([0, yf + 1, zb]) cube([ledge, t - 1, 2]);                              // front bump, lift 2 mm to slide out
    for (y = [yb + 20, yf - 40]) translate([0, y, zb]) cube([cs - 1, 20, 12]);     // side pads: router play 1 mm
    // Multiconnect back, mounting face up against the board: slot columns -> grid rows, slot axis -> x with the open end
    // (and its half on-ramp) at the outer face, stop at outer face + 14 = a cell centre.
    multmatrix([[0, 0, 1, -t], [-1, 0, 0, 1 + rows * grid], [0, -1, 0, -board - 6.5]])
        multiconnectBack(backWidth = rows * grid, backHeight = grid, distanceBetweenSlots = grid, slotStopFromBack = grid / 2);
}

module pair() { cheek(zl); translate([r.x + 2 * cs, 0, 0]) mirror([1, 0, 0]) cheek(zr); }
module rbox(p, s, rr = 5) translate(p) hull() for (x = [rr, s.x - rr], y = [rr, s.y - rr], z = [rr, s.z - rr]) translate([x, y, z]) sphere(rr, $fn = 16);
module router_ghost() {                                                  // PYUR router, visual only
    x0 = cs + stand.x;
    color("#f5f5f3") rbox([x0, yb, zbt - r.z], [r.x - stand.x, r.y, r.z]);
    color("#cfd0d0") for (z = [zbt - r.z - 0.3, zbt - 0.7]) translate([x0 + 20, yb + 15, z]) cube([r.x - stand.x - 40, r.y - 30, 1]);  // grilles
    color("#e6e6e4") hull() { translate([cs, yb, zt - stand.y]) cube([2, r.y, stand.y]); translate([x0, yb, zbt - r.z]) cube([0.1, r.y, r.z]); }
    color("#5ad15a") for (i = [0:3]) translate([x0 + 60 + i * 40, yf - 0.5, zbt - r.z / 2]) rotate([-90, 0, 0]) cylinder(d = 3, h = 1, $fn = 12);
}

module flat(zb) translate([0, 0, t]) rotate([0, -90, 0]) cheek(zb);   // plate on the bed

if (part == "pair") { color("#7385e6") pair(); router_ghost(); }
if (part == "left") flat(zl);
if (part == "right") mirror([0, 1, 0]) flat(zr);
echo(router_bottom = zl, rail_clearance = -rail_h - zt);
