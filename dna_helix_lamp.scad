// DNA Helix Lamp - A decorative double helix with connecting nodes
// Perfect for LED strip lighting or as a decorative piece
// Now with collapsible sections and multi-color support!

/* [Helix Dimensions] */
// Total height of the lamp
Height = 200; // [50:10:400]

// Radius of the helix
HelixRadius = 40; // [20:5:100]

// Number of complete rotations
NumTurns = 4; // [1:1:10]

/* [Strand & Node Settings] */
// Thickness of the DNA strands
StrandThickness = 4; // [2:0.5:10]

// Size of connecting nodes
NodeSize = 8; // [4:1:15]

// Number of connecting nodes
NumNodes = 40; // [10:5:100]

/* [Base Settings] */
// Height of the base
BaseHeight = 10; // [5:1:20]

// Radius of the base
BaseRadius = 60; // [30:5:100]

// Number of decorative elements on base
BasePatternCount = 12; // [6:1:24]

/* [Collapsible Design] */
// Enable collapsible sections with fabric joints
EnableCollapsible = true;

// Number of collapsible sections
CollapsibleSections = 4; // [2:1:8]

// Fabric joint height (spacing between sections)
FabricJointHeight = 2; // [1:0.5:5]

/* [Top Cap] */
// Enable top sphere
EnableTopCap = true;

// Top cap radius
TopCapRadius = 15; // [8:1:25]

/* [Extruders] */
// Extruder to render
_WhichExtruder = "All"; // ["All", 1, 2, 3, 4, 5]

// Base extruder
_BaseExtruder = 1; // [1, 2, 3, 4, 5]

// First strand extruder
_Strand1Extruder = 2; // [1, 2, 3, 4, 5]

// Second strand extruder
_Strand2Extruder = 3; // [1, 2, 3, 4, 5]

// Nodes extruder
_NodesExtruder = 4; // [1, 2, 3, 4, 5]

// Top cap extruder
_TopCapExtruder = 5; // [1, 2, 3, 4, 5]

module __Customizer_Limit__ () {}

// Map extruder to color
function ExtruderColor(Extruder) = 
  (Extruder == 1  ) ? "saddlebrown" : 
  (Extruder == 2  ) ? "cyan"        : 
  (Extruder == 3  ) ? "magenta"     : 
  (Extruder == 4  ) ? "yellow"      :
  (Extruder == 5  ) ? "orange"      :
                      "purple";

// Extruder wrapper
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

// === Helper Functions ===
module helix_strand(offset_angle = 0, start_z = 0, end_z = -1) {
    actual_end_z = (end_z < 0) ? Height : end_z;
    
    for (i = [0:$fn-1]) {
        t = i / $fn;
        z = start_z + t * (actual_end_z - start_z);
        
        // Only render if within our section
        if (z >= start_z && z <= actual_end_z) {
            angle = (z / Height) * 360 * NumTurns + offset_angle;
            next_t = (i+1) / $fn;
            next_z = start_z + next_t * (actual_end_z - start_z);
            
            if (next_z > actual_end_z) {
                next_z = actual_end_z;
            }
            
            next_angle = (next_z / Height) * 360 * NumTurns + offset_angle;
            
            hull() {
                translate([
                    HelixRadius * cos(angle),
                    HelixRadius * sin(angle),
                    z
                ])
                sphere(r=StrandThickness, $fn=20);
                
                translate([
                    HelixRadius * cos(next_angle),
                    HelixRadius * sin(next_angle),
                    next_z
                ])
                sphere(r=StrandThickness, $fn=20);
            }
        }
    }
}

module connecting_nodes(start_z = 0, end_z = -1) {
    actual_end_z = (end_z < 0) ? Height : end_z;
    
