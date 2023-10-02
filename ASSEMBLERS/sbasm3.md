
|Platforms|Assembler|Link
|-|-|-|
|<img src="../images/macos.png" width="24"><img src="../images/windows.png" width="24"><img src="../images/linux.png" width="24">|SB Assembler v3|[Homepage](https://www.sbprojects.net/sbasm/)|

|<b>Directive<b>|<b>Description|Example|Notes|
|-|-|-|-|
|<pre>.CR| Load in a specific overlay. Since SBASM is a multi-platform cross-assembler, the target chip must be specified|<pre>.CR 6800</pre>|
|<pre>.TF| Target file name and format| <pre>.TF ttt.exe,BIN</pre>|
|<pre>.OR| Start of assembly address| <pre>.OR $0200</pre>|
|<pre>.LI|Switch on/off assembly listing (apart from errors)|<pre>.LI OFF</pre>|
|<pre>.IN</pre>|INclude another .asm file|<pre>.IN input</pre>|Not supplying an extension will default it to .asm|
|<pre>.EQU</pre>| Equate/Create a constant|<pre>CSRPTR  .EQU     $1C</pre>|
|<pre>.AS</pre>| Define an ASCII string - the value is the ASCII value of the required string|<pre>CROSS   .AS    #88</pre>|
|<pre>.AZ</pre>| Define a zero-terminated ASCII string|<pre>LBOARD   .AZ    /---------/</pre>
|<pre>.DA</pre>| Define data values|<pre>ICURSX   .DA     #16</pre>|

* Labels are defined using a convention of uppercase.
* SBASM has the concept of "local labels" - [here](https://www.sbprojects.net/sbasm/labels.php) is a full description of how these are used and what they mean.


[Back to Assemblers](../ASSEMBLERS.md)