// arcs.scad - various kinds of arcs


/* [Arcs] */

// [Arc Count]
_ArcCount = 5;

// [Arc Width]
_ArcWidth = 5.0;

// [Arc Gap]
_ArcGap = 1.0;

// [Arc Start Radius]
_ArcStartRadius = 10.0;

// [Arc Thickness]
_ArcThickness = 2.0;

// [Arc Start Angle]
_ArcStartAngle = 0.0;

// [Arc End Angle]
_ArcEndAngle = 180.0;

// Arc
module Arc(InnerRadius, OuterRadius, StartAngle, EndAngle, Thickness)
{
    linear_extrude(Thickness)
    {
        H = sqrt(OuterRadius*OuterRadius + OuterRadius * OuterRadius);

        Cone =
        [
            [0, 0],
            for (Theta = [StartAngle : 1 : EndAngle]) [H * cos(Theta), H * sin(Theta)]
        ];
                 
        intersection()
        {
            difference()
            {
                circle(r=OuterRadius, $fn=99);
                circle(r=InnerRadius, $fn=99);
            }
            
            polygon(Cone);
        }
    }
}

module Arcs(ArcCount, ArcWidth, ArcGap, ArcStartRadius, ArcThickness, ArcStartAngle, ArcEndAngle)
{
    for (A = [0 : ArcCount - 1])
    {
        StartRadius = ArcStartRadius + (A *(ArcWidth + ArcGap));
        EndRadius   = StartRadius + ArcWidth;
        
        Arc(StartRadius, EndRadius, ArcStartAngle, ArcEndAngle, ArcThickness);
    }
}

module main(ArcCount, ArcWidth, ArcGap, ArcStartRadius, ArcThickness, ArcStartAngle, ArcEndAngle)
{
    Arcs(ArcCount, ArcWidth, ArcGap, ArcStartRadius, ArcThickness, ArcStartAngle, ArcEndAngle);
}

main(_ArcCount, _ArcWidth, _ArcGap, _ArcStartRadius, _ArcThickness, _ArcStartAngle, _ArcEndAngle);

