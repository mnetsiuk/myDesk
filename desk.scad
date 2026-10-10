// Library: include <desk.scad>. IKEA Bekant 1600x800, from STEP (SolidWorks). Units: mm, Z up, origin = floor under desk centre.
// X = length (1600), Y = depth (800). Front/back are symmetric in the model.

top_z    = 764;   // tabletop underside
top_t    = 16;
frame_h  = 30;    // steel frame hangs 734..764
// Frame rails (Y ranges, all span X -730..730): outer 200..230, inner 35..65, mirrored.
// Free bays under the top between rails: Y 65..200 (135 mm) and Y -35..35 (70 mm), mirrored.

module desk(show_top = true) {   // white Bekant
    if (show_top) color("#f4f4f2") import("desk/top.stl");
    color("#e4e4e1") import("desk/frame.stl");
    color("#ebebe8") import("desk/legs.stl");
}
