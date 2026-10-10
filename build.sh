#!/bin/sh
# Regenerate printable parts into build/ (plan.scad imports the holders from there).
set -e
cd "$(dirname "$0")"
mkdir -p build
H=lib/QuackWorks/Underware/Underware_Item_Holder.scad

# Underware Item Holder on openGrid (Multiconnect back): ClamShell_Mode pair, one cup per end, spaced so both snaps land on the grid.
# Cord slot through the end wall and the open underside, wide enough for the angled IEC plug body (largest face side + 1).
# holder <name> <item length> <item width + 1> <item thickness + 1> <cord slot> [slot shift towards the board]
holder() {
    openscad -q -o build/holder_$1.stl -D 'Mounting_Surface="openGrid"' -D ClamShell_Mode=true -D total_item_width=$2 \
        -D Internal_Width=$3 -D Internal_Height=$4 -D Internal_Depth=25 -D cordCutout=true -D cordCutoutDiameter=$5 \
        -D cordCutoutDepthOffset=-${6:-0} $H
}
holder laptop  154   74.5 31 28      # 154 x 73.5 x 30, C13 plug (21 x 27 ASSUMED)
holder monitor 114.5 52.6 31 28      # 114.5 x 51.6 x 30, C13 plug
holder speaker 110   51   31 22      # ASSUMED 110 x 50 x 30, brick will be replaced; C5 plug (16 x 21 ASSUMED)
holder strip   360   91   66 14 20   # Brennenstuhl Eco-Line datasheet 360 x 90 x 65; cord leaves the end face near the base (ASSUMED)

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
# D2 (cells 31-42, rows 1-5): the user already has a printed 12x5 board, nothing to print

for p in left right; do openscad -q -o build/cheek_$p.stl -D "part=\"$p\"" router_mount.scad; done
