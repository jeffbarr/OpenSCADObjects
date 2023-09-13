/* Nodes and Edges */

/*
 * TODO:
 *
 * Round the short edges of the nodes
 * Connect nodes in odd rows in Y direction
 * Ability to print a subset as a fancy hexagon
 */

// Node radius
NodeSize = 9;

// Node shape (0 for circle, 6 for hexagon)
NodeShape = 0; // [0, 6]

// Column count
CountX = 7;

// Row count
CountY = 7;

// Row spacing
SpaceY = 30;

// Column spacing
SpaceX = 32;

// Node height
NodeHeight = 3;

// Node rim height
NodeRimHeight = 3.4;

// Edge rim height
EdgeRimHeight = 3.4;

// Edge height
EdgeHeight = 3.0;

// Edge width
EdgeWidth = 6;

// Percentage of full length for edges in X direction 
EdgeLengthXFactor = 0.9;

// Percentage of full length for edges in XY direction
EdgeLengthXYFactor = 0.9;

// Rim thickness
RimThickness = 0.5;

/* End of customization */
module __Customizer_Limit__ () {}

// 	Shift for odd rows
OddShiftX = SpaceX / 2;

// Node rotation
NodeRotation = (NodeShape == 0) ? 0 : 30;

// Render a node, with a rim
module Node(Radius, Height, RimHeight)
{	
	rotate([0, 0, NodeRotation])
	{
	union()
	{
			/* Node */
			linear_extrude(Height)
			{
				circle(Radius, $fn=NodeShape);
			}
			
			/* Rim */	
			for (dd = [0 : 1.5 : 3])
			{
				linear_extrude(RimHeight)
				{
					difference()
					{
						circle(Radius - dd, $fn=NodeShape);
						offset(delta=-RimThickness)
						{
							circle(Radius - dd, $fn=NodeShape);
						}
					}
				}
			}
		}
	}
}

// Render the element that makes up the edge
module EdgeElement(Length, Width)
{
	square([Length, Width], center=true);
}

// Render an edge, with a rim
module Edge(Length, Width, Height, RimHeight)
{
	union()
	{
		/* Edge */
		{
			linear_extrude(Height)
			{
				EdgeElement(Length, Width);
			}
		}
		
		/* Rim */
		for (dd = [0 : 1.6 : 3.2])
		{
			linear_extrude(RimHeight)
			{
				difference()
				{
					EdgeElement(Length - dd, Width - dd);
					offset(delta=-RimThickness)
					{
						EdgeElement(Length - dd, Width - dd);
					}
				}
			}
		}
	}
}

// Compute center of a node (x,y) 
function NodeX(x, y, OddShiftX, SpaceX) = ((y % 2) == 1) ? OddShiftX + (x * SpaceX) : (x * SpaceX);
function NodeY(x, y, SpaceY) = y * SpaceY;

// Render nodes and edges
module NodesAndEdges(CountX, CountY, SpaceX, SpaceY, OddShiftX, NodeSize, NodeHeight, NodeRimHeight, EdgeLengthX, EdgeLengthXY, EdgeWidth, EdgeHeight, EdgeRimHeight)
{
	/* Nodes */
	for (x = [0 : CountX - 1])
	{
		for (y = [0 : CountY - 1])
		{
			PtX = NodeX(x, y, OddShiftX, SpaceX);
			PtY = NodeY(x, y, SpaceY);
			
			translate([PtX, PtY, 0])
			{
				Node(NodeSize, NodeHeight, NodeRimHeight);
			}
		}
	}
	
	/* Edges */
	for (x = [0 : CountX - 1])
	{
		for (y = [0 : CountY - 1])
		{
			StartPtX = NodeX(x, y, OddShiftX, SpaceX);
			StartPtY = NodeY(x, y, SpaceY);

			/* Edges along X axis */
			if (x != CountX - 1)
			{
				EndPtX = NodeX(x + 1, y, OddShiftX, SpaceX);
				EndPtY = NodeY(x, y, SpaceY);
				MidPtX = (EndPtX - StartPtX) / 2;
				MidPtY = (EndPtY - StartPtY) / 2;
				
				translate([StartPtX + MidPtX, StartPtY + MidPtY, 0])
				{
					color("red") 
						Edge(EdgeLengthX, EdgeWidth, EdgeHeight, EdgeRimHeight);
				}
			}		
	
			/* Forward edges between Y and Y+1 */
			if (y < (CountY - 1))
			{
				if (((y % 2) == 0) ||
				    (((y % 2) == 1) && (x != (CountX - 1))))
				{
					XXX = ((y % 2) == 1) ? x + 1: x;
					FwdEndPtX = NodeX(XXX, y + 1, OddShiftX, SpaceX);
					FwdEndPtY = NodeY(XXX, y + 1, SpaceY);
					FwdMidPtX = (FwdEndPtX - StartPtX) / 2;
					FwdMidPtY = (FwdEndPtY - StartPtY) / 2;
					
					translate([StartPtX + FwdMidPtX, StartPtY + FwdMidPtY, 0])
					{
						color("pink") 
							rotate([0, 0, AngA]) Edge(EdgeLengthXY, EdgeWidth, EdgeHeight, EdgeRimHeight);
					}
				}
			}

			/* Backward edges between Y and Y+1 */
			if (y < (CountY - 1))
			{
				if ((x != 0) ||
					((x == 0) && ((y % 2) == 1)))
				{
					XXX = ((y % 2) == 1) ? x : x - 1;
					BwdEndPtX = NodeX(XXX, y + 1, OddShiftX, SpaceX);
					BwdEndPtY = NodeY(XXX, y + 1, SpaceY);
					BwdMidPtX = (BwdEndPtX - StartPtX) / 2;
					BwdMidPtY = (BwdEndPtY - StartPtY) / 2;
					
					translate([StartPtX + BwdMidPtX, StartPtY + BwdMidPtY, 0])
					{
						color("green") 
							rotate([0, 0, 180-AngA]) Edge(EdgeLengthXY, EdgeWidth, EdgeHeight, EdgeRimHeight);
					}
				}
			}				
		}
	}
}


/* Rotate around Z */
cur_vpr = $vpr;
$vpr = [cur_vpr[0], cur_vpr[1], 360 * $t];

/* Compute overall size */
TotalX = (CountX - 1) * SpaceX;
TotalY = (CountY - 1) * SpaceY;
echo(TotalX, TotalY);

/* Compute angle for edges */
C = SpaceX / 2;
A = SpaceY;
B = sqrt(A^2 + C^2 - (2 * A * C) * cos(90));
AngA = acos((B^2 + C^2 - A^2) / (2 * B * C)); 

/* Compute edge lengths */
EdgeLengthX  = (SpaceX - 2 * NodeSize) * EdgeLengthXFactor;
EdgeLengthXY = (B - 2 * NodeSize) * EdgeLengthXYFactor;
echo("EdgeLengthX", EdgeLengthX);
echo("EdgeLengthXY", EdgeLengthXY);

translate([-TotalX / 2, -TotalY / 2, 0])
{
	NodesAndEdges(CountX, CountY, SpaceX, SpaceY, OddShiftX, NodeSize, NodeHeight, NodeRimHeight, EdgeLengthX, EdgeLengthXY, EdgeWidth, EdgeHeight, EdgeRimHeight);
}

