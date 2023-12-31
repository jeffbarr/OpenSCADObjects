/* Nodes and Graph (derivative of nodes_edges.scad), lots of ways to use this big but
*  useful mess:
*
* Circular Rays - Partial circle with rays extending from the center to the periphery.
*                 If RingCount is > 1, some inner rings are skipped to allow creation
*                 of hollow circles or semi-circles.
*
* Grid Rays - A rectangle of nodes, with diagonal, vertical, horizontal edges or 
*			   some combo.
*
* Fringe - A rectangle with triangles hanging down.
*
* Hexagon - Hexagon with interior goodness.
*
* This code is powerful yet messy. TODO:
*	
* --> Fix Fringe to have proper args
*
* --> Implement separate triangle pattern
*
* --> Move more parameters to "_" and never use them in modules
*
* --> Render edges that overlap (mostly in Axial) together so that the
*     pattern on top looks better.
*/

// Pattern
_Pattern = "Circular"; // [Circular, Grid, Fringe, Hexagon]

// Node radius
_NodeSize = 7.5;

// Node shape (0 for circle, , 4 for square, 6 for hexagon)
_NodeShape = 0; // [0, 4, 6]

// Node magnet holes
_NodeMagnetHole = "None"; // [None, 2.7 mm, 4.7 mm, 12 mm]

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

/* ************************************************************** */

/* [Circular Rays] */

// Draw ring center
_CircRayCenter = true;

// Angular step between rays
_CircRayStep = 45;

// Degrees of rays
_CircRayLimit = 360;

// First ring
_CircStartRing = 1;

// Ring count
_CircRingCount = 5;

// Ring spacing
_CircRingSpace = 20;

// Inside quads
_CircInsideQuads = true;

// Quad Inset
_CircQuadInset = 7;

// Half-nodes at start and end
_CircHalfNodes = false;

// Half-edges at start and end
_CircHalfEdges = false;

/* ************************************************************** */

/* [Grid Rays] */

// Number of rows
_GridRows = 4;

// Number of columns
_GridCols = 8;

// Step between rows
_GridRowStep = 30;

// Step between columns
_GridColStep = 50;

// Options for interior edges:
// Forward diagonal
// Backward diagonal
// X-aligned
// Y-aligned

// Forward diagonal edges
_GridFwdDiagonalEdges = false;

// Backward diagonal edges
_GridBwdDiagonalEdges = false;

// X edges
_GridXEdges = true;

// Y edges
_GridYEdges = true;

// Half nodes, first row
_GridHalfNodesFirst = false;

// Half nodes, last row
_GridHalfNodesLast = false;

// Half edges, first row
_GridHalfEdgesFirst = false;

// Half edges, last row
_GridHalfEdgesLast = false;

/* ************************************************************** */

/* [Fringe] */

// Number of vertical columns (must be even)
_FringeCols = 8;

// Rows in top of fringe
_FringeRows = 2;

// Width of each column
_FringeColSpace = 30;

// Height of each triangular fringe
_FringeTriangeHeight = 120;

/* ************************************************************** */

/* [Hexagon] */

// Base width
_HexBaseWidth = 100;

// Inside triangles
_HexInsideTriangles = true;

// Triangle inset
_HexTriangleInset = 7;

/* ************************************************************** */

/* End of customization */
module __Customizer_Limit__ () {}

//
// Map all of the possible values for _NodeMagnetHole into a diameter and a height:
//

function MagnetDiameter(MagnetHole) = 
	(MagnetHole == "None")   ? 0   :
	(MagnetHole == "2.7 mm") ? 2.7 :
	(MagnetHole == "4.7 mm") ? 4.7 :
	(MagnetHole == "12 mm")  ? 12  :
	0;

function MagnetHeight(MagnetHole) =
	(MagnetHole == "None")   ? 0   :
	(MagnetHole == "2.7 mm") ? 2   :
	(MagnetHole == "4.7 mm") ? 2   :
	(MagnetHole == "12 mm")  ? 2.4 :
	0;

//
// Hole:
//
//	Render a magnet hole.
//

module Hole(MagnetHole)
{
	Diameter = MagnetDiameter(MagnetHole);
	Height   = MagnetHeight(MagnetHole);
	
	if (Diameter != 0)
	{	
		FullDiameter = 1.1 * Diameter;	// Add some wiggle room
		
		linear_extrude(Height)
		{
			circle(FullDiameter);
		}
	}
}

//
// NodeGuts:
//
//	Render the elements that make up a node.
//

module NodeGuts(NodeShape, Radius, Height, RimHeight)
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

