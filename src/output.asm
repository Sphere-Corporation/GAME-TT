;
; Output subroutines used within ttt.asm
;


;===============================================================================================
; SPLASH: Print Splash screen
;
; Entry:
;       N/A
;
; Exit:
;       XYCHA           Character to store the first character to go to the last character
;  
; External definitions:
;
;       BUILD           Label for the build information
;       MSGAGN          Label for the "Press a key" lines
;       SPLSH1          Label for the title of the program
;       PLAY1N          Player 1 name
;       PLAY1S          Player 1 score
;       PLAY2N          Player 2 name
;       PLAY2S          Player 2 score
;       PLAYER          Current player
;       XYCHA           Character to store the first character to go to the last character
;       KBDPIA          Address of PIA for KBD/2 (Only supports KBD/2)
;
; Dependencies:
;
;       CLS
;       CRLF
;       HOME    (System)
;       MLTCHR
;       PPLYN
;       PUTMSG
;       RSTR
;       STR
;
; Notes:
;
;       The "BUILD" label is inserted by an external command prior to assembling the code.
;       It must contain a centered "VERSION: " literal, followed by the build or version number.

SPLASH  JSR     STR            ; Store A/B/X
        JSR     CLS            
        LDX     #SPLSH1        ; Output the Title of the program
        JSR     PUTMSG
        LDX     #BUILD         ; Show the build/version number
        JSR     PUTMSG
        LDX     #MSGAGN        
        JSR     PUTMSG         ; ... and wait for a keypress

        JSR     STR
        LDX     #PLAY1N        ; Load X with the start of Player name 1
        LDAA    #1             ; Set the X co-ordinate to be 1
        STAA    CURSX          ; Store it in CURSX
        LDAB    #16            ; Set the Y co-ordinate to be 16,
        STAB    CURSY          ; Store it in CURSY
        JSR     PPLYN          ; Display the player 1 name

        LDX     #PLAY2N        ; Load X with the start of Player name 2
        LDAA    #24
        STAA    CURSX          ; Set the X co-ordinate to be 25
        LDAB    #16            ; Set the Y co-ordinate to be 6,
        STAB    CURSY          ; Store it in CURSY
        JSR     PPLYN          ; Display the player 1 name

        JSR     .DOSCORE       ; Display players scores on the splash screen
        
        LDAA    PLAYER         ; Determine which is the player to select on first entry to the splash screen
        CMPA    #2
        BEQ     .S2 
        JMP     .S1 
.S2     JSR     .SEL1
        BRA     .LOOP
.S1     JSR     .SEL2          


.LOOP   JSR     HOME           ; Place the cursor top left (and the corresponding CSRPTR value in X)
        LDAA    39,X           ; Get the first character and stash it
        STAA    XYCHA

        LDAB    #17            ; There are 17 characters in the whole message
.AGAIN  LDAA    40,X           ; Get the "second" character
        STAA    39,X           ; Store in the "first" character
        INX                    ; Increment the X register
        DECB                   ; Decrement the AccB
        CMPB    #0             ; Has AccB reached 0 ?
        BNE     .AGAIN         ; If not, loop again

        LDAA    XYCHA          ; Get first character
        JSR     HOME           ; and make it the last character
        STAA    56,X           ; by sending directly to the screen
        
        LDX     #10000         ; Delay by 10000 microseconds
.DLY    DEX                    ;        (1/100th second)
        BNE     .DLY
                               ; Get keypresss.....        
        LDAA    #$40           ; Load a mask for CA2 flag.
        BITA    KBDPIA+1       ; See if a character has been typed in.
        BNE     .OUT
        BRA     .LOOP          ; Loop around.......

.OUT    JSR     HOME
        LDAA    #65
        STAA    XYCHA
        CLRA
        CLRB
        JSR     PRTXY


        JSR     RSTR           ; Restore the A/B/X values
        LDAA    KBDPIA         ; Load the keypress value
        CMPA    RESET          ; Did they press "R" ?
        BEQ     .RESET         ; If so, reset the names and scores
        CMPA    EQUALS         ; Did they press "="
        BEQ     .SELPLY        ; If so, toggle the "Player" indicator.
        CMPA    NOUGHT         ; Did they press "O" ?
        BEQ     .NOUGHT
        CMPA    CROSS          ; Did they press "X" ?
        BEQ     .CROSS
        BRA     .LOOP
