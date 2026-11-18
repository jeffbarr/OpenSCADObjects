// barbell_tile.scad - Square tile with interlocking quarter-circles
//
// Inspired by a sidewalk pattern found in Yerevan, Armenia:
//
//	https://photos.app.goo.gl/o6XYw7JjXdCT37jK6 
//
// TODO:
// - Try with Fabric
// - Option to put a rim around entire set of tiles to make puzzle-like pieces
// - Base that is shaped like entire set of tiles
//
// BUGS:
//	- Seems like RingWidth is somehow being divided by 2 before being used
//
// NOTES:
//

/* [Tiles] */

// Tile Size
_TileSize = 25;

// Circle Diameter
_CircleDiameter = 10;

// Tile Height
_TileHeight = 0.6;

/* [Grid] */

// Tile Count X
_TileCountX = 5;

// Tile Count Y
_TileCountY = 5;

// Tile Gap
_TileGap = 1.2;

// Tile Shape
_TileShape = "In Out Out In";	// ["In Out Out In", "In Out In Out"]

// Tile Pattern
_TilePattern = "Solid";	// ["Solid", "Stripes", "Checkers"]

// [Rim]

// Add Rim
_AddRim = true;

// Rim Width
_RimWidth = 0.8;

// Rim Height
_RimHeight = 0.2;

// [Ring]

// Add Ring
_AddRing = true;

// Ring Width
_RingWidth = 0.2;

// Ring Depth
_RingDepth = 0.2;

// [Base]

// Add Base
_AddBase = true;

// Base Thickness
_BaseThickness = 0.2;

// Base border
_BaseBorder = 2.0;

/* [Extruders] */

// Base Extruder
_BaseExtruder = 1;

// Rim Extruder
_RimExtruder = 2;

// First Tile Extruder
_FirstTileExtruder = 1;

// Last Tile Extruder
_LastTileExtruder = 5;

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

/* End of customization */
module __Customizer_Limit__ () {}

_TileExtruderCount = _LastTileExtruder - _FirstTileExtruder + 1;

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

module RenderTile2D_InOutOutIn(TileShape, TileSize, CircleDiameter, TileGap)
{
    difference()
    {
        union()
        {
            square(TileSize);
            
            translate([TileSize, TileSize / 2, 0])
            {
                circle(d=CircleDiameter, $fn=99);
            }
            
            translate([TileSize / 2, TileSize, 0])
            {
                circle(d=CircleDiameter, $fn=99);
            }
        }
        
        union()
        {
            translate([TileSize / 2, -TileGap, 0])
            {
                circle(d=CircleDiameter + 2 * TileGap, $fn=99);
            }
            
            translate([-TileGap, TileSize / 2, 0])
            {
                circle(d=CircleDiameter + 2 * TileGap, $fn=99);
            }
        }
    }
}

module RenderTile2D_InOutInOut(TileShape, TileSize, CircleDiameter, TileGap)
{
	difference()
	{
		union()
		{
            square(TileSize);
			
			translate([TileSize / 2, TileSize, 0])
            {
                circle(d=CircleDiameter, $fn=99);
            }
			
			translate([TileSize / 2, 0, 0])
			{
				circle(d=CircleDiameter, $fn=99);
			}
		}
		
		union()
		{
			translate([-TileGap, TileSize / 2, 0])
			{
				circle(d=CircleDiameter + 2 * TileGap, $fn=99);
			}
			
			translate([TileSize + TileGap, TileSize / 2, 0])
			{
				circle(d=CircleDiameter + 2 * TileGap, $fn=99);
			}

		}
	}
}

module RenderTile2D(TileShape, TileSize, CircleDiameter, TileGap)
{
	if (TileShape == "In Out Out In")
	{
		RenderTile2D_InOutOutIn(TileShape, TileSize, CircleDiameter, TileGap);
	}
	
	if  (TileShape == "In Out In Out")
	{
		RenderTile2D_InOutInOut(TileShape, TileSize, CircleDiameter, TileGap);
	}
}

module RenderRim(TileShape, TileSize, CircleDiameter, TileGap, RimThickness, RimHeight, RimExtruder)
{
	Extruder(RimExtruder)
	{
		linear_extrude(RimHeight)
		{
			difference()
			{
				RenderTile2D(TileShape, TileSize, CircleDiameter, TileGap);
					
				offset(delta=-RimThickness)
				{
					RenderTile2D(TileShape, TileSize, CircleDiameter, TileGap);
				}
			}
		}
	}
}