//
// Node:
//
// Render a node, with a rim and optional hole for magnet. 
//
//	PlusX must be true to render the part of the node at X > 0
//	MinuxX must be true to render the part of the node at X < 0
//

module Node(NodeShape, Radius, Height, RimHeight, MagnetHole, PlusX=true, MinusX=true)
{	
	// Node rotation
	NodeRotation = (_NodeShape == 0) ? 0  :	/* Circle  */
				   (_NodeShape == 4) ? 45 :	/* Square  */
                   (_NodeShape == 6) ? 30 :	/* Hexagon */
                                       0;
	difference()
	{
		/* Matter */
		rotate([0, 0, NodeRotation])
		{
			NodeGuts(NodeShape, Radius, Height, RimHeight);
		}
		
		/* Antimatter magnet hole */
		translate([0, 0, 0.4])
		{
			Hole(MagnetHole);
		}
		
		/* Optionally remove +Y half */
		if (!PlusX)
		{
			translate([-Radius, 0, 0])
			{
				cube([2 * Radius, Radius, Height + RimHeight]);
			}
		}

		/* Optionally remove -Y half */
		if (!MinusX)
		{
			translate([-Radius, -Radius, 0])
			{
				cube([2 * Radius, Radius, Height + RimHeight]);
			}
		}
	}
}

//
// EdgeElement:
//
// Render the element that makes up the edge.
//

module EdgeElement(Length, Width)
{
	square([Length, Width], center=true);
}

//
// Edge:
//
// Render an edge, with a rim, as long as edge is at least EdgeMinLength long.
//

module Edge(Length, Width, Height, RimHeight, PlusX, MinusX)
{
	if (Length >= EdgeMinLength)
	{
		difference()
		{
			/* Matter */
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
			
			/* Antimatter */
			
			/* Optionally remove +X half */
			if (!PlusX)
			{
				translate([-Length / 2, 0, 0])
				{
					cube([Length, Width / 2, RimHeight]);
				}
			}
			
			/* Optionally remove -X half */
			if (!MinusX)
			{
				translate([-Length / 2, -Width / 2, 0])
				{
					cube([Length, Width / 2, RimHeight]);
				}
			}
		}
		
	}
}

//
// ConnectNodesWithEdge:
//
// Connect two nodes using an edge.
//

module ConnectNodesWithEdge(FromX, FromY, ToX, ToY, EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize, PlusX=true, MinusX=true)
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
			Edge(EdgeLength, EdgeWidth, EdgeHeight, EdgeRimHeight, PlusX, MinusX);
		}
	}
}


//
// TriangleElement:
//
// Render the element that makes up the triangle.
//

module TriangleElement(Points)
{
	polygon(Points);
}

//
// Triangle:
//
// Triangle inset from the given points, styled like an edge.
//

module Triangle(X0, Y0, X1, Y1, X2, Y2, Inset, Height, RimHeight)
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
			offset(-Inset)
			{
				TriangleElement(TrianglePoints);
			}
		}
		
		/* Rim */
		for (dd = [0 : 1.5 : 3])
		{
			linear_extrude(RimHeight)
			{
				difference()
				{
					offset(delta= (-Inset - dd)) 
					{
						TriangleElement(TrianglePoints);
					}
					
					offset(delta= (-Inset - dd - RimThickness)) 
					{
						TriangleElement(TrianglePoints);
					}
				}
			}
		}
	}
}


//
// QuadElement:
//
// Render the element that makes up the quadrilateral.
//

module QuadElement(Points)
{
	polygon(Points);
}

//
// Quad:
//
// Quadrilateral inset from the given points, styled like an edge.
//

module Quad(X0, Y0, X1, Y1, X2, Y2, X3, Y3, Inset, Height, RimHeight)
{
	QuadPoints =
	[
		[X0, Y0],
		[X1, Y1],
		[X2, Y2],
		[X3, Y3],
	];
	
	union()
	{
		/* Quad */
		linear_extrude(Height)
		{
			offset(-Inset)
			{
				QuadElement(QuadPoints);
			}
		}
		
		/* Rim */
		for (dd = [0 : 1.5 : 3])
		{
			linear_extrude(RimHeight)
			{
				difference()
				{
					offset(delta= (-Inset - dd)) 
					{
						QuadElement(QuadPoints);
					}
					
					offset(delta= (-Inset - dd - RimThickness)) 
					{
						QuadElement(QuadPoints);
					}
				}
			}
		}
	}
}

