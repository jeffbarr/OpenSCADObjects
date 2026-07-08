// flexi_squares.scad
//
// From 8 segments to 16?

/* [Flexi Square] */

// Center length
_CenterLength = 20;

/* [Segments] */

// Segment count
_SegmentCount = 6;

// Segment width
_SegmentWidth = 15;

// Segment height
_SegmentHeight = 0.4;	// [0.2 : 0.1 : 10]

// Segment inset
_SegmentInset = 0.1;

/* [Base] */

// Render base
_RenderBase = false;

// Base height
_BaseHeight = 0.2;		// [0.2 : 0.1 : 10]

/* [Rim] */

// Render rim
_RenderRim = true;

// Additional rim height
_RimHeight = 0.4;		// [0.2 : 0.1 : 10]

// Rim thickness
_RimThickness = 0.4;	// [0.2 : 0.1 : 10]

// Rim count
_RimCount = 3;

// Rim spacing
_RimSpacing = 1.0;		//[0.2 : 0.1 : 10]

/* [Extruders] */

// Extruder color mode
_ColorMode = "Rings";	// ["Rings", "Rays"]

// First segment extruder
_FirstSegmentExtruder = 1;

// Last segment extruder 
_LastSegmentExtruder = 4;

// Base extruder
_BaseExtruder = 5;

// Center extruder
_CenterExtruder = 5;

// Rim extruder
_RimExtruder = 5;

// [Extruder to render]
_WhichExtruder = "All"; // ["All", 1, 2, 3, 4, 5]

// Map a value of _WhichExtruder to an OpenSCAD color
function ExtruderColor(Extruder) = 
  (Extruder == 1  ) ? "red"    : 
  (Extruder == 2  ) ? "green"  : 
  (Extruder == 3  ) ? "blue"   : 
  (Extruder == 4  ) ? "pink"   :
  (Extruder == 5  ) ? "yellow" :
                      "purple" ;

module EndCustomization(){}

// OctantMatrix is used to rotate a triangle into the proper octant (1-8)
OctantMatrix =
[
	[	// 0 - Identity
		[1, 0, 0, 0],
		[0, 1, 0, 0],
		[0, 0, 1, 0]
	],

	[	// 1 - Reflect across X=Y
		[0, 1, 0, 0],
		[1, 0, 0, 0],
		[0, 0, 1, 0]
	],
	
	[	// 2 - Rotate 90 CCW
		[0, -1, 0, 0],
		[1,  0, 0, 0],
		[0,  0, 1, 0]
	],

	[	// 3 - Reflect across X=0
		[-1, 0, 0, 0],
		[0,  1, 0, 0],
		[0,  0, 1, 0]
	],
	
	[	// 4 - Rotate 180
		[-1, 0, 0, 0],
		[0, -1, 0, 0],
		[0,  0, 1, 0]
	],
	
	[	// 5 - Reflect across X=-Y
		[0, -1, 0, 0],
		[-1, 0, 0, 0],
		[0,  0, 1, 0]
	],
	
	[	// 6 - Rotate 270
		[0,  1, 0, 0],
		[-1, 0, 0, 0],
		[0,  0, 1, 0]
	],


	[	// 7 - Reflect across Y=0
		[1,  0, 0, 0],
		[0, -1, 0, 0],
		[0,  0, 1, 0]
	]
];

// Compute some values
_SideLength = _CenterLength + 2 * _SegmentCount * _SegmentWidth;

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

module RenderBase(SideLength, BaseHeight, BaseExtruder)
{
	Extruder(BaseExtruder)
	{
		linear_extrude(BaseHeight)
		{
			square(SideLength, center=false);
		}
	}
}

module RenderCenter2D(SideLength, CenterLength)
{
	if (CenterLength > 0)
	{
		translate([(SideLength - CenterLength) / 2, (SideLength - CenterLength) / 2, 10])
		{
			square(CenterLength, center=false);
		}
	}
}

module RenderCenter(SideLength, CenterLength, CenterHeight, CenterExtruder)
{
	Extruder(CenterExtruder)
	{
		linear_extrude(CenterHeight)
		{
			RenderCenter2D(SideLength, CenterLength);
		}
	}
}

// 
// Render an octant (1 - 8)
//

module RenderOctant2D(Octant, SideLength)
{
	translate([SideLength / 2, SideLength / 2, 0])
	{
		OctantPoints = 
		[
			[0,				 	0],
			[SideLength / 2,	0],
			[SideLength / 2, 	SideLength / 2]
		];
	
		multmatrix(OctantMatrix[Octant - 1])
		{
			polygon(OctantPoints);
		}
	}
}

