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
 * Good settings:
 *
 * Rows	Cols	RectWidth	RectDepth	RectRowGap	RectColGap	RowPert	ColPert
 * ----	----	---------	---------	----------	----------	-------	-------
 *	9	9		16			16			2			2			8		8
 *	12	12		15			15
 */

/*
 * Each x in the grid is a point that will be perturbed (in x and y) 
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
 */
 
/* Define the grid */
Rows = 12;
Cols = 12;

/* Define size of rectangles */
RectWidth = 15;
RectDepth = 15;

/* Define gap between rectangles */
RectRowGap = 2;
RectColGap = 2;

/* 
 * Define amount of perturbation per rectangle, this is -/+, so the 
 * perturbation can be from (-RowPert) to (RowPert), and the same 
 * for ColPert. 
 */
RowPert = 8;
ColPert = 8;

/* Set height mode */
//HeightMode = "HM_FIXED";
HeightMode = "HM_RANDOM";

/* Set quad type */
//QuadType = "QT_VERT";
QuadType = "QT_TAPER";

/* Set options for fixed and random heights */
BaseHeight = 3;
HeightInc  = 0.4;
Heights    = 7;

/* Compute overall size */
Width = (Cols * RectWidth) + ((Cols - 1) * RectColGap);
Depth = (Cols * RectDepth) + ((Rows - 1) * RectRowGap);

echo ("Overall size: ", Width, Depth);

/* Build the grid */
G = 
[
	[for (c = [0 : Cols]) [ 0, 0]],
		
	for (r = [1 : Rows - 1]) 
		[	[0, 0],
			for (c = [1 : Cols - 1]) [
				round(rands(-RowPert, RowPert, 1)[0]), 
				round(rands(-ColPert, ColPert, 1)[0])],
			[0, 0]				
		],
			
	[for (c = [0 : Cols]) [ 0, 0]],
];

for (r = [0 : Rows])
{
	echo("Row: ", r);
	echo("  ", G[r], "\n");
}
	

/*
 *	  [X_TL, Y_TL]       [X_TR, Y_TR]
 *    +-------------...-------------+
 *    |                             |
 *    .                             .
 *    |                             |
 *    +-------------...-------------+
 *	  [X_BL, Y_BL]       [X_BR, Y_BR]
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
	
		/* Pick a height based on HeightMode */
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
			
	}
}
