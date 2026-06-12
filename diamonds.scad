/* Diamonds */

/*
 * TODO
 *
 * Color modes for primary and filler diamonds work as follows:
 *
 * Random - Color for each diamond is chosen at random within the range of
 *          _FirstPrimaryDiamond to _LastPrimaryDiamond or _FirstFillerDiamond
 *          to _LastFillerDiamond.
 *
 * By Row - Colors cycle row by row within the respective ranges.
 *
 * By Col - Colors cycle column by column within the respective ranges.
 *
 * Diagonal - Colors cycle diagonally within the respective ranges.
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
_CountX = 6;

// Row count
_CountY = 8;

// Row spacing
_SpaceY = 18;

// Column spacing
_SpaceX = 31;

/* [Multiple Extruders] */

// Primary diamond color mode
_PrimaryColorMode = "Random";       // ["Random", "By Row", "By Col", "Diagonal"]

// Filler diamond color mode
_FillerColorMode = "Random";        // ["Random", "By Row", "By Col", "Diagonal"]

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

// Return the extruder for the given color mode
function ExtruderForColorMode(ColorMode, X, Y, ExtruderGrid, FirstExtruder, LastExtruder) =
    (ColorMode == "Random")   ? ExtruderGrid[X][Y] :
    (ColorMode == "By Row")   ? FirstExtruder + Y       % (LastExtruder - FirstExtruder + 1) :  
    (ColorMode == "By Col")   ? FirstExtruder + X       % (LastExtruder - FirstExtruder + 1) :
    (ColorMode == "Diagonal") ? FirstExtruder + (X + Y) % (LastExtruder - FirstExtruder + 1) :
                                -1; 

// Randomize
ZZZ = rands(0, 1, 1, _RandomSeed);

/* Generate random extruders/colors for primary diamonds */
_PrimaryExtruderGrid = 
[
	for (x = [1 : _CountX]) 
		[
			for (y = [1 : _CountY])
				floor(rands(0, 1, 1)[0] * (_LastPrimaryExtruder - _FirstPrimaryExtruder + 1)) + _FirstPrimaryExtruder
		]
];

/* Generate random extruders/colors for filler diamonds */
_FillerExtruderGrid = 
[
	for (x = [1 : _CountX + 1]) 
		[
			for (y = [1 : _CountY])
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
			{
                rotate([0 ,0, 60])
				{
                    circle($fn=3, r=Size);
				}
			}
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
module PrimaryDiamonds(CountX, CountY, SpaceX, SpaceY, ColorMode, FirstDiamondExtruder, LastDiamondExtruder, RimExtruder)
{
	for (x = [0 : CountX - 1])
	{
		for (y = [0 : CountY - 1])
		{
			PtX = x * SpaceX;
			PtY = y * SpaceY;
		
            // Choose extruder
            DiamondExtruder = ExtruderForColorMode(ColorMode, x, y, _PrimaryExtruderGrid, FirstDiamondExtruder, LastDiamondExtruder);
            
            // Render primary diamond
			translate([PtX, PtY, 0])
			{
				Diamond(PrimaryDiamondSize, PrimaryDiamondHeight, RimHeight, DiamondExtruder, RimExtruder);
			}
		}
	}
}

/* Filler Diamonds */
module FillerDiamonds(CountX, CountY, SpaceX, SpaceY, ColorMode, FirstDiamondExtruder, LastDiamondExtruder, RimExtruder)
{
	for (x = [0 : CountX - 1])
	{
		for (y = [0 : CountY - 1])
		{
			PtX = (x * SpaceX) + (SpaceX / 2);
			PtY = (y * SpaceY) + (SpaceY / 2);
		
            // Choose extruder
            DiamondExtruder = ExtruderForColorMode(ColorMode, x + 1, y, _FillerExtruderGrid, FirstDiamondExtruder, LastDiamondExtruder);
            
            // Render filler diamond
			translate([PtX, PtY, 0])
			{
				Diamond(FillerDiamondSize, FillerDiamondHeight, RimHeight, DiamondExtruder, RimExtruder);
			}
		}
	}
}

module main()
{
	PrimaryDiamonds(_CountX, _CountY, _SpaceX, _SpaceY, _PrimaryColorMode, _FirstPrimaryExtruder, _LastPrimaryExtruder, _RimExtruder);
	FillerDiamonds(_CountX, _CountY, _SpaceX, _SpaceY, _FillerColorMode, _FirstFillerExtruder, _LastFillerExtruder, _RimExtruder);
}

main();

