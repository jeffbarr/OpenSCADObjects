// Baseboard heater knob

_KnobDiameter = 25.0;       // Knob diameter
_KnobWallThickness = 4.0;   // Knob wall thickness
_KnobHeight = 9.4;          // Knob height

_ShaftDiameter = 9.15;      // Shaft diameter // 9.2 measured, 9.15 test
_ShaftHeight = 21.0;        // Shaft height
_ShaftHoleDiameter = 6.50;  // Shaft hole diameter
_ShaftD = 5.5;                // Shaft D size (tried 4.9, 5.0, 5.25, 5.5)


module RenderKnob(KnobDiameter, KnobWallThickness, KnobHeight)
{
    difference()
    {   // Outside
        linear_extrude(KnobHeight)
        {
            circle(d=KnobDiameter, $fn=16);
        }
        // Inside
        translate([0, 0, KnobWallThickness])
        {
            linear_extrude(KnobHeight - KnobWallThickness)
            {
                circle(d=(KnobDiameter - KnobWallThickness));
            }
        }
     }
}

module RenderShaft(ShaftDiameter, ShaftHeight, ShaftHoleDiameter)
{
	linear_extrude(ShaftHeight)
	{
		difference()
		{
			// Matter
			union()
			{
				circle(d=ShaftDiameter, $fn=99);
			}
			
			// Antimatter
			circle(d=ShaftHoleDiameter, $fn=99);
		}
	}
}

module RenderD(Diameter, Height, D)
{
	linear_extrude(Height)
	{
		intersection()
		{
			circle(d=Diameter, $fn=99);
			translate([-D, 0, 0])
            {
                square(Diameter, center=true);
            }
		}
	}
}

module main(KnobDiameter, KnobWallThickness, KnobHeight, ShaftDiameter, ShaftHoleDiameter, ShaftHeight, ShaftD)
{
    union()
    {
        RenderKnob(KnobDiameter, KnobWallThickness, KnobHeight);
		translate([0, 0, KnobWallThickness])
		{
			RenderShaft(ShaftDiameter, ShaftHeight, ShaftHoleDiameter);
            RenderD(ShaftHoleDiameter, ShaftHeight, ShaftD); 
		}
    }
}

main(_KnobDiameter, _KnobWallThickness, _KnobHeight, _ShaftDiameter, _ShaftHoleDiameter, _ShaftHeight, _ShaftD);


