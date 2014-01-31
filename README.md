Tool-Change-post-processor
=========================

Works with KISSlicer and Cura gcode files with the comments enabled.

Relative retractions need to have at least one digit after the decimal place even if it is a zero

Must have M82 in start code for Absolute E or M83 for Relative E

Post processor to change the tool used for different extrusion types in RepRap gcode

It looks for the comments stating when each extrusion type starts (perimeter, loops, solid infill, sparse infill, 
support, support interface) and sets the temperatures and offset for different extruders

The script is written in lua so you will need lua installed or an executable copy in the same folder as the script 
and the slicer. 

To use with Kisslicer you will also need to add the following to the post-process field in the firmware tab of Kisslicer.
`lua "Tool_change.lua" " <FILE> "`

To use with Cura you will have to run it as a seperate process from the command line with the following command.
`lua "Tool_change.lua" "example.gcode"`

At the top of the script file you will see where the variables are set for each extrusion type

Note: The script creates a second gcode file marked processed.

