// Polygons with internal connections
//
//      Render a polygon with N (3 or more) nodes, with an 
//      optional center node. Then connect each of the nodes 
//      node to the center nodes and to the NodeConnectivity 
//      nearest neighbor nodes.

/* [Polygon] */

// [Number of points] 
_N = 6;

// [Radius] 
_Radius = 100.0;

// [Center Node]
_CenterNode = false;

/* Node */

// [Node Radius]
_NodeRadius = 5.0;

// [Node Thickness]
_NodeThickness = 1.0;

// [Node Connectivity]
_NodeConnectivity = 1;

/* Edge */

// [Edge Width]
_EdgeWidth = 2.0;

// [Inner Edge Gap]
_InnerEdgeGap = 4.0;

// [Outer Edge Gap]
_OuterEdgeGap = 1.5;

// [Edge Thickness]
_EdgeThickness = 1.0;

module Polygon(Radius, N, CenterNode, NodeRadius, NodeThickness, NodeConnectivity, EdgeWidth, EdgeThickness, OuterEdgeGap, InnerEdgeGap)
{
    X = [for (Theta = [0 : 360 / N : 360]) Radius * cos(Theta)];
    Y = [for (Theta = [0 : 360 / N : 360]) Radius * sin(Theta)];

    NodeCount = len(X) - 1;
  
    // Render nodes
    for (i = [0 : NodeCount - 1])
    {
        translate([X[i], Y[i], 0])
        {
            linear_extrude(NodeThickness)
            {
                echo(NodeRadius);
                circle(NodeRadius);
            }
        }
    }
  
    // Render center node
    if (CenterNode)
    {
        linear_extrude(NodeThickness)
        {
            circle(NodeRadius);
        }
    }
    
    // Render edge to connect center node to each node
    if (CenterNode)
    {
        for (i = [0 : NodeCount - 1])
        {
            Edge(0, 0, X[i], Y[i], EdgeThickness, EdgeWidth, InnerEdgeGap, OuterEdgeGap); 
        }
    }
    
    // Render edges to connect each node to all others
    for (i = [0 : NodeCount - 1])
    {
        for (j = [i + 1 : i + NodeConnectivity])
        {
            if (i != j)
            {
                jj = (j >= 0) ? (j % NodeCount) : (j + NodeCount);
                            
                Edge(X[i], Y[i], X[jj], Y[jj], EdgeThickness, EdgeWidth, InnerEdgeGap, OuterEdgeGap); 
            }
        }
    }
}

module Edge(X0, Y0, X1, Y1, EdgeThickness, EdgeWidth, InnerEdgeGap, OuterEdgeGap)
{
    // Compute distance between points
    DX = X1 - X0;
    DY = Y1 - Y0;
    H = sqrt(DX * DX + DY * DY);
    
    // Compute midpoint of [X0,Y0] - [X1, Y1]
    XMid = X0 + (X1 - X0) / 2;
    YMid = Y0 + (Y1 - Y0) / 2;
    
    // For debugging, plot the midpoint
    translate([XMid, YMid, 0])
    {
        color("red")
        {
            linear_extrude(EdgeThickness)    
            {
                circle(r=2);
            }
        }
    }
    
    // Compute angle between points
    A = atan2(DY, DX);

    // TODO This needs work to compute midpoint that respects InnerEdgeGap and OuterEdgeGap
    translate([XMid, YMid, 0])
    {
        rotate(A)
        {
            linear_extrude(EdgeThickness)
            {
                square([H - (InnerEdgeGap * 2), EdgeWidth], center=true);
            }
        }
    }
}


module main(Radius, N, CenterNode, NodeRadius, NodeThickness, NodeConnectivity, EdgeWidth, EdgeThickness, InnerEdgeGap, OuterEdgeGap)
{
  Polygon(Radius, N, CenterNode, NodeRadius, NodeThickness, NodeConnectivity, EdgeWidth, EdgeThickness, InnerEdgeGap, OuterEdgeGap);
}

main(_Radius, _N, _CenterNode, _NodeRadius, _NodeThickness, _NodeConnectivity, _EdgeWidth, _EdgeThickness, _InnerEdgeGap, _OuterEdgeGap);
