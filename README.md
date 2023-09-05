# Introduction
This repository contains a collection of [OpenSCAD](https://openscad.org/) objects that I am developing for my own use. Please check them out and let me know if you find them useful. Pull requests are always welcome!

Here's a review of each one:

## [neo_strip.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/neo_strip.scad)

A 2-piece channel and matching cover for Adafruit [NeoPixels](https://www.adafruit.com/category/168), designed to hold the strips tightly and to diffuse the light into a softer glow. The channel is sized to fit strips within the weatherproof casing;
if you don't plan to use the casing  measure your strips and adjust the values of *SZ* and *SY* to suit.
The cover has a hexagonal hole for each NeoPixel and tabs that snap in to the top of the channel. You can print strips of any length by changing *NN*, subject to the size of your print bed. After you generate (F6) and save (F7) the STL, open it in your slicer,
split the object into two in your slicer and invert the channel (feel free to submit a PR to generate both in the same orientation). In general you will want to print the channel using a transparent color and the cover using an opaque one, but experiment. 

The channels are sized so that they can be butted end-to-end. You can set SB to create a half-slot at the beginning of the channel, and SE to create one at the end. Then you can print a cover that spans channels and holds them together.

## [quads.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/quads.scad)

A rectangle built from a grid of rectangles that are gently and randomly perturbed into quadrilaterals ([sample](https://github.com/jeffbarr/OpenSCADObjects/blob/main/quads_sample_1.jpg) ). Watch this [animation](https://github.com/jeffbarr/OpenSCADObjects/blob/main/quad_12x12.gif) to see how the values of *RowPert* and *ColPert* affect the generated image. The generated rectangle is a grid measuring *Rows* by *Cols*. Each interior rectangle/quadrilateral-to-be measures *RectDepth* by *RectWidth*, and there's *RectRowGap* / *RectColGap* between each one. The higher that *ColPert* and *RowPert* are, the more perturbed each one will be. Practically, these values should probably be no higher than half of *RectDepth* and *RectWidth*, but nothing will break if you set a higher value. 

The *HeightMode* is used to determine the height of each quadrilatoral, and it can be either "HM_FIXED" to make them all *BaseHeight*, or "HM_RANDOM" to make them any one of *Heights* random heights starting from *BaseHeight* and incrementing by *HeightInc*.

The *QuadType* is used to  the type of each quadrilateral. "QT_VERT" creates simple polygons with vertical sides ([sample](https://github.com/jeffbarr/OpenSCADObjects/blob/main/quads_sample_vert.png) ), "QT_TAPERED" ([sample](https://github.com/jeffbarr/OpenSCADObjects/blob/main/quads_sample_taper.png) ) creates simple polygons that taper to 50% of the original width and depth, and "QT_TOPO" creates more complex polyhedra that resemble a topological map ([sample](https://github.com/jeffbarr/OpenSCADObjects/blob/main/quads_sample_topo.png) ).

This file is fully customizer-enabled, and you can play with all of [the options](https://github.com/jeffbarr/OpenSCADObjects/blob/main/quads_customizer.png) to get a better sense of what this code can do:

![OpenSCAD Customizer for quads.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/quads_customizer.png)

## [super_hexagons.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/super_hexagons.scad)

A grid of hexagons, each hexagon is made from 6 triangles, each of a different height:

![Super Hexagons Sample](https://github.com/jeffbarr/OpenSCADObjects/blob/main/super_hexagons_sample.png)

*TriangleSize* controls the size of each triangle, and there are *CountX* columns and *CountY* rows of hexagons. They are spaced by *SpaceX* from column to column, and *SpaceY* from row to row. *Shrinkage* if non-zero is scaling as the triangles get taller. The base height is *BaseHeight*, and step between the 6 heights (one per triangle) is *HeightInc*.  If *LeftFill* is set, the leftmost column has a straight edge. If *RightFill* is set, the rightmost column has a straight edge.

This file is fully customizer-enabled:

![OpenSCAD Customizer for super_hexagons.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/super_hexagons_customizer.png)

