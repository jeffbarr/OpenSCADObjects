/* 
 * Spikes on rafts, with selectable spike type:
 * 
 * Cylindrical - Cylinder topped by point
 * Pyramidal   - Pyramid
 *
 * Holes around the border of the raft are optional, and can be used to connect rafts with rings.
 */

// Number of rafts
_RaftCount = 1;

// Space between rafts
_RaftSpaceX = 20;

// Raft height
_RaftHeight = 2.0; // [0 : 0.2 : 4.0]

// Border
_RaftBorder = 10;

// Holes in raft below spikes
_RaftHoles = false;

// Rows of spikes per raft
_SpikeCountY = 4;

// Columns of spikes per raft
_SpikeCountX = 4;

// Space between columns of spikes
_SpikeSpaceX = 10;

// Space between rows of spikes
_SpikeSpaceY = 10;

// Spike type
_SpikeType = "Cylinder"; // ["Cylinder", "Pyramid"]

/* [Cylindrical Spikes] */
// Spike radius
_CylSpikeRadius = 7;

// Spike cylinder height
_CylSpikeCylHeight = 7.1;

// Spike tip height
_CylSpikeTipHeight = 5.3;

// Spike wall thickness
_CylSpikeWall = 2;

/* [Pyramidal Spikes] */
// Spike base width/depth
_PyrBase = 14;

// Spike height
_PyrHeight = 35;

// Spike wall thickness
_PyrWall = 2;

/* [Border Holes] */

// Holes to connect borders
_BorderHoles = true;

// Hole diameter
_BorderHoleDiameter = 1;

// Hole inset from perimeter
_BorderHoleInset = 2.5;

// Hole inset from corner
_BorderCornerHoleInset = 5.0;

module __end_customization() {}

/* Pyramid points */
PyrPoints =
[
    [0, 0, 0],
    [1, 0, 0],
    [1, 1, 0],
    [0, 1, 0],
    [0.5, 0.5, 1]
];

/* Pyramid faces */
PyrFaces =
[
    [0, 1, 2, 3],
    [4, 1, 0],
    [4, 2, 1],
    [4, 3, 2],
    [4, 0, 3]
];

// Render one spike (cylinder or pyramid)
module Spike(SpikeType, SpikeRadius, SpikeCylHeight, SpikeTipHeight, SpikeWall, PyrBase, PyrHeight, PyrWall)
{
    if (SpikeType == "Cylinder")
    {
        CylSpike(SpikeRadius, SpikeCylHeight, SpikeTipHeight, SpikeWall);
    }
    else if (SpikeType == "Pyramid")
    {
        PyrSpike(PyrBase, PyrHeight, SpikeWall);
    }
    else
    {
        echo("Unknown spike type ", SpikeType);
    }
}

// Render one cylinder spike
module CylSpike(SpikeRadius, SpikeCylHeight, SpikeTipHeight, SpikeWall)
{
	{
		union()
		{
			// Cylinder
			linear_extrude(SpikeCylHeight)
			{
				difference()
				{
					circle(SpikeRadius);
					circle(SpikeRadius - SpikeWall);
				}
			}
			
			// Spike
			translate([0, 0, SpikeCylHeight])
			{
				linear_extrude(SpikeTipHeight, scale=0.1)
				{
					difference()
					{
						circle(SpikeRadius);
						circle(SpikeRadius - SpikeWall);
					}
				}
			}
		}
	}
}

// Render one pyramid spike
module PyrSpike(PyrBase, PyrHeight, PyrWall)
{
    {
        difference()
        {
            translate([-PyrBase/2, -PyrBase/2, 0])
            scale([PyrBase, PyrBase, PyrHeight])
            {
                polyhedron(points=PyrPoints, faces=PyrFaces);
            }
            
            translate([-(PyrBase - PyrWall) / 2, -(PyrBase - PyrWall) / 2, 0])
            {
                scale([PyrBase - PyrWall, PyrBase - PyrWall, PyrHeight - PyrWall])
                {
                    polyhedron(points=PyrPoints, faces=PyrFaces);
                }
            }            
        }
    }
}

// Render one  hole
module Hole(SpikeType, SpikeRadius, SpikeWall, PyrBase, PyrWall)
{
    if (SpikeType == "Cylinder")
    {
        circle(SpikeRadius - SpikeWall);
    }
    else if (SpikeType == "Pyramid")
    {
        translate([-(PyrBase - PyrWall) / 2, -(PyrBase - PyrWall) / 2])
        {
            square([PyrBase - PyrWall, PyrBase - PyrWall]);
        }
    }
    else
    {
        echo("Unknown spike type ", SpikeType);
    }
}

function RaftSizeX(BorderX, CountX, SpikeSpaceX) = BorderX + ((CountX - 1) * SpikeSpaceX) + BorderX;
function RaftSizeY(BorderY, CountY, SpikeSpaceY) = BorderY + ((CountY - 1) * SpikeSpaceY) + BorderY;

