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
	<!--
    <a href="https://demo.thelounge.chat/"><img
		alt="#thelounge IRC channel on Libera.Chat"
		src="https://img.shields.io/badge/Libera.Chat-%23thelounge-415364.svg?colorA=ff9e18"></a>
	<a href="https://yarn.pm/thelounge"><img
		alt="npm version"
		src="https://img.shields.io/npm/v/thelounge.svg?colorA=333a41&maxAge=3600"></a>
	<a href="https://github.com/thelounge/thelounge/actions"><img
		alt="Build Status"
		src="https://github.com/thelounge/thelounge/workflows/Build/badge.svg"></a>
        --!>
</p>

<p align="center">
	<img src="./images/in-play-sphere.png" width="550">
</p>

## Overview

- **Natve 6800 Assembly code.** No requirement for a Sphere-1 BASIC ROM.
- **Play against your Sphere-1.** Challenge your computer to a skillful game.

## Installation and Requirements

There are a number of prerequisites for downloading and running the game.

Which of the methods you use will depend on how you want to approach it, how experienced you are with assemblers, and what equipment you may or may not have.

All of the methods below require a method of running the game in either a virtual or physical Sphere-1 computer.

### Running from source

The prerequisites for this are:
 -  An MC6800 assembler available on the search path

Note that the assembler code is written to be compatible with the [SB-Assembler 3](https://www.sbprojects.net/sbasm/). 

If you prefer to use your own/different assembler, please make the changes to the source file so you can assemble it, and add a section to the ASSEMBLERS.md file describing what changes you needed to do to ensure it works.

Clone the repo from GitHub

```sh
git clone https://github.com/Sphere-Corporation/GAME-TT.git`
cd GAME-TT
./build
```

### Running from source

The following commands install and run the development version of The Lounge:

```sh
git clone https://github.com/thelounge/thelounge.git
cd thelounge
yarn install
NODE_ENV=production yarn build
yarn start
```

When installed like this, `thelounge` executable is not created. Use `node index <command>` to run commands.

⚠️ While it is the most recent codebase, this is not production-ready! Run at
your own risk. It is also not recommended to run this as root.

### Acknowledgements 

**Ben Zotto**
Inspiration, a wealth of information, the image of the Sphere-1 used above, and for alerting me to the Sphere-1 in the first place.

