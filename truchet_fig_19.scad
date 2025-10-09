/* Tiling Patterns of Truchet, Fig 19 */

/* [Seed] */
_Seed = 13;

/* [Square Size] */
_SquareSize = 10;

/* [Square Height] */
_SquareHeight = 2.0;

/* [CircleMode] */
_CircleMode = "Circle";     // [Circle, Ring]

/* Circle Height] */
_CircleHeight = 0.4;

/* [Count X] */
_SquareCountX = 10;

/* [Count Y] */
_SquareCountY = 10;

/* [Gap] */
_SquareGap = 0.5;

/* [Ring Width] */
_RingWidth = 1.2;

/* [Extruders] */

// [Square Extruder]
_SquareExtruder = 1;

// [Circle Extruder]
_CircleExtruder = 2;

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

module RenderCircleOrRing(CircleMode, SquareSize, CircleHeight, RingWidth)
{
    if (CircleMode == "Circle")
    {
        circle(SquareSize / 2, $fn=99);
    }
    
    if (CircleMode == "Ring")
    {
        difference()
        {
            // Outer ring
            circle(SquareSize / 2 + RingWidth / 2, $fn=99);
            
            // Inner ring
            circle(SquareSize / 2 - RingWidth / 2, $fn=99);
        }
    }
}

module RenderSquare(SquareExtruder, CircleExtruder, SquareSize, SquareHeight, CircleMode, CircleHeight, RingWidth) 
{
    union()
    {
		Extruder(SquareExtruder)
		{
			cube([SquareSize, SquareSize, SquareHeight], center=false);
        }
		
        translate([0, 0, SquareHeight])
        {
            intersection()
            {
                // Clip circle or rings at edges of square
                cube([SquareSize, SquareSize, 99], center=false);
                
				Extruder(CircleExtruder)
                {
                    linear_extrude(CircleHeight)
                    {
                        union()
                        {
                            RenderCircleOrRing(CircleMode, SquareSize, CircleHeight, RingWidth);

                            translate([SquareSize, SquareSize, 0])
                            {   
                                RenderCircleOrRing(CircleMode, SquareSize, CircleHeight, RingWidth);
                            }
                        }
                     }
                 }
            }  
        }
     }
}

module RenderRotatedSquare(SquareExtruder, CircleExtruder, SquareSize, SquareHeight, CircleMode, CircleHeight, RingWidth, Rotated)
{
    if (Rotated)
    {
        translate([SquareSize / 2, SquareSize / 2, 0])
        {
            rotate([0, 0, 90])
            {
                translate([-SquareSize / 2, -SquareSize / 2, 0])
                {
                    RenderSquare(SquareExtruder, CircleExtruder, SquareSize, SquareHeight, CircleMode, CircleHeight, RingWidth);
                }
            }
        }
    }
    else
    {
        RenderSquare(SquareExtruder, CircleExtruder, SquareSize, SquareHeight, CircleMode, CircleHeight, RingWidth);
    }
}

module main(Seed, SquareCountX, SquareCountY, SquareExtruder, CircleExtruder, SquareSize, CircleMode, SquareHeight, CircleHeight, RingWidth, SquareGap)
{
    // Generate list of random numbers to set which squares are rendered vertically 
    // and which ones are renderer horizontally:
    
    Verticals = rands(0, 1.001, SquareCountX * SquareCountY, Seed);
    
    for (X = [0 : SquareCountX - 1])
    {
        for (Y = [0 : SquareCountY - 1])
        {
            PointX = X * (SquareSize + SquareGap);
            PointY = Y * (SquareSize + SquareGap);
            
            translate([PointX, PointY, 0])
            {
                Vertical = (Verticals[SquareCountY * X + Y] < 0.5) ? true : false;
                RenderRotatedSquare(SquareExtruder, CircleExtruder, SquareSize, SquareHeight, CircleMode, CircleHeight, RingWidth, Vertical);
            }
        }
    }
    
}

main(_Seed, _SquareCountX, _SquareCountY, _SquareExtruder, _CircleExtruder, _SquareSize, _CircleMode, _SquareHeight, _CircleHeight, _RingWidth, _SquareGap);
