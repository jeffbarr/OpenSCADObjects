// flexi_arcs.scad:
//
//	Concentric rings, sliced into arcs, on optional base, with optional corners.
//
// TODO:
// - Option to split corners at 90, 180, 270
// - Option to color like a checkerboard
// - Generalize to use polygons instead of circles
// - Recursive pattern on corners
//
// - Cornered ring:
//   Add patterns for center, or recursive

/* [Ring] */

// Radius of central circle
_CenterRadius = 30;

// Ring count
_RingCount = 12;

// Ring width
_RingWidth = 20;

// Ring height
_Height = 1.0;			// [0.2 : 0.1 : 10]

// Inner step degrees
_InnerStepDegrees = 15;	// [0 : 0.5 : 90]

// Outer step degrees
_OuterStepDegrees = 30;	// [0 : 0.5 : 90]

// Inner to outer step transition ring
_InnerToOuter = 4;

// Arc inset
_ArcInset = 0.4;		// [0.2 : 0.1 : 10]

// Ring style
_RingStyle = "Centered";		// ["Centered", "Cornered"]

/* [Base] */

// Render base
_RenderBase = true;

// Base height
_BaseHeight = 0.2;		// [0.2 : 0.1 : 10]

// Base outset
_BaseOutset = 1.0;

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

/* [Corners] */

// Render corners
_RenderCorners = false;

// Corner outset
_CornerOutset = 1.0;

/* [Extruders] */

// Extruder color mode
_ColorMode = "Random";	// ["Random", "Rings", "Rays"]

// first extruder
_FirstExtruder = 1;

// Last extruder
_LastExtruder = 4;

// Base extruder
_BaseExtruder = 5;

// Center extruder
_CenterExtruder = 1;

// Corner extruder
_CornerExtruder = 5;

// Rim extruder
_RimExtruder = 5;

// Random seed
_RandomSeed = 1313;

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

module RenderArc2D(ArcInset, InnerRadius, OuterRadius, StartAngle, ArcAngle)
{
	if (InnerRadius > ArcInset)
	{
		rotate(StartAngle)
		{
			offset(delta=-ArcInset)
			{
				projection()
				{
					rotate_extrude(angle=ArcAngle, $fn=99)
					{
						difference()
						{
							square([OuterRadius, 30], center=false);
							square([InnerRadius, 30], center=false);
						}
					}
				}
			}
		}
	}
}

module RenderArc(InnerRadius, OuterRadius, StartAngle, ArcAngle, ArcInset, Height, RenderRim, RimCount, RimSpacing, RimHeight, RimThickness, ArcExtruder, RimExtruder)
{
	// Render basic arc
	Extruder(ArcExtruder)
	{
		linear_extrude(Height)
		{
			RenderArc2D(ArcInset, InnerRadius, OuterRadius, StartAngle, ArcAngle);
		}
	}
	
	// Render optional rim
	if (RenderRim)
	{
		Extruder(RimExtruder)
		{
			translate([0, 0, Height])
			{
				linear_extrude(RimHeight)
				{
					for (r = [0 : RimCount - 1])
					{
						RS = -(r * RimSpacing);
						RT = -RimThickness + RS;

						difference()
						{
							offset(delta=RS)
							{
								RenderArc2D(ArcInset, InnerRadius, OuterRadius, StartAngle, ArcAngle);
							}

							offset(delta=RT)
							{
								RenderArc2D(ArcInset, InnerRadius, OuterRadius, StartAngle, ArcAngle);
							}
						}
					}
				}
			}
		}
	}
}

// Render center - Four arcs
module RenderCenter(Radius, ArcInset, Height, RenderRim, RimCount, RimSpacing, RimHeight, RimThickness, CenterExtruder, RimExtruder)
{
	for (Start = [0 : 90 : 360])
	{
		RenderArc(1, Radius, Start, 90, ArcInset, Height, RenderRim, RimCount, RimSpacing, RimHeight, RimThickness, CenterExtruder, RimExtruder);
	}
}