// 
// CircularRays:
//
// Partial or full circle, with optional node at the center, then rings of nodes,
// connected radially and cicularly, with optional quadrilaterals between nodes.
//
// If HalfNodes or HalfEdges is set, then the first and last nodes  or edges in the ring 
// are PlusX/MinusX half only. This makes it easier to print a pair of semi-circular rings that 
// can be joined with straight pieces. 
//
// TODO: Add parameters
//

module CircularRays(StartRing, RingCount, RingSpace, Step, Limit, Center, InsideQuads, QuadInset, NodeShape, NodeSize, NodeHeight, NodeMagnetHole, HalfNodes, HalfEdges)
{
	if (Center)
	{
		// Render center node
		Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight, NodeMagnetHole);
	}
	
	// Concentric rings of nodes
	for (Theta = [0 : Step : Limit])
	{
		for (Ring = [StartRing : RingCount])
		{
			RingX = cos(Theta) * Ring * RingSpace;
			RingY = sin(Theta) * Ring * RingSpace;

			translate([RingX, RingY, 0])
			{
				MinusXHalf =
					(!HalfNodes)
				     ||
					(HalfNodes && (Theta > 0) && (Theta < Limit));
				
				Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight, NodeMagnetHole, true, MinusXHalf);
			}
		}
	}

	if (Center)
	{
		// Radial edges from center to first ring
		for (Theta = [0 : Step : Limit])
		{
			RingX = cos(Theta) * RingSpace;
			RingY = sin(Theta) * RingSpace;
			
			ConnectNodesWithEdge(0, 0, RingX, RingY, EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
		}
	}
	
	// Radial edges from subsequent rings outward
	for (Theta = [0 : Step : Limit])
	{
		for (Ring = [StartRing : RingCount - 1])
		{
			RingFromX = cos(Theta) * Ring * RingSpace;
			RingFromY = sin(Theta) * Ring * RingSpace;

			RingToX = cos(Theta) * (Ring + 1) * RingSpace;
			RingToY = sin(Theta) * (Ring + 1) * RingSpace;
			
			//
			// Hacky, special-cased (half-circle only) hiding of half-edges (PluX or MinusX):
			//
			// 1. Hide MinusXHalf if HalfEdges set and Theta is 0
			//
			// 2. Hide PlusXHalf if HalfEdges set and Theta is 180
			//
			
			ShowMinusXHalf = (Theta != 0 && HalfEdges)   || !HalfEdges; 
			ShowPlusXHalf  = (Theta != 180 && HalfEdges) || !HalfEdges; 
			
			ConnectNodesWithEdge(RingFromX, RingFromY, RingToX, RingToY, EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize, ShowPlusXHalf, ShowMinusXHalf);
		}
	}

	// Circular edges within a ring
	for (Ring = [StartRing : RingCount])
	{
		for (Theta = [0 : Step : Limit - 1])
		{
			RingFromX = cos(Theta) * Ring * RingSpace;
			RingFromY = sin(Theta) * Ring * RingSpace;

			RingToX = cos(Theta + Step) * Ring * RingSpace;
			RingToY = sin(Theta + Step) * Ring * RingSpace;
			
			ConnectNodesWithEdge(RingFromX, RingFromY, RingToX, RingToY, EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);		

		}
	}
	
	if (InsideQuads)
	{
		// Quadrilaterals between nodes
		for (Theta1 = [0 : Step : Limit - 1])
		{
			for (Ring = [StartRing : RingCount - 1])
			{
				Theta2 = (Theta1 + Step) % 360;

				RingX0 = cos(Theta1) * (Ring + 1) * RingSpace;
				RingY0 = sin(Theta1) * (Ring + 1) * RingSpace;				
				RingX1 = cos(Theta2) * (Ring + 1) * RingSpace;
				RingY1 = sin(Theta2) * (Ring + 1) * RingSpace;				
				RingX2 = cos(Theta2) * Ring * RingSpace;
				RingY2 = sin(Theta2) * Ring * RingSpace;
				RingX3 = cos(Theta1) * Ring * RingSpace;
				RingY3 = sin(Theta1) * Ring * RingSpace;
					
				Quad(RingX0, RingY0, RingX1, RingY1, RingX2, RingY2, RingX3, RingY3, QuadInset, EdgeHeight, EdgeRimHeight);
			}
		}
	}
}

//
// GridRays:
//
// Grid of nodes, connected on the axes and optional:
//
// FwdDiagonalEdges
// BwdDiagonalEdges 
// XEdges
// YEdges
//
// Optional half edges and half nodes, for first and last row.
//

function GridPointX(i, ColStep) = i * ColStep;
function GridPointY(i, RowStep) = i * RowStep;

