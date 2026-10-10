#!/bin/sh
# Regenerate printable parts into build/ (plan.scad imports the holders from there).
set -e
cd "$(dirname "$0")"
mkdir -p build
H=lib/QuackWorks/Underware/Underware_Item_Holder.scad

# Underware Item Holder on openGrid (Multiconnect back), two per item: one at each end, cord slot in the base.
# holder <name> <item width> <item thickness> <cup depth> <cord slot>
holder() {
    openscad -q -o build/holder_$1.stl -D 'Mounting_Surface="openGrid"' \
        -D Internal_Width=$2 -D Internal_Height=$3 -D Internal_Depth=$4 -D cordCutout=true -D cordCutoutDiameter=$5 $H
}
holder laptop     74.5 31   25 12   # 154 x 73.5 x 30
holder monitor    52.6 31   25 12   # 114.5 x 51.6 x 30
holder speaker    51   31   25 12   # ASSUMED 110 x 50 x 30, brick will be replaced
holder strip      71   61   25 12   # Brennenstuhl Eco-Line 350 x 70 x 60, cord end; measure when bought
holder coil       95   22   95 12   # pocket for the laptop DC hank (loops ~80 mm)

for p in left right; do openscad -q -o build/cheek_$p.stl -D "part=\"$p\"" router_mount.scad; done
