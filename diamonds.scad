/* Diamonds */

// Primary Diamond Size
PrimaryDiamondSize = 10;

// Primary Diamond Height
PrimaryDiamondHeight = 3;

// Filler Diamond Size
FillerDiamondSize = 6;

// Filler Diamond Height
FillerDiamondHeight = 3;

// Additional Rim Height
RimHeight = 0.5;

// Rim Thickness
RimThickness = 0.5;

// Column count
CountX = 6
;

// Row count
CountY = 8;

// Row spacing
SpaceY = 18;

// Column spacing
SpaceX = 31;

module FlatDiamond(Size)
{
    translate([Size/2, 0, 0])
    {
        union()
        {
            circle($fn=3, r=Size);
            
            translate([-Size, 0, 0])
                rotate([0 ,0, 60])
                    circle($fn=3, r=Size);
        }
    }  
}

module Diamond(Size, Height, RimHeight)
{
    union()
    {
        // The diamond
        linear_extrude(Height)
        {
            FlatDiamond(Size);
        }
        
        // The rim
        for (dd = [0 : 1.5 : 3])
        {
        linear_extrude(RimHeight)
        {
            difference()
            {
                FlatDiamond(Size - dd);
                offset(delta=-RimThickness)
                {
                    FlatDiamond(Size - dd);
                }
            }
        }
    }
    }
}

/* Primary Diamonds */
for (x = [0 : CountX - 1])
{
	for (y = [0 : CountY - 1])
	{
        PtX = x * SpaceX;
		PtY = y * SpaceY;
	
		translate([PtX, PtY, 0])
		{
			Diamond(PrimaryDiamondSize, PrimaryDiamondHeight, PrimaryDiamondHeight+RimHeight);
		}
	}
}

/* Filler Diamonds */
for (x = [0 : CountX - 1])
{
	for (y = [0 : CountY - 1])
	{
        PtX = (x * SpaceX) + (SpaceX / 2);
		PtY = (y * SpaceY) + (SpaceY / 2);
	
		translate([PtX, PtY, 0])
		{
			Diamond(FillerDiamondSize, FillerDiamondHeight, FillerDiamondHeight+RimHeight);
		}
	}
}

