/* 
 * Hexagons in an offset grid with a frame.
 *
 * TODO:
 * - Add options to choose extruder (random, cyclic)
 * - Add frame extruder
 * - Add separate height for frame
 * - Compute frame size and position
 * - Add fancy top patterns for hexagons
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

// Gap
_Gap = 19;

/* [Frame] */

// Render frame
_Frame = false;

// Frame outer width
_FrameOuterWidth = 250;

// Frame outer depth
_FrameOuterDepth = 150;

// Frame border
_FrameBorder = 7;

/* [Extruders] */

// Extruder mode
//_ExtruderMode = "Random";	// ["Random"]

// first extruder
_FirstExtruder = 1;

// Last extruder
_LastExtruder = 4;

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

module RenderHexagon(Radius, Height, Extruder)
{
	Extruder(Extruder)
	{
		linear_extrude(Height)
		{
			rotate([0, 0, 90])
			{
				circle(Radius, $fn=6);
			}
		}
	}
}

module RenderHexagonGrid(RowCount, ColCount, HexRadius, HexHeight, HexExtruders, Gap, FrameBorder)
{
	translate([FrameBorder + FrameBorder + FrameBorder + 2, FrameBorder + FrameBorder + FrameBorder + 2, 0])
	{
		for (y = [0 : 2 : RowCount / 2])
		{
			/* Even Row */
			for (x = [0 : 2 : ColCount - 1])
			{ 
				Extruder = HexExtruders[x][y];

				translate([x * HexRadius, (y * Gap), 0])
				{
					RenderHexagon(HexRadius, HexHeight, Extruder);
				}
			}
			
			/* Odd Row */
			for (x = [1 : 2 : ColCount - 1])
			{
				Extruder = HexExtruders[x][y];

				translate([x * HexRadius, ((y + 1) * Gap), 0]) 
				{
					RenderHexagon(HexRadius, HexHeight, Extruder);
				}
			}
		}
	}
}

module RenderFrame(FrameOuterWidth, FrameOuterDepth, FrameBorder, HexHeight)
{
	InnerWidth = FrameOuterWidth - (2 * FrameBorder);
	InnerDepth = FrameOuterDepth - (2 * FrameBorder);

	linear_extrude(height=_HexHeight) 
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

module main(RowCount, ColCount, HexRadius, HexHeight, Gap, Frame, FrameOuterWidth, FrameOuterDepth, FrameBorder)
{
	XR = rands(_FirstExtruder, _LastExtruder, RowCount * ColCount, _RandomSeed);
	echo(XR);
	
	HexExtruders = 
	[
		for (c = [0 : ColCount - 1])
		[
			for (r = [0 : RowCount - 1]) 
					round(XR[r * ColCount + c])
		]
	];
	
	echo(HexExtruders);
	
	RenderHexagonGrid(RowCount, ColCount, HexRadius, HexHeight, HexExtruders, Gap, FrameBorder);
	
	if (_Frame)
	{
		RenderFrame(FrameOuterWidth, FrameOuterDepth, FrameBorder, HexHeight);
	}
}
	
main(_RowCount, _ColCount, _HexRadius, _HexHeight, _Gap, _Frame, _FrameOuterWidth, _FrameOuterDepth, _FrameBorder);
