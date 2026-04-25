/* 
 * Hexagons in an offset grid with a frame.
 *
 * TODO:
 * - Add options to choose extruder (random, cyclic)
 * - Compute frame size and position
 * - Add fancy top patterns for hexagons
 * - Add optional inset edge (and extruder) for hexagons
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
_Frame = false;

// Frame outer width
_FrameOuterWidth = 250;

// Frame outer depth
_FrameOuterDepth = 150;

// Frame border
_FrameBorder = 7;

// Frame height
_FrameHeight = 1.2;

/* [Extruders] */

// Extruder mode
//_ExtruderMode = "Random";	// ["Random"]

// first extruder
_FirstExtruder = 1;

// Last extruder
_LastExtruder = 4;

// Frame extruder
_FrameExtruder = 1;

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

module RenderHexagonGrid(RowCount, ColCount, HexRadius, HexHeight, HexExtruders, RowGap, ColGap, FrameBorder)
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
				}
			}
			
			/* Odd Row */
			for (x = [1 : 2 : ColCount - 1])
			{
				Extruder = HexExtruders[x][y];

				translate([x * ColGap, ((y + 1) * RowGap), 0]) 
				{
					RenderHexagon(HexRadius, HexHeight, Extruder);
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

module main(RowCount, ColCount, HexRadius, HexHeight, RowGap, ColGap, Frame, FrameOuterWidth, FrameOuterDepth, FrameBorder, FrameHeight, FrameExtruder)
{
	XR = rands(0, 1, RowCount * ColCount, _RandomSeed);
	echo(XR);
	
	HexExtruders = 
	[
		for (c = [0 : ColCount - 1])
		[
			for (r = [0 : RowCount - 1]) 
				floor(XR[r * ColCount + c] * (_LastExtruder - _FirstExtruder + 1)) + _FirstExtruder
		]
	];
	
	echo(HexExtruders);
	
	RenderHexagonGrid(RowCount, ColCount, HexRadius, HexHeight, HexExtruders, RowGap, ColGap, FrameBorder);
	
	if (_Frame)
	{
		RenderFrame(FrameOuterWidth, FrameOuterDepth, FrameBorder, FrameHeight, FrameExtruder, HexHeight);
	}
}
	
main(_RowCount, _ColCount, _HexRadius, _HexHeight, _RowGap, _ColGap, _Frame, _FrameOuterWidth, _FrameOuterDepth, _FrameBorder, _FrameHeight, _FrameExtruder);