module GridRays(Rows, Cols, RowStep, ColStep, NodeShape, NodeSize, NodeHeight, NodeMagnetHole, FwdDiagonalEdges, BwdDiagonalEdges, XEdges, YEdges, HalfNodesFirst, HalfNodesLast, HalfEdgesFirst, HalfEdgesLast)
{
	// Render grid of nodes
	for (x = [0 : Cols - 1])
	{
		for (y = [0 : Rows - 1])
		{
			translate([GridPointX(x, ColStep), GridPointY(y, RowStep), 0])
			{
				MinusX = (y != 0) || (y == 0 && !HalfNodesFirst);
				PlusX  = (y != (Rows - 1)) || (y == (Rows - 1) && !HalfNodesLast);
				
				Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight, NodeMagnetHole, PlusX, MinusX);
			}
		}
	}
	
	// Render edges along X axis
	if (XEdges)
	{
		for (x = [0 : Cols - 2])
		{
			for (y = [0 : Rows - 1])
			{
				MinusX = (y != 0) || (y == 0 && !HalfEdgesFirst);
				PlusX  = (y != (Rows - 1)) || (y == (Rows - 1) && !HalfEdgesLast);
				
				ConnectNodesWithEdge(GridPointX(x, ColStep), GridPointY(y, RowStep), GridPointX(x + 1, ColStep), GridPointY(y, RowStep), 
									 EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize, PlusX, MinusX);		
			}
		}
	}
	
	// Render edges along Y axis
	if (YEdges)
	{
		for (y = [0 : Rows - 2])
		{
			for (x = [0 : Cols - 1])
			{
				ConnectNodesWithEdge(GridPointX(x, ColStep), GridPointY(y, RowStep), GridPointX(x, ColStep), GridPointY(y + 1, RowStep), 
									 EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
			}
		}
	}
		
	// Render forward diagonal edges
	if (FwdDiagonalEdges)
	{
		for (x = [0 : Cols - 2])
		{
			for (y = [0 : Rows - 2])
			{
				ConnectNodesWithEdge(GridPointX(x, ColStep), GridPointY(y, RowStep), GridPointX(x + 1, ColStep), GridPointY(y + 1, RowStep), 
									 EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);					
			}
		}
	}
	
	// Render backward diagonal edges
	if (BwdDiagonalEdges)
	{
		for (x = [1 : Cols - 1])
		{
			for (y = [0 : Rows - 2])
			{
				ConnectNodesWithEdge(GridPointX(x, ColStep), GridPointY(y, RowStep), GridPointX(x - 1, ColStep), GridPointY(y + 1, RowStep), 
									 EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);					
			}
		}
	}
}

// 
// Fringe:
// 
//	A horizontal grid (FringeCols x FringeRows, then triangles of FringeTriangleHeight dropping down.
//	TODO - Fix to add ColSpace and RowSpace properly.
//

