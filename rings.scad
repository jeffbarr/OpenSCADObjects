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
_RingHeight = 0.8;

// Ring Shadow Width
_RingShadowWidth = 4;

// Ring Shape
_RingShape = "Circle"; // [Circle, Triangle, Square, Pentagon, Hexagon, Octagon]

// Ring Rotation
_RingRotation = 0.0;

/* [Ring Brim] */

// Ring Brim Height
_RingBrimHeight = 0.4;

// Ring Brim Width
_RingBrimWidth = 0.6;

// Ring Brim Count
_RingBrimCount = 3;

// Ring Brim Spacing
_RingBrimSpacing = 0.8;

/* [Extruders] */

// Ring extruder
_RingExtruder = 1;

// Brim extruder 1
_BrimExtruder1 = true;

// Brim extruder 2
_BrimExtruder2 = true;

// Brim extruder 3
_BrimExtruder3 = true;

// Brim extruder 4
_BrimExtruder4 = true;

// Brim extruder 5
_BrimExtruder5 = true;

// [Extruder to render]
_WhichExtruder = "All"; // ["All", 1, 2, 3, 4, 5]

module __end_customization() {}

// Map a value of _WhichExtruder to an OpenSCAD color
function ExtruderColor(Extruder) = 
  (Extruder == 1  ) ? "red"    : 
  (Extruder == 2  ) ? "green"  : 
  (Extruder == 3  ) ? "blue"   : 
  (Extruder == 4  ) ? "pink"   :
  (Extruder == 5  ) ? "yellow" :
                      "purple" ;

// Create vector of brim extruders					  
_BrimExtrudersRaw =
[
	false,
	_BrimExtruder1 ? 1 : 0,
	_BrimExtruder2 ? 2 : 0,
	_BrimExtruder3 ? 3 : 0,
	_BrimExtruder4 ? 4 : 0,
	_BrimExtruder5 ? 5 : 0
];

_BrimExtruders = [for (i = [0 : 5]) if (_BrimExtrudersRaw[i]) i];
					  
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
					  
// Ring Antimatter Shadow Outer Diameter
_RingOuterShadowDiameter = _RingOuterDiameter + _RingShadowWidth;

// Ring Antimatter Shadow Inner Diameter
_RingInnerShadowDiameter = _RingOuterDiameter;

// Render grid of rings
module RenderRings(CountX, CountY, SpaceX, SpaceY, RingSides, RingRotation, RingInnerDiameter, RingOuterDiameter, RingHeight, RingExtruder)
{
	for (x = [ 0 : CountX - 1])
	{
		for (y = [0 : CountY - 1])
		{
			PointX = x * SpaceX;
			PointY = y * SpaceY;
			
			translate([PointX, PointY, 0])
			{
				Extruder(RingExtruder)
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
}

// Render grid of ring brims
module RenderRingBrims(CountX, CountY, SpaceX, SpaceY, RingSides, RingRotation, RingOuterDiameter, RingBrimHeight, RingBrimWidth, RingBrimCount, RingBrimSpacing, BrimExtruders)
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
					Extruder(BrimExtruders[r % len(BrimExtruders)])
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
module Render(CountX, CountY, SpaceX, SpaceY, RingSides, RingRotation, RingInnerDiameter, RingOuterDiameter, RingHeight, RingBrimHeight, RingBrimWidth, RingBrimCount, RingBrimSpacing, RingInnerShadowDiameter, RingOuterShadowDiameter, RingExtruder, BrimExtruders)
{
	difference()
	{	
		// Matter
		{
			union()
			{
				RenderRings(CountX, CountY, SpaceX, SpaceY, RingSides, RingRotation, RingInnerDiameter, RingOuterDiameter, RingHeight, RingExtruder);
				
				translate([0, 0, RingHeight])
				{
					RenderRingBrims(CountX, CountY, SpaceX, SpaceY, RingSides, RingRotation, RingOuterDiameter, RingBrimHeight, RingBrimWidth, RingBrimCount, RingBrimSpacing, BrimExtruders);
				}
			}
		}
		
		// Antimatter
		{
			union()
			{
				RenderRingShadows(CountX, CountY, SpaceX, SpaceY, RingSides, RingRotation, RingHeight + RingBrimHeight, RingInnerShadowDiameter, RingOuterShadowDiameter);
				RenderRingHoles(CountX, CountY, SpaceX, SpaceY, RingSides, RingRotation, RingBrimHeight, RingInnerDiameter);
			}
		}
	}
}

module main(CountX, CountY, SpaceX, SpaceY, RingShape, RingRotation, RingInnerDiameter, RingOuterDiameter, RingHeight, RingBrimHeight, RingBrimWidth, RingBrimCount, RingBrimSpacing, RingInnerShadowDiameter, RingOuterShadowDiameter, RingExtruder, BrimExtruders)
{
	RingSides = 
	  (RingShape == "Circle")   ? 99 :
	  (RingShape == "Triangle") ? 3  :
	  (RingShape == "Square")   ? 4  :
	  (RingShape == "Pentagon") ? 5  :
	  (RingShape == "Hexagon")  ? 6  :
	  (RingShape == "Octagon")  ? 8  :
	                              0;
								 
	Render(CountX, CountY, SpaceX, SpaceY, RingSides, RingRotation, RingInnerDiameter, RingOuterDiameter, RingHeight, RingBrimHeight, RingBrimWidth, RingBrimCount, RingBrimSpacing, RingInnerShadowDiameter, RingOuterShadowDiameter, RingExtruder, BrimExtruders);
}

main(_CountX, _CountY, _SpaceX, _SpaceY, _RingShape, _RingRotation, _RingInnerDiameter, _RingOuterDiameter, _RingHeight, _RingBrimHeight, _RingBrimWidth, _RingBrimCount, _RingBrimSpacing, _RingInnerShadowDiameter, _RingOuterShadowDiameter, _RingExtruder, _BrimExtruders);

