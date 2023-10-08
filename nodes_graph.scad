/* Nodes and Graph (derivative of nodes_edges.scad), lots of ways to use this big but
*  useful mess:
*
* Circular Rays - Partial circle with rays extending from the center to the periphery.
*                 If RingCount is > 1, some inner rings are skipped to allow creation
*                 of hollow circles or semi-circles.
*
* Axial Rays - An "L" or a square of nodes, with diagonal, vertical, horizontal 
*              edges or some combo.
*
* Fringe - A rectangle with triangles hanging down.
*
* Hexagon - Hexagon with interior goodness.
*
* This code is powerful yet messy. TODO:
*	
* --> Fix HACK that intertwines Fringe metrics in the wrong way with Step:
*     _SquareStep = _FringeColSpace.
*
* --> Move more parameters to "_" and never use them in modules
*
* --> Render edges that overlap (mostly in Axial) together so that the
*     pattern on top looks better.
*
* --> Prefix all config variables with the pattern that they affect.
*/

// Pattern
_Pattern = "Circular"; // [Circular, Axial, Fringe, Hexagon]

// Node radius
_NodeSize = 7.5;

// Node shape (0 for circle, , 4 for square, 6 for hexagon)
_NodeShape = 0; // [0, 4, 6]

// Center node X
_CenterX = 0;

// Center node Y
_CenterY = 0;

// Node height
_NodeHeight = 3;

// Percentage of full length for edges
EdgeLengthFactor = 1.0;

// Minimum length to bother creating an edge
EdgeMinLength = 5;

// Rim thickness
RimThickness = 0.5;

// Node rim height
NodeRimHeight = 3.4;

// Edge rim height
EdgeRimHeight = 3.4;

// Edge height
EdgeHeight = 3.0;

// Edge width
EdgeWidth = 5.0;

/* [Circular Rays] */
// Draw ring center
_RayCenter = true;

// Angular step between rays
_RayStep = 45;

// Degrees of rays
_RayLimit = 360;

// First ring
_StartRing = 1;

// Ring count
_RingCount = 5;

// Ring spacing
_RingSpace = 20;

/* [Axial Rays] */
// Linear step between nodes
//_SquareStep = 27;

// Number of nodes on X and Y axis
_SquareCount = 3;

// Options for interior edges:
// Forward diagonal
// Backward diagonal
// X-aligned
// Y-aligned

_FwdDiagonalEdges = false;
_BwdDiagonalEdges = false;
_XEdges           = true;
_YEdges           = true;

/* [Fringe] */

// Number of vertical columns (must be even)
_FringeCols = 8;

// Rows in top of fringe
_FringeRows = 2;

// Width of each column
_FringeColSpace = 30;

// Height of each triangular fringe
_FringeTriangeHeight = 120;

/* [Hexagon] */

// Base width
_BaseWidth = 100;

// Inside triangles
_InsideTriangles = true;

// HaCK
_SquareStep = _FringeColSpace;

/* End of customization */
module __Customizer_Limit__ () {}

// Render a node, with a rim
module Node(NodeShape, Radius, Height, RimHeight)
{	
	// Node rotation
	NodeRotation = (_NodeShape == 0) ? 0  :	/* Circle  */
				   (_NodeShape == 4) ? 45 :	/* Square  */
                   (_NodeShape == 6) ? 30 :	/* Hexagon */
                                       0;
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

// Render an edge, with a rim, as long as edge is at least EdgeMinLength long

module Edge(Length, Width, Height, RimHeight)
{
	if (Length >= EdgeMinLength)
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
}

// Connect two nodes using an edge
module ConnectNodesWithEdge(FromX, FromY, ToX, ToY, EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize)
{
	// Compute angle for edge
	DeltaX = (ToX - FromX);
	DeltaY = (ToY - FromY);
	Theta = atan2(DeltaY, DeltaX);

	// Compute edge length, base then adjust for node side
	BaseEdgeLength = sqrt((DeltaX * DeltaX) + (DeltaY * DeltaY));
	EdgeLength = (BaseEdgeLength - (2.5 * NodeSize)) * EdgeLengthFactor;

	// Compute center of edge
	EdgeCenterX = FromX + (DeltaX / 2);
	EdgeCenterY = FromY + (DeltaY / 2);

