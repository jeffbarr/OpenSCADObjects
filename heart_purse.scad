// Heart Purse

//
// This is a hacky work in progress that was done under deadline pressure.
//
// To use it:
//
// 1 - Generate a heart with Separators true and Separator holes false, render, save, slice, print
//
// 2 - Generate another heart with Separators false and Separator Holes true, render, save, load into
//     slicer then flip on Z (pancake flip), and mirror in Y. Check to make sure that the holes will
//     line up with the separators, slice, print.
//

// TODO:
//
// - Figure out why 1.6 (BlackMagicOriginOffset) is needed
// - Additional separators closer to top for better balance, get metrics by building a better "heart" module
// - Fix inner brim
// - Option to print separate side parts that click in
// - Option grid of hearts
// - Embedded magnets
// - Holes for hooks or chain
//


/* [Heart] */
// Heart thickness 
_HeartThickness = 3;

// Single heart width
_HeartWidth = 10;

// Starting heart radius
_HeartStartR = 20;

// Wnding heart radius
_HeartEndR = 70;

// Heart radius step
_HeartStepR = 15;

/* [Details] */

// Separators
_Separators = false;

// Hinge cut
_HingeCut = false;

// Separator Holes
_SeparatorHoles = false;

// Brim (works on part without separator)
_Brim = false;

/* [Separators] */

// Separator height
_SeparatorHeight = 36;

// Separator X/Y size
_SeparatorSize = 7;

// Separator gap
_SeparatorGap = 20;

// Separator count
_SeparatorCount = 6;

// Separator inset from x or y axis
_SeparatorInset = 1.5;

/* [Separator Holes] */

// Separator hole depth
_SeparatorHoleDepth = 1.5;

// Separator hole X/Y wiggle adjustment
_SeparatorHoleWiggle = 0.2;

/* [Brim] */

// Brim width
_BrimWidth = 0.6;

// Brim height
_BrimHeight = 0.4;

// Sanity check
assert(!(_Separators && _SeparatorHoles), "Pick either separators or holes, not both!");
assert(!(_Separators && _Brim), "Don't use brim and separators together!");

// Black Magic - This makes the heart land at 0,0
BlackMagicOriginOffset = 1.6;
//BlackMagicOriginOffset = 0.0;

// Heart module based on math and code from https://openhome.cc/eGossip/OpenSCAD/Heart.html
module heart_sub_component(radius)
{
    rotated_angle = 45;
    diameter = radius * 2;
    $fn = 48;

    translate([-radius * cos(rotated_angle), 0, 0]) 
	{
        rotate(-rotated_angle) 
		{
			union()
			{
				circle(radius);
				translate([0, -radius, 0]) 
				{
					square(diameter);
				}
			}
		}
	}
}

module Heart(radius, center=true)
{
    offsetX = center ? 0 : radius + radius * cos(45);
    offsetY = center ? 1.5 * radius * sin(45) - 0.5 * radius : 3 * radius * sin(45);

    //center_offset_y = 1.5 * radius * sin(45) - 0.5 * radius;
	//echo("COY", center_offset_y);
	
	rotate(-45)
	{
		translate([offsetX, offsetY, 0]) union()
		{
			heart_sub_component(radius);
			
			mirror([1, 0, 0]) 
			{
				heart_sub_component(radius);
			}
		}
	}
}
// End of heart module

module HollowHeart(HeartRadius, Inset)
{
    difference()
    {
        Heart(HeartRadius);
        offset(-Inset) Heart(HeartRadius);
    }
}

// Nested rings of hearts
module HeartRings(Thickness, HeartStartR, HeartEndR, HeartStepR, HeartWidth, Brim, BrimWidth, BrimHeight)
{
    for (r = [HeartStartR : HeartStepR : HeartEndR])
    {
        linear_extrude(Thickness)
        {    
            HollowHeart(r, HeartWidth);
        }

		if (Brim)
		{
			translate([0, 0, Thickness])
			{
				{
					linear_extrude(BrimHeight)
					{
						HollowHeart(r, BrimWidth);
						// Following heart does not work right  - creates brim over thin air
						//HollowHeart(r - HeartWidth + (2 * BrimWidth), BrimWidth);
					}
				}
			}
		}
    }
}

// Separators
module HeartSeparators(BaseThickness, Height, Size, Gap, Count, Inset)
{
	// X Axis separators
	for (x = [0 : Count])
	{
		PointX = x * Gap + Inset;
		translate([PointX, Inset, BaseThickness])
		{
			cube([Size, Size, Height]);
		}
	}

