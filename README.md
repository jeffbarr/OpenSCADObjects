# Introduction
This repository contains a collection of [OpenSCAD](https://openscad.org/) objects that I am developing for my own use. Please check them out and let me know if you find them useful. Pull requests are always welcome!

Here's a review of each one:

* [aws_fabric_tiles.scad](https://github.com/jeffbarr/OpenSCADObjects#aws_fabric_tilesscad)
* [dentist_square.scad](https://github.com/jeffbarr/OpenSCADObjects#dentist_squarescad)
* [impossible_ring.scad](https://github.com/jeffbarr/OpenSCADObjects#impossible_ringscad)
* [neo_strip.scad](https://github.com/jeffbarr/OpenSCADObjects#neo_stripscad)
* [nodes_edges.scad](https://github.com/jeffbarr/OpenSCADObjects#nodes_edgesscad)
* [nodes_graph.scad](https://github.com/jeffbarr/OpenSCADObjects#nodes_graphscad)
* [quads.scad](https://github.com/jeffbarr/OpenSCADObjects#quadsscad)
* [rhombitrihexagon.scad](https://github.com/jeffbarr/OpenSCADObjects#rhombitrihexagonscad)
* [scales.scad](https://github.com/jeffbarr/OpenSCADObjects#scalesscad)
* [spikes.scad](https://github.com/jeffbarr/OpenSCADObjects#spikesscad)
* [super_hexagons.scad](https://github.com/jeffbarr/OpenSCADObjects#super_hexagonsscad)
* [talons.scad](https://github.com/jeffbarr/OpenSCADObjects#talonsscad)

## [aws_fabric_tiles.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/aws_fabric_tiles.scad)

A tiled grid of [AWS Service Icons](https://github.com/WayneStallwood/AWS-Tile-Generator/tree/main/samples). The STL files from that repo must be in the same directory as this script. Tiles are scaled by *TileScale* and then placed *SpaceX* and *SpaceY* apart, for a total of *CountX* columns and *CountY* rows.

![AWS Fabric Tiles](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/aws_fabric_tiles_sample.png)

This file is fully customizer-enabled.

## [dentist_square.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/dentist_square.scad)

An OpenSCAD replica of an interesting pattern that I found and captured in my dentist's office.
![Dentist Square](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/dentist_square_sample.jpg)

## [impossible_ring.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/impossible_ring.scad)

A tower of rings supported by round separators, fully customizer-enabled:

![Impossible Rings](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/impossible_ring_sample.jpg)

The math for the tilted separators was challenging, here is a diagram:
![Impossible Ring Math](https://github.com/jeffbarr/OpenSCADObjects/blob/main/diagrams/impossible_ring_math.jpg)

## [neo_strip.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/neo_strip.scad)

A 2-piece channel and matching cover for Adafruit [NeoPixels](https://www.adafruit.com/category/168), designed to hold the strips tightly and to diffuse the light into a softer glow.

![Neo Strip](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/neo_strip.png)

The channel is sized to fit strips within the weatherproof casing;
if you don't plan to use the casing  measure your strips and adjust the values of *SZ* and *SY* to suit.
The cover has a hexagonal hole for each NeoPixel and tabs that snap in to the top of the channel. You can print strips of any length by changing *NN*, subject to the size of your print bed. After you generate (F6) and save (F7) the STL, open it in your slicer,
split the object into two in your slicer and invert the channel (feel free to submit a PR to generate both in the same orientation). In general you will want to print the channel using a transparent color and the cover using an opaque one, but experiment. 

The channels are sized so that they can be butted end-to-end. You can set SB to create a half-slot at the beginning of the channel, and SE to create one at the end. Then you can print a cover that spans channels and holds them together.

Here is the original sketch that led to the design:

![Neo Strip Sketch](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/neo_strip_design.png)

## [quads.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/quads.scad)

A rectangle built from a grid of rectangles that are gently and randomly perturbed into quadrilaterals:

![Quads Sample](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/quads_sample_1.png)

Watch this [animation](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/quad_12x12.gif) to see how the values of *RowPert* and *ColPert* affect the generated image. The generated rectangle is a grid measuring *Rows* by *Cols*. Each interior rectangle/quadrilateral-to-be measures *RectDepth* by *RectWidth*, and there's *RectRowGap* / *RectColGap* between each one. The higher that *ColPert* and *RowPert* are, the more perturbed each one will be. Practically, these values should probably be no higher than half of *RectDepth* and *RectWidth*, but nothing will break if you set a higher value. 

The *HeightMode* is used to determine the height of each quadrilatoral, and it can be either "HM_FIXED" to make them all *BaseHeight*, or "HM_RANDOM" to make them any one of *Heights* random heights starting from *BaseHeight* and incrementing by *HeightInc*.

The *QuadType* is used to  the type of each quadrilateral. "QT_VERT" creates simple polygons with vertical sides ([sample](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/quads_sample_vert.png) ), "QT_TAPERED" ([sample](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/quads_sample_taper.png) ) creates simple polygons that taper to 50% of the original width and depth, and "QT_TOPO" creates more complex polyhedra that resemble a topological map ([sample](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/quads_sample_topo.png) ).

This file is fully customizer-enabled, and you can play with all of the options to get a better sense of what this code can do:

![OpenSCAD Customizer for quads.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/quads_customizer.png)

## [super_hexagons.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/super_hexagons.scad)

A grid of hexagons, each hexagon is made from 6 triangles, each of a different height:

![Super Hexagons Sample](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/super_hexagons_sample.png)

*TriangleSize* controls the size of each triangle, and there are *CountX* columns and *CountY* rows of hexagons. They are spaced by *SpaceX* from column to column, and *SpaceY* from row to row. *Shrinkage* if non-zero is scaling as the triangles get taller. The base height is *BaseHeight*, and step between the 6 heights (one per triangle) is *HeightInc*.  If *LeftFill* is set, the leftmost column has a straight edge. If *RightFill* is set, the rightmost column has a straight edge.

This file is fully customizer-enabled:

![OpenSCAD Customizer for super_hexagons.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/super_hexagons_customizer.png)

## [nodes_edges.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/nodes_edges.scad)

Nodes and edges in an offset grid:

![Nodes and Edges Sample](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/nodes_edges_sample.png)

*NodeSize* controls the size of each node, and there are *CountX* rows and *CountY* columns of nodes. They are spaced by *SpaceX* from column to column, and *SpaceY* from row to row. *NodeHeight* and *EdgeHeight* set the height of nodes and edges; *NodeRimHeight* and *EdgeRimHeight* do the same for the 3-concentric rim on nodes and edges, each of which is *RimThickness* thick. *EdgeWidth* is the width of each edge. *EdgeLengthXFactor* and *EdgeLengthXYFactor* are percentages that control the length of the X-aligned, and XY diagonal edges. 

Here's a sample in black and silver:

![Nodes and Edges Black and Silver](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/nodes_edges_black_silver.jpg)

This file is fully customizer-enabled.

## [nodes_graph.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/nodes_graph.scad)

A variant of [nodes_edges.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/nodes_edges.scad) with more layout flexibility -- circular (and semi-circular) rings of nodes and edges, axial rays that fill out a square or diagonal, and fringe. Still a work in progress.

Sample:

![Nodes Graphs Sample](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/nodes_graph_sample.jpg)

Mostly customizer-enabled, choosing the desired output is accomplished by editing the code.

## [scales.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/scales.scad)

All kinds of scales:

![Scales](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/scales_sample.png)

*CountX* and *CountY* set the number of scales in the X and Y direction, spaced *SpaceX* and *SpaceY* apart. If *EvenOddLayout* is set, scales on odd values of Y are offset by *SpaceX* / 2. If *EvenOddRotate* is set, those scales are rotated 180 degrees on the Z axis. 

The only supported *ScaleStyle* is "Ring". Within that, *ScaleRingShape* can be "Circle", "Triangle", "Hexagon", or "Octagon". The remaining parameters in this section control the size and thickness of each ring.

Fully customizer-enabled:

![Scales Customizer](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/scales_customizer.png)

## [spikes.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/spikes.scad)

Spikes on rafts:

![Spikes on Rafts](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/spikes_sample.png)

*_RaftCount* sets the number of rafts, each one separated by *_RaftSpaceX* and *_Raftheight* thick. Each raft has a grid of *_SpikeCountX* by *_SpikeCountY* spikes, and each spike is *_SpikeCylHeight* + *_SpikeTipHeight* high. Spikes can be cylindrical or pyramidal. Each cylindrical spike is *_SpikeRadius* around. Each pyramidal spike is on a square base *_PyrBase* wide and deep, and *_PyrHeight* tall, ith walls *_PyrWall* thick. Spikes of either type are spaced on the raft based on *_SpikeSpaceX* and *_SpikeSpaceY*. 

This file is fully customizer-enabled.

## [rhombitrihexagon.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/rhombitrihexagon.scad)

A [Rhombitrihexagon](https://en.wikipedia.org/wiki/Rhombitrihexagonal_tiling):

![Rhombitrihexagon](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/rth_small_sample.png)

One input value (*_HexRadius*) controls the size of all of the elements in the XY plane. The heights of the hexagons, squares, and triangles can be set individually. Read [this post](https://medium.com/@nextjeff/3d-printing-rhombitrihexagons-d9aa5c4a1251) to learn more about the code.

![Rhombitrihexagon Sample](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/rth_sample.png)

## [talons.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/talons.scad)

A grid or ring of talons, fully Customizer enabled, lots of parameters.

![Sample Talons](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/talons_sample.jpg)

Here's the Customizer:

![Talons Customizer](https://github.com/jeffbarr/OpenSCADObjects/blob/main/images/talons_customizer.png)

There are two layouts, *Grid* and *Ring*. If *SolidBase* is set, then talons are on a solid base that is *BaseThickness* high. Grid bases surround the talon grid with a border that is *BaseBorder* wide. Ring bases consist of a ring that has *RingBaseOuterRadius*, with a *RingBaseInnerRadius* hole in the center. Each talon is the intersection of two arcs of  *TalonRadius* , with the arcs separated by *TalonOffset*, and each talon *TalonThickness* wide. Talons are rotated by *TalonRotation*, with additional rotation for Ring bases.

Grid bases have *CountX* by *CountY* talons, spaced *SpaceX* and *SpaceY* apart, with talons on odd rows centered between those on even rows.

Ring bases have the primary ring of *MainRingTalonCount* talons at *MainFirstRingRadius*, then stepped by *MainRingRadiusStep* for *MainRingCount* times. There's also a secondary "fill" ring of *FillRingTalonCount* talons, starting at *FillFirstRingRadius*, then stepped by *FillRingRadiusStep* for *FillRingTalonCount* times. The ring itself is rotated by *FillRingRotate*.

