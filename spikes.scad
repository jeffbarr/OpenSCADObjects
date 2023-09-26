/* 
 * Spikes on rafts, with selectable spike type:
 * 
 * Cylindrical - Cylinder topped by point
 * Pyramidal   - Pyramid
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

/* Spike type */
_SpikeType = "Cylinder"; // ["Cylinder", "Pyramid"]

/* [Cylindrical Spikes] */
// Spike radius
_CylSpikeRadius = 7;

// Spike cylinder height
_CylSpikeCylHeight = 7;

// Spike tip height
_CylSpikeTipHeight = 35;

// Spike wall thickness
_CylSpikeWall = 2;

/* [Pyramidal Spikes] */
// Spike base width/depth
_PyrBase = 14;

// Spike height
_PyrHeight = 35;

// Spike wall thickness
_PyrWall = 2;

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

/* Pyramind faces */
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

// Render all of the rafts
for (r = [0 : _RaftCount - 1])
{
	RaftX = r * RaftSizeX(_RaftBorder, _SpikeCountX, _SpikeSpaceX) + (r - 1) * _RaftSpaceX;
	RaftY = 0;
	
	translate([RaftX, RaftY, 0])
	{
		Raft(_SpikeCountX, _SpikeCountY, _SpikeSpaceX, _SpikeSpaceY, 
             _RaftBorder, _RaftBorder, _RaftHeight, _RaftHoles, 
             _SpikeType, _CylSpikeRadius, _CylSpikeCylHeight, _CylSpikeTipHeight, _CylSpikeWall, _PyrBase, _PyrHeight, _PyrWall);
	}
}

