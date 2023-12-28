// Rhombitrihexagonal Tiling
//
// https://en.wikipedia.org/wiki/Rhombitrihexagonal_tiling
//

// Hexagon radius
_HexRadius = 17.5;

// Inset of each element
_Inset = 0.5;

// Hexagon height
_HexHeight = 2;

// Square height
_SquareHeight = 1.6;

// Triangle height
_TriangleHeight = 1.2;

module __end_cust() {};

//
// Render a square
//

module SquareShape(Points, Inset, Height)
{
	color("blue")
	{	
		linear_extrude(Height)
		{
			offset(-Inset)
			{
				polygon(Points);
			}
		}
	}
}

//
// Render a triangle
//

module TriangleShape(Points, Inset, Height)
{
	color("red")
	{	
		linear_extrude(Height)
		{
			offset(-Inset)
			{
				polygon(Points);
			}
		}
	}
}

//
// Render a hexagon
//

module HexagonShape(Points, Inset, Height)
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
// Render a dodecagon
//

module DodecagonShape(Points, Inset, Height)
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
// Render all or part of a rhombitrihexagon, with given inset and heights
//
// Squares and triangles are numbered counter-clockwise, with 0 intersecting the Y axis on the +x side.
//

module Rhombitrihexagon(HexRadius, Inset, HexHeight, SquareHeight, TriangleHeight, SquareList, TriangleList)
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
		SquareShape(Squares[Square], Inset, SquareHeight);
	}

	// Render desired triangles
	for (Triangle = TriangleList)
	{
		TriangleShape(Triangles[Triangle], Inset, TriangleHeight);
	}

	// Render hexagon
	HexagonShape(HexPoints, Inset, HexHeight);
	
	// Render dodecahedron (testing only)
	//DodecagonShape(DodPoints, 0, HexHeight - 0.6);
}

module main()
{
	AllSquares   = [0, 1, 2, 3, 4, 5];
	AllTriangles = [0, 1, 2, 3, 4, 5];
	
	NextSquares   = [0, 1, 2, 3, 5];
	NextTriangles = [0, 1, 2, 3];
	
	FirstMidSquares   = [4];
	FirstMidTriangles = [];
	
	NoSquares   = [];
	NoTriangles = [];
	
	// Compute X Spacing
	B = _HexRadius * sin(60);
	SpaceX = _HexRadius + B + _HexRadius + B + _HexRadius;
	
	// Compute Y Spacing
	SpaceY = B + _HexRadius + B;

	// Grid of  at full spacing
	// Row 0
	translate([0, 0, 0])
	{
		Rhombitrihexagon(_HexRadius, _Inset, _HexHeight, _SquareHeight, _TriangleHeight, AllSquares, AllTriangles);
	}
	
	translate([SpaceX, 0, 0])
	{
		Rhombitrihexagon(_HexRadius, _Inset, _HexHeight, _SquareHeight, _TriangleHeight, AllSquares, AllTriangles);
	}
	
	// Row 1
	translate([0, SpaceY, 0])
	{
		Rhombitrihexagon(_HexRadius, _Inset, _HexHeight, _SquareHeight, _TriangleHeight, NextSquares, NextTriangles);	
	}
	
	translate([SpaceX, SpaceY, 0])
	{
		Rhombitrihexagon(_HexRadius, _Inset, _HexHeight, _SquareHeight, _TriangleHeight, NextSquares, NextTriangles);
	}

	// Fill in between row
	translate([SpaceX / 2, -SpaceY / 2, 0])
	{
		Rhombitrihexagon(_HexRadius, _Inset, _HexHeight, _SquareHeight, _TriangleHeight, [3, 4, 5], [4, 5]);
	}
	
	translate([SpaceX / 2, SpaceY / 2, 0])
	{
		Rhombitrihexagon(_HexRadius, _Inset, _HexHeight, _SquareHeight, _TriangleHeight, FirstMidSquares, FirstMidTriangles);
	}

	translate([SpaceX / 2, SpaceY + SpaceY / 2, 0])
	{
		Rhombitrihexagon(_HexRadius, _Inset, _HexHeight, _SquareHeight, _TriangleHeight, [0, 1, 2, 4], [1, 2]);	
	}
}

main();
