# Introduction
This repository contains a collection of [OpenSCAD](https://openscad.org/) objects that I am developing for my own use. Please check them out and let me know if you find them useful. Pull requests are always welcome!

Here's a review of each one:

## [neo_strip.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/neo_strip.scad)

A 2-piece channel and matching cover for Adafruit [NeoPixels](https://www.adafruit.com/category/168), designed to hold the strips tightly and to diffuse the light into a softer glow. The channel is sized to fit strips within the weatherproof casing;
if you don't plan to use the casing  measure your strips and adjust the values of *SZ* and *SY* to suit.
The cover has a hexagonal hole for each NeoPixel and tabs that snap in to the top of the channel. You can print strips of any length by changing *NN*, subject to the size of your print bed. After you generate (F6) and save (F7) the STL, open it in your slicer,
split the object into two in your slicer and invert the channel (feel free to submit a PR to generate both in the same orientation). In general you will want to print the channel using a transparent color and the cover using an opaque one, but experiment. 

The channels are sized so that they can be butted end-to-end. You can set SB to create a half-slot at the beginning of the channel, and SE to create one at the end. Then you can print a cover that spans channels and holds them together.

## [quads.scad](https://github.com/jeffbarr/OpenSCADObjects/blob/main/neo_strip.scad)

A rectangle built from a grid of rectangles that are gently and randomly perturbed into quadrilaterals ([sample](https://github.com/jeffbarr/OpenSCADObjects/blob/main/quads_sample_1.jpg) ). Watch this [animation](https://github.com/jeffbarr/OpenSCADObjects/blob/main/quad_12x12.gif) to see how the values of *RowPert* and *ColPert* affect the generated image. The generated rectangle is a grid measuring *Rows* by *Cols*. Each interior rectangle/quadrilateral-to-be measures *RectDepth* by *RectWidth*, and there's *RectRowGap* / *RectColGap* between each one. The higher that *ColPert* and *RowPert* are, the more perturbed each onie will be. Practically, these values should probably be no higher than half of *RectDepth* and *RectWidth*, but nothing will break if you set a higher value.