.CROSS  LDAA    #1             ; Cross's turn first
        STAA    TURN           ; Store that cross is going first
        RTS
.NOUGHT
        CLR     TURN
        RTS

.RESET  CLR     PLAY1S         ; Clear player 1 score
        CLR     PLAY2S         ; Clear player 2 score 
        JSR     .DOSCORE       ; Display the scores again
        BRA     .LOOP          ; When done, go back to the main loop

.DISPQ  JSR     PRTXY          ; Display a "Selected" indicator around a specific player
        ADDA    #8             ; After outputting the first symbol, add 8 to the X co-ordinate 
        JSR     PRTXY          ; Output the second "Selected" symbol 
        RTS

.SELPLY LDAB    #16            ; Load AccB with the row number of the Player 1 name
        LDAA    PLAYER         ; Switch selection between players
        CMPA    #1
        BEQ     .SEL2          ; If Player 1 is current, then switch to Player 2
                        
.SEL1   LDAA    SPACE          ; Switch to Player 1 
        JSR     .P2
        LDAA    EQUALS
        JSR     .P1
        LDAA    #1
        STAA    PLAYER
        JMP     .LOOP
        
.SEL2   LDAA    SPACE          ; Switch to Player 2
        JSR     .P1
        LDAA    EQUALS
        JSR     .P2
        LDAA    #2
        STAA    PLAYER
        JMP     .LOOP

.P1     STAA    XYCHA          ; Store the equals character in XYCHA
        CLRA                   ; For Player 1, set the X co-ordinate
        JSR     .DISPQ         ; Display the player selection
        RTS

.P2     STAA    XYCHA          ; Store the equals character in XYCHA
        LDAA    #23            ; For Player 2, set the X co-ordinate
        JSR     .DISPQ         ; Display the player selection
        RTS
.DOSCORE        
        LDAB    #16            ; Set Y co-ordinate of Player 1 score
        LDAA    PLAY1S         ; Get Player 1 score
        ADDA    #48            ; Add 48 to the score to give an ASCII value
        STAA    XYCHA          ; Store the ASCII score character in XYCHA
        LDAA    #13            ; Set the X co-ordinate of the Player 1 score
        JSR     PRTXY          ; Output XYCHA at (13,16)

        LDAA    PLAY2S         ; Get Player 2 score
        ADDA    #48            ; Add 48 to the score to give an ASCII value
        STAA    XYCHA          ; Store the ASCII score character in XYCHA
        LDAA    #18            ; Set the X co-ordinate of the Player 2 score
        LDAB    #16            ; Set Y co-ordinate of Player 2 score
        JSR     PRTXY          ; Output XYCHA at (18,16)
        RTS
;===============================================================================================


;===============================================================================================
; BOARD: Display the initial board
;
; Entry:
;       N/A
;
; Exit:
;       N/A
;  
; External definitions:
;
;       BLINEV          Vertical line
;       BLINEH          Horizontal line
;       SPACE           A space character
;       HLPMSG          Help message
;       TURN            Who is going first
;       DISPLY          Display Y co-ordinate for O and X
;       DISPLO          Display X co-ordinate for O
;       DISPLX          Display X co-ordinate for X
;
; Dependencies:
;
;       CLS
;       CRLF
;       MLTCHR
;       PRNTO
;       PRNTX
;       PUTMSG
;
; Notes:
;
;       This is a destructive operation - no storage of A/B/X

BOARD   JSR     CLS            ; Clear the screen ready to show board
        LDAB    #15            ; There are 15 lines to display
.LOOP1  LDX     #BLINEV        ; Display top set of vertical lines of the play area
        DECB
        JSR     CRLF
        CMPB    #1
        BEQ     .EXIT1         ; If AccB is 1, finish the loop
        CMPB    #4
        BEQ     .HORIZ         ; If the counter is 4 or 10, display a horizontal line
        CMPB    #10
        BEQ     .HORIZ
        JSR     PUTMSG         ; If the counter is NOT 4 or 10, display a vertical line
        BRA     .LOOP1         ; Loop again
.HORIZ  LDX     #BLINEH        ; Display a horizontal line
        JSR     PUTMSG
        BRA     .LOOP1

.EXIT1  JSR     PUTMSG         ; Output the final vertical lines
        LDAA    SPACE          ; Use an " " character
        LDAB    #12            ; Print it 12 times
        JSR     MLTCHR         ; Using the MLTCHR routine
        LDX     #BLINEV
        JSR     PUTMSG
        LDAA    TURN
        CMPA    #1
        BEQ     .CROSS 
        JSR     PRTDFO         ; Print large Nought
        BRA     .REST
