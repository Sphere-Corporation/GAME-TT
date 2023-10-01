<h1 align="center">
	<img
		width="300"
		alt="OXO/TTT Logo"
		src="./images/logo.png">
</h1>

<h4 align="center">
	A Game of<br>OXO 
    <br>Tic-Tac-Toe<br>Noughts and Crosses
    <h3 align="center">for the Sphere-1</h3>
</h4>




<p align="center">
	<img src="./images/in-play-sphere.png" width="550">
</p>

## Overview

- **Native 6800 Assembly code.** No requirement for a Sphere-1 BASIC ROM.
- **Play against your friend.** Challenge your friend to a skillful game.
- **Read about Noughts and Crosses [here](https://en.wikipedia.org/wiki/Tic-tac-toe)**


## Status
This game is still under development. Not all features have been implemented.

## Installation and Requirements

There are a number of prerequisites for downloading and running the game.

Which of the methods you use will depend on how you want to approach it, how experienced you are with assemblers, and what equipment you may or may not have.

All of the methods below require a method of running the game in either a virtual or physical Sphere-1 computer.

### Running from source

The prerequisites for this are:
 -  An MC6800 assembler available on the search path

Note that the assembler code is written to be compatible with the [SB-Assembler 3](https://www.sbprojects.net/sbasm/). 

If you prefer to use your own/different assembler, please make the changes to the source file so you can assemble it, and add a section to the [ASSEMBLERS.md](ASSEMBLERS.md) file describing what changes you needed to do to ensure it works.

Clone the repo from GitHub, then run the build script

```sh
git clone https://github.com/Sphere-Corporation/GAME-TT.git`
cd GAME-TT
./build
```

### Acknowledgements 

**Ben Zotto**<br>
Inspiration, a wealth of information, the image of the Sphere-1 used above, and for alerting me to the Sphere-1 in the first place.

