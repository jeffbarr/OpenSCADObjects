// mirror_shapes.scad -
//
// Each shape is composed of three layers:
// - The base layer is solid, with sides and radius of OuterShape*
//
// - The middle layer has a hole in the middle. The later has sides
//   and radius of OuterShape*, and the hole has sides and radius
//   determined by InnerShape*.


/* [Outer Shape] */

// Number of sides of outer shape
_OuterShapeSides = 4;

// Radius of outer shape
_OuterShapeRadius = 20;

/* [Inner Shape] */

// Number of sides of inner shape
_InnerShapeSides = 3;

// Radius of inner shape
_InnerShapeRadius = 15;

// Rotation for inner shape
_InnerShapeRotation = 0;

/* [Lid] */

// Lid inset
_LidInset = 2;

/* [Z] */ 

// Base thickness (plate to fabric)
_BaseThickness = 0.2;

// Inner shape thickness (above fabric)
_InnerShapeThickness = 0.4;

// Lid thickness (retains mirror)
_LidThickness = 0.2;

module OuterShape(ShapeRadius, ShapeSides, ShapeThickness)
{
  // Outer shape
  linear_extrude(ShapeThickness)
  {
    circle(r=ShapeRadius, $fn=ShapeSides);
  }
}

module InnerShape(ShapeRotation, ShapeRadius, ShapeSides, ShapeThickness)
{
  rotate([0, 0, ShapeRotation])
  {
    // Outer shape
    linear_extrude(ShapeThickness)
    {
        circle(r=ShapeRadius, $fn=ShapeSides);
    }
  }
}

module main(OuterShapeSides, OuterShapeRadius, LidInset, InnerShapeSides, InnerShapeRadius, InnerShapeRotation, BaseThickness, InnerShapeThickness, LidThickness, LidInset)
{
    union()
    {
        // Outer shape below fabric
        OuterShape(OuterShapeRadius, OuterShapeSides, BaseThickness);
        
        // Outer shape above fabric with hole for inner shape / mirror
        translate([0, 0, BaseThickness])
        {
            difference()
            {
                OuterShape(OuterShapeRadius, OuterShapeSides, InnerShapeThickness);

                InnerShape(InnerShapeRotation, InnerShapeRadius, InnerShapeSides, InnerShapeThickness + .001);
            }
        }
        
        // Lid that locks in mirror
        translate([0, 0, BaseThickness + InnerShapeThickness])
        difference()
        {
            OuterShape(OuterShapeRadius, OuterShapeSides, LidThickness);
            InnerShape(InnerShapeRotation, InnerShapeRadius - LidInset, InnerShapeSides, InnerShapeThickness + .001);
        }
    }    
  
}

main(_OuterShapeSides, _OuterShapeRadius, _LidInset, _InnerShapeSides, _InnerShapeRadius, _InnerShapeRotation, _BaseThickness, _InnerShapeThickness, _LidThickness, _LidInset);

