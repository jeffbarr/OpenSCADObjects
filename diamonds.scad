/* Diamonds */

/*
 * TODO
 *
 * Add color patterns based on X,Y modulo
 */
 
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
CountX = 6;

// Row count
CountY = 8;

// Row spacing
SpaceY = 18;

// Column spacing
SpaceX = 31;

/* [Multiple Extruders] */

// First primary diamond extruder
_FirstPrimaryExtruder = 1;

// Last primary diamond extruder
_LastPrimaryExtruder = 2;

// First filler diamond extruder
_FirstFillerExtruder = 3;

// Last filler diamond extruder
_LastFillerExtruder = 4;

// Rim extruder
_RimExtruder = 5;

// Random seed
_RandomSeed = 131313;

// [Extruder to render]
_WhichExtruder = "All"; // ["All", 1, 2, 3, 4, 5]

module EndCustomization(){}

// Randomize
ZZZ = rands(0, 1, 1, _RandomSeed);

/* Generate random extruders/colors for primary diamonds */
_PrimaryExtruderGrid = 
[
	for (x = [1 : CountX]) 
		[
			for (y = [1 : CountY])
				floor(rands(0, 1, 1)[0] * (_LastPrimaryExtruder - _FirstPrimaryExtruder + 1)) + _FirstPrimaryExtruder
		]
];

/* Generate random extruders/colors for filler diamonds */
_FillerExtruderGrid = 
[
	for (x = [1 : CountX]) 
		[
			for (y = [1 : CountY])
				floor(rands(0, 1, 1)[0] * (_LastFillerExtruder - _FirstFillerExtruder + 1)) + _FirstFillerExtruder
		]
];

// Map a value of _WhichExtruder to an OpenSCAD color
function ExtruderColor(Extruder) = 
  (Extruder == 1  )   ? "red"    :  
  (Extruder == 2  )   ? "green"  : 
  (Extruder == 3  )   ? "blue"   : 
  (Extruder == 4  )   ? "pink"   :
  (Extruder == 5  )   ? "yellow" :
  (Extruder == "All") ? "orange" : 
                        "purple" ;

// If _WhichExtruder is "All" or is not "All" and matches the 
// requested extruder, render the child nodes.

module Extruder(DoExtruder)
{
	color(ExtruderColor(DoExtruder))
	{
		if (_WhichExtruder == "All" || DoExtruder == _WhichExtruder || DoExtruder == "All")
		{
			children();
		}
	}
}

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

module Diamond(Size, Height, RimHeight, DiamondExtruder, RimExtruder)
{
    union()
    {
		// The diamond
		Extruder(DiamondExtruder)
		{
			linear_extrude(Height)
			{
				FlatDiamond(Size);
			}
        }
		
        // The rim
		Extruder(RimExtruder)
		{
			translate([0, 0, Height])
			{
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
    }
}

/* Primary Diamonds */
module PrimaryDiamonds(FirstDiamondExtruder, LastDiamondExtruder, RimExtruder)
{
	for (x = [0 : CountX - 1])
	{
		for (y = [0 : CountY - 1])
		{
			PtX = x * SpaceX;
			PtY = y * SpaceY;
		
		    DiamondExtruder = _PrimaryExtruderGrid[x][y];
			translate([PtX, PtY, 0])
			{
				Diamond(PrimaryDiamondSize, PrimaryDiamondHeight, RimHeight, DiamondExtruder, RimExtruder);
			}
		}
	}
}

/* Filler Diamonds */
module FillerDiamonds(FirstDiamondExtruder, LastDiamondExtruder, RimExtruder)
{
	for (x = [0 : CountX - 1])
	{
		for (y = [0 : CountY - 1])
		{
			PtX = (x * SpaceX) + (SpaceX / 2);
			PtY = (y * SpaceY) + (SpaceY / 2);
		
		    DiamondExtruder = _FillerExtruderGrid[x][y];
			translate([PtX, PtY, 0])
			{
				Diamond(FillerDiamondSize, FillerDiamondHeight, RimHeight, DiamondExtruder, RimExtruder);
			}
		}
	}
}

module main()
{
	PrimaryDiamonds(_FirstPrimaryExtruder, _LastPrimaryExtruder, _RimExtruder);
	FillerDiamonds(_FirstFillerExtruder, _LastFillerExtruder, _RimExtruder);
}

main();

