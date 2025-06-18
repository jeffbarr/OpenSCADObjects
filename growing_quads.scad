// Increasingly wide quadrilaterals

// TODO
// - Option to create a reflected pair of patterns
// - Option for a spine between reflected pair

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

/* [Extruders] */

// [Extruder 1]
_QuadExtruder1 = true;

// [Extruder 2]
_QuadExtruder2 = true;

// [Extruder 3]
_QuadExtruder3 = true;

// [Extruder 4]
_QuadExtruder4 = true;

// [Extruder 5]
_QuadExtruder5 = true;

// [Extruder to render]
_WhichExtruder = "All"; // ["All", 1, 2, 3, 4, 5]

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

// Quad - Render a single quad, then recurse to render the next one at +X
module Quad(QuadCount, QuadN, Height, BottomThickness, TopThickness, Gap, TopWidth, BottomWidth, AddTopWidthPct, AddBottomWidthPct, BottomX, TopX, QuadExtruders)
{
	echo("Quad(", "Count=", QuadCount, "N=", QuadN, "H=", Height, "BT=", BottomThickness, "TT=", TopThickness, "G=", Gap, "TW=", TopWidth, "BW=", BottomWidth, "ATWP=",AddTopWidthPct, "ABWP=", AddBottomWidthPct, "BX=", BottomX, "TX=", TopX, "Ex=", QuadExtruders, ")"); 
	
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

	Ex = ((QuadCount - QuadN) % len(QuadExtruders)) + 1;
	
	Extruder(Ex)
	{
		polyhedron(PolyhedronPoints, PolyhedronFaces);
	}
	
    if (QuadN > 1)
    {
        Quad(QuadCount, QuadN - 1, Height, BottomThickness, TopThickness, Gap, TopWidth + (TopWidth * AddTopWidthPct), BottomWidth + (BottomWidth * AddBottomWidthPct), AddTopWidthPct, AddBottomWidthPct, BottomX + BottomWidth + Gap, TopX + TopWidth + Gap, QuadExtruders);
     }
}

// Quads - Render QuadCount quads, starting at 0,0 and proceeding to +X
module Quads(QuadCount, QuadHeight, QuadBottomThickness, QuadTopThickness, QuadGap, QuadStartTopWidth, QuadStartBottomWidth, QuadAddTopWidthPct, QuadAddBottomWidthPct, QuadBottomX, QuadTopX, QuadExtruders)
{
    Quad(QuadCount, QuadCount, QuadHeight, QuadBottomThickness, QuadTopThickness, QuadGap, QuadStartTopWidth, QuadStartBottomWidth, QuadAddTopWidthPct, QuadAddBottomWidthPct, QuadBottomX, QuadTopX, QuadExtruders);
}

module main(QuadCount, QuadHeight, QuadBottomThickness, QuadTopThickness, QuadGap, QuadStartTopWidth, QuadStartBottomWidth, QuadAddTopWidthPct, QuadAddBottomWidthPct, QuadExtruder1, QuadExtruder2, QuadExtruder3,QuadExtruder4, QuadExtruder5)
{
    AllQuadExtruders = 
    [
        QuadExtruder1 ? 1 : 0, 
        QuadExtruder2 ? 2 : 0,
        QuadExtruder3 ? 3 : 0,
        QuadExtruder4 ? 4 : 0, 
        QuadExtruder5 ? 5 : 0
    ];
    
    QuadExtruders = [for (E = AllQuadExtruders) if (E != 0) E];

    Quads(QuadCount, QuadHeight, QuadBottomThickness, QuadTopThickness, QuadGap, QuadStartTopWidth, QuadStartBottomWidth, QuadAddTopWidthPct, QuadAddBottomWidthPct, 0, 0, QuadExtruders);
}

main(_QuadCount, _QuadHeight, _QuadBottomThickness, _QuadTopThickness, _QuadGap, _QuadStartTopWidth, _QuadStartBottomWidth, _QuadAddTopWidthPct, _QuadAddBottomWidthPct, _QuadExtruder1, _QuadExtruder2, _QuadExtruder3,_QuadExtruder4, _QuadExtruder5);

