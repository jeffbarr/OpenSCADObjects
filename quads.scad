/* quads.scad -
 *
 * Some quadrilaterals that are perturbed rectangles, there are lots of settings
 * and options.
 *
 * HeightMode - Method used to set height of each quad, and must be one of:
 *
 *				HM_FIXED- All quads are the same height, BaseHeight.
 *
 *				HM_RANDOM - Each quad is BaseHeight + one of Heights
 *							random values, stepped by HeightInc.
 *
 * QuadType - Type of each quad, and must be one of:
 *
 *			  QT_VERT - Polygon with vertical sides.
 *
 *			  QT_TAPER - Polygon with tapered sides.
 *
 *			  QT_TOPO - Polyhedrons that meet at the edges, works best when
 *						HeightMode is HM_RANDOM.
 *
 * TODO:
 *	- Update documentation
 */

/*
 * Each x in the G grid is a point that will be perturbed (in x and y) 
 * to make slightly irregular quadrilaterals. The edges remain untouched
 * to create a rectangle.
  *
 *   0   1   2   3   4   5   6   7   8
 * 0 +---+---+---+---+---+---+---+---+
 *   | A |   |   |   |   |   |   |   |
 * 1 +---x---x---x---x---x---x---x---+
 *   |   |   |   |   |   |   |   |   |
 * 2 +---x---x---x---x---x---x---x---+
 *   |   |   |   |   |   |   |   |   |
 * 3 +---x---x---x---x---x---x---x---+
 *   |   |   |   |   |   |   |   |   |
 * 4 +---+---+---+---+---+---+---+---+
 *
 * A is the first rectangle (defined by the points around it, and so forth.
 *
 * The H grid is used only when QuadType is QT_TOPO, and has the same basic
 * layout as the G grid. Each x in the grid represents the height of the
 * polyhedron where the adjacent quadrilaterals meet. Each element of the
 * H grid is a height value.
 */
 
/* 
 * Define the grid:
 */
 
// Number of rows in the grid 
_Rows = 12;

// Number of columns in the grid 
_Cols = 12;

/* 
 * Define size of each rectangle in the grid:
 */

// Width of each rectangle
_RectWidth = 15;

// Depth of each rectangle
_RectDepth = 15;

/* 
 * Define gap between rectangles:
 */

// Gap between each row of rectangles
_RectRowGap = 2;

// Gap between each column of rectangles
_RectColGap = 2;

/* 
 * Define amount of perturbation per rectangle, this is -/+, so the 
 * perturbation can be from (-RowPert) to (RowPert), and the same 
 * for ColPert. 
 */
 
// Max perturbation between rows
_RowPert = 8;

// Max perturbation between columns
_ColPert = 8;

/* 
 * Set height mode:
 */
 
// Height mode
_HeightMode = "HM_FIXED"; // [HM_FIXED, HM_RANDOM]

/*
 * Define height parameters:
*/

// Quad height
_QuadHeight = 3;		// [0.2 : 10]

// Height increment
_HeightInc  = 0.4; 		// [0.2 : 0.2 : 10]

// Number of random heights
_Heights    = 7;		// [1 : 20]

// Scale at top of QT_TAPER quad
_TaperTopScale = 0.5;	// [0.0 : 0.1 : 1.0]

/* 
 * Set quad type:
 */
 
// Quad type
_QuadType = "QT_VERT"; // [QT_VERT, QT_TAPER, QT_TOPO]

// Random seed
_RandomSeed = 1313;

/* [Rim] */

// Render rim
_RenderRim = true;

// Additional Rim Height
_RimHeight = 0.4;

// Rim Thickness
_RimThickness = 0.5;

/* [Base] */

// Render base
_RenderBase = false;

// Base height
_BaseHeight = 0.2;		// [0.2 : 0.2 : 10]

// Base margin
_BaseMargin = 1.0;

/* [Lead] */

// Render lead
_RenderLead = false;

// Lead height
_LeadHeight = 0.4;		// [0.2 : 0.2 : 10]

/* [Extruders] */

// Multiple extruder
_MultiExtruder = false;

// first extruder
_FirstExtruder = 1;