	// Render edge
	translate([EdgeCenterX, EdgeCenterY, 0])
	{
		rotate([0, 0, Theta])
		{
			Edge(EdgeLength, EdgeWidth, EdgeHeight, EdgeRimHeight);
		}
	}
}
	
// Triangle inset from the given points, styled like an edge
// 7 is magic and should be a parameter
// Good luck understanding this, the 7 and the polygon should be another module
//
module Triangle(X0, Y0, X1, Y1, X2, Y2, Height, RimHeight)
{
	TrianglePoints =
	[
		[X0, Y0],
		[X1, Y1],
		[X2, Y2]
	];
	
	union()
	{
		/* Triangle */
		linear_extrude(Height)
		{
			offset(-7)
			{
				polygon(TrianglePoints);
			}
		}
		
		/* Rim */
		for (dd = [0 : 1.5 : 3])
		{
			linear_extrude(RimHeight)
			{
				difference()
				{
					offset(delta= (-7 - dd)) polygon(TrianglePoints);
					offset(delta= (-7 - dd - RimThickness)) polygon(TrianglePoints);
				}
			}
		}
	}
}

// Partial or full circle, with optional node at the center, then rings of nodes 
// connected radially and cicularly.
// TODO: Add parameters

module CircularRays(StartRing, RingCount, RingSpace, Step, Limit, Center, CenterX, CenterY, NodeShape, NodeSize, NodeHeight)
{
	if (Center)
	{
		// Render center node
		translate([CenterX, CenterY, 0])
		{
			Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight);
		}
	}
	
