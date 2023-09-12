/* Spikes on rafts */

// Number of rafts
RaftCount = 1;

// Space between rafts
RaftSpaceX = 20;

// Spike radius
SpikeRadius = 7;

// Spike cylinder height
SpikeCylHeight = 7;

// Spike tip height
SpikeTipHeight = 35;

// Raft height
RaftHeight = 2.0; // [0 : 0.2 : 4.0]

// Rows of spikes per raft
SpikeCountY = 4;

// Columns of spikes per raft
SpikeCountX = 4;

// Space between columns of spikes
SpikeSpaceX = 10;

// Space between rows of spikes
SpikeSpaceY = 10;

// Border
RaftBorder = 10;

// Render one spike
module Spike(SpikeRadius, SpikeCylHeight, SpikeTipHeight)
{
	//translate([SpikeRadius, SpikeRadius, 0])
	{
		union()
		{
			// Cylinder
			linear_extrude(SpikeCylHeight)
			{
				circle(SpikeRadius);
			}
			
			// Spike
			translate([0, 0, SpikeCylHeight])
			{
				linear_extrude(SpikeTipHeight, scale=0.1)
				{
					circle(SpikeRadius);
				}
			}
		}
	}
}

function RaftSizeX(BorderX, CountX, SpikeSpaceX) = BorderX + ((CountX - 1) * SpikeSpaceX) + BorderX;
function RaftSizeY(BorderY, CountY, SpikeSpaceY) = BorderY + ((CountY - 1) * SpikeSpaceY) + BorderY;

// Render a raft with a grid of spikes
module Raft(CountX, CountY, SpikeSpaceX, SpikeSpaceY, BorderX, BorderY, RaftHeight, SpikeRadius, SpikeCylHeight, SpikeTipHeight)
{
	// Compute size of raft
	RaftX = RaftSizeX(BorderX, CountX, SpikeSpaceX);
	RaftY = RaftSizeY(BorderY, CountY, SpikeSpaceY);
	
	// Raft
	cube([RaftX, RaftY, RaftHeight]);
	
	// Grid of spikes
	for (x = [0 : CountX -1])
	{
		for (y = [0 : CountY - 1])
		{
			SpikeX = BorderX + (x * SpikeSpaceX);
			SpikeY = BorderY + (y * SpikeSpaceY);
			translate([SpikeX, SpikeY, RaftHeight])
			{
				Spike(SpikeRadius, SpikeCylHeight, SpikeTipHeight);
			}
		}
	}
}

// Render all of the rafts
for (r = [0 : RaftCount - 1])
{
	RaftX = r * RaftSizeX(RaftBorder, SpikeCountX, SpikeSpaceX) + (r - 1) * RaftSpaceX;
	RaftY = 0;
	
	translate([RaftX, RaftY, 0])
	{
		Raft(SpikeCountX, SpikeCountY, SpikeSpaceX, SpikeSpaceY, RaftBorder, RaftBorder, 
			 RaftHeight, SpikeRadius, SpikeCylHeight, SpikeTipHeight);
	}
}