function PickArcExtruder(ColorMode, Ring, Arc, FirstExtruder, LastExtruder) =
	(ColorMode == "Random") ? floor(rands(0, 1, 1)[0] * (LastExtruder - FirstExtruder + 1)) + FirstExtruder :
	(ColorMode == "Rings")  ? Ring % (LastExtruder - FirstExtruder + 1) + FirstExtruder                     :
	(ColorMode == "Rays")   ? Arc % (LastExtruder - FirstExtruder + 1) + FirstExtruder                      :
	                          0;

// Render one set of rings
module RenderRing(Ring, InnerRadius, OuterRadius, AngleStep, ArcInset, Height, RenderRim, RimCount, RimSpacing, RimHeight, RimThickness, ColorMode, FirstExtruder, LastExtruder, RimExtruder)
{
	for (Arc = [ 0 : 360 / AngleStep - 1])
	{
		StartAngle = Arc * AngleStep;
		ArcExtruder = PickArcExtruder(ColorMode, Ring, Arc, FirstExtruder, LastExtruder);
		
		RenderArc(InnerRadius, OuterRadius, StartAngle, AngleStep, ArcInset, Height, RenderRim, RimCount, RimSpacing, RimHeight, RimThickness, ArcExtruder, RimExtruder);
	}
}

// Render all of the rings
module RenderRings(CenterRadius, RingCount, RingWidth, ArcInset, Height, InnerToOuter, OuterStepDegrees, InnerStepDegrees, RenderRim, RimCount, RimSpacing, RimHeight, RimThickness, ColorMode, FirstExtruder, LastExtruder, RimExtruder)
{
	for (Ring = [0 : RingCount - 1])
	{
		InnerRadius = CenterRadius + (RingWidth * Ring);
		AngleStep = (Ring >= InnerToOuter) ? OuterStepDegrees : InnerStepDegrees;

		RenderRing(Ring, InnerRadius, InnerRadius + RingWidth, AngleStep, ArcInset, Height, RenderRim, RimCount, RimSpacing, RimHeight, RimThickness, ColorMode, FirstExtruder, LastExtruder, RimExtruder);
	}
}

// Render 2D corner
module RenderCorner2D(Diameter, CornerOutset, ArcInset)
{
	difference()
	{
		square(Diameter + 2 * CornerOutset, center=true);
		circle(d=Diameter + ArcInset, $fn=99);
	}
}

// Render the corners
module RenderCorners(Diameter, CornerOutset, ArcInset, Height, RenderRim, RimCount, RimSpacing, RimHeight, RimThickness, CornerExtruder, RimExtruder)
{
	Extruder(CornerExtruder)
	{
		linear_extrude(Height)
		{
			RenderCorner2D(Diameter, CornerOutset, ArcInset);
		}
	}
	
	// Render optional rim
	if (RenderRim)
	{
		Extruder(RimExtruder)
		{
			translate([0, 0, Height])
			{
				linear_extrude(RimHeight)
				{
					for (r = [0 : RimCount - 1])
					{
						RS = -(r * RimSpacing);
						RT = -RimThickness + RS;

						difference()
						{
							offset(delta=RS)
							{
								RenderCorner2D(Diameter, CornerOutset, ArcInset);
							}

							offset(delta=RT)
							{
								RenderCorner2D(Diameter, CornerOutset, ArcInset);
							}
						}
					}
				}
			}
		}
	}
}

// Render the base, round or square
module RenderBase(BaseDiameter, BaseHeight, RenderCorners, CornerOutset, BaseExtruder)
{
	translate([0, 0, -BaseHeight])
	{
		linear_extrude(BaseHeight)
		{
			Extruder(BaseExtruder)
			{
				if (RenderCorners)
				{
					square(BaseDiameter + 2 * CornerOutset, center=true);
				}
				else
				{
					circle(d=BaseDiameter, $fn=99);
				}
			}
		}
	}
}

module main(CenterRadius, RingCount, RingWidth, ArcInset, Height, InnerToOuter, OuterStepDegrees, InnerStepDegrees, RenderBase, BaseHeight, BaseOutset, RenderRim, RimCount, RimSpacing, RimHeight, RimThickness, RenderCorners, CornerOutset, Extruders)
{
	/* Seed the Random number generator */
	X = rands(0, 100, 1, _RandomSeed);

	// Compute sizes
	Diameter = 2 * (CenterRadius + RingCount * RingWidth);
	BaseDiameter = Diameter + BaseOutset;

