$fn = $preview ? 24 : 96;
$fs = $preview ? 2  : 0.4;    // For BOSL2 continuous roundovers ($fa ignored)

// BOSL2 sweep controls
steps_pv  = $preview ? 6  : 24;
maxstep_pv= $preview ? 2  : 0.5; // horizontal step density
qual_pv   = $preview ? 0.8: 1.0;

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

// Number of OpenGrid slots to use in X direction
Slots_X = 2;
// Number of OpenGrid slots to use in Y direction
Slots_Y = 2;
// Height of the spool in mm
Spool_Height = 35;
// Offset from the edge of the base to the internal spool in mm in X direction. If set to 0 then auto-calculated based on the slot size and total X size.
Spool_Offset_X = 0;
// Offset from the edge of the base to the internal spool in mm in Y direction. If set to 0 then auto-calculated based on the slot size and total Y size.
Spool_Offset_Y = 0;
// Fillet radius of the spool connector. Set to 0 for auto calculation. If you don't want a fill set to 0.1. Don't exceed Spool Offset.
Spool_Fillet_Radius = 0;
// Bottom thickness of the spool in mm
Bottom_Thickness = 3;
// Rounding radius of the bottom. If set to 0 then equal to Spool Offset
Bottom_Rounding = 0;

/*[Multiconnect Options]*/
// Version of multiconnect (dimple or snap)
Multiconnect_Version = "v2"; // [v1, v2]
//Reduce the number of slots
Subtracted_Slots = 0;
//Offset the multiconnect on-ramps to be between grid slots rather than on the slot
onRampHalfOffset = true;
//QuickRelease removes the small indent in the top of the slots that lock the part into place
slotQuickRelease = false;
//Dimple scale tweaks the size of the dimple in the slot for printers that need a larger dimple to print correctly
dimpleScale = 1; //[0.5:.05:1.5]
//Scale the size of slots in the back (1.015 scale is default for a tight fit. Increase if your finding poor fit. )
slotTolerance = 1.00; //[0.925:0.005:1.075]
//Move the slot (Y axis) inwards (positive) or outwards (negative)
slotDepthMicroadjustment = 0; //[-.5:0.05:.5]
//Enable a slot on-ramp for easy mounting of tall items
onRampEnabled = true;
//Frequency of slots for on-ramp. 1 = every slot; 2 = every 2 slots; etc.
On_Ramp_Every_X_Slots = 1;
//Distance from the back of the item holder to where the multiconnect stops (i.e., where the dimple is) (by mm)
Multiconnect_Stop_Distance_From_Back = 13;
// Distance between slots on the back. Keep 28 for OpenGrid compatibility

/*[Advanced Options]*/
// Size of the OpenGrid slot in mm.
Slot_Size = 28;

/*[Hidden]*/

edgeRounding = 0.5; // [0:0.1:2]
//Change slot orientation, when enabled slots to come from the top of the back, when disabled slots come from the bottom
Slot_From_Top = false;
// XSize of the spool in mm. Don't set less than 28mm (OpenGrid size)
Spool_X_Size = Slots_X * Slot_Size;
// YSize of the spool in mm. Don't set less than 28mm (OpenGrid size)
Spool_Y_Size = Slots_Y * Slot_Size;
Internal_Spool_Offset_X = Spool_Offset_X > 0 ? Spool_Offset_X : min(Slot_Size / 2, Spool_X_Size / 4);
Internal_Spool_Offset_Y = Spool_Offset_Y > 0 ? Spool_Offset_Y : min(Slot_Size / 2, Spool_Y_Size / 4);
Internal_Spool_X_Size = Spool_X_Size - Internal_Spool_Offset_X * 2;
Internal_Spool_Y_Size = Spool_Y_Size * 2 - Internal_Spool_Offset_Y * 2;
Internal_Spool_Rounding = min(Internal_Spool_X_Size, Internal_Spool_Y_Size) / 2;
Spool_Fillet = Spool_Fillet_Radius ? Spool_Fillet_Radius : min(Internal_Spool_Offset_X - edgeRounding, Internal_Spool_Offset_Y - edgeRounding);
Real_Bottom_Rounding = Bottom_Rounding > 0 ? Bottom_Rounding : min(Internal_Spool_Offset_X, Internal_Spool_Offset_Y);

Backer_Negatives_Only = false;
Force_Back_Thickness = 0; // Set to 0 for auto thickness
//Offset the multiconnect on-ramps to be between grid slots rather than on the slot
onRampEveryXSlots = 
    onRampHalfOffset ? On_Ramp_Every_X_Slots : 
    On_Ramp_Every_X_Slots == 1 ? 2 : On_Ramp_Every_X_Slots;

Distance_Between_Slots = Slot_Size;

