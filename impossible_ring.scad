// Impossible (not really) Ring
//
// TODO:
// - Magnet option chooser:
//   - Small
//   - Large
//   - Custom
// - Per-level ring radius with angled separators
// - Separator shape
// - Compute and echo space between separators
// - Related way to create a "wall"
// - Related way to create rounded rectangle
//
// Ring that fits a soda can: 5, 45, 10, 3, 22, 16
//
//
// Small diametric magnet: 14.0, 3.5, 2.0, 0.8 -- for _RingInset = 12
// Large diametric magnet: 14.0, 7.0, 2.0, 0.8 -- for _RingInset = 19

// Ring count
_LayerCount = 1;

// Ring radius
_RingRadius = 77;

// Ring inset
_RingInset = 14;

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

// Magnet slots
_MagnetSlots = false;

/* [Partial] */

// Starting degrees
_StartRing = 0;

// Ending degrees
_EndRing = 360;

/* [Magnets] */

// Magnet angles
_MagnetAngles = [0, 0, 0, 0];

// Slot height
_MagnetSlotHeight = 14.0;

// Slot width/depth
_MagnetWidthDepth = 7; // 3.5;

// Height above base of separator
_MagnetHeight = 2.0;

// Inset from mid-point of separator
_MagnetInset = 0.8;

// Sanity checks
assert(_SeparatorHeight > (_MagnetHeight + _MagnetSlotHeight), "Magnet too tall");

// Render a ring
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

// Render a single separator
module RenderSeparator(Radius, Height)
{
		linear_extrude(Height)
		{
			circle(r=Radius, $fn=99);
		}
}

// Render a magnet hole centered horizontally within a separator of size SeparatorRadius
module RenderMagnetHole(SeparatorRadius, SlotHeight, WidthDepth, Height, Inset)
{
	translate([0, Inset + WidthDepth / 2, Height + SlotHeight / 2])
	{
		cube([WidthDepth, WidthDepth, SlotHeight], center=true);
	}
}

// Render a single separator with a magnet hole
module RenderSeparatorWithMagnetHole(Radius, Height, MagnetSlotHeight, MagnetWidthDepth, MagnetHeight, MagnetInset)
{
	difference()
	{
		// Matter
		RenderSeparator(Radius, Height);
		
		// Anti-matter
		RenderMagnetHole(Radius, MagnetSlotHeight, MagnetWidthDepth, MagnetHeight, MagnetInset);
	}
}

// Render entire ring of separators with optional magnet holes at the specified angles
module RenderSeparators(Count, Radius, Inset, Height, MagnetSlots, MagnetAngles, MagnetSlotHeight, MagnetWidthDepth, MagnetHeight, MagnetInset)
{

	for (Theta = [0 : 360 / Count : 359])
	{
		PointX = cos(Theta) * (Radius - (Inset / 2));
		PointY = sin(Theta) * (Radius - (Inset / 2));
		
		translate([PointX, PointY, 0])
		{
			MagnetHere = MagnetSlots && (len(search(Theta, MagnetAngles)) > 0);
					
			// Handle separators with and without magnets separately	
			if (MagnetHere)
			{
				echo("Need a magnet at ", Theta);
				
				// Does not work for 270, but 90 and 180 are the most important cases
				SeparatorRotate = (Theta == 90) ? -90 : 0;
				
				rotate([0, 0, SeparatorRotate])
				{
					RenderSeparatorWithMagnetHole(Inset / 2, Height, MagnetSlotHeight, MagnetWidthDepth, MagnetHeight, MagnetInset);
				}
			}
			else
			{
				RenderSeparator(Inset / 2, Height);
			}
		}
	}
}

// Render entire column of rings and separators, with optional magnet holes in separator, for the separators listed in MagnetAngles
module RenderColumn(RingRadius, RingInset, SolidBase, LayerCount, RingThickness, SeparatorCount, SeparatorHeight, MagnetSlots, MagnetAngles, MagnetSlotHeight, MagnetWidthDepth, MagnetHeight, MagnetInset)
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
				RenderSeparators(SeparatorCount, RingRadius, RingInset, SeparatorHeight, MagnetSlots, MagnetAngles, MagnetSlotHeight, MagnetWidthDepth, MagnetHeight, MagnetInset);
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
			RenderColumn(_RingRadius, _RingInset, _SolidBase, _LayerCount, _RingThickness, _SeparatorCount,  _SeparatorHeight, _MagnetSlots, _MagnetAngles, _MagnetSlotHeight, _MagnetWidthDepth, _MagnetHeight, _MagnetInset);
			RenderCheese(_RingRadius, ColumnHeight, _StartRing, _EndRing);
		}
	}
	else
	{
		RenderColumn(_RingRadius, _RingInset, _SolidBase, _LayerCount, _RingThickness, _SeparatorCount,  _SeparatorHeight, false, [], 0, 0, 0, 0);
	}
}

main();
