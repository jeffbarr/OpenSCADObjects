// routing_tiles.scad
//
// A grid of square tiles, each tile has one of the following routes:
//
//  "  "    - Nothing
//  LR      - Route from left to right
//  TB      - Route from top to bottom
//  TL      - Route from top to left
//  TR      - Route from top to right
//  BR      - Route from bottom to right
//  BL      - Route from bottom to left
//  CR      - Routes from left to right and top to bottom
//  LRD     - Route from left to right, and down from the midpoint
//  LRU     - Route from left to right, and up from the midpoint
//  TBL     - Route from top to bottom, and left from the midpoint
//  TBR     - Route from top to bottom, and right from the midpoint
//  L       - Route from left to midpoint
//  R       - Route from right to midpoint
//  T       - Route from top to midpoint
//  B       - Route from bottom to midpoint

// TODO:
//  Add decorations atop routes
//  Make routes more interesting
//  Multiple routes on a tile (lanes)

/* [Grid] */
_GridTileSpacing = 0.5;

/* [Tiles] */

// [Tile Size]
_TileSize = 24;

// [Route Width]
_RouteWidth = 4.0;

// [Tile Thickness]
_TileThickness = 2.0;

// [Route Thickness]
_RouteThickness = 0.2;

/* [Extruders] */

// [Tile Extruder]
_TileExtruder = 1;

// [Route Extruder]
_RouteExtruder = 2;

// [Extruder to render]
_WhichExtruder = "All"; // ["All", 1, 2, 3, 4, 5]

module _end_() {}

function GridX(Col, TileSize, GridTileSpacing) = Col * (TileSize + GridTileSpacing);
function GridY(Row, TileSize, GridTileSpacing) = Row * (TileSize + GridTileSpacing);

// Map a value of Extruder to an OpenSCAD color
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

/* Fully connected 5x5 grid */
/*
_Grid = 
[
    ["BR",  "LRD", "LRD", "LRD", "BL" ],
    ["TBR", "CR",  "CR",  "CR",  "TBL"],
    ["TBR", "CR",  "CR",  "CR",  "TBL"],
    ["TBR", "CR",  "CR",  "CR",  "TBL"],
    ["TR",  "LRU", "LRU", "LRU", "TL" ],
];
*/

/* Snake across 10x10 */

