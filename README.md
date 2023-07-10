# OpenSCADObjects
This repository contains a collection of [OpenSCAD](https://openscad.org/) objects that I am developing for my own use. Please check them out and let me know if you find them useful. Pull requests are always welcome!

Here's a review of each one:

* [**neo_strip.scad**](https://github.com/jeffbarr/OpenSCADObjects/blob/main/neo_strip.scad) - A 2-piece channel and matching cover for Adafruit [NeoPixels](https://www.adafruit.com/category/168). The channel is sized to fit strips within the weatherproof casing;
  if you don't plan to use the casing  measure your strips and adjust the values of *SZ* and *SY* to suit.
The cover has a hexagonal hole for each NeoPixel and tabs that snap in to the top of the channel. You can print strips of any length by changing *NN*, subject to the size of your print bed. After you generate (F6) and save (F7) the STL, open it in your slicer,
split the object into two in your slicer and invert the channel (feel free to submit a PR to generate both in the same orientation). In general you will want to print the channel using a transparent color and the cover using an opaque one, but experiment. The
channels are sized so that they can be butted end-to-end, but there's room for additional creativity here.
