// Rhombitrihexagonal Tiling
//
// https://en.wikipedia.org/wiki/Rhombitrihexagonal_tiling
//

/* [Rhombitrihexagon]  */

// Column count
_CountX = 3;

// Row count
_CountY = 4;

// Hexagon radius
_HexRadius = 17.5;

// Inset of each element
_Inset = 0.5;

// Hexagon height
_HexHeight = 0.6;

// Square height
_SquareHeight = 0.6;

// Triangle height
_TriangleHeight = 0.6;

// Rim thickness
_RimThickness = 0.4;

// Rim height
_RimHeight = 0.4;

// Gap between rim elements
_RimGap = 1.5;

// Max rim elements on a shape
_RimMaxElements = 99;

/* [Extruders] */

// Hexagon extruder
_HexagonExtruder = 1;

// Square extruder
_SquareExtruder = 2;

// Triangle extruder
_TriangleExtruder = 3;

// Rim extruder
_RimExtruder = 4;

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
					  
module __end_cust() {};

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

//
// Render a rim for a polygon
//

module RimShape(Points, Inset, Thickness, Height, Gap, MaxElements, RimExtruder)
{
	Extruder(RimExtruder)
	{
		for (r = [0 : MaxElements - 1])
		{
			linear_extrude(Height)
			{
				difference()
				{
					offset(delta=-(Inset + (r * Gap))) 
					{
						polygon(Points);
					}
					
					offset(delta=-(Thickness + Inset + (r * Gap)))
					{
						polygon(Points);
					}
				}
			}
		}
	}
}

//
// Render a square
//

module SquareShape(Points, Inset, Height, RimThickness, RimHeight, RimGap, RimMaxElements, SquareExtruder, RimExtruder)
{
	union()
	{
		// Square
		Extruder(SquareExtruder)
		{
			linear_extrude(Height)
			{
				offset(-Inset)
				{
					polygon(Points);
				}
			}
		}

		// Rim
		translate([0, 0, Height])
		{
			RimShape(Points, Inset, RimThickness, RimHeight, RimGap, RimMaxElements, RimExtruder);
		}
	}
}

//
// Render a triangle
//

module TriangleShape(Points, Inset, Height, RimThickness, RimHeight, RimGap, RimMaxElements, TriangleExtruder, RimExtruder)
{
	union()
	{
		// Triangle
		Extruder(TriangleExtruder)
		{
			linear_extrude(Height)
			{
				offset(-Inset)
				{
					polygon(Points);
				}
			}
		}
		
		// Rim
		translate([0, 0, Height])
		{
			RimShape(Points, Inset, RimThickness, RimHeight, RimGap, RimMaxElements, RimExtruder);
		}
	}	
}

//
// Render a hexagon
//

module HexagonShape(Points, Inset, Height, RimThickness, RimHeight, RimGap, RimMaxElements, HexagonExtruder, RimExtruder)
{	
	union()
	{
		// Hexagon
		Extruder(HexagonExtruder)
		{
			linear_extrude(Height)
			{
				offset(-Inset)
				{
					polygon(Points);
				}
			}
		}
			
		// Rim
		translate([0, 0, Height])
		{
			RimShape(Points, Inset, RimThickness, RimHeight, RimGap, RimMaxElements, RimExtruder);
		}
	}
}

//
// Render a dodecagon
//

module DodecagonShape(Points, Inset, Height, RimThickness, RimHeight, RimGap, RimMaxElements)
{	
	linear_extrude(Height)
	{
		offset(-Inset)
		{
			polygon(Points);
		}
	}
}

//
// Render all or part of a rhombitrihexagon, with given inset, heights, and extruders
//
// Squares and triangles are numbered counter-clockwise, with 0 intersecting the Y axis on the +x side.
//

module Rhombitrihexagon(HexRadius, Inset, HexHeight, SquareHeight, TriangleHeight, SquareList, TriangleList, RimThickness, RimHeight, RimGap, RimMaxElements, HexagonExtruder, TriangleExtruder, SquareExtruder, RimExtruder)
{
	// Compute apothem of hexagon then use it to compute radius of dodecagon
	Apothem = 0.5 * sqrt(3) * HexRadius;
	
	// Compute radius of dodecagon
	DodRadius = sqrt((HexRadius / 2 * HexRadius / 2) + ((Apothem + HexRadius) * (Apothem + HexRadius)));
	
	// Compute hexagon points
	HexPoints = [for (t = [0 : 60 : 360]) [HexRadius * cos(t), HexRadius * sin(t)]];
	
	// Compute dodecagon points
	DodPoints = [for (t = [0 : 30 : 360]) [DodRadius * cos(t + 15), DodRadius * sin(t + 15)]];	
	
	// Form squares
	Square0 =
		[HexPoints[0],
		 DodPoints[0],
		 DodPoints[1],
		 HexPoints[1]
	];
	
