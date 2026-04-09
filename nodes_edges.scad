/* Nodes and Edges */

/*
 * TODO:
 *
 * Round the short ends of the edges
 * Add additional rim types / styles, eg solid
 * Rename rim to be more general
 * Connect nodes in odd rows in Y direction
 * Ability to print a subset as a fancy hexagon
 * Fix base edge size calculations to work for all node shapes
 */

// Node radius
_NodeSize = 9;

// Node shape (0 for circle, , 4 for square, 6 for hexagon)
_NodeShape = 0; // [0, 4, 6]

// Edge shape
_EdgeShape = "Rectangle";	// ["Rectangle", "RoundedOut"]

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

// Edge width
_EdgeWidth = 6;

// Percentage of full length for edges in X direction 
_EdgeLengthXFactor = 0.9;

// Percentage of full length for edges in XY direction
_EdgeLengthXYFactor = 0.9;

/* [Rim] */
// Rim thickness
_RimThickness = 0.5;

// Node rim count
_NodeRimCount = 3;

// Edge rim count
_EdgeRimCount = 3;

// Node rim spacing
_NodeRimSpacing = 2.0;

// Edge rim spacing
_EdgeRimSpacing = 1.5;

// Base extra (X and Y)
_BaseExtra = 10.0;

/* [Heights] */

// Base height
_BaseHeight = 0.2;

// Node height
_NodeHeight = 1.2;

// Edge height
_EdgeHeight = 1.2;

// Node rim height
_NodeRimHeight = 0.4;

// Edge rim height
_EdgeRimHeight = 0.4;

/* [Extruders] */

// Node extruder
_NodeExtruder = 1;

// Edge extruder
_EdgeExtruder = 2;

// Node rim extruder
_NodeRimExtruder = 3;

// Edge rim extruder
_EdgeRimExtruder = 4;

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
module Node(NodeShape, Radius, Height, RimHeight, RimThickness, RimCount, RimSpacing, NodeExtruder, RimExtruder)
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
				translate([0, 0, Height])
				{
					for (R = [0 : RimCount - 1])
					{
						dd = R * RimSpacing;
						if ((Radius - dd) > 0)
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
	}
}

// Render the element that makes up the edge
module EdgeElement(Shape, Length, Width, LengthFull)
{
	if (Shape == "Rectangle")
	{
		if (Length > 0)
		{
			square([Length, Width], center=true);
		}
	}
	
	if (Shape == "RoundedOut")
	{
		if (Length > 0)
		{
		}
	}
}

// Render an edge, with a rim
module Edge(EdgeShape, Length, LengthFull, Width, Height, RimHeight, RimThickness, RimCount, RimSpacing, EdgeExtruder, RimExtruder)
{
	union()
	{
		/* Edge */
		{
			Extruder(EdgeExtruder)
			{
				linear_extrude(Height)
				{
					EdgeElement(Length, Width, LengthFull);
				}
			}
		}
		
		/* Rim */
		Extruder(RimExtruder)
		{
			for (R = [0 : RimCount - 1])
			{
				dd = R * RimSpacing;
				if (((Length - dd) > 0) && ((Width - dd) > 0))
				{
					translate([0, 0, Height])
					{
						linear_extrude(RimHeight)
						{
							difference()
							{
								EdgeElement(Length - dd, Width - dd, LengthFull);
								offset(delta=-RimThickness)
								{
									EdgeElement(Length - dd, Width - dd, LengthFull);
								}
							}
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
module NodesAndEdges(CountX, CountY, SpaceX, SpaceY, AngA, OddShiftX, OffsetOdd, NodeShape, EdgeShape, NodeSize, NodeHeight, NodeRimHeight, NodeRimCount, NodeRimSpacing, EdgeLengthX, EdgeLengthXY, EdgeLengthXYFull, EdgeWidth, EdgeHeight, EdgeRimHeight, EdgeRimCount, EdgeRimSpacing, RimThickness, NodeExtruder, EdgeExtruder, NodeRimExtruder, EdgeRimExtruder)
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
				Node(NodeShape, NodeSize, NodeHeight, NodeRimHeight, RimThickness, NodeRimCount, NodeRimSpacing, NodeExtruder, NodeRimExtruder);
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
					Edge(EdgeShape, EdgeLengthX, SpaceX, EdgeWidth, EdgeHeight, EdgeRimHeight, RimThickness, EdgeRimCount, EdgeRimSpacing, EdgeExtruder, EdgeRimExtruder);
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
								Edge(EdgeShape, EdgeLengthXY, EdgeLengthXYFull, EdgeWidth, EdgeHeight, EdgeRimHeight, RimThickness, EdgeRimCount, EdgeRimSpacing, EdgeExtruder, EdgeRimExtruder);
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
							Edge(EdgeShape, EdgeLengthXY, EdgeLengthXYFull, EdgeWidth, EdgeHeight, EdgeRimHeight, RimThickness, EdgeRimCount, EdgeRimSpacing, EdgeExtruder, EdgeRimExtruder);
						}
					}
				}
			}				
		}
	}
}