_Grid =
[
	["R",   "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "BL", ],
	["BR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "TL", ],	
	["TR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "BL", ],
	["BR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "TL", ],	
	["TR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "BL", ],
	["BR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "TL", ],	
	["TR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "BL", ],
	["BR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "TL", ],	
	["TR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "BL", ],
	["R",   "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "TL", ],	
];

/* Test */

/*
_Grid =
[
    ["L", "R", "T", "B"]
];
*/

module RenderTile(TileSize, TileThickness, TileExtruder)
{
    Extruder(TileExtruder)
    {
        linear_extrude(TileThickness)
        {
            square([TileSize, TileSize], center=false);
        }
    }
}

module RenderTileRouteLR(TileSize, RouteWidth)
{
    translate([0, TileSize / 2 - (RouteWidth / 2), 0])
    {
        square([TileSize, RouteWidth], center=false);
    }
}

module RenderTileRouteLRD(TileSize, RouteWidth)
{
    union()
    {
        translate([0, TileSize / 2 - (RouteWidth / 2), 0])
        {
            square([TileSize, RouteWidth], center=false);
        }
        
        translate([TileSize / 2 - (RouteWidth / 2), 0, 0])
        {
            square([RouteWidth, TileSize / 2 - RouteWidth / 2], center=false);
        }
    }
}

module RenderTileRouteLRU(TileSize, RouteWidth)
{
    union()
    {
        translate([0, TileSize / 2 - (RouteWidth / 2), 0])
        {
            square([TileSize, RouteWidth], center=false);
        }
        
        translate([TileSize / 2 - (RouteWidth / 2), TileSize / 2 + RouteWidth / 2, 0])
        {
            square([RouteWidth, TileSize / 2 - RouteWidth / 2], center=false);
        }
    }
}

module RenderTileRouteTBL(TileSize, RouteWidth)
{
    union()
    {
        translate([TileSize / 2 - (RouteWidth / 2), 0, 0])
        {
            square([RouteWidth, TileSize], center=false);
        }
        
        translate([0, TileSize / 2 - RouteWidth / 2, 0])
        {
            square([TileSize / 2 - RouteWidth / 2, RouteWidth], center=false);
        }
    }
}

module RenderTileRouteTBR(TileSize, RouteWidth)
{
    union()
    {
        translate([TileSize / 2 - (RouteWidth / 2), 0, 0])
        {
            square([RouteWidth, TileSize], center=false);
        }
        
        translate([TileSize / 2 + RouteWidth / 2, TileSize / 2 - RouteWidth / 2, 0])
        {
            square([TileSize / 2 - RouteWidth / 2, RouteWidth], center=false);
        }
    }
}

module RenderTileRouteTB(TileSize, RouteWidth)
{
    translate([TileSize / 2 - (RouteWidth / 2), 0, 0])
    {
        square([RouteWidth, TileSize], center=false);
    }
}

module RenderTileRouteBR(TileSize, RouteWidth)
{
    translate([TileSize, 0, 0])
    {
        intersection()
        {
            difference()
            {
                circle(r=TileSize / 2 + RouteWidth / 2);
                circle(r=TileSize / 2 - RouteWidth / 2);
            }
           
            translate([-TileSize, 0, 0])
            {
                square(TileSize, center=false);
            }
        }
    }
}

module RenderTileRouteBL(TileSize, RouteWidth)
{
    intersection()
    {
        difference()
        {
            circle(r=TileSize / 2 + RouteWidth / 2);
            circle(r=TileSize / 2 - RouteWidth / 2);
        }

        square(TileSize, center=false);
    }
}

module RenderTileRouteTL(TileSize, RouteWidth)
{
    translate([0, TileSize, 0])
    {
        intersection()
        {
            difference()
            {
                circle(r=TileSize / 2 + RouteWidth / 2);
                circle(r=TileSize / 2 - RouteWidth / 2);
            }
           
            translate([0, -TileSize, 0])
            {
                square(TileSize, center=false);
            }
        }
    }
}

module RenderTileRouteTR(TileSize, RouteWidth)
{
	
    translate([TileSize, TileSize, 0])
    {
        intersection()
        {
            difference()
            {
                circle(r=TileSize / 2 + RouteWidth / 2);
                circle(r=TileSize / 2 - RouteWidth / 2);
            }
           
            translate([-TileSize, -TileSize, 0])
            {
                square(TileSize, center=false);
            }
        }
    }
}

module RenderTileRouteL(TileSize, RouteWidth)
{
    translate([0, TileSize / 2 - RouteWidth / 2, 0])
    {
        square([TileSize / 2, RouteWidth], center=false);
    }
}

module RenderTileRouteR(TileSize, RouteWidth)
{
    translate([TileSize / 2, TileSize / 2 - RouteWidth / 2, 0])
    {
        square([TileSize / 2, RouteWidth], center=false);
    }
}

module RenderTileRouteT(TileSize, RouteWidth)
{
    translate([TileSize / 2 - (RouteWidth / 2), TileSize / 2, 0])
    {
        square([RouteWidth, TileSize / 2], center=false);
    }
}

module RenderTileRouteB(TileSize, RouteWidth)
{
    translate([TileSize / 2 - (RouteWidth / 2), 0, 0])
    {
        square([RouteWidth, TileSize / 2], center=false);
    }
}

module RenderRoute(Route, TileSize, RouteWidth, RouteThickness, RouteExtruder)
{
    Extruder(RouteExtruder)
    {
        linear_extrude(RouteThickness)
        {
            if (Route == "")
            {
            }
            
            if (Route == "LR")
            {
                RenderTileRouteLR(TileSize, RouteWidth);
            }
            
            if (Route == "TB")
            {
                RenderTileRouteTB(TileSize, RouteWidth);
            }
            
            if (Route == "BR")
            {
                RenderTileRouteBR(TileSize, RouteWidth);
            }
        
            if (Route == "BL")
            {
                RenderTileRouteBL(TileSize, RouteWidth);
            }

            if (Route == "TL")
            {
                RenderTileRouteTL(TileSize, RouteWidth);
            }
            
            if (Route == "TR")
            {
                RenderTileRouteTR(TileSize, RouteWidth);
            }
        
            if (Route == "CR")
            {
                union()
                {
                    RenderTileRouteLR(TileSize, RouteWidth);
                    RenderTileRouteTB(TileSize, RouteWidth);
                }
            }
            
            if (Route == "LRD")
            {
                RenderTileRouteLRD(TileSize, RouteWidth);
            }
            
            if (Route == "LRU")
            {
                RenderTileRouteLRU(TileSize, RouteWidth);
            }
            
            if (Route == "TBL")
            {
                RenderTileRouteTBL(TileSize, RouteWidth);
            }

            if (Route == "TBR")
            {
                RenderTileRouteTBR(TileSize, RouteWidth);
            }  
          
            if (Route == "L")
            {
                RenderTileRouteL(TileSize, RouteWidth);
            }

            if (Route == "R")
            {
                RenderTileRouteR(TileSize, RouteWidth);
            }
            
            if (Route == "T")
            {
                RenderTileRouteT(TileSize, RouteWidth);
            }

            if (Route == "B")
            {
                RenderTileRouteB(TileSize, RouteWidth);
            }
        }
    }
}

module RenderTiles(Grid, GridTileSpacing, TileSize, TileThickness, TileExtruder)
{
    GridRows = len(_Grid);
    GridCols = len(_Grid[0]);
    
    for (Row = [0 : GridRows - 1])
    {
        for (Col = [0 : GridCols - 1])
        {
            X = GridX(Col, TileSize, GridTileSpacing);
            Y = GridY(Row, TileSize, GridTileSpacing);
 
            translate([X, Y, 0])
            {
                RenderTile(TileSize, TileThickness, TileExtruder);
            }
        }
    }
}

module RenderRoutes(Grid, GridTileSpacing, TileSize, RouteWidth, RouteThickness, RouteExtruder)
{
    GridRows = len(_Grid);
    GridCols = len(_Grid[0]);
    
    for (Row = [0 : GridRows - 1])
    {
        for (Col = [0 : GridCols - 1])
        {
            Route = Grid[GridRows - Row - 1][Col];
            X = GridX(Col, TileSize, GridTileSpacing);
            Y = GridY(Row, TileSize, GridTileSpacing);
 
            translate([X, Y, 0])
            {
                RenderRoute(Route, TileSize, RouteWidth, RouteThickness, RouteExtruder);
            }
        }
    }
}

module RenderGrid(Grid, GridTileSpacing, TileSize, TileThickness, RouteWidth, RouteThickness, TileExtruder, RouteExtruder)
{
    union()
    {
        RenderTiles(Grid, GridTileSpacing, TileSize, TileThickness, TileExtruder);
        
        translate([0, 0, TileThickness])
        {
            RenderRoutes(Grid, GridTileSpacing, TileSize, RouteWidth, RouteThickness, RouteExtruder);
        }
        
        // Hack to use extruders 3, 4, and 5:
        {
            translate([0, 0, TileThickness + RouteThickness])
            {
                RenderRoutes(Grid, GridTileSpacing, TileSize, RouteWidth / 1.5, RouteThickness, 3);
            }        
            
            // Hack 2
            translate([0, 0, TileThickness + (2 * RouteThickness)])
            {
                RenderRoutes(Grid, GridTileSpacing, TileSize, RouteWidth / 2, RouteThickness, 4);
            } 
            
            // Hack 3
            translate([0, 0, TileThickness + (3 * RouteThickness)])
            {
                RenderRoutes(Grid, GridTileSpacing, TileSize, RouteWidth / 3, RouteThickness, 5);
            }
        }
    }
}

module main(Grid, GridTileSpacing, TileSize, TileThickness, RouteWidth,RouteThickness, TileExtruder, RouteExtruder)
{
    RenderGrid(Grid, GridTileSpacing, TileSize, TileThickness, RouteWidth,RouteThickness, TileExtruder, RouteExtruder);
}

main(_Grid, _GridTileSpacing, _TileSize, _TileThickness, _RouteWidth, _RouteThickness, _TileExtruder, _RouteExtruder);