	Square1 =
		[HexPoints[1],
		 DodPoints[2],
		 DodPoints[3],
		 HexPoints[2]
	];
	
	Square2 =
		[HexPoints[2],
		 DodPoints[4],
		 DodPoints[5],
		 HexPoints[3]
	];

	Square3 =
		[HexPoints[3],
		 DodPoints[6],
		 DodPoints[7],
		 HexPoints[4]
	];

	Square4 =
		[HexPoints[4],
		 DodPoints[8],
		 DodPoints[9],
		 HexPoints[5]
	];	

	Square5 =
		[HexPoints[5],
		 DodPoints[10],
		 DodPoints[11],
		 HexPoints[6]
	];	
	
	Squares = [Square0, Square1, Square2, Square3, Square4, Square5];
	
	// Form triangles
	Triangle0 = 
		[HexPoints[0],
		 DodPoints[11],
		 DodPoints[0]];

	Triangle1 = 
		[HexPoints[1],
		 DodPoints[1],
		 DodPoints[2]];
		
	Triangle2 = 
		[HexPoints[2],
		 DodPoints[3],
		 DodPoints[4]];		

	Triangle3 = 
		[HexPoints[3],
		 DodPoints[5],
		 DodPoints[6]];		

	Triangle4 = 
		[HexPoints[4],
		 DodPoints[7],
		 DodPoints[8]];		

	Triangle5 = 
		[HexPoints[5],
		 DodPoints[9],
		 DodPoints[10]];		
		
	Triangles = [Triangle0, Triangle1, Triangle2, Triangle3, Triangle4, Triangle5];
	
	// Render desired squares
	for (Square = SquareList)
	{
		SquareShape(Squares[Square], Inset, SquareHeight, RimThickness, RimHeight, RimGap, RimMaxElements, SquareExtruder, RimExtruder);
	}

	// Render desired triangles
	for (Triangle = TriangleList)
	{
		TriangleShape(Triangles[Triangle], Inset, TriangleHeight, RimThickness, RimHeight, RimGap, RimMaxElements, TriangleExtruder, RimExtruder);
	}

	// Render hexagon
	HexagonShape(HexPoints, Inset, HexHeight, RimThickness, RimHeight, RimGap, RimMaxElements, HexagonExtruder, RimExtruder);
	
	// Render dodecahedron (testing only)
	//DodecagonShape(DodPoints, 0, HexHeight - 0.6, RimThickness, RimHeight, RimGap, RimMaxElements);
}

module main()
{
	AllSquares   = [0, 1, 2, 3, 4, 5];
	AllTriangles = [0, 1, 2, 3, 4, 5];
	
	NextSquares   = [0, 1, 2, 3, 5];
	NextTriangles = [0, 1, 2, 3];
	
	// Compute X Spacing
	B = _HexRadius * sin(60);
	SpaceX = _HexRadius + B + _HexRadius + B + _HexRadius;
	
	// Compute Y Spacing
	SpaceY = B + _HexRadius + B;

	// Gap between rhombitrihexagons for debugging (set to 0 for production)
	Explode = 0;

	// Grid of nearly complete rhombitrihexagons at integer coordinates
	for (X = [0 : _CountX - 1])
	{
		for (Y = [0 : _CountY - 1])
		{
			// Compute location
			PointX = X * (SpaceX + Explode);
			PointY = Y * (SpaceY + Explode);

			// Figure out which squares and triangles to render
			RenderSquares   = (Y == 0) ? AllSquares   : NextSquares;
			RenderTriangles = (Y == 0) ? AllTriangles : NextTriangles;
			
			translate([PointX, PointY, 0])
			{
				Rhombitrihexagon(_HexRadius, _Inset, _HexHeight, _SquareHeight, _TriangleHeight, RenderSquares, RenderTriangles, _RimThickness, _RimHeight, _RimGap, _RimMaxElements, _HexagonExtruder, _TriangleExtruder, _SquareExtruder, _RimExtruder);
			}
		}
	}
	
	// Grid of very partial rhombitrihexagons at 0.5 coordinates
	for (X = [0 : _CountX - 2])
	{
		for (Y = [0 : _CountY - 1])
		{
			// Compute location
			PointX = (X * (SpaceX + Explode)) + SpaceX / 2 + Explode / 2;
			PointY = (Y * (SpaceY + Explode)) + SpaceY / 2 + Explode / 2;

			translate([PointX, PointY, 0])
			{
				Rhombitrihexagon(_HexRadius, _Inset, _HexHeight, _SquareHeight, _TriangleHeight, [4], [], _RimThickness, _RimHeight, _RimGap, _RimMaxElements, _HexagonExtruder, _TriangleExtruder, _SquareExtruder, _RimExtruder);
			}
		}
	}
}

main();