	// Concentric rings of nodes
	for (Theta = [0 : Step : Limit])
	{
		for (Ring = [StartRing : RingCount])
		{
			RingX = CenterX + (cos(Theta) * Ring * RingSpace);
			RingY = CenterY + (sin(Theta) * Ring * RingSpace);

			translate([RingX, RingY, 0])
			{
				Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight);
			}
		}
	}

	// Radial edges from center to first ring
	for (Theta = [0 : Step : Limit])
	{
		RingX = CenterX + (cos(Theta) * RingSpace);
		RingY = CenterY + (sin(Theta) * RingSpace);
		
		ConnectNodesWithEdge(CenterX, CenterY, RingX, RingY, EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
	}

	// Radial edges from subsequent rings outward
	for (Theta = [0 : Step : Limit])
	{
		for (Ring = [StartRing : RingCount - 1])
		{
			RingFromX = CenterX + (cos(Theta) * Ring * RingSpace);
			RingFromY = CenterY + (sin(Theta) * Ring * RingSpace);

			RingToX = CenterX + (cos(Theta) * (Ring + 1) * RingSpace);
			RingToY = CenterY + (sin(Theta) * (Ring + 1) * RingSpace);
				
			ConnectNodesWithEdge(RingFromX, RingFromY, RingToX, RingToY, EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
		}
	}

	// Circular edges within a ring
	for (Ring = [StartRing : RingCount])
	{
		for (Theta = [0 : Step : Limit - 1])
		{
			RingFromX = CenterX + (cos(Theta) * Ring * RingSpace);
			RingFromY = CenterY + (sin(Theta) * Ring * RingSpace);

			RingToX = CenterX + (cos(Theta + Step) * Ring * RingSpace);
			RingToY = CenterY + (sin(Theta + Step) * Ring * RingSpace);
			
			ConnectNodesWithEdge(RingFromX, RingFromY, RingToX, RingToY, EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);		

		}
	}
}

//
// AxialRays:
//
// Nodes along X and Y axis, connected on the axes and:
//
// FwdDiagonalEdges TODO (does not work with !Square)
// BwdDiagonalEdges 
// XEdges
// YEdges
//
// TODO: add parameters
// If Square is set, render a square else render a triangle
//

function AxialPointX(i) = i * _SquareStep;
function AxialPointY(i) = i * _SquareStep;

module AxialRays(Square, SquareStep, SquareCount, NodeShape, NodeSize, NodeHeight, FwdDiagonalEdges, BwdDiagonalEdges, XEdges, YEdges)
{
	// Render origin node
	Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight);
	
	// Render nodes along X axis
	for (x = [1 : SquareCount])
	{
		translate([AxialPointX(x), AxialPointY(0), 0])
		{
			Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight);
		}
		
		if (Square)
		{
			translate([AxialPointX(x), AxialPointY(SquareCount), 0])
			{
				Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight);
			}
		}
	}
	
	// Render nodes along Y axis
	for (y = [1 : SquareCount])
	{
		translate([AxialPointX(0), AxialPointY(y), 0])
		{
			Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight);
		}
		
		if (Square)
		{
			translate([AxialPointX(SquareCount), AxialPointY(y), 0])
			{
				Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight);
			}
		}
	}
	
	if (BwdDiagonalEdges)
	{
		// Render backward diagonal edges 
		for (i = [1 : SquareCount])
		{
			ConnectNodesWithEdge(AxialPointX(i), AxialPointY(0), AxialPointX(0), AxialPointY(i), 
								 EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);	
			
			if (Square)
			{
				ConnectNodesWithEdge(AxialPointX(i), AxialPointY(SquareCount), AxialPointX(SquareCount), AxialPointY(i), 
									 EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);				
			}
		}
	}
	
	if (FwdDiagonalEdges)
	{
		// Render forward diagonal edges 
		for (i = [0 : SquareCount])
		{
			ConnectNodesWithEdge(AxialPointX(i), AxialPointY(0), AxialPointX(SquareCount), AxialPointY(SquareCount - i), 
								 EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);	
		}
		
		for (i = [1 : SquareCount])
		{
				ConnectNodesWithEdge(AxialPointX(0), AxialPointY(i), AxialPointX(SquareCount - i), 
									 AxialPointY(SquareCount), EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
		}
	}
	
	// Render edges along top & bottom X axis
	for (i = [0 : SquareCount - 1])
	{
		ConnectNodesWithEdge(AxialPointX(i), AxialPointY(0), AxialPointX(i+1), AxialPointY(0), 
							 EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);		
	
		if (Square)
		{
			ConnectNodesWithEdge(AxialPointX(i), AxialPointY(SquareCount),AxialPointX(i+1), AxialPointY(SquareCount), 
								 EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
		}
	}
	
	// Render interior X edges
	if (XEdges)
	{
		for (i = [1 : SquareCount - 1])
		{
			ConnectNodesWithEdge(AxialPointX(0), AxialPointY(i), AxialPointX(SquareCount), AxialPointY(i), EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
		}
	}
	
	// Render edges along left and right Y axis
		for (i = [0 : SquareCount - 1])
	{
		ConnectNodesWithEdge(AxialPointX(0), AxialPointY(i), AxialPointX(0), AxialPointY(i+1), 
							 EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);		
	
		if (Square)
		{
			ConnectNodesWithEdge(AxialPointX(SquareCount), AxialPointY(i), AxialPointX(SquareCount), AxialPointY(i+1), 
								 EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);		
		}
	}
	
	// Render interior Y edges
	if (YEdges)
	{
		for (i = [1 : SquareCount - 1])
		{
			ConnectNodesWithEdge(AxialPointX(i), AxialPointY(0), AxialPointX(i), AxialPointY(SquareCount), EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
		}
	}
}

// 
// Fringe:
// 
//	A horizontal grid (FringeCols x FringeRows, then triangles of FringeTriangleHeight dropping down
//

module Fringe(FringeCols, FringeRows, FringeColSpace, FringeTriangleHeight, NodeShape, NodeSize, NodeHeight, NodeRimHeight)
{
	// Render grid of nodes for top
	for (y = [0 : FringeRows - 1])
	{
		for (x = [0 : FringeCols - 1])
		{
			translate([AxialPointX(x), AxialPointY(y), 0])
			{
				Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight);
			}
		}
	}
	
	// Render edges along top & bottom X axis
	for (i = [0 : FringeCols - 2])
	{
		ConnectNodesWithEdge(AxialPointX(i), AxialPointY(0), AxialPointX(i + 1), AxialPointY(0), 
							 EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);		

		ConnectNodesWithEdge(AxialPointX(i), AxialPointY(FringeRows - 1),AxialPointX(i + 1), AxialPointY(FringeRows - 1), 
							 EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
	}
	
	// Render edges along Y axis
	for (i = [0 : FringeRows - 2])
	{
		for (j = [0 : FringeCols - 1])
		{
			ConnectNodesWithEdge(AxialPointX(j), AxialPointY(i), AxialPointX(j), AxialPointY(i + 1), 
							 EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);		
		}
	}
	
	TriangleCount = FringeCols / 2;
	
	// Render triangles - apex and edges to the apex
	for (t = [0 : TriangleCount - 1])
	{
		TriangleNodeIndex = t * 2;
		
		// Triangle points
		T0X = AxialPointX(TriangleNodeIndex);
		T0Y = AxialPointY(FringeRows - 1);
		
		T1X = AxialPointX(TriangleNodeIndex + 1);
		T1Y = AxialPointY(FringeRows - 1);
		
		T2X = T0X + (FringeColSpace / 2);
		T2Y = T1Y + FringeTriangleHeight;
		
		translate([T2X, T2Y, 0])
		{
			Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight);
		}
		
		ConnectNodesWithEdge(T0X, T0Y, T2X, T2Y, EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
		ConnectNodesWithEdge(T1X, T1Y, T2X, T2Y, EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);		
	}
}

//
// Hexagon:
//
//		Hexagon with interior goodies, with middle split on exterior edges, and optional
//		interior triangle panels.
//
//		Consult https://github.com/jeffbarr/OpenSCADObjects/blob/main/nodes_graph_hexagon_node_ids.jpg
//		to see how X/Y, XX/YY, XXX/YYY, and XI/YI map to node coordinates.
//

module Hexagon(BaseWidth, InsideTriangles, NodeShape, NodeSize, NodeHeight)
{
	// Compute coordinates of each exterior node
	X = [for (d = [0 : 60 : 359]) BaseWidth * cos(d)];
	Y = [for (d = [0 : 60 : 359]) BaseWidth * sin(d)];
		
	// Compute coordinates for mid-points of each exterior node
	XX = [for (i = [0 : 5]) (X[i] + X[(i + 1) % 6]) / 2];
	YY = [for (i = [0 : 5]) (Y[i] + Y[(i + 1) % 6]) / 2];

	// Merge so that XXX and YYY are coordinates of all exterior nodes
	XXX = 
	[
		X[0], XX[0],
		X[1], XX[1],
		X[2], XX[2],
		X[3], XX[3],
		X[4], XX[4],
		X[5], XX[5]
	];

	YYY = 
	[
		Y[0], YY[0],
		Y[1], YY[1],
		Y[2], YY[2],
		Y[3], YY[3],
		Y[4], YY[4],
		Y[5], YY[5]
	];
	
	// Compute coordinates for 4 interior nodes
	XI =
	[
		X[1], 
		0,
		X[2],
		0
	];
	
	YI =
	[
		0,
		Y[1] / 2,
		0,
		-Y[1] / 2
	];
	
	// Render exterior nodes
	for (i = [0 : 11])
	{
		translate([XXX[i], YYY[i], 0])
		{
			Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight);
		}
	}	
	
	// Render edges between exterior nodes
	for (i = [0 : 11])
	{
		X0 = XXX[i];
		Y0 = YYY[i];
		X1 = XXX[(i + 1) % 12];
		Y1 = YYY[(i + 1) % 12];

		ConnectNodesWithEdge(X0, Y0, X1, Y1, EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);	
	}
	
	// Render center node
	translate([0, 0, 0])
	{
		Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight);
	}
	
	// Render other interior nodes
	for (i = [0 : 3])
	{
		translate([XI[i], YI[i], 0])
		{
			Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight);
		}
	}

	// Render edges from center to interior nodes
	for (i = [0 : 3])
	{
		ConnectNodesWithEdge(0, 0, XI[i], YI[i], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);			
	}
	
	// Render edges from interior nodes to exterior nodes on X axis
	ConnectNodesWithEdge(XI[0], YI[0], XXX[0], YYY[0], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);		
	ConnectNodesWithEdge(XI[2], YI[2], X[3], Y[3], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);	
	
	// Render edges from interior nodes to exterior nodes on Y axis
	ConnectNodesWithEdge(XI[1], YI[1], XXX[3], YYY[3], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);	
	ConnectNodesWithEdge(XI[3], YI[3], XXX[9], YYY[9], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);

	// Render edges to connect interior nodes to each other
	for (i = [0 : 3])
	{
		ConnectNodesWithEdge(XI[i], YI[i], XI[(i + 1) % 4], YI[(i + 1) % 4], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
	}
	
	// Render edges to connect interior nodes to top and bottom diagonals
	ConnectNodesWithEdge(XI[0], YI[0], XXX[1], YYY[1], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
	ConnectNodesWithEdge(XI[2], YI[2], XXX[5], YYY[5], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
	ConnectNodesWithEdge(XI[2], YI[2], XXX[7], YYY[7], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);	
	ConnectNodesWithEdge(XI[0], YI[0], XXX[11], YYY[11], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
	
	// Render edge to connect the "corner" exterior nodes to the X axis
	ConnectNodesWithEdge(XI[0], YI[0], XXX[2], YYY[2], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
	ConnectNodesWithEdge(XI[2], YI[2], XXX[4], YYY[4], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
	ConnectNodesWithEdge(XI[2], YI[2], XXX[8], YYY[8], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);	
	ConnectNodesWithEdge(XI[0], YI[0], XXX[10], YYY[10], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
	
	// Render edges to connect the "corner" exterior nodes to those at X=0 above and below the axis
	ConnectNodesWithEdge(XI[1], YI[1], XXX[2], YYY[2], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
	ConnectNodesWithEdge(XI[1], YI[1], XXX[4], YYY[4], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
	ConnectNodesWithEdge(XI[3], YI[3], XXX[8], YYY[8], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);	
	ConnectNodesWithEdge(XI[3], YI[3], XXX[10], YYY[10], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);	
	
	if (InsideTriangles)
	{
		// Fill in lots of triangles
		Triangle(XXX[0], YYY[0], XXX[1], YYY[1], XI[0], XI[1], EdgeHeight, EdgeRimHeight);
		Triangle(XI[0], YI[0], XXX[1], YYY[1], XXX[2], YYY[2], EdgeHeight, EdgeRimHeight);
		Triangle(XI[0], YI[0], XI[1], YI[1], XXX[2], YYY[2], EdgeHeight, EdgeRimHeight);
		Triangle(XI[1], YI[1], XXX[2], YYY[2], XXX[3], YYY[3], EdgeHeight, EdgeRimHeight);
		Triangle(XI[1], YI[1], XXX[2], YYY[2], XXX[4], YYY[4], EdgeHeight, EdgeRimHeight);
		Triangle(XI[1], YI[1], XXX[4], YYY[4], XI[2], YI[2], EdgeHeight, EdgeRimHeight);
		Triangle(XXX[4], YYY[4], XI[2], YI[2], XXX[5], YYY[5], EdgeHeight, EdgeRimHeight);
		Triangle(XI[2], YI[2], XXX[5], YYY[5], XXX[6], YYY[6], EdgeHeight, EdgeRimHeight);
		Triangle(XI[2], YI[2], XXX[6], YYY[6], XXX[7], YYY[7], EdgeHeight, EdgeRimHeight);
		Triangle(XI[2], YI[2], XXX[7], YYY[7], XXX[8], YYY[8], EdgeHeight, EdgeRimHeight);	
		Triangle(XI[2], YI[2], XXX[8], YYY[8], XI[3], YI[3], EdgeHeight, EdgeRimHeight);	
		Triangle(XXX[8], YYY[8], XI[3], YI[3], XXX[9], YYY[9], EdgeHeight, EdgeRimHeight);
		Triangle(XXX[9], YYY[9], XI[3], YI[3], XXX[10], YYY[10], EdgeHeight, EdgeRimHeight);
		Triangle(XI[3], YI[3], XXX[10], YYY[10], XI[0], YI[0], EdgeHeight, EdgeRimHeight);
		Triangle(XXX[11], YYY[11], XXX[10], YYY[10], XI[0], YI[0], EdgeHeight, EdgeRimHeight);
		Triangle(XXX[11], YYY[11], XI[0], YI[0], XXX[0], YYY[0], EdgeHeight, EdgeRimHeight);

		for (i = [0 : 3])
		{
			Triangle(0, 0, XI[i], YI[i], XI[(i + 1) % 4], YI[(i + 1) % 4], EdgeHeight, EdgeRimHeight);
		}
	}
}

/* Render chosen pattern */

if (_Pattern == "Circular")
{
	CircularRays(_StartRing,_RingCount, _RingSpace, _RayStep, _RayLimit, _RayCenter, 
			     _CenterX, _CenterY,_NodeShape, _NodeSize, _NodeHeight);
}

else if (_Pattern == "Axial")
{
	AxialRays(true, _SquareStep, _SquareCount, _NodeShape, _NodeSize, _NodeHeight, 
			  _FwdDiagonalEdges, _BwdDiagonalEdges, _XEdges, _YEdges);}

else if (_Pattern == "Fringe")
{
	Fringe(_FringeCols, _FringeRows, _FringeColSpace, _FringeTriangeHeight, _NodeShape, _NodeSize,
			_NodeHeight, NodeRimHeight);
}

else if (_Pattern == "Hexagon")
{
	Hexagon(_BaseWidth, _InsideTriangles, _NodeShape, _NodeSize, _NodeHeight);
}
else
{
	echo("Unknown pattern ", _Pattern);
}