// Last extruder
_LastExtruder = 4;

// Rim extruder
_RimExtruder = 5;

// Base extruder
_BaseExtruder = 5;

// Lead extruder
_LeadExtruder = 5;

// [Extruder to render]
_WhichExtruder = "All"; // ["All", 1, 2, 3, 4, 5]

/* End of customization */
module __Customizer_Limit__ () {}

/* Perform sanity checks */
assert(_Rows > 0);
assert(_Cols > 0);
assert(_RectWidth > 0);
assert(_RectDepth > 0);
assert(_RectRowGap >= 0);
assert(_RectColGap >= 0);
assert(_RowPert >= 0);
assert(_ColPert >= 0);
assert((_HeightMode == "HM_FIXED") || (_HeightMode == "HM_RANDOM"));
assert((_QuadType == "QT_VERT") || (_QuadType == "QT_TAPER") || (_QuadType == "QT_TOPO"));

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

/* Seed the Random number generator */
X = rands(0, 100, 1, _RandomSeed);

/* Compute overall size */
_OverallWidth = _BaseMargin + (_Cols * _RectWidth) + ((_Cols - 1) * _RectColGap) + _BaseMargin;
_OverallDepth = _BaseMargin + (_Cols * _RectDepth) + ((_Rows - 1) * _RectRowGap) + _BaseMargin;

echo ("Overall size: ", _OverallWidth, _OverallDepth);

/*
 * GridRowPert - Return a value that will be used to perturb a row coordinate in the G grid
 * GridColPert - Return a value that will be used to perturb a column coordinate in the G grid
 */
 
function GridRowPert() = rands(-_RowPert, _RowPert, 1)[0];
function GridColPert() = rands(-_ColPert, _ColPert, 1)[0];

 /* Build the G grid */
G = 
[
	[for (c = [0 : _Cols]) [ 0, 0]],
		
	for (r = [1 : _Rows - 1]) 
		[
			[0, 0],
			for (c = [1 : _Cols - 1])
				[
					GridRowPert(), GridColPert()
				],
			[0, 0]				
		],
			
	[for (c = [0 : _Cols]) [ 0, 0]],
];

echo("G Grid:");
for (r = [0 : _Rows])
{
	echo("  Row: ", r);
	echo("    ", G[r], "\n");
}

/* Build the H grid */
H =
[
	[for (c = [0 : _Cols]) _QuadHeight],
		
	for (r = [1 : _Rows - 1]) 
		[	
			_QuadHeight,
			for (c = [1 : _Cols - 1]) _QuadHeight + floor(rands(0, _Heights, 1)[0]) * _HeightInc,
			_QuadHeight				
		],	
		
	[for (c = [0 : _Cols]) _QuadHeight],
];
	
echo("H Grid:");
for (r = [0 : _Rows])
{
	echo("  Row: ", r);
	echo("    ", H[r], "\n");
}

/* Generate random extruders/colors */
_ExtruderGrid = 
[
	for (r = [1 : _Rows]) 
		[
			for (c = [1 : _Cols])
				floor(rands(0, 1, _RandomSeed)[0] * (_LastExtruder - _FirstExtruder + 1)) + _FirstExtruder
		]
];

echo("Extruder Grid:");
echo(_ExtruderGrid);

/*
 * Names of the X_BL (Bottom Left) define the four corners of the rectangle:
 *
 *	  [X_TL, Y_TL]       [X_TR, Y_TR]
 *    +-------------...-------------+
 *    |                             |
 *    .                             .
 *    |                             |
 *    +-------------...-------------+
 *	  [X_BL, Y_BL]       [X_BR, Y_BR]
 *
 * These values are then perturbed via the G grid to define the corners of the
 * quadrilateral, with names suffixed by _G.
 */

//translate([-Width / 2, -Depth / 2, 0])
/* Construct polygons */

/* Render a quadrilateral of type QT_VERT */
module RenderQuadVert(QuadPoly, QuadExtruder, QuadHeight, RenderRim, RimExtruder, RimHeight, RimThickness)
{
	Extruder(QuadExtruder)
	{
		linear_extrude(QuadHeight)
		{	 
			polygon(QuadPoly);
		}
	}