.CROSS  JSR     PRTDFX         ; Print large Cross

        
.REST   JSR     HOME           ; Print the help message top left of the board
        LDX     #HLPMSG
        JSR     PUTMSG


        LDX     #PLAY1N        ; Load X with the start of Player name 1
        CLR     CURSX          ; Set the X co-ordinate to be zero
        LDAB    #6             ; Set the Y co-ordinate to be 6,
        STAB    CURSY          ; Store it in CURSY
        JSR     PPLYN          ; Display the player 1 name

        LDX     #PLAY2N        ; Load X with the start of Player name 2
        CLR     CURSX          ; Set the X co-ordinate to be zero
        LDAB    #12            ; Set the Y co-ordinate to be 12,
        STAB    CURSY          ; Store it in CURSY
        JSR     PPLYN          ; Display the player 2 name

        LDAB    #8             ; Set Y co-ordinate of Player 1 score
        LDAA    PLAY1S         ; Get Player 1 score
        ADDA    #48            ; Add 48 to the score to give an ASCII value
        STAA    XYCHA          ; Store the ASCII score character in XYCHA
        LDAA    #3             ; Set the X co-ordinate of the Player 1 score
        JSR     PRTXY          ; Output XYCHA at (3,8)

        LDAA    PLAY2S         ; Get Player 2 score
        ADDA    #48            ; Add 48 to the score to give an ASCII value
        STAA    XYCHA          ; Store the ASCII score character in XYCHA
        LDAA    #3             ; Set the X co-ordinate of the Player 2 score
        LDAB    #10            ; Set Y co-ordinate of Player 2 score
        JSR     PRTXY          ; Output XYCHA at (3,10)

        RTS
;===============================================================================================


;===============================================================================================
; PPLYN: Print a player's name at a specific location
;

PPLYN   CLR     .PPLYNC 
.PPLP   LDAA    0,X            ; Get the next character of the player's name
        STAA    XYCHA          ; Store it in XYCHA ready for output
        LDAA    .PPLYNC
        CMPA    #7             ; Is AccA 7 (have we reached the end of the player's name)?
        BEQ     .PPDN          ; If we have, jump to the end
        LDAA    CURSX          ; CURSX is the X co-ordinate 
        JSR     PRTXY          ; Otherwise, output the character
        INX                    ; Increment X (look at the next character)
        INC     CURSX          ; Increment the X position
        INC     .PPLYNC
        BRA     .PPLP          ; Go around the loop again
.PPDN
        RTS

.PPLYNC .DA     #0
;===============================================================================================


;===============================================================================================
; PUTPCE: Determine which piece to place at CURSX/CURSY
;
; Entry:
;       CURSX,CURSY : Contains the current location of the cursor (X,Y)
;       TURN        : Contains the current turn : 0 for Noughts, 1 for Crosses
;       POSIT       : Contains the "square number" being targetted  
;       PIECES      : Contains the number of pieces currently on the board
;
; Exit:
;       PIECES      : Contains the number of pieces currently on the board after this piece has been placed
;  
; External definitions:
;
;       CURSX,CURSY : 1 byte each
;       TURN        : 1 byte
;       POSIT       : 1 byte
;       PIECES      : 1 byte
;
; Dependencies:
;
;       CLS
;       CRLF
;       HOME    (System)
;       MLTCHR
;       PUTMSG
;       RSTR
;       STR
;
; Notes:
;

