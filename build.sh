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

# shir's cord spool (lib/spool-shir), one half 2x2 (his size for power cords), post 35 mm = his default; two halves face each other
openscad -q -o build/spool_2x2.stl -D Slots_X=2 -D Slots_Y=2 -D Spool_Height=35 lib/spool-shir/underware-cord-spool.scad

# openGrid Full boards (QuackWorks generator), screwed to the tabletop; seams joined with openGrid Connectors.
# board <name> <cells w> <cells d> <screw mode> -> screws on inner nodes every 3 columns x 3 rows (corners for tiny boards)
board() {
    openscad -q -o build/board_$1.stl -D 'Full_or_Lite="Full"' -D Board_Width=$2 -D Board_Height=$3 \
        -D "Screw_Mounting=\"$4\"" -D Screw_Every_X_Columns=3 -D Screw_Every_X_Rows=3 lib/QuackWorks/openGrid/openGrid.scad
}
board A  9 6 "By Row and Column"   # cells 0-8:   router
board B  7 6 "By Row and Column"   # cells 9-15:  speaker brick
board C  3 4 "Corners"             # cells 16-18, rows 2-5: in front of the clamp
board D1 12 6 "By Row and Column"  # cells 19-30: monitor, spool, laptop
board D2 12 6 "By Row and Column"  # cells 31-42: strip

for p in left right; do openscad -q -o build/cheek_$p.stl -D "part=\"$p\"" router_mount.scad; done
