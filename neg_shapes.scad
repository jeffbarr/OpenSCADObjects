// negative_shapes carved from a slab

//
// Final clip to get rid of element borders for partial elements
//
// Add texture to base
//  Make texture height and thickness into parameters
//	Better compute size
//	Grid texture should be adjacent to cut lines
//
// Very fancy rotate
//   MAJOR time - sequence through element shapes
//	 MID time - sequence through element sizes
//   MINOR time - rotate 360
//
// Option to not do half-elements at each edge

/* [Base] */

// X count
_CountX = 10;

// Y count
_CountY = 10;

// X space
_SpaceX = 20;

// Y Space
_SpaceY = 20;

// Base thickness
_BaseThickness = 2;

// Gap
_BaseGap = 1;

/* [Element] */

_ElementShape = "Circle"; // [Circle, Triangle, Square, Hexagon, Octagon]

// Element size
_ElementSize = 6;

// Element border
_ElementBorder = false;

// Element border thickness
_ElementBorderThickness = 2;

// Element border height
_ElementBorderHeight = 0.4;

/* [Texture] */

// Texture style
_TextureStyle = "None"; // [None, BaseRing, BaseGrid]

// Texture shape
_TextureShape = "None"; // [None, Circle, Triangle, Square, Hexagon, Octagon]

// Texture space
_TextureSpace = 4;

module __end_cust() {};

// Compute size of base
_BaseWidth = _CountX * (_SpaceX + _BaseGap);
_BaseDepth = _CountY * (_SpaceY + _BaseGap);

module Base(Width, Depth, Thickness)
{
	color("blue")
	{
		cube([Width, Depth, Thickness]);
	}
}

// Cuts in X or Y direction
module Cuts(XorY, Start, Count, Space, Width, Depth, Gap)
{
	if (XorY == "X")
	{
		for (X = [0 : Count])
		{
			PointX = Start + (X * (Space + Gap)) - Gap / 2;
			translate([PointX, 0, -99])
			{
				cube([Gap, Depth, 200]);
			}
		}
	}
	
	if (XorY == "Y")
	{
		for (Y = [0 : Count])
		{
			PointY = Start + (Y * (Space + Gap)) - Gap / 2;
			translate([0, PointY, -99])
			{
				cube([Width, Gap, 200]);
			}
		}
	}
}

// Render an element that will be used as anti-matter
module Element(Shape, Size, Thickness)
{
	if (Shape == "Circle")
	{
		translate([0, 0, Thickness / 2])
		{
			cylinder(Thickness, r=Size, center=true);
		}
	}	
	
	if (Shape == "Triangle")
	{
		linear_extrude(Thickness)
		{
			circle(Size, $fn=3);
		}
	}
	
	if (Shape == "Square")
	{
		linear_extrude(Thickness)
		{
			square(Size, Size, center=true);
		}
	}
	
	if (Shape == "Hexagon")
	{
		linear_extrude(Thickness)
		{
			circle(Size, $fn=6);
		}
	}

	if (Shape == "Octagon")
	{
		linear_extrude(Thickness)
		{
			rotate(22.5)
			{
				circle(Size, $fn=8);
			}
		}
	}	
}

// Render a grid of elements
module 	ElementGrid(CountX, CountY, SpaceX, SpaceY, BaseThickness, Gap, ElementShape, ElementSize)
{
	for (X = [0 : CountX ])
	{
		for (Y = [0 : CountY])
		{
			// Compute center of cell
			PointX = X * (SpaceX + Gap);
			PointY = Y * (SpaceY + Gap);
			
			translate([PointX, PointY, -.001])
			{
				Element(ElementShape, ElementSize, BaseThickness + .002);
			}
		}
	}
}

// Render a grid of element borders
module ElementGridBorder(CountX, CountY, SpaceX, SpaceY, Gap, Shape, ElementSize, ElementBorderThickness, ElementBorderHeight)
{
	Sides = ShapeToSides(Shape);
	Angle = ShapeToAngle(Shape);
			
	for (X = [0 : CountX ])
	{
		for (Y = [0 : CountY])
		{
			// Compute center of cell
			PointX = X * (SpaceX + Gap);
			PointY = Y * (SpaceY + Gap);
			
			translate([PointX, PointY, 0])
			{
				linear_extrude(ElementBorderHeight)
				{
					difference()
					{
						circle(r=ElementSize + ElementBorderThickness, $fn=Sides);
						circle(r=ElementSize, $fn=Sides);
					}
				}
			}
		}
	}
}

