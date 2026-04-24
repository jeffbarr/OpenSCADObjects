/* 
 * Hexagons in an offset grid with a frame.
 *
 * TODO:
 * - Add multi-extruder 
 * - Add options to choose extruder (random, cyclic)
 * - Compute frame size and position
 * - Add fancy top patterns for hexagons
 * - Render hexagon in a module
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

module RenderHexagons(RowCount, ColCount, HexRadius, HexHeight, Gap, FrameBorder)
{
	translate([FrameBorder + FrameBorder + FrameBorder + 2, FrameBorder + FrameBorder + FrameBorder + 2, 0])
	{
		for (y = [0 : 2 : RowCount / 2])
		{
			/* Even Row */
			for (x = [0 : 2 : ColCount])
			{ 
				linear_extrude(height=HexHeight)
				{
					translate([x * HexRadius, (y * Gap), 0])
					{
						rotate([0, 0, 90])
						{
							circle(HexRadius, $fn=6);
						}
					}
				}
			}
			
			/* Odd Row */
			for (x =[1 : 2 : ColCount])
			{
				linear_extrude(height=HexHeight)
				{
					translate([x * HexRadius, ((y + 1) * Gap), 0]) 
					{
						rotate([0, 0, 90])
						{
							circle(HexRadius, $fn=6);
						}
					}
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
	RenderHexagons(RowCount, ColCount, HexRadius, HexHeight, Gap, FrameBorder);
	
	if (_Frame)
	{
		RenderFrame(FrameOuterWidth, FrameOuterDepth, FrameBorder, HexHeight);
	}
}
	
main(_RowCount, _ColCount, _HexRadius, _HexHeight, _Gap, _Frame, _FrameOuterWidth, _FrameOuterDepth, _FrameBorder);