	// Get extruders
	RimExtruder    = Extruders.RimExtruder;
	BaseExtruder   = Extruders.BaseExtruder;
	CenterExtruder = Extruders.CenterExtruder;
	ColorMode      = Extruders.ColorMode;
	FirstExtruder  = Extruders.FirstExtruder;
	LastExtruder   = Extruders.LastExtruder;
	CornerExtruder = Extruders.CornerExtruder;
	
	if (CenterRadius > 0)
	{
		RenderCenter(CenterRadius, ArcInset, Height, RenderRim, RimCount, RimSpacing, RimHeight, RimThickness, CenterExtruder, RimExtruder);
	}
	
	RenderRings(CenterRadius, RingCount, RingWidth, ArcInset, Height, InnerToOuter, OuterStepDegrees, InnerStepDegrees, RenderRim, RimCount, RimSpacing, RimHeight, RimThickness, ColorMode, FirstExtruder, LastExtruder, RimExtruder);
	
	if (RenderCorners)
	{
		RenderCorners(Diameter, CornerOutset, ArcInset, Height, RenderRim, RimCount, RimSpacing, RimHeight, RimThickness, CornerExtruder, RimExtruder);
	}

	if (RenderBase)
	{
		RenderBase(BaseDiameter, BaseHeight, RenderCorners, CornerOutset, BaseExtruder);
	}
	
	echo("BaseDiameter=", BaseDiameter);
}

_Extruders = object
			(
				ColorMode      = _ColorMode,
				FirstExtruder  = _FirstExtruder,
				LastExtruder   = _LastExtruder,
				CenterExtruder = _CenterExtruder,
				BaseExtruder   = _BaseExtruder,
				RimExtruder    = _RimExtruder,
				CornerExtruder = _CornerExtruder
			);

// Render ring centered
if (_RingStyle == "Centered")
{
	// Centered ring
	main(_CenterRadius, _RingCount, _RingWidth, _ArcInset, _Height, _InnerToOuter, _OuterStepDegrees, _InnerStepDegrees, _RenderBase, _BaseHeight, _BaseOutset, _RenderRim, _RimCount, _RimSpacing, _RimHeight, _RimThickness, _RenderCorners, _CornerOutset, _Extruders);
}

// Render ring broken into 4 quadrants, mapped to corners
if (_RingStyle == "Cornered")
{
	// Compute sizes
	Diameter = 2 * (_CenterRadius + _RingCount * _RingWidth);
	BaseDiameter = Diameter + _BaseOutset;
	BaseRadius = BaseDiameter / 2;

	//
	// Set up translations to render quadrants in corners:
	//
	//	[0]	- Q1 in Q3
	//	[1] - Q3 in Q1
	//	[2] - Q4 in Q2
	//	[3] - Q4 in Q2
	//
	
	MainTranslation =
	[
		[-BaseRadius, 	-BaseRadius],
		[BaseRadius, 	 BaseRadius],
		[-BaseRadius, 	 BaseRadius],
		[BaseRadius, 	-BaseRadius]
	];
	
	CubeTranslation =
	[
		[-BaseRadius, 	-BaseRadius],
		[0,				 0],
		[-BaseRadius, 	 0],
		[0, 			-BaseRadius]
	];
	
	for (Q = [0 : 3])
	{
		intersection()
		{
			translate([MainTranslation[Q][0], MainTranslation[Q][1], 0])
			{
				main(_CenterRadius, _RingCount, _RingWidth, _ArcInset, _Height, _InnerToOuter, _OuterStepDegrees, _InnerStepDegrees, _RenderBase, _BaseHeight, _BaseOutset, _RenderRim, _RimCount, _RimSpacing, _RimHeight, _RimThickness, _RenderCorners, _CornerOutset, _Extruders);
			}
			
			translate([CubeTranslation[Q][0], CubeTranslation[Q][1], -_BaseHeight])
			{
				cube([BaseRadius, BaseRadius, 99], center=false);
			}
		}
	}
}

// DEBUGGING
//RenderArc(30, 60, 0, 90, _Height, _RenderRim, _RimCount, _RimSpacing, _RimHeight, _RimThickness);
