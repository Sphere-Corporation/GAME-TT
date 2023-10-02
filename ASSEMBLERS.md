## Assembler compatibility

In order to assemble the GAME-TT code, an MC6800 assembler must be used. The game was built using [SB-Assembler 3](https://www.sbprojects.net/sbasm/).

Here, each assembler that is used to assemble to the code into a working executable is listed, together with any changes that need to be done to the code to make it work with that specific assembler. 

The source code should NOT change, however, since the source code is assembled by an assembler which takes as input one or more source files, and, together with some directives, produces executable code. It is those directives that differ between assemblers.

This compatibility chart is designed to assist developers in adapting this code (and other code) for different assemblers.

Other directives may be added over time as they are used.

|<b>Directive<b>|<b>[SB Assembler v3](./ASSEMBLERS/sbasm3.md)</b>|<b>[ASM-80](./ASSEMBLERS/asm80.md)</b>|[Sphere-1 Mini-assembler](./ASSEMBLERS/sphere-mini.md)|
|-|-|-|-|
|Target Processor Type<pre>|.CR| .CPU|
|Target file name and format|.TF||
|Start of assembly address|.OR|ORG|=|
|Toggle assembly listing|.LI||
|Include another source file|.IN|.INCLUDE|
|Equate/Create a constant|.EQU|EQU|=|
|Define an ASCII string|.AS|.ISTR|
|Define a word|.DB|DB|
<hr>
