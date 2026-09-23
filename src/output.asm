;
; Output subroutines used within ttt.asm
;

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

        LDAA    MODE           ; Find out what game mode we are playing
        CMPA    #$46           ; If we are playing 2-players i.e. MODE='F'
        BEQ     .PL2           ; 
        LDX     #PLAYCN        ; Load X with the start of Computer player name
        JMP     .DISP           
.PL2    LDX     #PLAY2N        ; Load X with the start of Player name 2
.DISP   CLR     CURSX          ; Set the X co-ordinate to be zero
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