	// Y Axis separators
	for (y = [1 : Count])
	{
		PointY = y * Gap;
		translate([Inset, PointY, BaseThickness])
		{
			cube([Size, Size, Height]);
		}
	}
}

// Separator holes, to be used as negative volume
module HeartSeparatorHoles(Depth, Wiggle, Size, Gap, Count, Inset)
{
	HalfWiggle = Wiggle / 2;
	
	// X Axis separator holes
	for (x = [0 : Count])
	{
		PointX = x * Gap + Inset;
		translate([PointX - HalfWiggle, Inset - HalfWiggle, -.001])
		{
			cube([Size + Wiggle, Size + Wiggle, Depth + .002]);
		}
	}

	// Y Axis separator holes
	for (y = [1 : Count])
	{
		PointY = y * Gap;
		translate([Inset - HalfWiggle, PointY - HalfWiggle, -.001])
		{
			cube([Size + Wiggle, Size + Wiggle, Depth + .002]);
		}
	}
}

// Render hearts
//
// Translate and rotate so that it is easier to see size of 
// finished set of hearts (BlackMagicOriginOffsetis empirical, and probably an actual computable value if I was smart enough)

module RenderHearts(HeartThickness, HeartStartR, HeartEndR, HeartStepR, HeartWidth, Brim, BrimWidth, BrimHeight)
{
	translate([HeartEndR + BlackMagicOriginOffset, HeartEndR + BlackMagicOriginOffset, 0])
	{
		//rotate(-45)
		{
			HeartRings(HeartThickness, HeartStartR, HeartEndR, HeartStepR, HeartWidth, Brim, BrimWidth, BrimHeight);
		}
	}
}

// Render a cut hinge (negative space) - Portion is fraction 0 to 1 of Length, determines position of hinge
module RenderHingeCut(Portion, Thickness, Length)
{
	translate([Portion * Length, Portion * Length, 0])
	rotate([0, 0, -45])
	{
		translate([-Length, 0, 0])
		cube([2 * Length, 3, Thickness + .001]);
	}
}

// Render the matter - heart itself aned optional separators
module RenderHeartMatter(HeartThickness, HeartStartR, HeartEndR, HeartStepR, HeartWidth, Separators, SeparatorHeight, SeparatorSize, SeparatorGap, SeparatorCount, SeparatorInset, Brim, BrimWidth, BrimHeight)
{
	RenderHearts(HeartThickness, HeartStartR, HeartEndR, HeartStepR, HeartWidth, Brim, BrimWidth, BrimHeight);

	if (Separators)
	{
		HeartSeparators(HeartThickness, SeparatorHeight, SeparatorSize, SeparatorGap, SeparatorCount, SeparatorInset);
	}
}

// Render the antimatter - optional hinge and optional separator holes
module RenderHeartAntiMatter(HingeCut, HeartThickness, HeartEndR, SeparatorHoles, SeparatorHoleDepth, SeparatorHoleWiggle, SeparatorSize, SeparatorGap, SeparatorCount, SeparatorInset)
{
		if (HingeCut)
		{
			RenderHingeCut(0.75, HeartThickness, 2 * HeartEndR);
		}
		
		if (SeparatorHoles)
		{
			HeartSeparatorHoles(SeparatorHoleDepth, SeparatorHoleWiggle, SeparatorSize, SeparatorGap, SeparatorCount, SeparatorInset);
		}
}

module main()
{
	difference()
	{
		// Matter: Heart and optional separators
		{
			RenderHeartMatter(_HeartThickness, _HeartStartR, _HeartEndR, _HeartStepR, _HeartWidth, _Separators, _SeparatorHeight, _SeparatorSize, _SeparatorGap, _SeparatorCount, _SeparatorInset, _Brim, _BrimWidth, _BrimHeight);
		}
		
		// Anti-matter: Optional hinge and optional hinge holes
		{
			RenderHeartAntiMatter(_HingeCut, _HeartThickness, _HeartEndR, _SeparatorHoles, _SeparatorHoleDepth, _SeparatorHoleWiggle, _SeparatorSize, _SeparatorGap, _SeparatorCount, _SeparatorInset);
		}
	}
}

main();
	
//translate([0, -5, 0]) cube([30, 5, 1], center=false);
/*linear_extrude(1)
translate([50, 50, 0])
Heart(50);*/