// Map a texture shape to the number of sides
function ShapeToSides(Shape) =
(
	(Shape == "None"     ?  0 :
	 Shape == "Circle"   ? 99 : 
	 Shape == "Triangle" ?  3 :
	 Shape == "Square"   ?  4 :
	 Shape == "Hexagon"  ?  6 :
	 Shape == "Octagon"  ?  8 :
	 0)
);

// Map a texture shape to rotation angle
function ShapeToAngle(Shape) =
(
	(Shape == "None"     ?  0    :
	 Shape == "Circle"   ?  0    : 
	 Shape == "Triangle" ?  0    :
	 Shape == "Square"   ?  45   :
	 Shape == "Hexagon"  ?  0    :
	 Shape == "Octagon"  ?  22.5 :
	 0)
);

// Render a texture over the base
//
// Shape works for some of the styles, as follows:
//
//	BaseRing - Each ring is the given Shape
//

module Texture(Shape, Width, Depth, Style, Space)
{
	color("red")
	{
		if (Style == "None")
		{
		}
		
		// A bunch of rings centered on the base
		if (Style == "BaseRing")
		{
			Sides = ShapeToSides(Shape);
			Angle = ShapeToAngle(Shape);
			
			// TODO: Compute more accurate limits
			for (r = [0 : Space : max(Width / 2, Depth / 2)])
			{
				linear_extrude(0.6)
				{
					difference()
					{
						// Matter
						{
							rotate(Angle)
							{
								circle(r + 1, $fn=Sides);
							}
						}
						
						// Anti-matter
						{
							rotate(Angle)
							{
								circle(r, $fn=Sides);
							}
						}
					}
				}
			}
		}
		
		if (Style == "BaseGrid")
		{
			// TODO
		}
	}
}

// Render base, elements, and texture
module BasePlusElements(BaseWidth, BaseDepth, BaseThickness, CountX, CountY, SpaceX, SpaceY, Gap, ElementShape, ElementSize, ElementBorder, ElementBorderThickness, ElementBorderHeight, TextureShape, TextureStyle, TextureSpace)
{
	difference()
	{
		// Matter
		{
			union()
			{
				// Base
				Base(BaseWidth, BaseDepth, BaseThickness);

				// Texture
				translate([BaseWidth / 2, BaseDepth / 2, BaseThickness])
				{
					Texture(TextureShape, BaseWidth, BaseDepth, TextureStyle, TextureSpace);
				}
				
				// Element borders
				if (ElementBorder)
				{
					translate([0, 0, BaseThickness])
					{
						ElementGridBorder(CountX, CountY, SpaceX, SpaceY, Gap, ElementShape, ElementSize, ElementBorderThickness, ElementBorderHeight);
					}
				}
			}
		}
		
		// Anti-matter
		{
			union()
			{
				// Cuts between elements
				Cuts("X", 0, CountX, SpaceX, BaseWidth, BaseDepth, Gap);
				Cuts("Y", 0, CountY, SpaceY, BaseWidth, BaseDepth, Gap);
				
				// Elements
				// 5 is a hack to make the elements tall enough to clip out texture
				ElementGrid(CountX, CountY, SpaceX, SpaceY, BaseThickness + 5, Gap, ElementShape, ElementSize);
			}
		}
	}
}

module main()
{
	// If animating, use $t to determine rotation, element shape, and element size:
	//
	// SERRR

	if ($t != 0)
	{
		T10K = $t * 10000;
		echo(T10K);
		
		
		//Rotation = ;
		//Shape = ;
		//Size = ;
		// Use Rotation to change viewport not object
		
		rotate( 0* 360)
		{
			translate([-_BaseWidth / 2, -_BaseDepth / 2, 0])
			{
				BasePlusElements(_BaseWidth, _BaseDepth, _BaseThickness, _CountX, _CountY, _SpaceX, _SpaceY, _BaseGap, _ElementShape, _ElementSize, _ElementBorder, _ElementBorderThickness, _ElementBorderHeight, _TextureShape, _TextureStyle, _TextureSpace);
			}
		}
	}
	else
	{
		translate([-_BaseWidth / 2, -_BaseDepth / 2, 0])
		{
			BasePlusElements(_BaseWidth, _BaseDepth, _BaseThickness, _CountX, _CountY, _SpaceX, _SpaceY, _BaseGap, _ElementShape, _ElementSize, _ElementBorder, _ElementBorderThickness, _ElementBorderHeight, _TextureShape, _TextureStyle, _TextureSpace);
		}
	}
}



main();
