// Pride hearts, overlaid with stripes or rings
//
// TODO
//  * Rename a bunch of stripe variables to overlay variables
//	* Test with fabric
//	* Re-origin the rings or stripes for each heart
//	* Get rid of 99 in ring code
//

/* [Grid] */
// Count of items in X direction
_CountX = 1;

// Count of items in Y direction
_CountY = 1;

// X spacing
_SpaceX = 50;

// Y spacing
_SpaceY = 50;

/* [Base] */
// Base height
_BaseZ = 0.4;

// Base padding
_BasePad = 10;

/* [Hearts] */
// Heart thickness
_HeartZ = 0.6;

// Circle diameter
_Diameter = 30;

/* [Overlay] */
_Overlay = "Stripes";	// ["Stripes", "Rings"]

// Stripe width
_StripeWidth = 2;

// Stripe thickness
_StripeZ = 0.4;

// Stripe rotation
_StripeRotation = 0;

// Ring origin
_RingOrigin = "Bottom"; // ["Bottom", "Center", "Tip"]

/* [Extruders] */

// Extruder to render
_WhichExtruder = "All"; // ["All", 1, 2, 3, 4, 5]

// Base extruder
_BaseExtruder = 1; 			// [1, 2, 3, 4, 5]

// Heart extruder
_HeartExtruder = 1;			// [1, 2, 3, 4, 5]

// Stripe extruder 1
_StripeExtruder1 = true;

// Stripe extruder 2
_StripeExtruder2 = true;

// Stripe extruder 3
_StripeExtruder3 = true;

// Stripe extruder 4
_StripeExtruder4 = true;

// Stripe extruder 5
_StripeExtruder5 = true;

// Create _StripeExtruders vector from individual values, then use it to create _StripeExtruders
_StripeExtrudersVec = [false, _StripeExtruder1, _StripeExtruder2, _StripeExtruder3, _StripeExtruder4, _StripeExtruder5];
_StripeExtruders    = [for (i = [0 : 5]) if (_StripeExtrudersVec[i]) i];

// Map a value of _WhichExtruder to an OpenSCAD color
function ExtruderColor(Extruder) = 
  (Extruder == 1  ) ? "red"    : 
  (Extruder == 2  ) ? "green"  : 
  (Extruder == 3  ) ? "blue"   : 
  (Extruder == 4  ) ? "pink"   :
  (Extruder == 5  ) ? "yellow" :
                      "purple" ;
					  
// If _WhichExtruder is "All" or is not "All" and matches the requested extruder, render 
// the child nodes.

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

// Render one heart 
module RenderHeart(Diameter, Thickness)
{
	Radius = Diameter / 2;

	linear_extrude(Thickness)
	{
		union()
		{
			square(Diameter, center=false);
			translate([Diameter, Radius, 0]) circle(d=Diameter, $fn=99);
			translate([Radius, Diameter, 0]) circle(d=Diameter, $fn=99);
		}
	}
}

// Render a grid of hearts
module RenderGrid(CountX, CountY, SpaceX, SpaceY, Diameter, Thickness)
{
	for (x = [0 : CountX - 1])
	{
		for (y = [0 : CountY - 1])
		{
			PointX = x * SpaceX;
			PointY = y * SpaceY;
			
			translate([PointX, PointY, 0])
			{
				RenderHeart(Diameter, Thickness);
			}
		}
		
	}
}

// Render base
module RenderBase(BaseZ, BasePad, CountX, CountY, SpaceX, SpaceY)
{
	SizeX = BasePad + (CountX * SpaceX) + BasePad;
	SizeY = BasePad + (CountY * SpaceY) + BasePad;
	
	translate([-BasePad, -BasePad, 0])
	{
		cube([SizeX, SizeY, BaseZ], center=false);
	}
}

// Render Pride stripes for overlay
module RenderStripes(Extruders, CountX, CountY, SpaceX, SpaceY, StripeZ, StripeWidth, StripeRotation)
{
	// Over-estimate size of stripes, since this will be clipped wiht the hearts
	SizeX = 4 * CountX * SpaceX;
	SizeY = 4 * CountY * SpaceY;
	
	rotate([0, 0, StripeRotation])
	{
		translate([-SizeX / 2, -SizeY / 2, 0])
		{
			for (s = [0 : SizeX / StripeWidth])
			{
				Extruder(Extruders[floor(s % len(Extruders))])
				{
					translate([s * StripeWidth, 0, 0])
					{
						cube([StripeWidth, SizeY, StripeZ], center=false);
					}
				}
			}
		}
	}
}

// Compute center (origin) of rings given diameter and origin
// TODO - this works for the first heart only

function GetRingOriginX(Diameter, Origin) =
 (Origin == "Bottom") ? 0            :
 (Origin == "Center") ? Diameter / 2 :
 (Origin == "Tip")     ? Diameter    :
 999;		// FAIL
 
function GetRingOriginY(Diameter, Origin) =
 (Origin == "Bottom") ? 0            :
 (Origin == "Center") ? Diameter / 2 :
 (Origin == "Tip")     ? Diameter    :
 999;		// FAIL

// Render Pride rings for overlay
module RenderRings(Extruders, CountX, CountY, SpaceX, SpaceY, StripeZ, StripeWidth, HeartDiameter, RingOrigin)
{
	RingRadius = StripeWidth / 2;
	RingCount  = 99;	// FIX
	
	OriginX = GetRingOriginX(HeartDiameter, RingOrigin);
	OriginY = GetRingOriginY(HeartDiameter, RingOrigin);
	
	translate([OriginX, OriginY, 0])
	{
		linear_extrude(StripeZ)
		{
			// First one is a full circle
			Extruder(Extruders[0])
			{
				circle(r=RingRadius);
			}
			
			// All others are rings
			for (Ring = [1 : RingCount])
			{
				Extruder(Extruders[floor(Ring % len(Extruders))])
				{
					difference()
					{
						InnerRadius = Ring * RingRadius;
						OuterRadius = InnerRadius + RingRadius;
						circle(r=OuterRadius, $fn=99);
						circle(r=InnerRadius, $fn=99);
					}
				}
			}
		}
	}
}

module main()
{
	// Base
	if (_BaseZ > 0)
	{
		Extruder(_BaseExtruder)
		{
			RenderBase(_BaseZ, _BasePad, _CountX, _CountY, _SpaceX, _SpaceY);
		}
	}
	
	// Grid of hearts
	if (_HeartZ > 0)
	{
		translate([0, 0, _BaseZ])
		{
			Extruder(_HeartExtruder)
			{
				RenderGrid(_CountX, _CountY, _SpaceX, _SpaceY, _Diameter, _HeartZ);
			}
		}
	}
	
	// Stripes or Rings
	//** StripeExtruders rename to OverlayExtruders **//
	translate([0, 0, _BaseZ + _HeartZ])
	{
		intersection()
		{
			if (_Overlay == "Stripes")
			{
				RenderStripes(_StripeExtruders, _CountX, _CountY, _SpaceX, _SpaceY, _StripeZ, _StripeWidth, _StripeRotation);
			}
		
			if (_Overlay == "Rings")
			{
				RenderRings(_StripeExtruders, _CountX, _CountY, _SpaceX, _SpaceY, _StripeZ, _StripeWidth, _Diameter, _RingOrigin);
			}
			
			RenderGrid(_CountX, _CountY, _SpaceX, _SpaceY, _Diameter, _StripeZ + .01);
		}
	}
}

main();