module Fringe(FringeCols, FringeRows, FringeColSpace, FringeTriangleHeight, NodeShape, NodeSize, NodeHeight, NodeRimHeight, NodeMagnetHole)
{
	// Render grid of nodes for top
	for (y = [0 : FringeRows - 1])
	{
		for (x = [0 : FringeCols - 1])
		{
			translate([GridPointX(x), GridPointY(y), 0])
			{
				Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight, NodeMagnetHole);
			}
		}
	}
	
	// Render edges along top & bottom X axis
	for (i = [0 : FringeCols - 2])
	{
		ConnectNodesWithEdge(GridPointX(i), GridPointY(0), GridPointX(i + 1), GridPointY(0), 
							 EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);		

		ConnectNodesWithEdge(GridPointX(i), GridPointY(FringeRows - 1),GridPointX(i + 1), GridPointY(FringeRows - 1), 
							 EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);
	}
	
	// Render edges along Y axis
	for (i = [0 : FringeRows - 2])
	{
		for (j = [0 : FringeCols - 1])
		{
			ConnectNodesWithEdge(GridPointX(j), GridPointY(i), GridPointX(j), GridPointY(i + 1), 
							 EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);		
		}
	}
	
	TriangleCount = FringeCols / 2;
	
	// Render triangles - apex and edges to the apex
	for (t = [0 : TriangleCount - 1])
	{
		TriangleNodeIndex = t * 2;
		
		// Triangle points
		T0X = GridPointX(TriangleNodeIndex);
		T0Y = GridPointY(FringeRows - 1);
		
		T1X = GridPointX(TriangleNodeIndex + 1);
		T1Y = GridPointY(FringeRows - 1);
		
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
//		to see how X/Y, XX/YY, XXX/YYY, XI/YI, and NX/NY map to node coordinates.
//

module Hexagon(BaseWidth, InsideTriangles, TriangleInset, NodeShape, NodeSize, NodeHeight, NodeMagnetHole)
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
	
	// Put all coordinates together, indices are "fixed" per the diagram
	NX =
	[
		0, 
	    XXX[0], XXX[1], XXX[2], XXX[3], XXX[4],  XXX[5], 
		XXX[6], XXX[7], XXX[8], XXX[9], XXX[10], XXX[11],
	  	XI[0], XI[1], XI[2], XI[3]
	];
		  
	NY = 
	[
		0, 
	    YYY[0], YYY[1], YYY[2], YYY[3], YYY[4],  YYY[5], 
	    YYY[6], YYY[7], YYY[8], YYY[9], YYY[10], YYY[11], 
		YI[0], YI[1], YI[2], YI[3]
	];
	
	// Build list of nodes to render
	Nodes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];

	// Build list of edges to render, as node indexes
	Edges =
	[
		// Connect exterior nodes
		[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10], [10, 11], [11, 12], [12, 1],
	
		// Connect center node to interior nodes
		[0, 13], [0, 14], [0, 15], [0, 16],
	
		// Connect interior nodes to exterior nodes on X axis
		[1, 13], [7, 15],
	
		// Connect interior nodes to exterior nodes on Y axis
		[4, 14], [10, 16],
	
		// Connect interior nodes to each other
		[13, 14], [14, 15], [15, 16], [16, 13],
	
		// Connect interior nodes to top and bottom diagonals
		[2, 13], [6, 15], [8, 15], [12, 13],
		
		// Connect corner interior nodes to X axis
		[3, 13], [5, 15], [9, 15], [11, 13],
		
		// Connect corner interior nodes to Y axis
		[3, 14], [5, 14], [9, 16], [11, 16]
	];
	
	// Render nodes
	for (n = Nodes)
	{
		translate([NX[n], NY[n], 0])
		{
			Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight, NodeMagnetHole);
		}
	}

	// Render edges
	for (e = Edges)
	{
		ConnectNodesWithEdge(NX[e[0]], NY[e[0]], NX[e[1]], NY[e[1]], EdgeWidth, EdgeHeight, EdgeRimHeight, NodeSize);	
	}

	if (InsideTriangles)
	{
		// Build list of triangles as node indices
		Triangles =
		[
			[0,  13, 14],
			[0,  14, 15],
			[0,  15, 16],
			[0,  13, 16],
			[1,  2,  13],
			[1,  12, 13],
			[2,  3,  13],
			[3,  4,  14],
			[3,  13, 14],
			[4,  5,  14],
			[5,  6,  15],
			[5,  14, 15],
			[6,  7,  15],
			[7,  8,  15],
			[8,  9,  15],
			[9,  10, 16],
			[9,  15, 16],
			[10, 11, 16],
			[11, 12, 13],
			[11, 13, 16]
		];
		
		// Render triangles
		for (t = Triangles)
		{
			Triangle(NX[t[0]], NY[t[0]], NX[t[1]], NY[t[1]], NX[t[2]], NY[t[2]], TriangleInset, EdgeHeight, EdgeRimHeight);
		}
	}
}

/* Render chosen pattern */

if (_Pattern == "Circular")
{
	CircularRays(_CircStartRing,_CircRingCount, _CircRingSpace, _CircRayStep, _CircRayLimit, _CircRayCenter, _CircInsideQuads, _CircQuadInset, _NodeShape, _NodeSize, _NodeHeight, _NodeMagnetHole, _CircHalfNodes, _CircHalfEdges);
}

else if (_Pattern == "Grid")
{
	GridRays(_GridRows, _GridCols, _GridRowStep, _GridColStep,  _NodeShape, _NodeSize, _NodeHeight, _NodeMagnetHole, _GridFwdDiagonalEdges, _GridBwdDiagonalEdges, _GridXEdges, _GridYEdges, _GridHalfNodesFirst, _GridHalfNodesLast, _GridHalfEdgesFirst, _GridHalfEdgesLast);
}

else if (_Pattern == "Fringe")
{
	Fringe(_FringeCols, _FringeRows, _FringeColSpace, _FringeTriangeHeight, _NodeShape, _NodeSize, _NodeHeight, NodeRimHeight, _NodeMagnetHole);
}

else if (_Pattern == "Hexagon")
{
	Hexagon(_HexBaseWidth, _HexInsideTriangles, _HexTriangleInset, _NodeShape, _NodeSize, _NodeHeight, _NodeMagnetHole);
}
else
{
	echo("Unknown pattern ", _Pattern);
}