module multiconnectBack(backWidth, backHeight, distanceBetweenSlots, slotStopFromBack = 13) {
  //slot count calculates how many slots can fit on the back. Based on internal width for buffer. 
  //slot width needs to be at least the distance between slot for at least 1 slot to generate
  let (
    backWidth = max(backWidth, Distance_Between_Slots),
    backHeight = max(backHeight, 25),
    slotCount = floor(backWidth / Distance_Between_Slots) - Subtracted_Slots,
    backThickness = Force_Back_Thickness == 0 ? 6.5 : Force_Back_Thickness
  ) {
    diff() {
      tag(Backer_Negatives_Only ? "remove" : "")
        translate(v=[0, -backThickness, 0])
          cuboid(
            size=[backWidth, backThickness, backHeight],
            rounding=edgeRounding,
            // except_edges=BACK,
            anchor=FRONT + LEFT + BOT
          )
            children();
      //Loop through slots and center on the item
      //Note: I kept doing math until it looked right. It's possible this can be simplified.
      for (slotNum = [0:1:slotCount - 1]) {
        force_tag(Backer_Negatives_Only ? "keep" : "remove")
          translate(
            v=[Distance_Between_Slots / 2 + (backWidth / Distance_Between_Slots - slotCount) * Distance_Between_Slots / 2 + slotNum * distanceBetweenSlots,
            -2.35 + slotDepthMicroadjustment + (Force_Back_Thickness == 0 ? 0 : 6.5 - Force_Back_Thickness),
            backHeight - slotStopFromBack]
          ) {
            if (Backer_Negatives_Only)
              back_half(y=-4.15, s=backHeight * 2 + 20)
                slotTool(backHeight);
            else
              slotTool(backHeight);
          }
      }
    }
  }

  //Create Slot Tool
  module slotTool(totalDepth) {
    //In slotTool, added a new variable distanceOffset which is set by the option:
    distanceOffset = onRampHalfOffset ? Distance_Between_Slots / 2 : 0;

    scale(v=slotTolerance)
    //slot minus optional dimple with optional on-ramp
    let (slotProfile = [[0, 0], [10.15, 0], [10.15, 1.2121], [7.65, 3.712], [7.65, 5], [0, 5]])
    difference() {
      union() {
        //round top
        rotate(a=[90, 0, 0])
          rotate_extrude($fn=50)
            polygon(points=slotProfile);
        //long slot
        translate(v=[0, 0, 0])
          rotate(a=[180, 0, 0])
            union() {
              difference() {
                // Main half slot
                linear_extrude(height=totalDepth + 1)
                  polygon(points=slotProfile);

                // Snap cutout
                if (slotQuickRelease == false && Multiconnect_Version == "v2")
                  translate(v=[10.15, 0, 0])
                    rotate(a=[-90, 0, 0])
                      linear_extrude(height=5) // match slot height (5mm)
                        polygon(points=[[0, 0], [-0.4, 0], [0, -8]]);
                // triangle polygon with multiconnect v2 specs
              }

              mirror([1, 0, 0])
                difference() {
                  // Main half slot
                  linear_extrude(height=totalDepth + 1)
                    polygon(points=slotProfile);

                  // Snap cutout
                  if (slotQuickRelease == false && Multiconnect_Version == "v2")
                    translate(v=[10.15, 0, 0])
                      rotate(a=[-90, 0, 0])
                        linear_extrude(height=5) // match slot height (5mm)
                          polygon(points=[[0, 0], [-0.4, 0], [0, -8]]);
                  // triangle polygon with multiconnect v2 spec
                }
            }
        //on-ramp
        if (onRampEnabled)
          for (y = [1:onRampEveryXSlots:totalDepth / distanceBetweenSlots])
          //then modify the translate within the on-ramp code to include the offset
          translate(v=[0, -5, ( -y * distanceBetweenSlots) + distanceOffset])
            rotate(a=[-90, 0, 0])
              cylinder(h=5, r1=12, r2=10.15);
      }
      //dimple
      if (slotQuickRelease == false && Multiconnect_Version == "v1")
        scale(v=dimpleScale)
          rotate(a=[90, 0, 0])
            rotate_extrude($fn=50)
              polygon(points=[[0, 0], [0, 1.5], [1.5, 0]]);
    }
  }
}

module base() {
  rotate([0,Slot_From_Top ? 180 : 0,0])
    multiconnectBack(
      backWidth=Spool_X_Size,
      backHeight=Spool_Y_Size,
      distanceBetweenSlots=Distance_Between_Slots,
      slotStopFromBack=Multiconnect_Stop_Distance_From_Back
    )
      children();
}

module spool() {
  base()
    position(BACK + BOT)
      top_half(s = max(Spool_X_Size * 2, Spool_Y_Size) * 2 + 10)
        xrot(90) offset_sweep(
          rect(
            [Internal_Spool_X_Size, Internal_Spool_Y_Size],
            rounding=Internal_Spool_Rounding
          ),
          height=Spool_Height,
          anchor=TOP,
          check_valid=false,
          bottom=os_circle(r=-Spool_Fillet),
          top=os_circle(r=-Spool_Fillet)
        )
          position(BOT)
            offset_sweep(
              rect(
                [Spool_X_Size, Spool_Y_Size * 2],
                rounding=Real_Bottom_Rounding
              ),
              height=Bottom_Thickness,
              anchor=TOP,
              check_valid=false,
              bottom=os_circle(r=edgeRounding),
              top=os_circle(r=edgeRounding)
            );
}

spool();
