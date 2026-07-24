// pog_bin_strip.scad -
// 
// A strip of open bins with varied floor colors
//
// TODO:
// - Collapsing top
// - Interlocking hinges?
//

/* [Bins] */

// Count
_BinCount = 20;

// Spacing
_BinSpacing = 5.0;

// Width
_BinWidth = 25.0;

// Depth
_BinDepth = 50.0;

// Height
_BinHeight = 10.0;

// Wall thickness
_BinWallThickness = 0.4;

// Floor thickness
_BinFloorThickness = 0.4;

/* [Extruders] */

// Bin extruder
_BinWallExtruder = 1;

// First floor extruder
_FirstBinFloorExtruder = 2;

// Last floor extruder
_LastBinFloorExtruder = 5;

// [Extruder to render]
_WhichExtruder = "All"; // ["All", 1, 2, 3, 4, 5]

// Map a value of _WhichExtruder to an OpenSCAD color
function ExtruderColor(Extruder) = 
  (Extruder == 1  ) ? "red"    : 
  (Extruder == 2  ) ? "green"  : 
  (Extruder == 3  ) ? "blue"   : 
  (Extruder == 4  ) ? "pink"   :
  (Extruder == 5  ) ? "yellow" :
                      "purple" ;

module EndCustomizer(){}

// If _WhichExtruder is "All" or is not "All" and matches the 
// requested extruder, render the child nodes.

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

module RenderBin(BinWidth, BinDepth, BinHeight, BinWallThickness, BinFloorThickness, BinWallExtruder, BinFloorExtruder)
{
	// Render a hollow bin
	Extruder(BinWallExtruder)
	{
		difference()
		{
			cube([BinWidth, BinDepth, BinHeight], center=false);
			
			translate([BinWallThickness, BinWallThickness, 0])
			{
				cube([BinWidth - (2 * BinWallThickness), BinDepth - (2 * BinWallThickness), BinHeight + .1], center=false);
			}
		}
	}
	
	// Render bin floor
	Extruder(BinFloorExtruder)
	{
		translate([BinWallThickness, BinWallThickness, 0])
		{
			cube([BinWidth - (2 * BinWallThickness), BinDepth - (2 * BinWallThickness), BinFloorThickness], center=false);
		}
	}
}

module RenderBinStrip(BinCount, BinSpacing, BinWidth, BinDepth, BinHeight, BinWallThickness, BinFloorThickness, BinWallExtruder, FirstBinFloorExtruder, LastBinFloorExtruder)
{
	for (B = [0 : BinCount - 1])
	{
		BinX = B * (BinWidth + BinSpacing);
		
		BinFloorExtruder = FirstBinFloorExtruder + B % (LastBinFloorExtruder - FirstBinFloorExtruder + 1);
		
		translate([BinX, 0, 0])
		{
			RenderBin(BinWidth, BinDepth, BinHeight, BinWallThickness, BinFloorThickness, BinWallExtruder, BinFloorExtruder);
		}
	}
}

module main(Args)
{
	RenderBinStrip(Args.BinCount, Args.BinSpacing, Args.BinWidth, Args.BinDepth, Args.BinHeight, Args.BinWallThickness, Args.BinFloorThickness, Args.BinWallExtruder, Args.FirstBinFloorExtruder, Args.LastBinFloorExtruder);
	
	TotalWidth = (Args.BinCount * Args.BinWidth) + ((Args.BinCount - 1) * Args.BinSpacing);
	echo("Total Width=", TotalWidth);
}

Args = object
(
	[
		["BinCount",				_BinCount],
		["BinSpacing",				_BinSpacing],
		["BinWidth",				_BinWidth],
		["BinDepth",				_BinDepth],
		["BinHeight",				_BinHeight],
		["BinWallThickness",		_BinWallThickness],
		["BinFloorThickness",		_BinFloorThickness],
		["BinWallExtruder",			_BinWallExtruder],
		["FirstBinFloorExtruder",	_FirstBinFloorExtruder],
		["LastBinFloorExtruder",	_LastBinFloorExtruder]
	]
);

main(Args);
