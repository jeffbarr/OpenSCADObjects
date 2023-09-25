/* Spikes on rafts, with selectable spike type */

// Number of rafts
_RaftCount = 1;

// Space between rafts
_RaftSpaceX = 20;

// Spike radius
_SpikeRadius = 7;

// Spike cylinder height
_SpikeCylHeight = 7;

// Spike tip height
_SpikeTipHeight = 35;

// Spike wall thickness
_SpikeWall = 2;

// Raft height
_RaftHeight = 2.0; // [0 : 0.2 : 4.0]

// Rows of spikes per raft
_SpikeCountY = 4;

// Columns of spikes per raft
_SpikeCountX = 4;

// Space between columns of spikes
_SpikeSpaceX = 10;

// Space between rows of spikes
_SpikeSpaceY = 10;

// Border
_RaftBorder = 10;

// Holes in raft below spikes
_RaftHoles = false;

// Render one spike
module Spike(SpikeRadius, SpikeCylHeight, SpikeTipHeight, SpikeWall)
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

function RaftSizeX(BorderX, CountX, SpikeSpaceX) = BorderX + ((CountX - 1) * SpikeSpaceX) + BorderX;
function RaftSizeY(BorderY, CountY, SpikeSpaceY) = BorderY + ((CountY - 1) * SpikeSpaceY) + BorderY;

// Render a raft with a grid of spikes
module Raft(CountX, CountY, SpikeSpaceX, SpikeSpaceY, BorderX, BorderY, RaftHeight, RaftHoles, SpikeRadius, SpikeCylHeight, SpikeTipHeight, SpikeWall)
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
							circle(SpikeRadius - SpikeWall);
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
				Spike(SpikeRadius, SpikeCylHeight, SpikeTipHeight, SpikeWall);
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
		Raft(_SpikeCountX, _SpikeCountY, _SpikeSpaceX, _SpikeSpaceY, _RaftBorder, _RaftBorder, 
			 _RaftHeight, _RaftHoles, _SpikeRadius, _SpikeCylHeight, _SpikeTipHeight, _SpikeWall);
	}
}

