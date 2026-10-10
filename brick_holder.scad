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
        rotate([90, 0, 0]) mirror([0, 0, 1]) linear_extrude(w)                            // U + tabs, rounded profile in XZ
            offset(r = 1) offset(delta = -1) offset(r = -2) offset(delta = 2) union() {
                translate([-t, -ih - t]) square([iw + 2 * t, t]);                          // bottom
                for (x = [-t, iw]) translate([x, -ih - t]) square([t, ih + t]);            // walls
                for (x = [-t - tab, iw + t]) translate([x, -t]) square([tab, t]);          // tabs
            }
        for (x = [-t - tab / 2, iw + t + tab / 2]) translate([x, w / 2, -t - 0.01]) {
            cylinder(d = 3.8, h = t + 1, $fn = 24);
            cylinder(d1 = 7.5, d2 = 3.8, h = 2, $fn = 24);
        }
    }
}

function brick(name) = [for (b = bricks) if (b[0] == name) b[1]][0];

if (part != "none") for (i = [0, 1]) translate([0, i * (brick(part).z + 10), w]) rotate([-90, 0, 0]) strap(brick(part));
