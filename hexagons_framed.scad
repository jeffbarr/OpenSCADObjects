/* 
 * Hexagons in an offset grid with a frame.
 *
 * TODO:
 * - Add "computed" extruder mode
 * - Rename extruder mode to pattern
 * - Compute frame size and position
 * - Add more Rim parameters
 */

/* [Hexagons] */

// Hexagon radius
_HexRadius = 11.5; 

// Hexagon height
_HexHeight = 1.2;

/* [Grid] */

// Rows
_RowCount = 16;

// Columns
_ColCount = 18;

// Row gap
_RowGap = 19;

// Column gap
_ColGap = 19;

/* [Frame] */

// Render frame
_RenderFrame = false;

// Frame outer width
_FrameOuterWidth = 250;

// Frame outer depth
_FrameOuterDepth = 150;

// Frame border
_FrameBorder = 7;

// Frame height
_FrameHeight = 1.2;

/* [Rim] */

// Render rim
_RenderRim = true;

// Additional Rim Height
_RimHeight = 0.4;

// Rim Thickness
_RimThickness = 0.5;

/* [Extruders] */

// Extruder mode
_ExtruderMode = "Random";	// ["Random", "Stripes"]

// first extruder
_FirstExtruder = 1;

// Last extruder
_LastExtruder = 4;

// Frame extruder
_FrameExtruder = 1;

// Rim extruder
_RimExtruder = 5;

// [Extruder to render]
_WhichExtruder = "All"; // ["All", 1, 2, 3, 4, 5]

// Random seed
_RandomSeed = 1313;

// Map a value of _WhichExtruder to an OpenSCAD color
function ExtruderColor(Extruder) = 
  (Extruder == 1  ) ? "red"    : 
  (Extruder == 2  ) ? "green"  : 
  (Extruder == 3  ) ? "blue"   : 
  (Extruder == 4  ) ? "pink"   :
  (Extruder == 5  ) ? "yellow" :
                      "purple" ;
					  
// If _WhichExtruder is "All" or is not "All" and matches the 
// requested extruder, render the child nodes.

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

module RenderFlatHexagon(Radius)
{
	rotate([0, 0, 90])
	{
		circle(Radius, $fn=6);
	}
}

module RenderHexagon(Radius, Height, Extruder)
{
	Extruder(Extruder)
	{
		linear_extrude(Height)
		{
			RenderFlatHexagon(Radius);
		}
	}
}

module RenderRim(Radius, Height, Thickness, Extruder)
{
	Extruder(Extruder)
	{
		for (dd = [0 : 1.5 : 3])
		{
			linear_extrude(Height)
			{
				difference()
				{
					RenderFlatHexagon(Radius - dd);
					
					offset(delta=-Thickness)
					{
						RenderFlatHexagon(Radius-dd);
					}
				}
			}
		}
	}
}

module RenderHexagonGrid(RowCount, ColCount, HexRadius, HexHeight, HexExtruders, RowGap, ColGap, FrameBorder, Rim, RimHeight, RimThickness, RimExtruder)
{
	translate([FrameBorder + FrameBorder + FrameBorder + 2, FrameBorder + FrameBorder + FrameBorder + 2, 0])
	{
		for (y = [0 : 2 : RowCount / 2])
		{
			/* Even Row */
			for (x = [0 : 2 : ColCount - 1])
			{ 
				Extruder = HexExtruders[x][y];

				translate([x * ColGap, (y * RowGap), 0])
				{
					RenderHexagon(HexRadius, HexHeight, Extruder);
					
					if (Rim)
					{
						translate([0, 0, HexHeight])
						{
							RenderRim(HexRadius, RimHeight, RimThickness, RimExtruder);
						}
					}
				}
			}
			
			/* Odd Row */
			for (x = [1 : 2 : ColCount - 1])
			{
				Extruder = HexExtruders[x][y];

				translate([x * ColGap, ((y + 1) * RowGap), 0]) 
				{
					RenderHexagon(HexRadius, HexHeight, Extruder);
					
					if (Rim)
					{
						translate([0, 0, HexHeight])
						{
							RenderRim(HexRadius, RimHeight, RimThickness, RimExtruder);
						}
					}
				}
			}
		}
	}
}

module RenderFrame(FrameOuterWidth, FrameOuterDepth, FrameBorder, FrameHeight, FrameExtruder, HexHeight)
{
	InnerWidth = FrameOuterWidth - (2 * FrameBorder);
	InnerDepth = FrameOuterDepth - (2 * FrameBorder);

	Extruder(FrameExtruder)
	{
		linear_extrude(height=FrameHeight) 
		{
			difference () 
			{
				square([FrameOuterWidth, FrameOuterDepth]);
				translate([FrameBorder, FrameBorder, 0]) 
				{
					square([InnerWidth, InnerDepth]);
				}
			}
		}
	}
}

module main(RowCount, ColCount, HexRadius, HexHeight, RowGap, ColGap, RenderFrame, FrameOuterWidth, FrameOuterDepth, FrameBorder, FrameHeight, FirstExtruder, LastExtruder, FrameExtruder, ExtruderMode, RenderRim, RimHeight, RimThickness, RimExtruder)
{
	XR = rands(0, 1, RowCount * ColCount, _RandomSeed);
	echo(XR);
	
	ExtruderCount = LastExtruder - FirstExtruder + 1;

	HexRandomExtruders = 
	[
		for (c = [0 : ColCount - 1])
		[
			for (r = [0 : RowCount - 1]) 
				FirstExtruder + floor(XR[r * ColCount + c] * ExtruderCount)
		]
	];
	
	HexStripeExtruders = 
	[
		for (c = [0 : ColCount - 1])
		[
			for (r = [0 : RowCount - 1])
				FirstExtruder + floor((c / ColCount) * ExtruderCount)
		]
	];
	
	echo("Random Extruders:",   HexRandomExtruders);
	echo("");
	echo("Stripe Extruders:",   HexStripeExtruders);
	
	HexExtruders = (ExtruderMode == "Random")   ? HexRandomExtruders   :
	               (ExtruderMode == "Stripes")  ? HexStripeExtruders   :
				                                  0;
				   
	RenderHexagonGrid(RowCount, ColCount, HexRadius, HexHeight, HexExtruders, RowGap, ColGap, FrameBorder, RenderRim, RimHeight, RimThickness, RimExtruder);
	
	if (RenderFrame)
	{
		RenderFrame(FrameOuterWidth, FrameOuterDepth, FrameBorder, FrameHeight, FrameExtruder, HexHeight);
	}
}
	
main(_RowCount, _ColCount, _HexRadius, _HexHeight, _RowGap, _ColGap, _RenderFrame, _FrameOuterWidth, _FrameOuterDepth, _FrameBorder, _FrameHeight, _FirstExtruder, _LastExtruder, _FrameExtruder, _ExtruderMode, _RenderRim, _RimHeight, _RimThickness, _RimExtruder);
