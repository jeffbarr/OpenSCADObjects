// Overlapping scales

// X count
_CountX = 10;

// Y count
_CountY = 10;

// X space
_SpaceX = 33;

// Y Space
_SpaceY = 12;

// Inner radius of ring
_ScaleRingInnerRadius = 10;

// Outer radius of ring
_ScaleRingOuterRadius = 16;

// Ring thickness
_ScaleRingThickness = 4;

// Ring base depth
_ScaleRingBaseDepth = 10;

// Ring tilt
_ScaleRingTilt = 45;

// Alternate spacing on even and odd rows
_EvenOddLayout = true;

// Scale style
_ScaleStyle = "Ring"; // ["Ring", "???"]

// Ring with base

module Ring(Tilt, InnerRadius, OuterRadius, RingBaseDepth, RingThickness)
{
	// Compute height of leading edge of ring
	EdgeHeight = RingThickness * sin(90 - Tilt);
	
	// Compute how far top of leading edge sticks out
	EdgeOut = RingThickness * cos(Tilt);
	
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
					difference()
					{
						// Matter - Ring
						difference()
						{
							circle(OuterRadius);
							circle(InnerRadius);
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

module OneScaleRing(Tilt, InnerRadius, OuterRadius, RingBaseDepth, RingThickness)
{
	translate([0, RingThickness, 0])
	{
		Ring(Tilt, InnerRadius, OuterRadius, RingBaseDepth, RingThickness);
	}
}

module OneScale(ScaleStyle, Tilt, InnerRadius, OuterRadius, RingBaseDepth, RingThickness)
{
	if (ScaleStyle == "Ring")
	{
		OneScaleRing(Tilt, InnerRadius, OuterRadius, RingBaseDepth, RingThickness);
	}
}

module Panel(CountX, CountY, SpaceX, SpaceY, EvenOddLayout, ScaleStyle, Tilt, InnerRadius, OuterRadius, RingBaseDepth, RingThickness)
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
				OneScale(ScaleStyle, Tilt, InnerRadius, OuterRadius, RingBaseDepth, RingThickness);
			}
		}
	}
}

module main()
{
	intersection()
	{
		Panel(_CountX, _CountY, _SpaceX, _SpaceY, _EvenOddLayout, _ScaleStyle, _ScaleRingTilt, _ScaleRingInnerRadius, _ScaleRingOuterRadius, _ScaleRingBaseDepth, _ScaleRingThickness);
		
		cube([1000, 1000, 100]);
	}
}

main();