	if (RenderRim)
	{
		translate([0, 0, QuadHeight])
		{
			Extruder(RimExtruder)
			{
				linear_extrude(RimHeight)
				{
					difference()
					{
						polygon(QuadPoly);
					
						offset(delta=-RimThickness)
						{
							polygon(QuadPoly);
						}
					}	
				}
			}
		}
	}
}

/* Render a quadrilateral of type QT_TAPER */
module RenderQuadTaper(X_Center, Y_Center, TaperPoly, QuadExtruder, Height, TaperTopScale)
{
	Extruder(QuadExtruder)
	{
		translate([X_Center, Y_Center, 0])
		{
			linear_extrude(Height, scale=TaperTopScale)
			{
				translate([-X_Center, -Y_Center, 0])
				{
					polygon(TaperPoly);
				}
			}
		}
	}
}

/* Render a quadrilateral of type QT_TOPO */
module RenderQuadTopo(PolyPoints, PolyFaces, QuadExtruder)
{
	Extruder(QuadExtruder)
	{
		polyhedron(points=PolyPoints,faces=PolyFaces);
	}
}

/* Render the grid of quadrilaterals */
module RenderQuadGrid(Rows, Cols, QuadType, HeightMode, RectWidth, RectDepth, RectRowGap, RectColGap, RowPert, ColPert, QuadHeight, HeightInc, Heights, TaperTopScale, MultiExtruder, SingleExtruder, RimExtruder, RenderRim, RimHeight, RimThickness)
{
	for (r = [0 : Rows - 1])
	{
		for (c = [0 : Cols - 1])
		{ 
			/* Compute coordinates of each rectangle */
			X_BL = (c * (RectWidth + RectColGap)); 
			X_BR = X_BL + RectWidth;
			X_TL = X_BL;
			X_TR = X_BR;
		
			Y_BL = (r * (RectDepth + RectRowGap)); 
			Y_TL = Y_BL + RectDepth;
			Y_BR = Y_BL;
			Y_TR = Y_TL;
		
			/* Adjust by the per-corner perturbation in the grid */
			X_BL_G = X_BL + G[r][c][1];
			Y_BL_G = Y_BL + G[r][c][0];

			X_BR_G = X_BR + G[r][c+1][1];
			Y_BR_G = Y_BR + G[r][c+1][0];
		
			X_TL_G = X_TL + G[r+1][c][1];
			Y_TL_G = Y_TL + G[r+1][c][0];

			X_TR_G = X_TR + G[r+1][c+1][1];
			Y_TR_G = Y_TR + G[r+1][c+1][0];		
		
			/* Pick a height based on HeightMode (this value is not used for QT_TOPO, since each corner has a distinct height) */
			Height =
				(HeightMode == "HM_FIXED")  ? QuadHeight :
				(HeightMode == "HM_RANDOM") ? QuadHeight + floor(rands(0, Heights, 1)[0]) * HeightInc :
				0;
			
			// If MultiExtruder is specified use the pert-quad color from _ExtruderGrid, otherwise use the given single extruder
			QuadExtruder = MultiExtruder ? _ExtruderGrid[r][c] : SingleExtruder;

			/* Generate quad based on QuadType */
			if (QuadType == "QT_VERT")
			{
				QuadPoly = [[X_BL_G, Y_BL_G], [X_BR_G, Y_BR_G], 
						[X_TR_G, Y_TR_G], [X_TL_G, Y_TL_G]];

				RenderQuadVert(QuadPoly, QuadExtruder, Height, RenderRim, RimExtruder, RimHeight, RimThickness);
			}
			else 
			if (QuadType == "QT_TAPER")
			{
				X_Center = X_BL + RectWidth / 2;
				Y_Center = Y_BL + RectDepth / 2;
				
				TaperPoly = [[X_BL_G, Y_BL_G], [X_BR_G, Y_BR_G], [X_TR_G, Y_TR_G], [X_TL_G, Y_TL_G]];
				
				RenderQuadTaper(X_Center, Y_Center, TaperPoly, QuadExtruder, Height, TaperTopScale);
			}
			
			else if (QuadType == "QT_TOPO")
			{
				/* Get height of each corner */
				Z_BL = H[r][c];
				Z_BR = H[r][c+1];
				Z_TL = H[r+1][c];
				Z_TR = H[r+1][c+1];
				
				echo("[", r, ", ", c, "]: ", Z_TL, ", ", Z_TR, ", ", Z_BL, ", ", Z_BR);
				
				/* Create points for polyhedron */
				PolyPoints = 
				[
					[X_BL_G, Y_BL_G, 0],		// 0
					[X_BR_G, Y_BR_G, 0],		// 1
					[X_TR_G, Y_TR_G, 0],		// 2
					[X_TL_G, Y_TL_G, 0],		// 3
					[X_BL_G, Y_BL_G, Z_BL],		// 4
					[X_BR_G, Y_BR_G, Z_BR],		// 5
					[X_TR_G, Y_TR_G, Z_TR],		// 6
					[X_TL_G, Y_TL_G, Z_TL],		// 7
				];
				
				/* Create polyhedron */
				PolyFaces =
				[  
					[0,1,2,3],  // bottom
					[4,5,1,0],  // front
					[7,6,5,4],  // top
					[5,6,2,1],  // right
					[6,7,3,2],  // back
					[7,4,0,3]	// left
				];

				RenderQuadTopo(PolyPoints, PolyFaces, QuadExtruder);
			}
		}
	}
}

