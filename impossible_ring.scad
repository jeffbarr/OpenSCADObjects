// Impossible (not really) Ring
//
// TODO:
// - Slots for magnets
// - Per-level ring radius with angled separators
// - Separator shape
// - Compute and echo space between separators
// - Related way to create a "wall"
// - Related way to create rounded rectangle
//

// Ring count
_LayerCount = 1;

// Ring radius
_RingRadius = 77;

// Ring inset
_RingInset = 10;

// Ring thickness
_RingThickness = 3;

// Separator height
_SeparatorHeight = 30;

// Separator count
_SeparatorCount = 16;

/* [Options] */

// Solid base
_SolidBase = true;

// Partial ring
_PartialRing = false;

/* [Partial] */

// Starting degrees
_StartRing = 0;

// Ending degrees
_EndRing = 360;

// To hold a soda can: 5, 45, 10, 3, 22, 16

module RenderRing(Radius, Inset, Thickness)
{
	linear_extrude(Thickness)
	{
		difference()
		{
			circle(r=Radius, $fn=99);
			
			if (Inset != 0)
			{
				circle(r=Radius - Inset, $fn=99);
			}
		}
	}	
}

module RenderSeparators(Count, Radius, Inset, Height)
{

	for (Theta = [0 : 360 / Count : 360])
	{
		PointX = cos(Theta) * (Radius - (Inset / 2));
		PointY = sin(Theta) * (Radius - (Inset / 2));
		
		translate([PointX, PointY, 0])
		{
			linear_extrude(Height)
			{
				circle(r=Inset/2, $fn=99);
			}
		}
	}
}

// Render entire column of rings and separators
module RenderColumn(RingRadius, RingInset, SolidBase, LayerCount, RingThickness, SeparatorCount, SeparatorHeight)
{
	// First ring
	RenderRing(RingRadius, (SolidBase ? 0 : RingInset), RingThickness);
	
	LayerHeight = RingThickness + SeparatorHeight;
	
	// Separators and subsequent ring
	for (l = [1 : 1 : LayerCount - 1])
	{
		translate([0, 0, (l - 1) * LayerHeight])
		{
			translate([0, 0, RingThickness])
			{
				RenderSeparators(SeparatorCount, RingRadius, RingInset, SeparatorHeight);
			}
			
			translate([0, 0, RingThickness + SeparatorHeight])
			{
				RenderRing(RingRadius, RingInset, RingThickness);
			}
		}
	}
}

// Render a cheese wedge that keeps only the selected part of the column
// This is used as negative space and as such is slightly larger than necessary
module RenderCheese(Radius, Height, StartRing, EndRing)
{
	Radius2 = 1.2 * Radius; // Hack
	
	linear_extrude(Height)
	{
		Points = 
		[
			[0, 0], 
			for (Theta = [StartRing : $fa : EndRing - 1]) 
				[Radius2 * cos(Theta), Radius2 * sin(Theta)],
			[Radius2 * cos(EndRing), Radius2 * sin(EndRing)]
		];
		
		polygon(Points);
	}
	
}

module main()
{
	ColumnHeight = ((_LayerCount - 1) * _SeparatorHeight) + (_LayerCount * _RingThickness);
	
	echo("Column Height = ", ColumnHeight);
	
	if (_PartialRing)
	{
		intersection()
		{
			RenderColumn(_RingRadius, _RingInset, _SolidBase, _LayerCount, _RingThickness, _SeparatorCount,  _SeparatorHeight);
			RenderCheese(_RingRadius, ColumnHeight, _StartRing, _EndRing);
		}
	}
	else
	{
		RenderColumn(_RingRadius, _RingInset, _SolidBase, _LayerCount, _RingThickness, _SeparatorCount,  _SeparatorHeight);
	}
}

main();
