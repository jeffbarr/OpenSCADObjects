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

// Render hollow square of width and depth WD, height H, edges of EdgeWidth
module HollowSquare(WD, H, EdgeWidth)
{
	linear_extrude(H)
	{
		difference()
		{
			// Matter
			{
				square(WD, center=false);
			}
			
			// Anti-matter
			{
				translate([EdgeWidth, EdgeWidth, 0])
				{
					square(WD - (2 * EdgeWidth), center=false);
				}
			}
		}
	}
}

module FourHollowSquares(WD, H, Space, EdgeWidth)
{
	for (x = [0 : 1])
	{
		for (y = [0 : 1])
		{
			translate([x * Space, y * Space, 0])
			{
				HollowSquare(WD,  H, EdgeWidth);
			}
		}
	}
}

module FiveSquare(SmallWD, BigWD, SmallH, BigH, Space, EdgeWidth)
{
	Center = (Space + SmallWD) / 2;

	union()
	{
		FourHollowSquares(SmallWD, SmallH, Space, EdgeWidth);
		

		
		translate([Center - BigWD / 2, Center - BigWD / 2, 0])
		{
			HollowSquare(BigWD, BigH, EdgeWidth);
		}
	}	
}

module main()
{
	FiveSquare(_SmallSquareWD, _BigSquareWD, _SmallSquareH, _BigSquareH, _SmallSquareSpace, _EdgeWidth);
}

main();

