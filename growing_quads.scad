// Increasingly wide quadrilaterals

// TODO
// - Multiple extruder mod support
// - Option to create a reflected pair of patterns

/* [Quads] */

// [Count]
_QuadCount = 5;

// [Height]
_QuadHeight = 100;

// [Bottom Thickness]
_QuadBottomThickness = 2.0;

// [Top Thickness]
_QuadTopThickness = 2.0;

// [Quad-to-quad Gap]
_QuadGap = 5;

// [Starting Top Width]
_QuadStartTopWidth = 10;

// [Starting Bottom Width]
_QuadStartBottomWidth = 15;

// [Additonal Top Width %]
_QuadAddTopWidthPct = 0.20;

// Additional Bottom Width %]
_QuadAddBottomWidthPct = 0.25;

// Quad - Render a single quad, then recurse to render the next one at +X
module Quad(QuadN, Height, BottomThickness, TopThickness, Gap, TopWidth, BottomWidth, AddTopWidthPct, AddBottomWidthPct, BottomX, TopX)
{
	echo("Quad(", "N=", QuadN, "H=", Height, "BT=", BottomThickness, "TT=", TopThickness, "G=", Gap, "TW=", TopWidth, "BW=", BottomWidth, "ATWP=",AddTopWidthPct, "ABWP=", AddBottomWidthPct, "BX=", BottomX, "TX=", TopX, ")"); 
	
	PT0 = [BottomX + 0,           0,      0];
	PT1 = [BottomX + BottomWidth, 0,      0];
	PT4 = [BottomX + 0,           0,      BottomThickness];
	PT5 = [BottomX + BottomWidth, 0,      BottomThickness];
	
	PT2 = [TopX + TopWidth,    Height, 0];
	PT3 = [TopX + 0,           Height, 0];
	PT6 = [TopX + TopWidth,    Height, TopThickness];
	PT7=  [TopX + 0,           Height, TopThickness];
	
	PolyhedronPoints =
	[
		PT0, PT1, PT2, PT3, PT4, PT5, PT6, PT7
	];
	
	PolyhedronFaces =
	[
		[0, 1, 2, 3],
		[4, 5, 1, 0],
		[7, 6, 5, 4],
		[5, 6, 2, 1],
		[6, 7, 3, 2],
		[7, 4, 0, 3]
	];
	
	polyhedron(PolyhedronPoints, PolyhedronFaces);
	
	
    if (QuadN > 1)
    {
        Quad(QuadN - 1, Height, BottomThickness, TopThickness, Gap, TopWidth + (TopWidth * AddTopWidthPct), BottomWidth + (BottomWidth * AddBottomWidthPct), AddTopWidthPct, AddBottomWidthPct, BottomX + BottomWidth + Gap, TopX + TopWidth + Gap);
     }
}

// Quads - Render QuadCount quads, starting at 0,0 and proceeding to +X
module Quads(QuadCount, QuadHeight, QuadBottomThickness, QuadTopThickness, QuadGap, QuadStartTopWidth, QuadStartBottomWidth, QuadAddTopWidthPct, QuadAddBottomWidthPct, QuadBottomX, QuadTopX)
{
    Quad(QuadCount, QuadHeight, QuadBottomThickness, QuadTopThickness, QuadGap, QuadStartTopWidth, QuadStartBottomWidth, QuadAddTopWidthPct, QuadAddBottomWidthPct, QuadBottomX, QuadTopX);
}

module main(QuadCount, QuadHeight, QuadBottomThickness, QuadTopThickness, QuadGap, QuadStartTopWidth, QuadStartBottomWidth, QuadAddTopWidthPct, QuadAddBottomWidthPct)
{
    Quads(QuadCount, QuadHeight, QuadBottomThickness, QuadTopThickness, QuadGap, QuadStartTopWidth, QuadStartBottomWidth, QuadAddTopWidthPct, QuadAddBottomWidthPct, 0, 0);
}

main(_QuadCount, _QuadHeight, _QuadBottomThickness, _QuadTopThickness, _QuadGap, _QuadStartTopWidth, _QuadStartBottomWidth, _QuadAddTopWidthPct, _QuadAddBottomWidthPct);

