// Fabric-Ready Honeycomb Skep
// Designed for Jeff Barr's fabric printing technique
// Rigid honeycomb sections with fabric joints between them
// Based on: https://nextjeff.com/3d-printing-on-fabric-tips-and-tricks-f306f4d56833

/* [Skep Dimensions] */
// Base diameter of the skep (mm)
BaseDiameter = 120; // [60:10:200]

// Height when fully extended (mm)
ExtendedHeight = 100; // [50:10:150]

// Number of collapsible sections
CollapsibleSections = 4; // [2:1:6]

/* [Honeycomb Pattern] */
// Hexagon cell size (mm)
HexSize = 8; // [4:1:15]

// Wall thickness of hexagons (mm)
WallThickness = 1.5; // [0.8:0.1:3]

// Cell depth (mm)
CellDepth = 3; // [2:0.5:6]

/* [Fabric Integration] */
// Fabric layer thickness (mm) - for spacing
FabricThickness = 0.3; // [0.2:0.1:1]

// Fabric overlap height (mm) - how much print overlaps fabric
FabricOverlap = 1.5; // [1:0.5:3]

// Add registration marks for fabric alignment
EnableRegistrationMarks = true;

/* [Entrance] */
// Enable entrance hole
EnableEntrance = true;

// Entrance diameter (mm)
EntranceDiameter = 20; // [10:2:40]

/* [Base] */
// Enable base ring
EnableBase = true;

// Base ring height (mm)
BaseHeight = 8; // [4:1:15]

/* [Extruders] */
// Extruder to render
_WhichExtruder = "All"; // ["All", 1, 2, 3, 4, 5]

// Base ring extruder
_BaseExtruder = 1; // [1, 2, 3, 4, 5]

// Honeycomb extruder
_HoneycombExtruder = 2; // [1, 2, 3, 4, 5]

// Registration marks extruder
_MarksExtruder = 3; // [1, 2, 3, 4, 5]

// Top knob extruder
_KnobExtruder = 4; // [1, 2, 3, 4, 5]

module __Customizer_Limit__ () {}

// Map extruder to color
function ExtruderColor(Extruder) = 
  (Extruder == 1  ) ? "saddlebrown" : 
  (Extruder == 2  ) ? "goldenrod"   : 
  (Extruder == 3  ) ? "red"         : 
  (Extruder == 4  ) ? "sienna"      :
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

// Create a hexagon
module hexagon(size, height) {
    cylinder(h=height, r=size, $fn=6);
}

// Create honeycomb cell
module honeycomb_cell(size, wall, depth) {
    difference() {
        hexagon(size, depth);
        translate([0, 0, -0.5])
        hexagon(size - wall, depth + 1);
    }
}

// Create a ring of hexagons
module hexagon_ring(radius, hex_size, wall, depth) {
    circumference = 2 * PI * radius;
    hex_count = max(6, floor(circumference / (hex_size * 1.8)));
    
    for (i = [0:hex_count-1]) {
        angle = (i / hex_count) * 360;
        x = radius * cos(angle);
        y = radius * sin(angle);
        
        translate([x, y, 0])
        rotate([0, 0, angle])
        honeycomb_cell(hex_size, wall, depth);
    }
}

// Create fabric attachment lip (bottom of section)
module fabric_attachment_lip_bottom(radius, overlap, thickness) {
    difference() {
        cylinder(h=overlap, r=radius + thickness, $fn=60);
        translate([0, 0, -0.5])
        cylinder(h=overlap + 1, r=radius, $fn=60);
    }
}

// Create fabric attachment lip (top of section)
module fabric_attachment_lip_top(radius, overlap, thickness) {
    translate([0, 0, -overlap])
    difference() {
        cylinder(h=overlap, r=radius + thickness, $fn=60);
        translate([0, 0, -0.5])
        cylinder(h=overlap + 1, r=radius, $fn=60);
    }
}

// Create registration marks for fabric alignment
module registration_marks(radius, count) {
    for (i = [0:count-1]) {
        angle = (i / count) * 360;
        x = radius * cos(angle);
        y = radius * sin(angle);
        
        translate([x, y, 0])
        cylinder(h=2, r=1, $fn=20);
    }
}

