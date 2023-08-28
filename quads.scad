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
Rows = 12;
// Number of columns in the grid 
Cols = 12;

/* 
 * Define size of each rectangle in the grid:
 */

// Width of each rectangle
RectWidth = 15;
// Depth of each rectangle
RectDepth = 15;

/* 
 * Define gap between rectangles:
 */

// Gap between each row of rectangles
RectRowGap = 2;
// Gap between each column of rectangles
RectColGap = 2;

/* 
 * Define amount of perturbation per rectangle, this is -/+, so the 
 * perturbation can be from (-RowPert) to (RowPert), and the same 
 * for ColPert. 
 */
 
// Max perturbation between rows
RowPert = 8;
// Max perturbation between columns
ColPert = 8;

/* 
 * Set height mode:
 */
 
// Height mode
HeightMode = "HM_FIXED"; // [HM_FIXED, HM_RANDOM]

/*
 * Define height parameters:
*/

// Base height
BaseHeight = 3;		// [0.2 : 10]
// Height increment
HeightInc  = 0.4; 	// [0.2 : 0.2 : 10]
// Number of random heights
Heights    = 7;		// [1 : 20]

/* 
 * Set quad type:
 */
 
// Quad type
QuadType = "QT_VERT"; // [QT_VERT, QT_TAPER, QT_TOPO]

/* End of customization */
module __Customizer_Limit__ () {}

/* Perform sanity checks */
assert(Rows > 0);
assert(Cols > 0);
assert(RectWidth > 0);
assert(RectDepth > 0);
assert(RectRowGap >= 0);
assert(RectColGap >= 0);
assert(RowPert >= 0);
assert(ColPert >= 0);
assert((HeightMode == "HM_FIXED") || (HeightMode == "HM_RANDOM"));
assert((QuadType == "QT_VERT") || (QuadType == "QT_TAPER") || (QuadType == "QT_TOPO"));

/* Compute overall size */
Width = (Cols * RectWidth) + ((Cols - 1) * RectColGap);
Depth = (Cols * RectDepth) + ((Rows - 1) * RectRowGap);

echo ("Overall size: ", Width, Depth);

/* Build the G grid */
G = 
[
	[for (c = [0 : Cols]) [ 0, 0]],
		
	for (r = [1 : Rows - 1]) 
		[
			[0, 0],
			for (c = [1 : Cols - 1]) [
				round(rands(-RowPert, RowPert, 1)[0]), 
				round(rands(-ColPert, ColPert, 1)[0])],
			[0, 0]				
		],
			
	[for (c = [0 : Cols]) [ 0, 0]],
];

echo("G Grid:");
for (r = [0 : Rows])
{
	echo("  Row: ", r);
	echo("    ", G[r], "\n");
}

/* Build the H grid */
H =
[
	[for (c = [0 : Cols]) BaseHeight],
		
	for (r = [1 : Rows - 1]) 
		[	
			BaseHeight,
			for (c = [1 : Cols - 1]) BaseHeight + floor(rands(0, Heights, 1)[0]) * HeightInc,
			BaseHeight				
		],	
		
	[for (c = [0 : Cols]) BaseHeight],
];
	
echo("H Grid:");
for (r = [0 : Rows])
{
	echo("  Row: ", r);
	echo("    ", H[r], "\n");
}
	
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

translate([-Width / 2, -Depth / 2, 0])
/* Construct polygons */
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
			(HeightMode == "HM_FIXED")  ? BaseHeight :
			(HeightMode == "HM_RANDOM") ? BaseHeight + floor(rands(0, Heights, 1)[0]) * HeightInc :
			0;
		
		/* Generate quad based on QuadType */
		if (QuadType == "QT_VERT")
		{
			linear_extrude(Height)
				polygon([[X_BL_G, Y_BL_G], [X_BR_G, Y_BR_G], 
						 [X_TR_G, Y_TR_G], [X_TL_G, Y_TL_G]]);
		}
		else 
		if (QuadType == "QT_TAPER")
		{
			X_Center = X_BL + RectWidth / 2;
			Y_Center = Y_BL + RectDepth / 2;
			
			translate([X_Center, Y_Center, 0])
				linear_extrude(Height, scale=0.5)
					translate([-X_Center, -Y_Center, 0])
						polygon([[X_BL_G, Y_BL_G], [X_BR_G, Y_BR_G], 
								 [X_TR_G, Y_TR_G], [X_TL_G, Y_TL_G]]);
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

			polyhedron(points=PolyPoints,faces=PolyFaces);
		}
	}
}
