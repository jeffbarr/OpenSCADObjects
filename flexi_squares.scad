// flexi_squares.scad
//
// Nested squares divided into either eight Octants or sixteen Hexants
// with optional rim and base.
//
// TODO:
//	- Generalize naming - Octants should be sectors, rings should be tracks
//	- Add outset around base
//  - Add rim that is solid inset of shape

/* [Flexi Square] */

// Ant type
_AntType = "Octants";		// ["Octants", "Hexants"]

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

//
// OctantMatrix is used to rotate a triangle into the proper octant or hexant. 
// It is indexed directly for octants, and with index/2 for hexants.
//

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
// Render an octant:
//	(1 - 8)  for AntType == "Octants"
//	(1 - 16) for AntType == "Hexants" 
//

function IndexForOctantMatrix(AntType, Octant)= 
  (AntType == "Octants") ? Octant -1               :
  (AntType == "Hexants") ? floor((Octant - 1) / 2) :
			               99;
													
module RenderOctant2D(AntType, Octant, SideLength)
{
	// Points to define an octant in the first quadrant
	OctantPoints = 
	[
		[0,				 	0],
		[SideLength / 2,	0],
		[SideLength / 2, 	SideLength / 2]
	];

	// Points to define a hexant with an even index, in the first quadrant
	HexantPointsEven =
	[
		[0,					0],
		[SideLength / 2,	0],
		[SideLength / 2,	SideLength / 4]
	];
	
	// Points to define a hexant with an odd index, in the first quadrant
	HexantPointsOdd =
	[
		[0,					0],
		[SideLength / 2,	SideLength / 4],
		[SideLength / 2,	SideLength / 2]
	];

	// Get index for matrix
	Index = IndexForOctantMatrix(AntType, Octant);
			 
	// Choose points for polygon that defines octant
	Points = 
		(AntType == "Octants")                              ? OctantPoints     :
		(AntType == "Hexants" && (((Octant - 1) % 2) == 0)) ? HexantPointsEven :
		(AntType == "Hexants" && (((Octant - 1) % 2) != 0)) ? HexantPointsOdd  :
		                                                      99;
			
	translate([SideLength / 2, SideLength / 2, 0])
	{
		multmatrix(OctantMatrix[Index])
		{
			polygon(Points);
		}
	}
}

module RenderOctantSegment2D(AntType, Octant, Segment, SideLength, CenterLength, SegmentWidth, SegmentInset)
{
	offset(delta=-SegmentInset)
	{
		intersection()
		{
			RenderOctant2D(AntType, Octant, SideLength);
			
			translate([SideLength / 2, SideLength / 2, 0])
			{
				// Get index for matrix
				Index = IndexForOctantMatrix(AntType, Octant);

				multmatrix(OctantMatrix[Index])
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

// Render a segment (1-N) of an octant (1-8) or hexant (1-16)
module RenderOctantSegment(AntType, Octant, Segment, SideLength, CenterLength, SegmentWidth, SegmentHeight, SegmentInset, SegmentExtruder)
{
	Extruder(SegmentExtruder)
	{
		linear_extrude(SegmentHeight)
		{
			RenderOctantSegment2D(AntType, Octant, Segment, SideLength, CenterLength, SegmentWidth, SegmentInset);
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

module RenderOctantSegmentRim(AntType, Octant, Segment, SideLength, CenterLength, SegmentWidth, SegmentHeight, SegmentInset, RimHeight, RimThickness, RimCount, RimSpacing, RimExtruder)
{
	Extruder(RimExtruder)
	{
		translate([0, 0, SegmentHeight])
		{
			linear_extrude(RimHeight)
			{
				RenderChildAsRims(RimHeight, RimCount, RimSpacing, RimThickness)
				{
					RenderOctantSegment2D(AntType, Octant, Segment, SideLength, CenterLength, SegmentWidth, SegmentInset);
				}
			}
		}
	}
}

function ExtruderForOctantSegment(Oct, Seg, ColorMode, FirstExtruder, LastExtruder) =
(ColorMode == "Rays")  ? FirstExtruder + (Oct - 1) % (LastExtruder - FirstExtruder + 1) :
(ColorMode == "Rings") ? FirstExtruder + (Seg - 1) % (LastExtruder - FirstExtruder + 1) :
                         99;

module main(AntType, SideLength, CenterLength, RenderBase, BaseHeight, BaseExtruder, CenterExtruder, SegmentCount, SegmentWidth, SegmentHeight, SegmentInset, ColorMode, FirstSegmentExtruder, LastSegmentExtruder, RenderRim, RimHeight, RimThickness, RimCount, RimSpacing, RimExtruder)
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
	
	OctCount = (AntType == "Octants") ? 8  :
	           (AntType == "Hexants") ? 16 :
			                            99;
										
	// This map compensates for some self-inflicted strangeness in how the octant values map to positions
	HexantMap = 
	[
		0,
		1,   2,  4,  3,
		5,   6,  8,  7,
	    9,  10, 12, 11,
		13, 14, 16, 15
	];

	// Render segments
	// NB to fix, Oct/Octant is not the best prefix now that this also does Hexants
	for (Oct = [1 : 16])
	{
		for (Seg = [1 : SegmentCount])
		{
			MappedOct = (AntType == "Octants") ? Oct            :
			            (AntType == "Hexants") ? HexantMap[Oct] :
						                         99;

			SegmentExtruder = ExtruderForOctantSegment(MappedOct, Seg, ColorMode, FirstSegmentExtruder, LastSegmentExtruder);
			
			RenderOctantSegment(AntType, MappedOct, Seg, SideLength, CenterLength, SegmentWidth, SegmentHeight, SegmentInset, SegmentExtruder);
			
			if (RenderRim)
			{
				RenderOctantSegmentRim(AntType, MappedOct, Seg, SideLength, CenterLength, SegmentWidth, SegmentHeight, SegmentInset, RimHeight, RimThickness, RimCount, RimSpacing, RimExtruder);
			}
		}
	}
}

main(_AntType, _SideLength, _CenterLength, _RenderBase, _BaseHeight, _BaseExtruder, _CenterExtruder, _SegmentCount, _SegmentWidth, _SegmentHeight, _SegmentInset, _ColorMode, _FirstSegmentExtruder, _LastSegmentExtruder, _RenderRim, _RimHeight, _RimThickness, _RimCount, _RimSpacing, _RimExtruder);
