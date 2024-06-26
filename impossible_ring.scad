//// Impossible (not really) Ring with lots of features and options.
//
// TODO:
//
// - Either top and bottom sizes, or array (to allow for in/out taper)
//
// - Magnet option chooser (add model numbers):
//   - Small
//	 - Medium
//   - Large
//   - Custom
// - Separator shape
//
// - Related way to create a "wall"
// - Related way to create rounded rectangle
//
// Some useful presets:
// * Ring that fits a soda can: 5, 45, 45, 10, 3, 22, 16
//
// * Small diametric magnet: 14.0, 3.5, 2.0, 0.8 -- for _RingInset = 12
// * Large diametric magnet: 14.0, 7.0, 2.0, 0.8 -- for _RingInset = 19
//
// The [Extruders] parameters work as follows:
//
//	* WhichExtruder controls on-screen and STL rendering. Set it to All while
//	  designing. To render STL, set it successively to 1, 2, 3, 4, and 5 then
//	  render (F6) and save (F7) to numbered files (perhaps append "_1", "_2",
//	  and so forth to the base names. 
//
//	* BaseExtruder sets the extruder for the round or semicircular base.
//
//	* RingExtruder sets the extruder for the rings.
//
//	* SeparatorExtruders sets the extruder(s) for the vertical separators 
//    between the rings.
//
//  * SeparatorExtruderMode sets the extruder selection mode:
//
//		Horizontal - Each row of the ring has a single extruder setting, cycling through
//	    the list of SeparatorExtruder values.
//
//		Vertical - Each column of separators has a single extruder setting, cycling
//	    through the list fo SeparatorExtruder values.
//
// BUGS:
//
// * Expanding rings (wider at top than bottom), the separators are one Z level too low. Tilt is 
//   miscalculated when the triangle is pointing out, perhaps subtract 180? This is currently
//   disabled via an assert.
//
// * The inner edge of tilted separators hangs out a bit to the inside of each ring, 
//   causing printing problems. Perhaps render the entire thing and subtract the space inside of 
//   each ring to clear it (except first one if there's a solid bottom). Or, flatten out the 
//   inside part of each separator.
//
// TO TEST / IMPLEMENT:
//
// * Full expanding rings
// * Partial expanding rings
// * Full contracting rings
// * Partial contracting rings
// * Vertical (same size top and bottom) rings
//

// Ring count
_LayerCount = 1;

// Bottom ring radius
_BottomRingRadius = 77;

// Top ring radius
_TopRingRadius = 47;

// Ring inset
_RingInset = 14;

// Ring thickness
_RingThickness = 3;

// Separator height
_SeparatorHeight = 30;

// Separator count
_SeparatorCount = 16;

/* [Options] */

// Solid base
_SolidBase = true;

// Partial ring
_PartialRing = false;

// Magnet slots
_MagnetSlots = false;

/* [Partial] */

// Starting degrees
_StartRing = 0;

// Ending degrees
_EndRing = 360;

/* [Magnets] */

// Magnet angles
_MagnetAngles = [0, 0, 0, 0];

// Slot height
_MagnetSlotHeight = 14.0;

// Slot width/depth
_MagnetWidthDepth = 7; // 3.5;

// Height above base of separator
_MagnetHeight = 2.0;

// Inset from mid-point of separator
_MagnetInset = 0.8;

/* [Extruders] */

// Extruder to render
_WhichExtruder = "All"; // ["All", 1, 2, 3, 4, 5]

// Base extruder
_BaseExtruder = 1; 			// [1, 2, 3, 4, 5]

// Ring extruder
_RingExtruder = 1;			// [1, 2, 3, 4, 5]

// Separator extruder mode
_SeparatorExtruderMode = "Horizontal";	// [Horizontal, Vertical]

// Separator extruder 1
_SeparatorExtruder1 = true;

// Separator extruder 2
_SeparatorExtruder2 = true;

// Separator extruder 3
_SeparatorExtruder3 = true;

// Separator extruder 4
_SeparatorExtruder4 = true;

// Separator extruder 5
_SeparatorExtruder5 = true;

// Sanity checks
assert(_SeparatorHeight > (_MagnetHeight + _MagnetSlotHeight), "Magnet too tall");
assert(_TopRingRadius <= _BottomRingRadius, "Expanding rings don't work");

// Create _SeparatorExtruders vector from individual values, then use it to create _SeparatorExtruders
_SeparatorExtrudersVec = [false, _SeparatorExtruder1, _SeparatorExtruder2, _SeparatorExtruder3, _SeparatorExtruder4, _SeparatorExtruder5];
_SeparatorExtruders    = [for (i = [0 : 5]) if (_SeparatorExtrudersVec[i]) i];

