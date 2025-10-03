/* Tiling Patterns of Truchet, Fig 19 */

// Multi-extruder
// Filled circle or ring

/* [Seed] */
_Seed = 13;

/* [Square Size] */
_SquareSize = 10;

/* [Square Height] */
_SquareHeight = 2.0;

/* [Count X] */
_SquareCountX = 10;

/* [Count Y] */
_SquareCountY = 10;

/* [Gap] */
_SquareGap = 0.5;


module RenderSquare(SquareSize, SquareHeight) 
{
    union()
    {
        cube([SquareSize, SquareSize, SquareHeight], center=false);
        
        translate([0, 0, SquareHeight])
        {
            intersection()
            {
                cube([SquareSize, SquareSize, 99], center=false);
                
                color("red")
                union()
                {
                    circle(SquareSize / 2);
                
                    translate([SquareSize, SquareSize, 0])
                    {   
                        circle(SquareSize / 2);
                    }
                }
            }  
        }
     }
}

module RenderRotatedSquare(SquareSize, SquareHeight, Rotated)
{
    if (Rotated)
    {
        translate([SquareSize / 2, SquareSize / 2, 0])
        {
            rotate([0, 0, 90])
            {
                translate([-SquareSize / 2, -SquareSize / 2, 0])
                {
                    RenderSquare(SquareSize, SquareHeight);
                }
            }
        }
    }
    else
    {
        RenderSquare(SquareSize, SquareHeight);
    }
}

module main(Seed, SquareCountX, SquareCountY, SquareSize, SquareHeight, SquareGap)
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
                RenderRotatedSquare(SquareSize, SquareHeight, Vertical);
            }
        }
    }
    
}

main(_Seed, _SquareCountX, _SquareCountY, _SquareSize, _SquareHeight, _SquareGap);
