// Quad from Dentist's office

// Edge width
_EdgeWidth = 3.5;

// Small Square Width/Depth
_SmallSquareWD = 18.5;

// Small Square Height
_SmallSquareH = 2;

// Big Square Width/Depth
_BigSquareWD = 28.5;

// Big Square Height
_BigSquareH = 2.6;

// SmallSquare Space
_SmallSquareSpace = 22.5;

// Rim Width
_RimWidth = 0.4;

// Render hollow square of width and depth WD, height H, edges of EdgeWidth
module HollowSquare(WD, H, EdgeWidth)
{
	difference()
	{
		// Matter
		{
			cube([WD, WD, H], center=false);
		}
		
		// Anti-matter
		{
			translate([EdgeWidth, EdgeWidth, 0])
			{
				cube([WD - (2 * EdgeWidth), WD - (2 * EdgeWidth), H + .01], center=false);
			}
		}
	}
}

module HollowSquareWithRim(WD, H, EdgeWidth, RimWidth)
{
	HollowSquare(WD, H, EdgeWidth);
	
	translate([0, 0, H])
	{
		HollowSquare(WD, 0.2, RimWidth);
	}
}

module FourHollowSquares(WD, H, Space, EdgeWidth, RimWidth)
{
	for (x = [0 : 1])
	{
		for (y = [0 : 1])
		{
			translate([x * Space, y * Space, 0])
			{
				HollowSquareWithRim(WD,  H, EdgeWidth, RimWidth);
			}
		}
	}
}

module FiveSquare(SmallWD, BigWD, SmallH, BigH, Space, EdgeWidth, RimWidth)
{
	Center = (Space + SmallWD) / 2;

	union()
	{
		FourHollowSquares(SmallWD, SmallH, Space, EdgeWidth, RimWidth);
		
		translate([Center - BigWD / 2, Center - BigWD / 2, 0])
		{
			HollowSquareWithRim(BigWD, BigH, EdgeWidth, RimWidth);
		}
	}	
}

module main()
{
	FiveSquare(_SmallSquareWD, _BigSquareWD, _SmallSquareH, _BigSquareH, _SmallSquareSpace, _EdgeWidth, _RimWidth);
}

main();