    for (i = [0:NumNodes-1]) {
        z = (i / NumNodes) * Height;
        
        // Only render if within our section
        if (z >= start_z && z <= actual_end_z) {
            angle = (z / Height) * 360 * NumTurns;
            
            // Node on first strand
            translate([
                HelixRadius * cos(angle),
                HelixRadius * sin(angle),
                z
            ])
            sphere(r=NodeSize, $fn=16);
            
            // Node on second strand
            translate([
                HelixRadius * cos(angle + 180),
                HelixRadius * sin(angle + 180),
                z
            ])
            sphere(r=NodeSize, $fn=16);
            
            // Connecting bar between strands
            hull() {
                translate([
                    HelixRadius * cos(angle),
                    HelixRadius * sin(angle),
                    z
                ])
                sphere(r=StrandThickness * 0.6, $fn=12);
                
                translate([
                    HelixRadius * cos(angle + 180),
                    HelixRadius * sin(angle + 180),
                    z
                ])
                sphere(r=StrandThickness * 0.6, $fn=12);
            }
        }
    }
}

module decorative_base() {
    difference() {
        union() {
            // Main base
            cylinder(h=BaseHeight, r=BaseRadius, $fn=60);
            
            // Decorative rim
            translate([0, 0, BaseHeight])
            cylinder(h=3, r1=BaseRadius, r2=BaseRadius-5, $fn=60);
            
            // Pattern on base
            for (i = [0:BasePatternCount-1]) {
                rotate([0, 0, i * (360/BasePatternCount)])
                translate([BaseRadius - 10, 0, BaseHeight/2])
                cylinder(h=BaseHeight, r=3, center=true, $fn=20);
            }
        }
        
        // Hollow out the center for LED wiring
        translate([0, 0, -1])
        cylinder(h=BaseHeight + 2, r=BaseRadius - 8, $fn=60);
    }
}

// === Main Assembly ===
$fn = 100; // Smoothness of the helix

// Base
Extruder(_BaseExtruder)
decorative_base();

if (EnableCollapsible) {
    // Collapsible sections with fabric joints
    section_height = Height / CollapsibleSections;
    
    for (section = [0:CollapsibleSections-1]) {
        start_z = BaseHeight + section * (section_height + FabricJointHeight);
        end_z = start_z + section_height;
        
        // First DNA strand section
        Extruder(_Strand1Extruder)
        helix_strand(0, start_z, end_z);
        
        // Second DNA strand section (180 degrees offset)
        Extruder(_Strand2Extruder)
        helix_strand(180, start_z, end_z);
        
        // Connecting nodes for this section
        Extruder(_NodesExtruder)
        connecting_nodes(start_z, end_z);
    }
    
    // Add fabric joint indicators (thin rings)
    for (section = [1:CollapsibleSections-1]) {
        joint_z = BaseHeight + section * (section_height + FabricJointHeight) - FabricJointHeight/2;
        
        Extruder(_NodesExtruder)
        translate([0, 0, joint_z])
        difference() {
            cylinder(h=0.5, r=HelixRadius + StrandThickness + 2, $fn=60);
            translate([0, 0, -0.5])
            cylinder(h=2, r=HelixRadius - StrandThickness - 2, $fn=60);
        }
    }
} else {
    // Non-collapsible version
    // First DNA strand
    Extruder(_Strand1Extruder)
    translate([0, 0, BaseHeight])
    helix_strand(0, 0, Height);
    
    // Second DNA strand (180 degrees offset)
    Extruder(_Strand2Extruder)
    translate([0, 0, BaseHeight])
    helix_strand(180, 0, Height);
    
    // Connecting nodes
    Extruder(_NodesExtruder)
    translate([0, 0, BaseHeight])
    connecting_nodes(0, Height);
}

// Optional: Top cap
if (EnableTopCap) {
    Extruder(_TopCapExtruder)
    translate([0, 0, BaseHeight + Height])
    sphere(r=TopCapRadius, $fn=40);
}

echo("=== DNA HELIX LAMP ===");
echo(str("Height: ", Height, "mm"));
echo(str("Collapsible: ", EnableCollapsible ? "Yes" : "No"));
if (EnableCollapsible) {
    echo(str("Sections: ", CollapsibleSections));
    echo("FABRIC PRINTING: Pause at each section boundary to insert fabric");
}
echo("=====================");
