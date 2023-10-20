
|Platforms|Assembler|Link
|-|-|-|
|<img src="../../images/sphere.png" width="24">|Sphere-1 Mini-Assembler|[Binary](https://sphere.computer/firmware/pds-v3n.bin)|

|<b>Directive<b>|<b>Description|Example|Notes|
|-|-|-|-|
|<pre>=</pre>| Equate/Create a constant|<pre>S = _ _ _ _ _ 1 5 _ _</pre>|Create a constant named `S`|
|<pre>=</pre>| Start of assembly address|<pre>_ = _ _ _ _ _ 0 2 0 0</pre>|

* Labels can only be 1 ASCII character long:
    <pre>B _ _ 7 F _ E * 2  3  4</pre>
  In this example, the label is "`B`"

* The program must contain an "`END`" as the last line
* The mini-assembler used in the Sphere-1 requires hand-assembly of mnemonics to op-codes prior to entry.

**(Extracted from the Sphere-1 Operator's Guide section 9)**

The Mini-Assembler is entered via the Ctrl A Command from the keyboard to assemble source code from a fixed position in memory.

The low memory pointer SRCASM is set up by the editor to point to the start of the source code. This means that the origin of the assembled code is the first byte after the end of the source code in memory, unless an `=` directive is used with no label in position 1.

This assembler requires: 
- only one statement reside on a line at a time. 
- each line to be assembled must appear in fixed format. 
- each line must end in a carriage return, however, the CR is not recognized until after column 8 of the input line. 

Below is a description of the assembier statement format:
*Example*
<pre>
               <u>B</u> <u> </u> <u> </u> <u>7</u> <u>F</u> <u> </u> <u>E</u> <u>*</u> <u>2</u>  <u>3</u>  <u>4</u>
Input position 1 2 3 4 5 6 7 8 9 10 11
</pre>

<u>Notes on Assembler format</u>

##### LOCATION TAG: Position 1 ##### 
This position contains any one of the sixty three ASCII characters or a blank. Placing a non-blank character
in this position allows the user to access the location
in other places using a label rather than an address.

##### EQUATE: Position 2 #####
This position may contain an "=" or a blank.
If it is equal to "=" then the location label (position) will reference the location specified by the operand. (positions 8 +).

##### OP-CODE: Position 4 and 5 #####
These positions may contain spaces or a two digit hexadecimal equivalent of an instruction code. If the
field is blank no allocation of memory will be made for the instruction code. 
Otherwise the supplied two hexadecimal digits will be converted to a single byte and be deposited in the current assembly output location.

##### OPERAND TYPE: Position 7 #####
This field may contain one of the three letters R, D, E, or a blank. 

- If the operand type is blank no operand will be evaluated and no allocation of memory will take place. 

- An "R" specifies that the operand in positions 8 + will create one byte of data relative to the current label assignment plus 2, this operand type is used for branches.

- A "D" specifies that the operand in position 8 + will create one byte of data. 

- An "E" specifies that the operand in positions 8 + will create two bytes of data.

##### OPERAND VALUE: Positions 8 + #####
These positions must be terminated by a space or a carriage return. The four forms of operand values are described below:

**1** The at sign "@" followed by a single character indicates that data shall be referenced at the location specified by the letter following the "@"
The reference is to the last definition encountered before it is used. The definition can be made on either the first or second pass (backward or forward references respectively).

**2** One or more hexadecimal characters. If a number overflows the 16 bit BA register, only the low order 16 bits are saved, high order bits are best.

**3** One or more decimal digits proceded by a period.

**4** One or more octal digits preceded by an asterisk.

[Back to Assemblers](../ASSEMBLERS.md)