// Create one rigid honeycomb section with fabric attachment lips
module fabric_section(section_num, total_sections, base_r, section_height, hex_size, wall, cell_depth, fabric_overlap) {
    // Calculate taper for this section
    top_r = base_r * (1 - (section_num / total_sections) * 0.3);
    bottom_r = base_r * (1 - ((section_num - 1) / total_sections) * 0.3);
    
    union() {
        // Bottom fabric attachment lip
        if (section_num > 1) {
            fabric_attachment_lip_bottom(bottom_r, fabric_overlap, wall);
        }
        
        // Main honeycomb structure
        translate([0, 0, fabric_overlap])
        union() {
            // Bottom ring of hexagons
            hexagon_ring(bottom_r, hex_size, wall, cell_depth);
            
            // Middle ring
            translate([0, 0, section_height / 2])
            hexagon_ring((top_r + bottom_r) / 2, hex_size, wall, cell_depth);
            
            // Top ring of hexagons
            translate([0, 0, section_height])
            hexagon_ring(top_r, hex_size, wall, cell_depth);
            
            // Vertical connecting struts
            for (i = [0:5]) {
                angle = i * 60;
                x1 = bottom_r * cos(angle);
                y1 = bottom_r * sin(angle);
                x2 = top_r * cos(angle);
                y2 = top_r * sin(angle);
                
                hull() {
                    translate([x1, y1, 0])
                    cylinder(h=1, r=wall, $fn=8);
                    translate([x2, y2, section_height])
                    cylinder(h=1, r=wall, $fn=8);
                }
            }
        }
        
        // Top fabric attachment lip
        translate([0, 0, fabric_overlap + section_height])
        fabric_attachment_lip_top(top_r, fabric_overlap, wall);
        
        // Registration marks at top
        if (EnableRegistrationMarks) {
            translate([0, 0, fabric_overlap + section_height])
            registration_marks(top_r, 4);
        }
    }
}

// Create base ring
module base_ring(diameter, height, thickness) {
    difference() {
        cylinder(h=height, r=diameter/2 + thickness, $fn=60);
        translate([0, 0, -0.5])
        cylinder(h=height + 1, r=diameter/2, $fn=60);
    }
}

// Main assembly
module main() {
    section_height = (ExtendedHeight - (CollapsibleSections * FabricOverlap * 2)) / CollapsibleSections;
    
    difference() {
        union() {
            // Base ring
            if (EnableBase) {
                Extruder(_BaseExtruder)
                base_ring(BaseDiameter, BaseHeight, 3);
            }
            
            // Collapsible sections with fabric joints
            for (section = [1:CollapsibleSections]) {
                // Calculate Z offset accounting for fabric layers
                z_offset = (EnableBase ? BaseHeight : 0) + 
                          (section - 1) * (section_height + FabricThickness + FabricOverlap * 2);
                
                translate([0, 0, z_offset]) {
                    // Honeycomb section with fabric attachment lips
                    Extruder(_HoneycombExtruder)
                    fabric_section(
                        section, 
                        CollapsibleSections, 
                        BaseDiameter/2, 
                        section_height, 
                        HexSize, 
                        WallThickness, 
                        CellDepth,
                        FabricOverlap
                    );
                    
                    // Registration marks
                    if (EnableRegistrationMarks && section > 1) {
                        Extruder(_MarksExtruder)
                        registration_marks(
                            BaseDiameter/2 * (1 - ((section - 1) / CollapsibleSections) * 0.3),
                            4
                        );
                    }
                }
            }
            
            // Top decorative knob
            Extruder(_KnobExtruder)
            translate([0, 0, (EnableBase ? BaseHeight : 0) + ExtendedHeight])
            sphere(r=8, $fn=30);
        }
        
        // Entrance hole
        if (EnableEntrance) {
            translate([BaseDiameter/2, 0, BaseHeight + 15])
            rotate([0, 90, 0])
            cylinder(h=30, r=EntranceDiameter/2, center=true, $fn=30);
        }
    }
}

// Add comment block for printing instructions
echo("=== FABRIC PRINTING INSTRUCTIONS ===");
echo("1. Print first section completely");
echo("2. PAUSE print at each section boundary");
echo("3. Cut tulle to size using registration marks");
echo("4. Tape tulle to print bed");
echo("5. Resume print - next section will print over fabric");
echo("6. Repeat for each section");
echo("7. Fabric creates flexible joints between rigid sections");
echo("====================================");

main();
