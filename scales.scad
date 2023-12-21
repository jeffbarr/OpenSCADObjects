// Overlapping scales

// X count
_CountX = 10;

// Y count
_CountY = 10;

// X space
_SpaceX = 33;

// Y Space
_SpaceY = 12;

// Alternate spacing on even and odd rows
_EvenOddLayout = true;

// Scale style
_ScaleStyle = "Ring"; // ["Ring", "???"]

/* [Ring-Style Scale] */

// Ring shape
_ScaleRingShape = "Circle"; // ["Circle", "Triangle", "Hexagon", "Octagon"]

// Inner radius of ring
_ScaleRingInnerRadius = 10;

// Outer radius of ring
_ScaleRingOuterRadius = 16;

// Ring thickness
_ScaleRingThickness = 4;			// 0.20

// Ring base depth
_ScaleRingBaseDepth = 10;

// Ring vertical stretch
_ScaleRingVerticalStretch = 1.0;	// 0.10

// Ring tilt
_ScaleRingTilt = 45;

module _end_config() {}

// Full list of parameters
_Params =
[
	["CountX", 						_CountX],
	["CountY", 						_CountY],
	["SpaceX",						_SpaceX],
	["SpaceY", 						_SpaceY],
	["EvenOddLayout", 				_EvenOddLayout],
	["ScaleStyle",					_ScaleStyle],
	["ScaleRingShape",				_ScaleRingShape],
	["ScaleRingTilt",				_ScaleRingTilt],
	["ScaleRingInnerRadius",		_ScaleRingInnerRadius],
	["ScaleRingOuterRadius",		_ScaleRingOuterRadius],
	["ScaleRingBaseDepth",			_ScaleRingBaseDepth], 
	["ScaleRingThickness",			_ScaleRingThickness],
	["ScaleRingVerticalStretch",	_ScaleRingVerticalStretch]	
];

// Ring with base

module Ring(Shape, Tilt, InnerRadius, OuterRadius, RingBaseDepth, RingThickness, RingVerticalStretch)
{
	// Compute height of leading edge of ring
	EdgeHeight = RingThickness * sin(90 - Tilt);
	
	// Compute how far top of leading edge sticks out
	EdgeOut = RingThickness * cos(Tilt);
	
	// Map shape to number of sides and rotation
	Sides = 
		(Shape == "Circle")   ? 99 :
		(Shape == "Triangle") ? 4  :
	    (Shape == "Hexagon")  ? 6  :
	    (Shape == "Octagon")  ? 8  :
	                            0;

	if (Sides == 0)
	{
		echo("Ring: Unknown shape: ", Shape);
	}
		
	// Base
	translate([0, -EdgeOut, 0])
	{
		color("green") cube([2 * OuterRadius, RingBaseDepth, EdgeHeight]);
	}
	
	// Ring
	translate([0, EdgeOut, -EdgeHeight])
	{
		rotate([Tilt, 0, 0])
		{
			translate([OuterRadius, 0, RingThickness])
			{
				linear_extrude(RingThickness)
				{
					scale([1, RingVerticalStretch, 1])
					{
						difference()
						{
							// Matter - Ring
							difference()
							{
								circle(OuterRadius, $fn=Sides);
								circle(InnerRadius, $fn=Sides);
							}
							
							// Anti-matter - Minus-Y half
							translate([-OuterRadius, 2 * -OuterRadius, 0])
							{
								square(2 * OuterRadius, OuterRadius);
							}
						}
					}
				}
			}
		}
	}

}

module OneScaleRing(Shape, Tilt, InnerRadius, OuterRadius, RingBaseDepth, RingThickness, RingVerticalStretch)
{
	translate([0, RingThickness, 0])
	{
		Ring(Shape, Tilt, InnerRadius, OuterRadius, RingBaseDepth, RingThickness, RingVerticalStretch);
	}
}

module OneScale(ScaleStyle, Shape, Tilt, InnerRadius, OuterRadius, RingBaseDepth, RingThickness, RingVerticalStretch)
{
	if (ScaleStyle == "Ring")
	{
		OneScaleRing(Shape, Tilt, InnerRadius, OuterRadius, RingBaseDepth, RingThickness, RingVerticalStretch);
	}
}

module Panel(CountX, CountY, SpaceX, SpaceY, EvenOddLayout, ScaleStyle, Shape, Tilt, InnerRadius, OuterRadius, RingBaseDepth, RingThickness, RingVerticalStretch)
{
	// All the scales
	for (x = [0 : CountX - 1])
	{
		for (y = [0 : CountY - 1])
		{
			PointX = EvenOddLayout && ((y % 2) == 1) ? 
						(x * SpaceX) + (SpaceX / 2)  :
					    (x * SpaceX);
			
			PointY = y * SpaceY;
			
			translate([PointX, PointY, 0])
			{
				OneScale(ScaleStyle, Shape, Tilt, InnerRadius, OuterRadius, RingBaseDepth, RingThickness, RingVerticalStretch);
			}
		}
	}
}

// Generate a legend to capture all of the parameters
module Legend(Items)
{
	for (i = [0 : len(Items) - 1])
	{
		Item = Items[i];
		echo(Item[0], "=", Item[1]);
	}
}

module main()
{
	intersection()
	{
		Panel(_CountX, _CountY, _SpaceX, _SpaceY, _EvenOddLayout, _ScaleStyle, _ScaleRingShape,_ScaleRingTilt, _ScaleRingInnerRadius, _ScaleRingOuterRadius, _ScaleRingBaseDepth, _ScaleRingThickness, _ScaleRingVerticalStretch);
		
		cube([1000, 1000, 100]);
	}
	
	Legend(_Params);

}

main();
