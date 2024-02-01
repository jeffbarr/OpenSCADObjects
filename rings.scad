// Overlapping rings that have an antimatter shadow that cut out parts of other rings

// X Count
_CountX = 5;

// Y Count
_CountY = 5;

// X Spacing
_SpaceX = 24;

// Y Spacing
_SpaceY = 24;

/* [Ring] */

// Ring Inner Diameter
_RingInnerDiameter = 10;

// Ring Outer Diameter
_RingOuterDiameter = 32;

// Ring Height
_RingHeight = 2;

// Ring Shadow Width
_RingShadowWidth = 4;

// Ring Shape
_RingShape = "Circle"; // [Circle, Square, Pentagon, Hexagon, Octagon]

// Ring Rotation
_RingRotation = 0.0;

/* [Ring Brim] */

// Ring Brim Height
_RingBrimHeight = 2.4;

// Ring Brim Width
_RingBrimWidth = 0.6;

// Ring Brim Count
_RingBrimCount = 3;

// Ring Brim Spacing
_RingBrimSpacing = 0.4;

module __end_customization() {}

// Ring Antimatter Shadow Outer Diameter
_RingOuterShadowDiameter = _RingOuterDiameter + _RingShadowWidth;

// Ring Antimatter Shadow Inner Diameter
_RingInnerShadowDiameter = _RingOuterDiameter;

__SIDES = 6;

// Render grid of rings
module RenderRings(CountX, CountY, SpaceX, SpaceY, RingSides, RingRotation, RingInnerDiameter, RingOuterDiameter, RingHeight)
{
	for (x = [ 0 : CountX - 1])
	{
		for (y = [0 : CountY - 1])
		{
			PointX = x * SpaceX;
			PointY = y * SpaceY;
			
			translate([PointX, PointY, 0])
			{
				linear_extrude(RingHeight)
				{
					rotate(RingRotation)
					{
						difference()
						{
							circle(d = RingOuterDiameter, $fn=RingSides);
							circle(d = RingInnerDiameter, $fn=RingSides);
						}
					}
				}
			}
		}
	}
}

// Render grid of ring brims
module RenderRingBrims(CountX, CountY, SpaceX, SpaceY, RingSides, RingRotation, RingOuterDiameter, RingBrimHeight, RingBrimWidth, RingBrimCount, RingBrimSpacing)
{
	for (x = [ 0 : CountX - 1])
	{
		for (y = [0 : CountY - 1])
		{
			PointX = x * SpaceX;
			PointY = y * SpaceY;
			
			translate([PointX, PointY, 0])
			{
				for (r = [ 0 : RingBrimCount - 1])
				{
					linear_extrude(RingBrimHeight)
					{
						rotate(RingRotation)
						{
							difference()
							{
								circle(d = (RingOuterDiameter - r * RingBrimSpacing), $fn=RingSides);
								circle(d = (RingOuterDiameter - (RingBrimWidth + (r * RingBrimSpacing))), $fn=RingSides);
							}
						}
					}
				}
			}
		}
	}
}

// Render grid of ring shadows outside of rings
module RenderRingShadows(CountX, CountY, SpaceX, SpaceY, RingSides, RingRotation, RingHeight, RingInnerShadowDiameter, RingOuterShadowDiameter)
{
	for (x = [ 0 : CountX - 1])
	{
		for (y = [0 : CountY - 1])
		{
			PointX = x * SpaceX;
			PointY = y * SpaceY;
			
			translate([PointX, PointY, - .001])
			{
				linear_extrude(RingHeight + .002)
				{
					rotate(RingRotation)
					{
						difference()
						{
							circle(d = RingOuterShadowDiameter, $fn=RingSides);
							circle(d = RingInnerShadowDiameter, $fn=RingSides);
						}
					}
				}
			}
		}
	}
}

// Render grid of holes inside of rings
module RenderRingHoles(CountX, CountY, SpaceX, SpaceY, RingSides, RingRotation, RingHeight, RingInnerDiameter)
{
	for (x = [ 0 : CountX - 1])
	{
		for (y = [0 : CountY - 1])
		{
			PointX = x * SpaceX;
			PointY = y * SpaceY;
			
			translate([PointX, PointY, 0])
			{
				linear_extrude(RingHeight)
				{
					rotate(RingRotation)
					{
						circle(d = RingInnerDiameter, $fn=RingSides);
					}
				}
			}
		}
	}
}
// Render rings, then subtract the outer shadows and inner holes
module Render(CountX, CountY, SpaceX, SpaceY, RingSides, RingRotation, RingInnerDiameter, RingOuterDiameter, RingHeight, RingBrimHeight, RingBrimWidth, RingBrimCount, RingBrimSpacing, RingInnerShadowDiameter, RingOuterShadowDiameter)
{
	difference()
	{	
		// Matter
		{
			union()
			{
				RenderRings(CountX, CountY, SpaceX, SpaceY, RingSides, RingRotation, RingInnerDiameter, RingOuterDiameter, RingHeight);
				RenderRingBrims(CountX, CountY, SpaceX, SpaceY, RingSides, RingRotation, RingOuterDiameter, RingBrimHeight, RingBrimWidth, RingBrimCount, RingBrimSpacing);
			}
		}
		
		// Antimatter
		{
			union()
			{
				RenderRingShadows(CountX, CountY, SpaceX, SpaceY, RingSides, RingRotation, RingBrimHeight, RingInnerShadowDiameter, RingOuterShadowDiameter);
				RenderRingHoles(CountX, CountY, SpaceX, SpaceY, RingSides, RingRotation, RingBrimHeight, RingInnerDiameter);
			}
		}
	}
}

module main()
{
	RingSides = 
	  (_RingShape == "Circle")   ? 99 :
	  (_RingShape == "Square")   ? 4  :
	  (_RingShape == "Pentagon") ? 5  :
	  (_RingShape == "Hexagon")  ? 6  :
	  (_RingShape == "Octagon")  ? 8  :
	                               0;
								 
	Render(_CountX, _CountY, _SpaceX, _SpaceY, RingSides, _RingRotation, _RingInnerDiameter, _RingOuterDiameter, _RingHeight, _RingBrimHeight, _RingBrimWidth, _RingBrimCount, _RingBrimSpacing,
_RingInnerShadowDiameter, _RingOuterShadowDiameter);
}

main();

