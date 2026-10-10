// Strap for a power brick lying flat under the tabletop. Two straps per brick; the brick slides in lengthwise.
// Local: x across the brick, y along it, z = 0 at tabletop underside (down is negative).
// Export: openscad -D 'part="laptop"' -o straps_laptop.stl brick_holder.scad   -> 2 straps, profile flat on the bed.

part = "none";             // monitor | laptop | router | none
bricks = [["monitor", [114.5, 51.6, 30]], ["laptop", [154, 73.5, 30]], ["router", [80, 54, 33.3]]];  // L x W x H

t   = 3;                   // wall
w   = 15;                  // strap width along the brick
tab = 12;                  // screw tab, 3.5 x 12 mm countersunk wood screw
clr = 1;

module strap(b) {
    iw = b.y + 2 * clr;  ih = b.z + clr;
    difference() {
        union() {
            translate([-t, 0, -ih - t]) cube([iw + 2 * t, w, t]);                         // bottom
            for (x = [-t, iw]) translate([x, 0, -ih - t]) cube([t, w, ih + t]);           // walls
            for (x = [-t - tab, iw + t]) translate([x, 0, -t]) cube([tab, w, t]);         // tabs
        }
        for (x = [-t - tab / 2, iw + t + tab / 2]) translate([x, w / 2, -t - 0.01]) {
            cylinder(d = 3.8, h = t + 1, $fn = 24);
            cylinder(d1 = 7.5, d2 = 3.8, h = 2, $fn = 24);
        }
    }
}

function brick(name) = [for (b = bricks) if (b[0] == name) b[1]][0];

if (part != "none") for (i = [0, 1]) translate([0, i * (brick(part).z + 10), w]) rotate([-90, 0, 0]) strap(brick(part));
