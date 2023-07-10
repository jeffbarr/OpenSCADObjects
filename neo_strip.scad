/*
 * NeoPixel strip + cover, fully parameterized
 */
 
NN = 8;             // Number of NeoPixels
IH = false;         // True to generate interior hexagons  
SB = false;         // True to generate half-slot at beginning
SE = false;         // True to generate half-slot at end
NR = 5;             // Radius of hexagon for a single NeoPixel

NC = 16.2;          // Center-to-center NeoPixel spacing (measured)
SZ = 4.1;           // Height of channel for NeoPixel strip (measured)
SY = 12.3;          // Width of channel for NeoPixel strip (measured)

TY = 20;            // Total width, must be > SY
TZ1 = 6;            // Height from base to top of hexagon plane
TZ2 = 10;           // Height from base to top of plate that covers hexagon plane
CZ1 = 1;            // Height of cover
DY  = 1;            // Thickness of divider
SLOT_GROW = 1.2;    // Growth factor for slots (literal wiggle room)

/*
 * Parameter sanity checks:
 */
 
assert(TY > SY, "TY must be greater than SY.");

/* 
 * Derived values:
 */
 
 NE = NC / 2;                       // Space from edge to center of first & last hexagon
 TX = NE + (NN - 1) * NC + NE;      // Total depth
 DZ = TZ1 - SZ;                     // Height of divider slot

 echo("NE=", NE);
 echo("TX=", TX);
 echo("DZ=", DZ);

/* 
 * Strip
 */
 
difference()
{
    // Main block
    cube([TX, TY, TZ2]);
    
    // Channel for NeoPixel strip
    translate([0, (TY - SY) / 2, 0])
    {
        cube([TX, SY, SZ]);
    }
    
    // Hexagons for NeoPixels
    for (n = [0 : 1 : NN - 1])
    {
        translate([NE + (n * NC), TY / 2, SZ])
        {
            linear_extrude(TZ1 - SZ)
            {
                if (IH)
                {
                    circle(NR, $fn = 6);
                }
            }
        }
    }
    
    // Slots for dividers between hexagons to block light
    //  Extra half-slot at beginning if SB is set
    //  Extra half-slot at end if SE is set
    
    StartN = SB ? -1 : 0;
    EndN   = SE ? (NN -1) : (NN - 2);
    for (n = [StartN : 1 : EndN])
    {
        translate([NE + (n * NC) + (NC / 2), TY / 2, TZ2])
        {
            cube([DY * SLOT_GROW, (2 * NR) * SLOT_GROW, 4 * DZ], center=true);
        }
    }
}

/*
 * Cover:
 */

translate([0, 2 * TY, 0])
{
    difference()
    {
        // Main block
        cube([TX, TY, CZ1]);
        
        // Hexagons for NeoPixels
        for (n = [0 : 1 : NN - 1])
        {
            translate([NE + (n * NC), TY / 2, 0])
            {
                linear_extrude(CZ1)
                {
                    circle(NR, $fn = 6);
                }
            }
        }
    }
    
    // Dividers between hexagons
    for (n = [0 : 1 : NN - 2])
    {
        translate([NE + (n * NC) + (NC / 2), TY / 2, CZ1 + (DZ / 2)])
        {
            color("red") cube([DY, 2 * NR, 2 * DZ], center=true);
        }
    }
}

