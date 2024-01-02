// Talons - grid or ring layout

// Layout
_Layout = "Grid";	// [Grid, Ring]

/* [Base] */
// Solid base
_SolidBase = true;

// Base thickness
_BaseThickness = 3;

// Base border
_BaseBorder = 2;

// Ring base outer radius
_RingBaseOuterRadius = 40;

// Ring base inner radis
_RingBaseInnerRadius = 30;

/* [Talon] */

// Talon radius
_TalonRadius = 30;

// Talon thickness
_TalonThickness = 6;

// Talon front/back offset
_TalonOffset = 6;

// Talon XY rotation
_TalonRotation = 0;

/* [Grid] */
// X spacing
_SpaceX = 8;

// Y spacing
_SpaceY = 8;

// X count
_CountX = 4;

// Y count
_CountY = 4;

/* [Main Ring] */

// Radius of first ring
_MainFirstRingRadius = 4;

// Step between rings
_MainRingRadiusStep = 10;

// Number of rings
_MainRingCount = 4;

// Talons per ring
_MainRingTalonCount = 8;

/* [Fill Ring] */

// Radius of first ring
_FillFirstRingRadius = 14;

// Step between rings
_FillRingRadiusStep = 10;

// Number of rings
_FillRingCount = 3;

// Talons per ring
_FillRingTalonCount = 8;

// Rotation
_FillRingRotate = 22.5;

module __end_cust() {};

//
// Render a Talon
//

module Talon(Radius, Thickness, Offset)
{
	color("blue")
	{
		intersection()
		{
			// Half-moon Talon
			translate([0, Radius, 0])
			{
				rotate([90, 0, 90])
				{
					linear_extrude(Thickness)
					{
						difference()
						{
							circle(Radius);
							
							translate([Offset, 0, 0])
							{
								circle(Radius);
							}
						}
					}
				}
			}
			
			// Box above Z = 0
			cube([Thickness, Radius - Offset, Radius]);
		}
	}
}

//
// Render a grid of talons
//

module TalonGrid(CountX, CountY, SpaceX, SpaceY, TalonRadius, TalonThickness, TalonOffset)
{
	for (X = [0 : 1 : CountX - 1])
	{
		for (Y = [0 : 1 : CountY - 1])
		{
			OddY = (Y % 2) == 1;
			
			PointX = OddY ? (X * SpaceX) + SpaceX / 2 : (X * SpaceX);
			PointY = Y * SpaceY;
			
			translate([PointX, PointY, 0])
			{
				Talon(TalonRadius, TalonThickness, TalonOffset);	
			}
		}
	}
}

//
// Render a ring of talons
//
// TODO:
//	Add stepping up or down of size

module TalonRing(FirstRingRadius, RingRadiusStep, RingRadiusCount, TalonCount, TalonRadius, TalonThickness, TalonOffset, TalonRotation)
{
	Theta = 360 / TalonCount;
			
	// Each ring
	if (RingRadiusCount > 0 && TalonCount > 0)
	{
		for (r = [0 : RingRadiusCount - 1])
		{
			// Each talon
			for (t = [0 : TalonCount - 1])
			{
				PointX = (FirstRingRadius + (r * RingRadiusStep)) * cos(t * Theta);
				PointY = (FirstRingRadius + (r * RingRadiusStep)) * sin(t * Theta);
				
				translate([PointX, PointY, 0])
				{
					rotate([0, 0, 270 + (t * Theta) + TalonRotation])
					{
						// Translate so talons are centered on ray
						translate([-TalonThickness / 2, 0, 0])
						{
							Talon(TalonRadius, TalonThickness, TalonOffset);	
						}
					}
				}
			}
		}
	}
}

module main()
{
	Z_Up = _SolidBase ? _BaseThickness : 0;
	
	translate([0, 0, Z_Up])
	{
		if (_Layout == "Grid")
		{
			translate([2, 2, 0])
			{
				TalonGrid(_CountX, _CountY, _SpaceX, _SpaceY, _TalonRadius, _TalonThickness, _TalonOffset);
			}
		}
		
		if (_Layout == "Ring")
		{
			// TODO:
			//	translate to center
			//	Compute size of base
			
			// Main ring
			color("red")
			{
				TalonRing(_MainFirstRingRadius, _MainRingRadiusStep, _MainRingCount, _MainRingTalonCount, _TalonRadius, _TalonThickness, _TalonOffset, _TalonRotation);
			}
			
			// Fill ring
			color("blue")
			{
				rotate([0, 0, _FillRingRotate])
				{
					TalonRing(_FillFirstRingRadius, _FillRingRadiusStep, _FillRingCount, _FillRingTalonCount, _TalonRadius, _TalonThickness, _TalonOffset, _TalonRotation);
				}
			}
		}
	}
	
	if (_SolidBase  && _Layout == "Grid")
	{
		CubeWidth = _BaseBorder + (_CountX * _SpaceX) + (_TalonThickness / 2) + _BaseBorder;
		CubeDepth = _BaseBorder + (_CountY * _SpaceY) + _BaseBorder;
		
		cube([CubeWidth, CubeDepth, _BaseThickness]);
	}
	
	if (_SolidBase && _Layout == "Ring")
	{
		translate([0, 0, Z_Up / 2])
		{
			difference()
			{
				// Matter
				cylinder(Z_Up, r=_RingBaseOuterRadius, center=true);
				
				// Anti-matter
				cylinder(Z_Up + .001, r=_RingBaseInnerRadius, center=true);			}
		}
	}
}

main();
