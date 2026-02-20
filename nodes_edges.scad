/* Nodes and Edges */

/*
 * TODO:
 *
 * Round the short edges of the nodes
 * Connect nodes in odd rows in Y direction
 * Ability to print a subset as a fancy hexagon
 * Add optional base
 * add main()
 * modernize formatting
 */

// Node radius
_NodeSize = 9;

// Node shape (0 for circle, , 4 for square, 6 for hexagon)
_NodeShape = 0; // [0, 4, 6]

// Offset odd rows
_OffsetOdd = true;

// Column count
_CountX = 7;

// Row count
_CountY = 7;

// Row spacing
_SpaceY = 30;

// Column spacing
_SpaceX = 32;

// Node height
_NodeHeight = 3;

// Node rim height
_NodeRimHeight = 3.4;

// Edge rim height
_EdgeRimHeight = 3.4;

// Edge height
_EdgeHeight = 3.0;

// Edge width
_EdgeWidth = 6;

// Percentage of full length for edges in X direction 
_EdgeLengthXFactor = 0.9;

// Percentage of full length for edges in XY direction
_EdgeLengthXYFactor = 0.9;

// Rim thickness
_RimThickness = 0.5;

/* [Extruders] */

// Node extruder
_NodeExtruder = 1;

// Edge extruder
_EdgeExtruder = 2;

// Rim extruder
_RimExtruder = 3;

// Base extruder
_BaseExtruder = 0;

// [Extruder to render]
_WhichExtruder = "All"; // ["All", 1, 2, 3, 4, 5]

// Map a value of _WhichExtruder to an OpenSCAD color
function ExtruderColor(Extruder) = 
  (Extruder == 1  ) ? "red"    : 
  (Extruder == 2  ) ? "green"  : 
  (Extruder == 3  ) ? "blue"   : 
  (Extruder == 4  ) ? "pink"   :
  (Extruder == 5  ) ? "yellow" :
                      "purple" ;

/* End of customization */
module __Customizer_Limit__ () {}

// 	Possible shift for odd rows
_OddShiftX = _OffsetOdd ? (_SpaceX / 2) : 0;

// Node rotation
NodeRotation = (_NodeShape == 0) ? 0  :	/* Circle  */
               (_NodeShape == 4) ? 45 :	/* Square  */
               (_NodeShape == 6) ? 30 :	/* Hexagon */
                                  0;

// If _WhichExtruder is "All" or is not "All" and matches the 
// requested extruder, render the child nodes.

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

// Render a node, with a rim
module Node(NodeShape, Radius, Height, RimHeight, RimThickness, NodeExtruder, RimExtruder)
{	
	rotate([0, 0, NodeRotation])
	{
	union()
	{
			/* Node */
			Extruder(NodeExtruder)
			{
				linear_extrude(Height)
				{
					circle(Radius, $fn=NodeShape);
				}
			}
			
			/* Rim */
			Extruder(RimExtruder)
			{
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
}

// Render the element that makes up the edge
module EdgeElement(Length, Width)
{
	square([Length, Width], center=true);
}

// Render an edge, with a rim
module Edge(Length, Width, Height, RimHeight, RimThickness, EdgeExtruder, RimExtruder)
{
	union()
	{
		/* Edge */
		{
			Extruder(EdgeExtruder)
			{
				linear_extrude(Height)
				{
					EdgeElement(Length, Width);
				}
			}
		}
		
		/* Rim */
		Extruder(RimExtruder)
		{
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
}

// Compute center of a node (x,y) 
function NodeX(x, y, OddShiftX, SpaceX) = ((y % 2) == 1) ? OddShiftX + (x * SpaceX) : (x * SpaceX);
function NodeY(x, y, SpaceY) = y * SpaceY;

// Render nodes and edges
module NodesAndEdges(CountX, CountY, SpaceX, SpaceY, OddShiftX, OffsetOdd, NodeShape, NodeSize, NodeHeight, NodeRimHeight, EdgeLengthX, EdgeLengthXY, EdgeWidth, EdgeHeight, EdgeRimHeight, RimThickness, NodeExtruder, EdgeExtruder, RimExtruder)
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
				Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight, RimThickness, NodeExtruder, RimExtruder);
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
					Edge(EdgeLengthX, EdgeWidth, EdgeHeight, EdgeRimHeight, RimThickness, EdgeExtruder, RimExtruder);
				}
			}		
	
			/* Forward edges between Y and Y+1 */
			if (y < (CountY - 1))
			{
				if ((!OffsetOdd)   || 
					((y % 2) == 0) ||
				    (((y % 2) == 1) && (x != (CountX - 1))))
				{
					XXX = (OffsetOdd && (y % 2) == 1) ? x + 1: x;
					FwdEndPtX = NodeX(XXX, y + 1, OddShiftX, SpaceX);
					FwdEndPtY = NodeY(XXX, y + 1, SpaceY);
					FwdMidPtX = (FwdEndPtX - StartPtX) / 2;
					FwdMidPtY = (FwdEndPtY - StartPtY) / 2;
					
					translate([StartPtX + FwdMidPtX, StartPtY + FwdMidPtY, 0])
					{
						rotate([0, 0, AngA])
							{
								Edge(EdgeLengthXY, EdgeWidth, EdgeHeight, EdgeRimHeight, RimThickness, EdgeExtruder, RimExtruder);
							}
					}
				}
			}

			/* Backward edges between Y and Y+1 */
			if (OffsetOdd && (y < (CountY - 1)))
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
						rotate([0, 0, 180-AngA])
						{
							Edge(EdgeLengthXY, EdgeWidth, EdgeHeight, EdgeRimHeight, RimThickness, EdgeExtruder, RimExtruder);
						}
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
TotalX = (_CountX - 1) * _SpaceX;
TotalY = (_CountY - 1) * _SpaceY;
echo(TotalX, TotalY);

/* Compute angle for edges, special case if not offsetting odd rows */
C = _SpaceX / 2;
A = _SpaceY;
B = sqrt(A^2 + C^2 - (2 * A * C) * cos(90));
AngA = _OffsetOdd ? acos((B^2 + C^2 - A^2) / (2 * B * C)) : 90;

/* Compute edge lengths */
EdgeLengthX  = (_SpaceX - 2 * _NodeSize) * _EdgeLengthXFactor;
EdgeLengthXY = (B - 2 * _NodeSize) * _EdgeLengthXYFactor;
echo("EdgeLengthX", EdgeLengthX);
echo("EdgeLengthXY", EdgeLengthXY);

translate([-TotalX / 2, -TotalY / 2, 0])
{
	NodesAndEdges(_CountX, _CountY, _SpaceX, _SpaceY, _OddShiftX, _OffsetOdd, _NodeShape, _NodeSize, _NodeHeight, _NodeRimHeight, EdgeLengthX, EdgeLengthXY, _EdgeWidth, _EdgeHeight, _EdgeRimHeight, _RimThickness, _NodeExtruder, _EdgeExtruder, _RimExtruder);
}