// Map row and column of separator into an extruder, based on _SeparatorExtruderMode
function PickSeparatorExtruder(Row, Col) =
 (_SeparatorExtruderMode == "Horizontal") ? _SeparatorExtruders[floor(Row % len(_SeparatorExtruders))] :
 (_SeparatorExtruderMode == "Vertical")   ? _SeparatorExtruders[floor(Col % len(_SeparatorExtruders))] : 
 -1;	// Illegal value for _SeparatorExtruderMode

// Map a value of _WhichExtruder to an OpenSCAD color
function ExtruderColor(Extruder) = 
  (Extruder == 1  ) ? "red"    : 
  (Extruder == 2  ) ? "green"  : 
  (Extruder == 3  ) ? "blue"   : 
  (Extruder == 4  ) ? "pink"   :
  (Extruder == 5  ) ? "yellow" :
                      "purple" ;
					  
// If _WhichExtruder is "All" or is not "All" and matches the requested extruder, render 
// the child nodes.

module Extruder(DoExtruder)
{
	color(ExtruderColor(DoExtruder))
	{
		if (_WhichExtruder == "All" || DoExtruder == _WhichExtruder)
		{
			children();
		}
	}
}

// Render a ring
module RenderRing(Radius, Inset, Thickness)
{
	linear_extrude(Thickness)
	{
		difference()
		{
			circle(r=Radius, $fn=99);
			
			if (Inset != 0)
			{
				circle(r=Radius - Inset, $fn=99);
			}
		}
	}
}

// Render a single separator
//	Height is the vertical spacing between rings
//	Length is the commputed length of the separator, taking tilt in to account
//
module RenderSeparator(Extruder, Radius, Height, Length)
{
	Extruder(Extruder)
	{
		linear_extrude(Length)
		{
			circle(r=Radius, $fn=99);
		}
	}
}

// Render a magnet hole centered horizontally within a separator of size SeparatorRadius
module RenderMagnetHole(SeparatorRadius, SlotHeight, WidthDepth, Height, Inset)
{
	translate([0, Inset + WidthDepth / 2, Height + SlotHeight / 2])
	{
		cube([WidthDepth, WidthDepth, SlotHeight], center=true);
	}
}

// Render a single separator with a magnet hole
module RenderSeparatorWithMagnetHole(Extruder, Radius, Height, MagnetSlotHeight, MagnetWidthDepth, MagnetHeight, MagnetInset)
{
	difference()
	{
		// Matter
		RenderSeparator(Extruder, Radius, Height);
		
		// Anti-matter
		RenderMagnetHole(Radius, MagnetSlotHeight, MagnetWidthDepth, MagnetHeight, MagnetInset);
	}
}

// Render entire ring of separators with optional magnet holes at the specified angles
module RenderSeparators(Row, Count, Radius, RingThickness, Inset, Height, Length, Tilt, MagnetSlots, MagnetAngles, MagnetSlotHeight, MagnetWidthDepth, MagnetHeight, MagnetInset)
{
	for (Col = [0 : Count - 1])
	{
		Theta  = Col * 360 / Count;
		PointX = cos(Theta) * (Radius - (Inset / 2));
		PointY = sin(Theta) * (Radius - (Inset / 2));
		
		Extruder = PickSeparatorExtruder(Row, Col);
		
		translate([PointX, PointY, -RingThickness])
		{
			MagnetHere = MagnetSlots && (len(search(Theta, MagnetAngles)) > 0);
					
			// Handle separators with and without magnets separately	
			if (MagnetHere)
			{
				echo("Need a magnet at ", Theta);
				
				// Does not work for 270, but 90 and 180 are the most important cases
				SeparatorRotate = (Theta == 90)  ? -90 : 
				                  (Theta == 180) ? 180 : 0;

				rotate([0, -Tilt, Theta])
				{
					rotate([0, 0, SeparatorRotate])
					{
						RenderSeparatorWithMagnetHole(Extruder, Inset / 2, Length, MagnetSlotHeight, MagnetWidthDepth, MagnetHeight, MagnetInset);
					}
				}
			}
			else
			{
				rotate([0, -Tilt, Theta])
				{
					RenderSeparator(Extruder, Inset / 2, Height, Length);
				}
			}
		}
	}
}

//
// Render entire ring of separators inside of a clipping box. 
// The box removes the parts of the separator that extend above or below the rings.
//
module RenderSeparatorsInBox(Row, Count, Radius, RingThickness, Inset, Height, Length, Tilt, MagnetSlots, MagnetAngles, MagnetSlotHeight, MagnetWidthDepth, MagnetHeight, MagnetInset)
{
	intersection()
	{
		// Separators
		RenderSeparators(Row, Count, Radius, RingThickness, Inset, Height, Length + RingThickness, Tilt, MagnetSlots, MagnetAngles, MagnetSlotHeight, MagnetWidthDepth, MagnetHeight, MagnetInset);
		
		// Box
		translate([-Radius, -Radius, 0])
		{
			cube([2 * Radius, 2 * Radius, Height], center=false);
		}
	}
		
}