module RenderOctantSegment2D(Octant, Segment, SideLength, CenterLength, SegmentWidth, SegmentInset)
{
	offset(delta=-SegmentInset)
	{
		intersection()
		{
			RenderOctant2D(Octant, SideLength);
			
			translate([SideLength / 2, SideLength / 2, 0])
			{
				multmatrix(OctantMatrix[Octant - 1])
				{
					translate([CenterLength / 2 + (Segment - 1) * SegmentWidth, 0, 0])
					{
						square([SegmentWidth, SideLength / 2], center=false);
					}
				}
			}
		}
	}
}

// Render a segment (1-N) of an octant (1-8)
module RenderOctantSegment(Octant, Segment, SideLength, CenterLength, SegmentWidth, SegmentHeight, SegmentInset, SegmentExtruder)
{
	Extruder(SegmentExtruder)
	{
		linear_extrude(SegmentHeight)
		{
			offset(delta=-SegmentInset)
			{
				RenderOctantSegment2D(Octant, Segment, SideLength, CenterLength, SegmentWidth, SegmentInset);
			}
		}
	}
}

// Render a set of rims that consist of the difference of the child and an inset of the child
module RenderChildAsRims(RimHeight, RimCount, RimSpacing, RimThickness)
{
	for (r = [0 : RimCount - 1])
	{
		RS = -(r * RimSpacing);
		RT = -RimThickness + RS;

		difference()
		{
			offset(delta=RS)
			{
				children();
			}

			offset(delta=RT)
			{
				children();
			}
		}
	}
}

module RenderOctantSegmentRim(Octant, Segment, SideLength, CenterLength, SegmentWidth, SegmentHeight, SegmentInset, RimHeight, RimThickness, RimCount, RimSpacing, RimExtruder)
{
	Extruder(RimExtruder)
	{
		translate([0, 0, SegmentHeight])
		{
			linear_extrude(RimHeight)
			{
				RenderChildAsRims(RimHeight, RimCount, RimSpacing, RimThickness)
				{
					RenderOctantSegment2D(Octant, Segment, SideLength, CenterLength, SegmentWidth, SegmentInset);
				}
			}
		}
	}
}

function ExtruderForOctantSegment(Oct, Seg, ColorMode, FirstExtruder, LastExtruder) =
(ColorMode == "Rays")  ? FirstExtruder + (Oct - 1) % (LastExtruder - FirstExtruder + 1) :
(ColorMode == "Rings") ? FirstExtruder + (Seg - 1) % (LastExtruder - FirstExtruder + 1) :
                         99;

module main(SideLength, CenterLength, RenderBase, BaseHeight, BaseExtruder, CenterExtruder, SegmentCount, SegmentWidth, SegmentHeight, SegmentInset, ColorMode, FirstSegmentExtruder, LastSegmentExtruder, RenderRim, RimHeight, RimThickness, RimCount, RimSpacing, RimExtruder)
{
	echo("SideLength=", _SideLength);
	
	// Render the base
	if (RenderBase)
	{
		translate([0, 0, -_BaseHeight])
		{
			RenderBase(SideLength, BaseHeight, BaseExtruder);
		}
	}
	
	if (CenterLength > 0)
	{
		// Render the center
		RenderCenter(SideLength, CenterLength, SegmentHeight, CenterExtruder);
		
		if (RenderRim)
		{
			Extruder(RimExtruder)
			{
				translate([0, 0, SegmentHeight])
				{
					RenderChildAsRims(RimHeight, RimCount, RimSpacing, RimThickness)
					{
						RenderCenter2D(SideLength, CenterLength - RimSpacing);
					}
				}
			}
		}
	}
	
	// Render segments
	for (Oct = [1 : 8])
	{
		for (Seg = [1 : SegmentCount])
		{
			SegmentExtruder = ExtruderForOctantSegment(Oct, Seg, ColorMode, FirstSegmentExtruder, LastSegmentExtruder);
			
			RenderOctantSegment(Oct, Seg, SideLength, CenterLength, SegmentWidth, SegmentHeight, SegmentInset, SegmentExtruder);
			
			if (RenderRim)
			{
				RenderOctantSegmentRim(Oct, Seg, SideLength, CenterLength, SegmentWidth, SegmentHeight, SegmentInset, RimHeight, RimThickness, RimCount, RimSpacing, RimExtruder);
			}
		}
	}
}

main(_SideLength, _CenterLength, _RenderBase, _BaseHeight, _BaseExtruder, _CenterExtruder, _SegmentCount, _SegmentWidth, _SegmentHeight, _SegmentInset, _ColorMode, _FirstSegmentExtruder, _LastSegmentExtruder, _RenderRim, _RimHeight, _RimThickness, _RimCount, _RimSpacing, _RimExtruder);