module main(CountX, CountY, SpaceX, SpaceY, OddShiftX, OffsetOdd, NodeShape, EdgeShape, NodeSize, NodeHeight, NodeRimHeight, NodeRimCount, NodeRimSpacing, EdgeWidth, EdgeHeight, EdgeRimHeight, EdgeRimCount, EdgeRimSpacing, EdgeLengthXFactor, EdgeLengthXYFactor, BaseHeight, BaseExtra, RimThickness, BaseExtruder, NodeExtruder, EdgeExtruder, NodeRimExtruder, EdgeRimExtruder)
{
	/* Compute angle for edges, special case if not offsetting odd rows */
	C = SpaceX / 2;
	A = SpaceY;
	B = sqrt(A^2 + C^2 - (2 * A * C) * cos(90));
	AngA = OffsetOdd ? acos((B^2 + C^2 - A^2) / (2 * B * C)) : 90;

	/* Compute edge lengths */
	EdgeLengthX  = (SpaceX - 2 * NodeSize) * EdgeLengthXFactor;
	EdgeLengthXY = (B - 2 * NodeSize) * EdgeLengthXYFactor;
	EdgeLengthXYFull = (B - 2 * NodeSize);
	echo("EdgeLengthX", EdgeLengthX);
	echo("EdgeLengthXY", EdgeLengthXY);
	echo("EdgeLengthXYFull", EdgeLengthXYFull);

	/* Render nodes and edges to connect them */
	NodesAndEdges(CountX, CountY, SpaceX, SpaceY, AngA, OddShiftX, OffsetOdd, NodeShape, EdgeShape, NodeSize, NodeHeight, NodeRimHeight, NodeRimCount, NodeRimSpacing, EdgeLengthX, EdgeLengthXY, EdgeLengthXYFull, EdgeWidth, EdgeHeight, EdgeRimHeight, EdgeRimCount, EdgeRimSpacing, RimThickness, NodeExtruder, EdgeExtruder, NodeRimExtruder, EdgeRimExtruder);

	/* Render optional base */
	if (BaseHeight > 0)
	{
		/* Compute size of base */
		TotalX = (CountX - 1) * SpaceX + (SpaceX / 2) + NodeSize + NodeSize;
		TotalY = (CountY - 1) * SpaceY + (SpaceY / 2);

		translate([-(NodeSize + BaseExtra / 2), -(NodeSize + BaseExtra / 2), - BaseHeight])
		{
			Extruder(BaseExtruder)
			{
				cube([TotalX + BaseExtra, TotalY + BaseExtra, BaseHeight]);
			}
		}
	}
}

main(_CountX, _CountY, _SpaceX, _SpaceY, _OddShiftX, _OffsetOdd, _NodeShape, _EdgeShape, _NodeSize, _NodeHeight, _NodeRimHeight, _NodeRimCount, _NodeRimSpacing, _EdgeWidth, _EdgeHeight, _EdgeRimHeight, _EdgeRimCount,_EdgeRimSpacing, _EdgeLengthXFactor, _EdgeLengthXYFactor, _BaseHeight, _BaseExtra, _RimThickness, _BaseExtruder, _NodeExtruder, _EdgeExtruder, _NodeRimExtruder, _EdgeRimExtruder);