// Render entire column of rings and separators, with optional magnet holes in separator, for the separators listed in MagnetAngles
module RenderColumn(BottomRingRadius, TopRingRadius, RingInset, SolidBase, LayerCount, RingThickness, SeparatorCount, SeparatorHeight, MagnetSlots, MagnetAngles, MagnetSlotHeight, MagnetWidthDepth, MagnetHeight, MagnetInset)
{
	// Render first ring
	Extruder(_BaseExtruder)
	{
		RenderRing(BottomRingRadius, (SolidBase ? 0 : RingInset), RingThickness);
	}
	
	// Do some math
	LayerHeight = RingThickness + SeparatorHeight;
	RingRadiusStep = (TopRingRadius - BottomRingRadius) / (LayerCount - 1);
	
	// Separators and subsequent ring
	for (Row = [1 : 1 : LayerCount - 1])
	{
		// Do some more math
		ThisRingRadius = BottomRingRadius + (Row * RingRadiusStep);
		LastRingRadius = ThisRingRadius - RingRadiusStep;
		
		SeparatorLength = sqrt(((ThisRingRadius - LastRingRadius) ^ 2) + (SeparatorHeight  ^ 2)) + RingThickness;
		SeparatorTilt   = 90 - atan((SeparatorHeight  + RingThickness) / (LastRingRadius - ThisRingRadius));
		
		echo("LastRingRadius=", LastRingRadius);
		echo("ThisRingRadius=", ThisRingRadius);
		echo("SeparatorLength=", SeparatorLength);
		echo("SeparatorTilt=", SeparatorTilt);
		
		translate([0, 0, (Row - 1) * LayerHeight])
		{
			translate([0, 0, RingThickness])
			{
				RenderSeparatorsInBox(Row, SeparatorCount, ThisRingRadius - RingRadiusStep, RingThickness, RingInset, SeparatorHeight, SeparatorLength, SeparatorTilt, MagnetSlots, MagnetAngles, MagnetSlotHeight, MagnetWidthDepth, MagnetHeight, MagnetInset);
			}
			
			translate([0, 0, RingThickness + SeparatorHeight])
			{
				Extruder(_RingExtruder)
				{
					RenderRing(ThisRingRadius, RingInset, RingThickness);
				}
			}
		}
	}
}

// Render a cheese wedge that keeps only the selected part of the column
// This is used as negative space and as such is slightly larger than necessary
module RenderCheese(BottomRadius, TopRadius, Height, StartRing, EndRing)
{
	Radius2 = 1.2 * max(BottomRadius, TopRadius); // Hack
	
	linear_extrude(Height)
	{
		Points = 
		[
			[0, 0], 
			for (Theta = [StartRing : $fa : EndRing - 1]) 
				[Radius2 * cos(Theta), Radius2 * sin(Theta)],
			[Radius2 * cos(EndRing), Radius2 * sin(EndRing)]
		];
		
		polygon(Points);
	}
}

module main()
{
	ColumnHeight = ((_LayerCount - 1) * _SeparatorHeight) + (_LayerCount * _RingThickness);
	echo("Column Height = ", ColumnHeight);

	// Compute center-to-center distance between two adjacent separators
	X1 = _BottomRingRadius * cos(0);
	Y1 = _BottomRingRadius * sin(0);
	X2 = _BottomRingRadius * cos(360 / _SeparatorCount);
	Y2 = _BottomRingRadius * sin(360 / _SeparatorCount);

	SeparatorDistance = sqrt((X2 - X1) ^ 2 + (Y2 - Y1) ^ 2);
	echo("SeparatorDistance = ", SeparatorDistance);
	
	if (_PartialRing)
	{
		intersection()
		{
			RenderColumn(_BottomRingRadius, _TopRingRadius, _RingInset, _SolidBase, _LayerCount, _RingThickness, _SeparatorCount,  _SeparatorHeight, _MagnetSlots, _MagnetAngles, _MagnetSlotHeight, _MagnetWidthDepth, _MagnetHeight, _MagnetInset);
			RenderCheese(_BottomRingRadius, _TopRingRadius, ColumnHeight, _StartRing, _EndRing);
		}
	}
	else
	{
		RenderColumn(_BottomRingRadius, _TopRingRadius, _RingInset, _SolidBase, _LayerCount, _RingThickness, _SeparatorCount,  _SeparatorHeight, false, [], 0, 0, 0, 0);
	}
}

main();
