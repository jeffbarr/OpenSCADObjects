// Grid of squares using random extruders, each square a random height

// Base height
_BaseHeight = 0.4;

// Square height multiplier
_SquareHeightMul = 0.6;

// Square width
_SquareWidth = 10;

// Square depth
_SquareDepth = 10;

// Square count, X
_SquareCountX = 20;

// Square count, Y
_SquareCountY = 20;

// Random seed for extruders
_SeedExtruder = 99;

// Random seed for heights
_SeedHeight = 13;

// Extruder to render
_WhichExtruder = "All"; // ["All", 1, 2, 3, 4, 5]

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

module Base()
{
	Extruder(1)
	{
		cube([_SquareWidth * _SquareCountX, _SquareDepth * _SquareCountY, _BaseHeight], center = false);
	}
}

module Grid(Extruders, Heights)
{
	for (X = [0 : _SquareCountX - 1])
	{
		for (Y = [0 : _SquareCountY - 1])
		{
			PointX = X * _SquareWidth;
			PointY = Y * _SquareDepth;
			
			translate([PointX, PointY, 0])
			{
				Ex = Extruders[X * _SquareCountX + Y];
				Hi = Heights[X * _SquareCountX + Y];
				
				Extruder(Ex)
				{
					cube([_SquareWidth, _SquareDepth, Hi], center=false);
				}
			}
		}
	}
}

module main()
{
	// Generate a list of all needed random extruders
	ExRand = rands(1, 6, _SquareCountX * _SquareCountY, _SeedExtruder);
	Extruders = [for (i = [0 : (_SquareCountX * _SquareCountY) - 1]) floor(ExRand[i])];
	
	// Generate a list of all needed random heights
	ExHeight = rands(1, 5, _SquareCountX * _SquareCountY, _SeedHeight);
	Heights = [for (i = [0 : (_SquareCountX * _SquareCountY) - 1]) floor(ExHeight[i]) * _SquareHeightMul];
	
	Base();
	translate([0, 0, _BaseHeight])
	{
		Grid(Extruders, Heights);
	}
}

main();

