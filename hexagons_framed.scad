/* Hexagons in an offset grid with a frame */
{
  /* hexagons_l15_3_23 */
  R = 11.5; // Radius
  H = 1.2;    //Height 
  G = 19;   // Gap between items 
  F = 6;    // Hexagon 
  V = 16;    // Height count in Y direction
  W = 18;    // Width count in X direction
}

{
  /* hexagons_7_12_19_31
   *
   * Fills 250x150 bed with allowance for frame
   */
/*  
  R = 7;   // Radius
  H = 3;   // Height
  G = 12;  // Gap between items
  F = 6;   // Hexagon
  V = 19;    // Height count in Y direction
  W = 31;  // Width count in X direction
 */
}


/* 
 * frame
 */

OuterWidth = 250;
OuterDepth = 150;
Border = 7;
Step = 10;

translate([Border + Border + 2, Border + Border + Border + 2, 0])
{
    for (y = [0 : 2 : V / 2])
    {
        /* Even Row */
        for (x=[0 : 2 : W])
        { 
            color("red")
            linear_extrude(height=H) translate([x * R, (y * G), 0]) rotate([0, 0,90]) circle(R, $fn=F);
        }
        
        /* Odd Row */
        for (x =[1 : 2 : W])
        {
            color("blue")
            linear_extrude(height = H) translate([x * R, ((y + 1) * G), 0]) rotate([0, 0,90]) circle(R, $fn=F);
        }
        
        /* Initial half-hexagon at start of odd row */
        /* Not yet working, need genuine hexagon math */
        /*
            color("purple")
            linear_extrude(height = H) 
             translate([- R, ((y + 1) * G), 0]) 
                intersection()
                {
                    //rotate([0, 0,90])circle(R, $fn=F);
                    translate([R/2, 0, 0]) rotate([0, 0, 0]) square([R/2, R], center=false);
                }
        */
            
    }
}

InnerWidth = OuterWidth - (2 * Border);
InnerDepth = OuterDepth - (2 * Border);

linear_extrude(height=H) 
    {
      difference () 
      {
          //square([OuterWidth, OuterDepth]);
          //translate([Border, Border, 0]) square([InnerWidth, InnerDepth]);
      }
    };