// Render a raft with a grid of spikes
module Raft(CountX, CountY, SpikeSpaceX, SpikeSpaceY, BorderX, BorderY, RaftHeight, RaftHoles, SpikeType, SpikeRadius, SpikeCylHeight, SpikeTipHeight, SpikeWall,
    PyrBase, PyrHeight, PyrWall)
{
	// Compute size of raft
	RaftX = RaftSizeX(BorderX, CountX, SpikeSpaceX);
	RaftY = RaftSizeY(BorderY, CountY, SpikeSpaceY);
	
	// Raft with holes cut out for spikes
	difference()
	{
		cube([RaftX, RaftY, RaftHeight]);
		
		if (RaftHoles)
		{
			for (x = [0 : CountX -1])
			{
				for (y = [0 : CountY - 1])
				{
					SpikeX = BorderX + (x * SpikeSpaceX);
					SpikeY = BorderY + (y * SpikeSpaceY);
					translate([SpikeX, SpikeY, 0])
					{
						linear_extrude(RaftHeight)
						{
                            Hole(SpikeType, SpikeRadius, SpikeWall, PyrBase, PyrWall);
						}
					}
				}
			}
		}
	}
	
	// Grid of spikes
	for (x = [0 : CountX -1])
	{
		for (y = [0 : CountY - 1])
		{
			SpikeX = BorderX + (x * SpikeSpaceX);
			SpikeY = BorderY + (y * SpikeSpaceY);
			translate([SpikeX, SpikeY, RaftHeight])
			{
				Spike(SpikeType, SpikeRadius, SpikeCylHeight, SpikeTipHeight, SpikeWall, PyrBase, PyrHeight, PyrWall);
			}
		}
	}
}

// Render edge holes (intended to be used as antimatter)
module Holes(CountX, CountY, SpikeSpaceX, SpikeSpaceY, RaftHeight, BorderX, BorderY, BorderHoles, BorderHoleDiameter, BorderHoleInset,BorderCornerHoleInset)
{
	// Compute size of raft
	RaftX = RaftSizeX(BorderX, CountX, SpikeSpaceX);
	RaftY = RaftSizeY(BorderY, CountY, SpikeSpaceY);
	
	// Drill holes - bottom left
	translate([BorderCornerHoleInset, BorderHoleInset, 0]) cylinder(99, d=BorderHoleDiameter, $fn=99);
	translate([BorderHoleInset, BorderCornerHoleInset, 0]) cylinder(99, d=BorderHoleDiameter, $fn=99);	

	// Drill holes - top left
	translate([BorderCornerHoleInset, RaftY - BorderHoleInset, 0]) cylinder(99, d=BorderHoleDiameter, $fn=99);	
	translate([BorderHoleInset, RaftY - BorderCornerHoleInset, 0]) cylinder(99, d=BorderHoleDiameter, $fn=99);		
	
	// Drill holes - bottom left
	translate([RaftX - BorderCornerHoleInset, BorderHoleInset, 0]) cylinder(99, d=BorderHoleDiameter, $fn=99);
	translate([RaftX - BorderHoleInset, BorderCornerHoleInset, 0]) cylinder(99, d=BorderHoleDiameter, $fn=99);
	
	// Drill holes - top right
	translate([RaftX - BorderCornerHoleInset, RaftY - BorderHoleInset, 0]) cylinder(99, d=BorderHoleDiameter, $fn=99);
	translate([RaftX - BorderHoleInset, RaftY - BorderCornerHoleInset, 0]) cylinder(99, d=BorderHoleDiameter, $fn=99);
	
	// Drill holes - bottom and top edges
	translate([RaftX / 2, BorderHoleInset, 0]) cylinder(99, d=BorderHoleDiameter, $fn=99);
	translate([RaftX / 2, RaftY - BorderHoleInset, 0]) cylinder(99, d=BorderHoleDiameter, $fn=99);
	
	// Drill holes - left and right edges
	translate([BorderHoleInset, RaftY / 2, 0]) cylinder(99, d=BorderHoleDiameter, $fn=99);	
	translate([RaftX - BorderHoleInset, RaftY / 2, 0]) cylinder(99, d=BorderHoleDiameter, $fn=99);
}

// Render a raft, with optional edge holes
module FullRaft(CountX, CountY, SpikeSpaceX, SpikeSpaceY, BorderX, BorderY, RaftHeight, RaftHoles, SpikeType, SpikeRadius, SpikeCylHeight, SpikeTipHeight, SpikeWall, PyrBase, PyrHeight, PyrWall, BorderHoles, BorderHoleDiameter, BorderHoleInset, BorderCornerHoleInset)
{
	if (BorderHoles)
	{
		difference()
		{
			// Matter
			Raft(CountX, CountY, SpikeSpaceX, SpikeSpaceY, BorderX, BorderY, RaftHeight, RaftHoles, SpikeType, SpikeRadius, SpikeCylHeight, SpikeTipHeight, SpikeWall, PyrBase, PyrHeight, PyrWall);
			
			// Antimatter
			Holes(CountX, CountY, SpikeSpaceX, SpikeSpaceY, RaftHeight, BorderX, BorderY, BorderHoles, BorderHoleDiameter, BorderHoleInset,_BorderCornerHoleInset);
		}
	}
	else
	{
		Raft(CountX, CountY, SpikeSpaceX, SpikeSpaceY, BorderX, BorderY, RaftHeight, RaftHoles, SpikeType, SpikeRadius, SpikeCylHeight, SpikeTipHeight, SpikeWall, PyrBase, PyrHeight, PyrWall);
	}
}

// Render all of the rafts
for (r = [0 : _RaftCount - 1])
{
	RaftX = r * RaftSizeX(_RaftBorder, _SpikeCountX, _SpikeSpaceX) + (r * _RaftSpaceX);
	RaftY = 0;

	translate([RaftX, RaftY, 0])
	{
		FullRaft(_SpikeCountX, _SpikeCountY, _SpikeSpaceX, _SpikeSpaceY, 
                 _RaftBorder, _RaftBorder, _RaftHeight, _RaftHoles, 
                 _SpikeType, _CylSpikeRadius, _CylSpikeCylHeight, _CylSpikeTipHeight, _CylSpikeWall,
                 _PyrBase, _PyrHeight, _PyrWall, _BorderHoles, _BorderHoleDiameter, _BorderHoleInset, _BorderCornerHoleInset);
	}
}

