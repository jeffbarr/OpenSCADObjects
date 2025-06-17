// Increasingly wide quadrilaterals

/* [Quads] */

// [Count]
_QuadCount = 5;

// [Height]
_QuadHeight = 100;

// [Thickness]
_QuadThickness = 2.0;

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

// Quad - Recursion continuation
module Quad(QuadN, Height, Gap, Thickness, TopWidth, BottomWidth, AddTopWidthPct, AddBottomWidthPct, BottomX, TopX)
{
    Poly =
    [
        [BottomX, 0],
        [BottomX + BottomWidth, 0],
        [TopX + TopWidth, Height],
        [TopX, Height]
    ];
    
    linear_extrude(Thickness)
    {
        polygon(Poly);
    }
    
    if (QuadN > 1)
    {
        Quad(QuadN - 1, Height, Gap, Thickness, TopWidth + (TopWidth * AddTopWidthPct), BottomWidth + (BottomWidth * AddBottomWidthPct), AddTopWidthPct, AddBottomWidthPct, BottomX + BottomWidth + Gap, TopX + TopWidth + Gap);
     }
}

// Quads - Recursion starter
module Quads(QuadCount, QuadHeight, QuadGap, QuadThickness, QuadStartTopWidth, QuadStartBottomWidth, QuadAddTopWidthPct, QuadAddBottomWidthPct, QuadBottomX, QuadTopX)
{
    Quad(QuadCount, QuadHeight, QuadThickness, QuadGap, QuadStartTopWidth, QuadStartBottomWidth, QuadAddTopWidthPct, QuadAddBottomWidthPct, QuadBottomX, QuadTopX);
}

module main(QuadCount, QuadHeight, QuadThickness, QuadGap, QuadStartTopWidth, QuadStartBottomWidth, QuadAddTopWidthPct, QuadAddBottomWidthPct)
{
    Quads(QuadCount, QuadHeight, QuadThickness, QuadGap, QuadStartTopWidth, QuadStartBottomWidth, QuadAddTopWidthPct, QuadAddBottomWidthPct, 0, 0);
}

main(_QuadCount, _QuadHeight, _QuadThickness, _QuadGap, _QuadStartTopWidth, _QuadStartBottomWidth, _QuadAddTopWidthPct, _QuadAddBottomWidthPct);