module RenderTile3D(TileShape, TileSize, CircleDiameter, TileHeight, TileRotation, TileGap, AddRim, RimThickness, RimHeight, AddRing, RingWidth, RingDepth, TileExtruder, RimExtruder)
{
	translate([TileSize / 2, TileSize / 2, 0]) 
	{
		rotate([0, 0, TileRotation])
		{
			translate([-TileSize / 2, -TileSize / 2, 0])
			{
				difference()
				{
					// Tile
					Extruder(TileExtruder)
					{
						linear_extrude(TileHeight)
						{
							RenderTile2D(TileShape, TileSize, CircleDiameter, TileGap);
						}
					}
				
					if (AddRim)
					{
						translate([0, 0, TileHeight])
						{
							RenderRim(TileShape, TileSize, CircleDiameter, TileGap, RimThickness, RimHeight, RimExtruder);
						}
					}
										
					// Embossed ring
					if (AddRing)
					{
						// Adjust ring size to reflect gap between tiles
						RingDiameter = TileSize + TileGap + RingWidth / 2;
						
						// Top left
						translate([-TileGap / 2, TileSize + TileGap / 2, TileHeight - RingDepth])
						{
							linear_extrude(RingDepth + RimHeight)
							{
								difference()
								{
									circle(d=RingDiameter,             $fn=99);
									circle(d=RingDiameter - RingWidth, $fn=99);
								}
							}
						}
				
						// Bottom right
						translate([TileSize + TileGap / 2, -TileGap / 2, TileHeight - RingDepth])
						{
							linear_extrude(RingDepth + RimHeight)
							{
								difference()
								{
									circle(d=RingDiameter,             $fn=99);
									circle(d=RingDiameter - RingWidth, $fn=99);
								}
							}
						}
					}
				}				
			}
		}
	}
}

function ExtruderForCheckersTilePattern(X, Y, FirstExtruder) =
  FirstExtruder + ((X + Y) % _TileExtruderCount);
  
function ExtruderForTilePattern(Pattern, X, Y, FirstExtruder) = 
  (Pattern == "Solid")    ? FirstExtruder                                       :
  (Pattern == "Stripes")  ? FirstExtruder + (Y % _TileExtruderCount)            :
  (Pattern == "Checkers") ? ExtruderForCheckersTilePattern(X, Y, FirstExtruder) : 
                            0;

function RotationForTileShape(TileShape, X, Y) =
  (TileShape == "In Out Out In") ? 0                           :
  (TileShape == "In Out In Out") ? ((X + Y) % 2 == 1 ? 90 : 0) :
                                   0;

module RenderTileGrid(TileCountX, TileCountY, TileGap, TileSize, CircleDiameter, TileHeight, AddRim, RimWidth, RimHeight, TileShape, TilePattern, AddRing, RingWidth, RingDepth, FirstTileExtruder, RimExtruder)
{
    for (X = [0 : TileCountX - 1])
    {
        for (Y = [0 : TileCountY - 1])
        {
			// Compute coordinates
            PointX = X * (TileSize + TileGap);
            PointY = Y * (TileSize + TileGap);
			
			// Compute tile rotation
			TileRotation = RotationForTileShape(TileShape, X, Y);
			
			// Ascertain extruder
			TileExtruder = ExtruderForTilePattern(TilePattern, X, Y, FirstTileExtruder);

            translate([PointX, PointY, 0])
            {
				RenderTile3D(TileShape, TileSize, CircleDiameter, TileHeight, TileRotation, TileGap, AddRim, RimWidth, RimHeight, AddRing, RingWidth, RingDepth, TileExtruder, RimExtruder);
            }
        }
    }
    
}

module RenderBase(BaseThickness, BaseBorder, TileCountX, TileCountY, TileGap, TileSize, TileShape, CircleDiameter, BaseExtruder)
{
	// Compute size of base
	BaseNegX = (TileShape == "In Out Out In") ? 0 : (CircleDiameter / 2);
	BaseNegY = (TileShape == "In Out Out In") ? 0 : (CircleDiameter / 2);
	
	BaseSizeX = BaseNegX + BaseBorder + (TileCountX * TileSize) + ((TileCountX - 1) * TileGap) + (CircleDiameter / 2) + BaseBorder;
	BaseSizeY = BaseNegY + BaseBorder + (TileCountY * TileSize) + ((TileCountY - 1) * TileGap) + (CircleDiameter / 2) + BaseBorder;

	// Compute origin of base
	BaseOriginX = -BaseNegX;
	BaseOriginY = -BaseNegY;
	
	translate([BaseOriginX, BaseOriginY, 0])
	{
		Extruder(BaseExtruder)
		{
			linear_extrude(BaseThickness)
			{
				square([BaseSizeX, BaseSizeY]);
			}
		}
	}
}

module main(TileCountX, TileCountY, TileGap, TileSize, CircleDiameter, TileHeight, AddRim, RimWidth, RimHeight, AddBase, BaseThickness, BaseBorder, TileShape, TilePattern, AddRing, RingWidth, RingDepth, FirstTileExtruder, BaseExtruder, RimExtruder)
{
	if (AddBase)
	{
		RenderBase(BaseThickness, BaseBorder, TileCountX, TileCountY, TileGap, TileSize, TileShape, CircleDiameter, BaseExtruder);
	}
		
	GridOriginX = AddBase ? BaseBorder    : 0;
	GridOriginY = AddBase ? BaseBorder    : 0;
	GridOriginZ = AddBase ? BaseThickness : 0;
	
	translate([GridOriginX, GridOriginY, GridOriginZ])
	{
		RenderTileGrid(TileCountX, TileCountY, TileGap, TileSize, CircleDiameter, TileHeight, AddRim, RimWidth, RimHeight, TileShape, TilePattern, AddRing, RingWidth, RingDepth, FirstTileExtruder, RimExtruder);
	}
}

main(_TileCountX, _TileCountY, _TileGap, _TileSize, _CircleDiameter, _TileHeight, _AddRim,  _RimWidth, _RimHeight, _AddBase, _BaseThickness, _BaseBorder, _TileShape, _TilePattern, _AddRing, _RingWidth, _RingDepth, _FirstTileExtruder, _BaseExtruder, _RimExtruder);
