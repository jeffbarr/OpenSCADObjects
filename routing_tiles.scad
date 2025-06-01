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

// TODO:
//  Add half-routes (4x)
//  Add extruder color support
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

module _end_() {}

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
	["LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "BL", ],
	["BR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "TL", ],	
	["TR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "BL", ],
	["BR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "TL", ],	
	["TR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "BL", ],
	["BR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "TL", ],	
	["TR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "BL", ],
	["BR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "TL", ],	
	["TR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "BL", ],
	["LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "LR", "LR",  "TL", ],	
];


module RenderTileBase(TileSize, TileThickness)
{
    linear_extrude(TileThickness)
    {
        square([TileSize, TileSize], center=false);
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

module RenderTileRoute(Route, TileSize, RouteWidth, RouteThickness)
{
    color("red")
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
    }
}

module RenderTile(Route, TileSize, TileThickness, RouteWidth, RouteThickness)
{
    echo("RenderTile(", Route, TileSize, TileThickness, RouteWidth, RouteThickness, ")");

    union()
    {
        RenderTileBase(TileSize, TileThickness);
        translate([0, 0, TileThickness])
        {
            RenderTileRoute(Route, TileSize, RouteWidth, RouteThickness);
        }
    }
}
module RenderGrid(Grid, GridTileSpacing, TileSize, TileThickness, RouteWidth,RouteThickness)
{
    GridRows = len(_Grid);
    GridCols = len(_Grid[0]);
    
    echo("Rows=", GridRows, ", Cols=", GridCols);
    
    for (Row = [0 : GridRows - 1])
    {
        for (Col = [0 : GridCols - 1])
        {
            Route = Grid[GridRows - Row - 1][Col];
            X = Col * (TileSize + GridTileSpacing);
            Y = Row * (TileSize + GridTileSpacing);
 
            translate([X, Y, 0])
            {
                RenderTile(Route, TileSize, TileThickness, RouteWidth,RouteThickness);
            }
        }
    }
}

module main(Grid, GridTileSpacing, TileSize, TileThickness, RouteWidth,RouteThickness)
{
    RenderGrid(Grid, GridTileSpacing, TileSize, TileThickness, RouteWidth,RouteThickness);
}

main(_Grid, _GridTileSpacing, _TileSize, _TileThickness, _RouteWidth, _RouteThickness);
