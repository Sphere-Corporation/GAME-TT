
|Platforms|Assembler|Link
|-|-|-|
|<img src="../../images/internet.png" width="24">|ASM-80/6800|[Homepage](https://www.asm80.com/onepage/asm6800.html)|

|<b>Directive<b>|<b>Description|Example|Notes|
|-|-|-|-|
|<pre>.CPU| Load in a specific overlay. Since ASM-80 is a multi-platform cross-assembler, the target chip must be specified|<pre>.CPU M6800</pre>|
|<pre>ORG| Start of assembly address| <pre>ORG $0200</pre>|
|<pre>EQU</pre>| Equate/Create a constant|<pre>CSRPTR  EQU     $1C</pre>|
|<pre>DB</pre>| Define data values|<pre>ICURSX   DB     #16</pre>|
|<pre>DW</pre>| Define Words|<pre>ICURSX   DW     $0104</pre>|
|<pre>.INCLUDE</pre>|INCLUDE another .asm file|<pre>.INCLUDE input.asm</pre>||
|<pre>.CSTR</pre>| Define a zero-terminated ASCII string|<pre>LBOARD   .CSTR    /---------/</pre>
|<pre>.ISTR</pre>| Define an ASCII string|<pre>LBOARD   .ISTR    /---------/</pre>

[Back to Assemblers](../ASSEMBLERS.md)