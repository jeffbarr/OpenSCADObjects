// Circles or hearts with holes for rings
//
// TODO:
//	- Fine-tune hole position on straight sides of hearts

// Count of items in X direction
_CountX = 1;

// Count of items in Y direction
_CountY = 1;

// X spacing
_SpaceX = 50;

// Y spacing
_SpaceY = 50;

// Item thickness
_Thickness = 1.3;

// Item type
_ItemType = "Circle"; // [Circle, Heart]

/* [Circles] */

// Circle diameter
_Diameter = 30;

/* [Hearts] */

/* [Holes] */

// Hole diameter
_HoleDiameter = 1;

// Hole inset from perimeter
_HoleInset = 2.5;

// Render one circle with four holes
module RenderCircle(Diameter, Thickness, HoleDiameter, HoleInset)
{
	linear_extrude(Thickness)
	{
		difference()
		{
			// Matter
			{
				circle(d=Diameter);
			}
			
			// Antimatter
			{
				Radius = Diameter / 2 - HoleInset;
				for (Theta = [0 : 90 : 360])
				{
					PointX = Radius * cos(Theta);
					PointY = Radius * sin(Theta);
					
					translate([PointX, PointY, 0])
					{
						circle(HoleDiameter, $fn=99);
					}
				}
			}
		}
		
	}
}

// Render one heart with four holes
module RenderHeart(Diameter, Thickness, HoleDiameter, HoleInset)
{
	Radius = Diameter / 2;
	
	linear_extrude(Thickness)
	{
		difference()
		{
			// Matter
			{
				union()
				{
					square(Diameter, center=false);
					translate([Diameter, Radius, 0]) circle(d=Diameter);
					translate([Radius, Diameter, 0]) circle(d=Diameter);
				}
			}
			
			// Antimatter
			{
				union()
				{
					// Holes on straight sides
					translate([Radius, HoleInset, 0]) circle(HoleDiameter, $fn=99);
					translate([HoleInset, Radius, 0]) circle(HoleDiameter, $fn=99);
					
					// Holes on curved sides
					translate([Diameter + Radius - HoleInset, Radius, 0]) circle(HoleDiameter, $fn=99);
					translate([Radius, Diameter + Radius - HoleInset, 0]) circle(HoleDiameter, $fn=99);		
				}
			}
		}
	}
}

// Render a grid of circles or hearts
module RenderGrid(ItemType, CountX, CountY, SpaceX, SpaceY, Diameter, Thickness, HoleDiameter, HoleInset)
{
	for (x = [0 : CountX - 1])
	{
		for (y = [0 : CountY - 1])
		{
			PointX = x * SpaceX;
			PointY = y * SpaceY;
			
			translate([PointX, PointY, 0])
			{
				if (ItemType == "Circle") RenderCircle(Diameter, Thickness, HoleDiameter, HoleInset);
				if (ItemType == "Heart")  RenderHeart(Diameter, Thickness, HoleDiameter, HoleInset);
			}
		}
		
	}
}

module main()
{
	RenderGrid(_ItemType, _CountX, _CountY, _SpaceX, _SpaceY, _Diameter, _Thickness, _HoleDiameter, _HoleInset);
}

main();