PUTPCE  
        INC     PIECES         ; Increment the number of pieces on the board
        LDAA    TURN           ; Find out who's turn it is.
        BEQ     .DO0
        JSR     .COMMON        ; This is Cross's turn so go get the X/Y positions
        JSR     PRNTX          ; Print Cross at correct location
        JSR     .OXOD          ; Pop it in the board matrix
        LDAA    CROSS          ; Get the cross symbol
        STAA    0,X            ; Store it in the board matrix
        LDAA    DISPLX
        LDAB    DISPLY
        JSR     PRNTB          ; Remove old symbol
        JSR     PRTDFO         ; Print large Nought
        CLR     TURN           ; Reset the TURN to zero (indicating next is nought's turn)
        JSR     SWPPLR

        BRA     .COMMON
        
.OXOD   LDX     #IBOARD
        LDAA    POSIT

.DOXOL  INX
        DECA
        BNE     .DOXOL
        DEX
        RTS

.DO0    JSR     .COMMON        ; Go get the X/Y positions
        JSR     PRNTO          ; Print Nought at correct location
        JSR     .OXOD
        LDAA    NOUGHT
        STAA    0,X
        LDAA    DISPLO
        LDAB    DISPLY
        JSR     PRNTB          ; Remove old symbol
        JSR     PRTDFX         ; Print large Cross

        LDAA    #1
        STAA    TURN
        JSR     SWPPLR

                               ; Falls through to .COMMON

.COMMON 

        LDAA    CURSX          ; Load current cursor x- co-ordinate
        LDAB    CURSY          ; Load current cursor y- co-ordinate
        RTS


;===============================================================================================
; PRNTX: Prints a cross  
;
; A Accumulator contains the X coordinate of the centre of the cross
; B Accumulator contains the Y coordinate of the centre of the cross

PRNTX   JSR     STR            ; Store A/B/X
        LDAA    CROSS
        STAA    CHARAT         ; Store piece to display
        STAA    XYCHA          ; also store in "previous character"
        LDAA    SCRTCHA
        JSR     PRTXY          ; Move cursor to centre of cross
        DECA
        DECB
        JSR     PRTXY
        ADDA    #2
        JSR     PRTXY
        ADDB    #2    
        JSR     PRTXY
        SUBA    #2
        JSR     PRTXY
        JSR     RSTR           ; Restore X/B/X
        RTS

;===============================================================================================
; PRNTO: Prints a nought  
;
; A Accumulator contains the X coordinate of the centre of the nought
; B Accumulator contains the Y coordinate of the centre of the nought

PRNTO   JSR     STR            ; Store A/B/X
        LDAA    SPACE
        STAA    XYCHA
        LDAA    SCRTCHA
        JSR     PRTXY
        LDAA    NOUGHT  
        STAA    XYCHA
        LDAA    SCRTCHA
        DECA
        DECB
        JSR     PRTXY          ; Move cursor to TOP LEFT of the nought
        INCA
        JSR     PRTXY          ; Top middle
        INCA
        JSR     PRTXY          ; Top right
        INCB
        JSR     PRTXY          ; Middle right
        INCB
        JSR     PRTXY          ; Bottom right
        DECA
        JSR     PRTXY          ; Bottom middle
        DECA
        JSR     PRTXY          ; Bottom left
        DECB
        JSR     PRTXY          ; Middle left
        JSR     RSTR           ; Restore A/B/X
        RTS

;===============================================================================================
; PRNTB: Prints a BIG blank space over where the nought/cross indicator was  
;
; A Accumulator contains the X coordinate of the centre of the space
; B Accumulator contains the Y coordinate of the centre of the space


PRNTB   JSR     STR            ; Store A/B/X
        LDAA    SPACE
        STAA    XYCHA
        LDAA    SCRTCHA
        JSR     PRTXY
        DECA
        DECB
        JSR     PRTXY          ; Move cursor to TOP LEFT of the square
        INCA
        JSR     PRTXY          ; Top middle
        INCA
        JSR     PRTXY          ; Top right
        INCB
        JSR     PRTXY          ; Middle right
        INCB
        JSR     PRTXY          ; Bottom right
        DECA
        JSR     PRTXY          ; Bottom middle
        DECA
        JSR     PRTXY          ; Bottom left
        DECB
        JSR     PRTXY          ; Middle left
        DECB
        JSR     PRTXY
        JSR     RSTR           ; Restore X/B/X
        RTS

;===============================================================================================
; INSTR: Show lines of instructions
;

INSTR   JSR     STR
        JSR     RSTCHA         ; Restore character previously at cursor position
        JSR     HOME           ; Ensure that printing will occur at (0,0)
        LDAA    SHOWHLP
        BEQ     .NOHELP
        CLRA
        STAA    SHOWHLP
        LDX     #INSLN
        BRA     .SHOW
.NOHELP LDAA    #1
        STAA    SHOWHLP
        LDX     #HLPMSG
        JSR     PUTMSG
        LDAA    SPACE          ; Use a " " character
        LDAB    #25            ; Print it 25 times to erase "Help" text
        JSR     MLTCHR
        RTS
.SHOW   JSR     PUTMSG
        JSR     RSTR
        RTS
;===============================================================================================


;===============================================================================================
; RSTCHA: Restore the character at the current cursor position
; 
; Entry:
;       CHARAT: Contains the character to restore
;       AccA  : Contains the X- co-ordinate of the position to restore
;       AccB  : Contains the Y- co-ordinate of the position to restore 
;
; Exit:
;       N/A
;  
; External definitions:
;
;       CHARAT          Contains the character to restore
;       XYCHA           Character to replace
;       CURSX           X- co-ordinate of the position to restore
; Dependencies:
;
;       PRTXY
;       RSTR
;       STR
;
; Notes:
;
;       The X- co-ordinate supplied is only used to restore it post operation.

RSTCHA  JSR     STR            ; Store the A/B/X Registers
        LDAA    CHARAT         ; Get the character to replace
        STAA    XYCHA          ; Store it in the "standard" position for PRTXY to get
        LDAA    CURSX          ; Reload the X co-ordinate
        JSR     PRTXY          ; Print the character
        JSR     RSTR           ; Restore A/B/X
        RTS
;===============================================================================================


;===============================================================================================
; DRAW: Game is a draw
;
; Entry:
;       N/A
;
; Exit:
;       N/A
;  
; External definitions:
;
;       DRWMSG          Label for "Draw Game" message
;
; Dependencies:
;
;       GETCHRB
;       HOME
;       PUTMSG
;       RSTR
;       STR
;
; Notes:
;
DRAW    JSR     STR            ; Store A/B/X
        JSR     HOME           ; Put cursor at (0,0)
        LDX     #DRWMSG        ; Get address of "Draw Game" message
        JSR     PUTMSG         ; Put the messge on the screen
        JSR     PRTDFO         ; Print a large-O in the default position
        JSR     PRTDFX         ; Print a large-X in the default position
        JSR     GETCHRB        ; Wait for a key press
        JSR     RSTR           ; Restore A/B/X
        RTS
;===============================================================================================


;===============================================================================================
; WIN: Show Win message
;
; TURN: 0 = nought has won
;       1 = cross has won

WIN     JSR     STR            ; Store the A/B/X registers
                               ; Blank out the large pieces on a win
        LDAB    DISPLY         ; Y-coordinate for O- and X-piece display
        LDAA    DISPLO         ; X-coordinate for O-piece display
        JSR     PRNTB          ; Print a blank over the nought symbol
        LDAB    DISPLY         ; Y-coordinate for O- and X-piece display
        LDAA    DISPLX         ; X-coordinate for X-piece display
        JSR     PRNTB          ; Print a blank over the cross symbol


        LDAA    PLAYER         ; Increment the player score or rollover to zero
        CMPA    #1             ; when the total reaches 9
        BEQ     .INCP2
        LDAA    PLAY1S
        CMPA    #9
        BEQ     .ROLL1
        INC     PLAY1S
        JMP     .NORX
.ROLL1  CLR     PLAY1S
        JMP     .NORX
.INCP2  LDAA    PLAY2S
        CMPA    #9
        BEQ     .ROLL2
        INC     PLAY2S
        JMP     .NORX
.ROLL2  CLR     PLAY2S

.NORX   LDAA    TURN
        BNE     .N

        LDAA    CROSS          ; Put cross symbol into AccA
        JMP     .STRMSG
.N      LDAA    NOUGHT         ; Put nought symbol into AccA
        
          
.STRMSG JSR     HOME           ; Put the cursor at (0,0)
        LDX     #WINLN         ; Get the address of the line of text to produce 
        STAA    0,X            ; Store appropriate symbol into first character of win message
        JSR     PUTMSG         ; Print the win line
        JSR     GETCHRB        ; Await a keypress
        JSR     RSTR           ; Restore the A/B/X registers
        RTS

;===============================================================================================
; PRTDFO: Display Large O in the default position
;
; 

PRTDFO  LDAB    DISPLY         ; Y-coordinate for O- and X-piece display
        LDAA    DISPLO         ; X-coordinate for O-piece display
        JSR     PRNTO          ; Print a nought symbol
        RTS

;===============================================================================================
; PRTDFX: Display Large X in the default position
;
; 

PRTDFX  LDAB    DISPLY         ; Y-coordinate for O- and X-piece display
        LDAA    DISPLX         ; X-coordinate for X-piece display
        JSR     PRNTX          ; Print a cross symbol
        RTS