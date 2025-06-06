// fan_blades.scad
//
// Fan blades, just like it says.
//
// TODO:
//	Blade decoration
//	Optional cut/segmentation
//	Multiple color outer rings

/* [Fan] */

// [Inner radius]
_FanInnerRadius = 20;

// [Outer Radius]
_FanOuterRadius = 100;

// [Blades]
_FanBladeCount = 4;

// [Blade Thickness]
_FanBladeThickness = 1.0;

// [Inner Angle]
_FanInnerAngle = 15.0;

// [Outer Angle]
_FanOuterAngle = 20.0;

/* [Inner Circle, Ouuter Ring] */

// [Inner Circle]
_FanInnerCircle = true;

// [Outer Ring]
_FanOuterRing = true;

// [Inner Circle Radius]
_FanInnerCircleRadius = 10;

// [Outer Ring Inner Radius]
_FanOuterRingInnerRadius = 90;

// [Outer Ring Outer Radius]
_FanOuterRingOuterRadius = 100;

/* [Extruders] */

// [Extruder Count]
_FanExtruderCount = 5;

// [Inner Circle Extruder]
_FanInnerCircleExtruder = 1;

// [Outer Ring Extruder]
_FanOuterRingExtruder = 1;

// [Extruder to render]
_WhichExtruder = "All"; // ["All", 1, 2, 3, 4, 5]

// Map a value of Extruder to an OpenSCAD color
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

module RenderBlade(Theta, InnerRadius, OuterRadius, BladeThickness, InnerAngle, OuterAngle, Extruder)
{
	// Compute points
	X0 = InnerRadius * cos(Theta - InnerAngle / 2);
	Y0 = InnerRadius * sin(Theta - InnerAngle / 2);
	X1 = InnerRadius * cos(Theta + InnerAngle / 2);
	Y1 = InnerRadius * sin(Theta + InnerAngle / 2);

	X2 = OuterRadius * cos(Theta + OuterAngle / 2);
	Y2 = OuterRadius * sin(Theta + OuterAngle / 2);
	X3 = OuterRadius * cos(Theta - OuterAngle / 2);
	Y3 = OuterRadius * sin(Theta - OuterAngle / 2);

	BladePoly =
	[
		[X0, Y0], [X1, Y1],	[X2, Y2], [X3, Y3]
	];
	
	Extruder(Extruder)
	{
		linear_extrude(BladeThickness)
		{
			polygon(BladePoly);
		}
	}
}

module RenderFan(FanInnerRadius, FanOuterRadius, FanBladeCount, FanBladeThickness, FanInnerAngle, FanOuterAngle, FanExtruderCount, FanInnerCircle, FanInnerCircleRadius, FanInnerCircleExtruder, FanOuterRing, FanOuterRingInnerRadius, FanOuterRingOuterRadius, FanOuterRingExtruder)
{
	// Render each blade
	for (Blade = [0 : FanBladeCount - 1])
	{
		Theta = Blade * (360 / FanBladeCount);
		RenderBlade(Theta, FanInnerRadius, FanOuterRadius, FanBladeThickness, FanInnerAngle, FanOuterAngle, 1 + (Blade % FanExtruderCount));
	}
	
	// Render inner circle
	if (FanInnerCircle)
	{
		Extruder(FanInnerCircleExtruder)
		{
			linear_extrude(FanBladeThickness)
			{
				circle(FanInnerCircleRadius, $fn=99);
			}
		}
	}
	
	// Render outer ring
	if (FanOuterRing)
	{
		Extruder(FanOuterRingExtruder)
		{
			linear_extrude(FanBladeThickness)
			{
				difference()
				{
					circle(FanOuterRingOuterRadius, $fn=99);
					circle(FanOuterRingInnerRadius, $fn=99);
				}
			}
		}
	}
}

module main(FanInnerRadius, FanOuterRadius, FanBladeCount, FanBladeThickness, FanInnerAngle, FanOuterAngle, FanExtruderCount, FanInnerCircle, FanInnerCircleRadius, FanInnerCircleExtruder, FanOuterRing, FanOuterRingInnerRadius, FanOuterRingOuterRadius, FanOuterRingExtruder)
{
	RenderFan(FanInnerRadius, FanOuterRadius, FanBladeCount, FanBladeThickness, FanInnerAngle, FanOuterAngle, FanExtruderCount, FanInnerCircle, FanInnerCircleRadius, FanInnerCircleExtruder, FanOuterRing, FanOuterRingInnerRadius, FanOuterRingOuterRadius, FanOuterRingExtruder);
}

main(_FanInnerRadius, _FanOuterRadius, _FanBladeCount, _FanBladeThickness, _FanInnerAngle, _FanOuterAngle, _FanExtruderCount, _FanInnerCircle, _FanInnerCircleRadius, _FanInnerCircleExtruder, _FanOuterRing, _FanOuterRingInnerRadius, _FanOuterRingOuterRadius, _FanOuterRingExtruder);
