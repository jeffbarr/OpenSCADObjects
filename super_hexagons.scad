/* Super-hexagons built from 6 triangles */

/* TODO:
 *
 * Print partial hexagons
 * Good settings:
 *   10, 6, 5, 29, 33, 3, 1.0, 0.4
 */

// Triangle radius
TriangleSize = 10;

// Column count
CountX = 10;

// Row count
CountY = 10;

// Row spacing
SpaceY = 29;

// Column spacing
SpaceX = 33;

// Shrinkage
Shrinkage = 1.0;

// Base height
BaseHeight = 3;		// [0.2 : 10]
// Height increment
HeightInc  = 0.4; 	// [0.0 : 0.2 : 10]

// 	Shift for odd rows
OddShiftX = SpaceX / 2;

// Optional fill on left side
LeftFill = true; // [false, true]

// Optional fill on right side
RightFill = true; // [false, true]

/* End of customization */
module __Customizer_Limit__ () {}

/* Rotate around Z */
cur_vpr = $vpr;
$vpr = [cur_vpr[0], cur_vpr[1], 360 * $t];

/* Compute overall size */
TotalX = (CountX - 1) * SpaceX;
TotalY = (CountY - 1) * SpaceY;

/* Compute heights */
Heights = [for (h = [0 : 5]) (BaseHeight + (h * HeightInc))];
echo(Heights);

AllSides = [0, 1, 2, 3, 4, 5];
	
module SuperHex(Size, Spread, Heights, Sides)
{
	Mult = Size * Spread;
	
	for (i = Sides)
	{
		Angle = 60 * i;
		linear_extrude(Heights[i], scale=Shrinkage)
			translate([cos(Angle) * Mult, sin(Angle) * Mult, 0])
				rotate(Angle + 60)
					circle($fn=3, r=Size);
	}
}

translate([-TotalX / 2, -TotalY / 2, 0])
for (x = [0 : CountX - 1])
{
	for (y = [0 : CountY - 1])
	{
		PtX = ((y % 2) == 1) ? OddShiftX + (x * SpaceX) : (x * SpaceX);
		PtY = y * SpaceY;

		/* Choose sides to print */
		OddY   = (y % 2) == 1;
		FirstX = (x == 0);
		LastX  = (x == (CountX - 1));

		WhichSides = (RightFill && LastX && OddY)   ? [2, 3, 4]
		           : (LeftFill  && FirstX && !OddY) ? [0, 1, 5]
		           : AllSides;
		
		translate([PtX, PtY, 0])
		{
			SuperHex(TriangleSize, 1.1, Heights, WhichSides);
		}
	}
}
