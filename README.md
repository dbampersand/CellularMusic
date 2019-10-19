# CellularMusic
Musical 2D cellular automata using Processing

Usage: draw in the screen by holding the mouse button down, then press space to start the simulation.

Rows of buttons at the bottom are for the live/death rule and the procreate rule:

The live/death rule determines whether or not a cell dies in a given world tick based on it's number of neighbours and goes from 0 to 7 - that is to say, if the first button and only the first button is clicked, the cell will live if there is exactly zero neighbours adjacent to it. 

The procreate rule is similar, in that it determines if a cell will be born in a given coordinate if it's neighbors are equal to the rule; for example, if the third button is clicked, that means a cell will be born if it has exactly two neighbours. 

A musical scale can be selected by clicking the radio buttons on the right.

The sound tick speed and world tick speed sliders are for setting the sound tempo and the world simulation speed respectively. 

TODO:

Add dimensions above 2

Add arbitrary scales from 0-12 (maybe microtonal with more)

Investigate mouse input weirdness (unresponsive sometimes?)