/* Render base below quads */
module RenderQuadBase(Rows, Cols, RectWidth, RectDepth, RectRowGap, RectColGap, BaseHeight, BaseMargin, BaseExtruder)
{
	translate([-BaseMargin, -BaseMargin, 0])
	{
		Extruder(BaseExtruder)
		{
			linear_extrude(BaseHeight)
			{
				square([_OverallWidth, _OverallDepth], center=false);
			}
		}
	}
}

module main(Rows, Cols, QuadType, HeightMode, RectWidth, RectDepth, RectRowGap, RectColGap, RowPert, ColPert, QuadHeight, HeightInc, Heights, TaperTopScale, MultiExtruder, RimExtruder, RenderRim, RimHeight, RimThickness, RenderBase, BaseHeight, BaseMargin, BaseExtruder, RenderLead, LeadHeight, LeadExtruder)
{
	RenderQuadGrid(Rows, Cols, QuadType, HeightMode, RectWidth, RectDepth, RectRowGap, RectColGap, RowPert, ColPert, QuadHeight, HeightInc, Heights, TaperTopScale, MultiExtruder, 1, RimExtruder, RenderRim, RimHeight, RimThickness);
	
	if (RenderBase)
	{
		translate([0, 0, -BaseHeight])
		{
			RenderQuadBase(Rows, Cols, RectWidth, RectDepth, RectRowGap, RectColGap, BaseHeight, BaseMargin, BaseExtruder);
		}
	}
	
	if (RenderLead)
	{
		difference()
		{
			// A full plate of lead
			translate([-BaseMargin, -BaseMargin, 0])
			{
				Extruder(LeadExtruder)
				{
					linear_extrude(LeadHeight - 0.001)
					{
						square([_OverallWidth, _OverallDepth], center=false);
					}
				}
			}
			
			// With holes cut out for the quad grid
			{
				RenderQuadGrid(Rows, Cols, QuadType, "HM_FIXED", RectWidth, RectDepth, RectRowGap, RectColGap, RowPert, ColPert, LeadHeight, HeightInc, Heights, TaperTopScale, false, "All", RimExtruder, RenderRim, RimHeight, RimThickness);
			}
		}
	}
}

main(_Rows, _Cols, _QuadType, _HeightMode, _RectWidth, _RectDepth, _RectRowGap, _RectColGap, _RowPert, _ColPert, _QuadHeight, _HeightInc, _Heights, _TaperTopScale, _MultiExtruder, _RimExtruder, _RenderRim, _RimHeight, _RimThickness, _RenderBase, _BaseHeight, _BaseMargin, _BaseExtruder, _RenderLead, _LeadHeight, _LeadExtruder);
