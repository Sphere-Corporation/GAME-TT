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
;       SPLSH2          Label for the copyright line
;
;       XYCHA           Character to store the first character to go to the last character
;       KBDPIA          Address of PIA for KBD/2 (Only supports KBD/2)
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
;       The "BUILD" label is inserted by an external command prior to assembling the code.
;       It must contain a centered "VERSION: " literal, followed by the build or version number.

SPLASH  JSR     STR            ; Store A/B/X
        JSR     CLS            ; Clear the screen and output two lines of banner
        LDAB    #2             ; Produce 2 blank lines
        JSR     MULTCR
        LDX     #SPLSH1        ; Output the Title of the program
        JSR     PUTMSG
        LDAB    #8             ; Produce 8 blank lines
        JSR     MULTCR
        LDX     #SPLSH2        ; Then the copyright message
        JSR     PUTMSG
        JSR     CRLF           ; Display a blank line
        LDX     #BUILD         ; Display Build information
        JSR     PUTMSG
        LDAB    #3             ; Produce 3 blank lines
        JSR     MULTCR
        LDX     #MSGAGN        
        JSR     PUTMSG         ; ... and wait for a keypress

        JSR     STR
        ;LDX     #PLAY1N
        ;CLR     CURSX
        ;LDAB    #16
        ;STAB    CURSY
        ;JSR     PPLYN
        
        ;LDX     #PLAY2N
        ;LDAA    #20
        ;STAA    CURSX
        ;LDAB    #16
        ;STAB    CURSY
        ;JSR     PPLYN
        JSR     RSTR 
        
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

.OUT    JSR     RSTR           ; Restore the A/B/X values
        LDAA    KBDPIA         ; Load the keypress value
        CMPA    RESET          ; Did they press "R" ?
        BEQ     .RESET         ; If so, reset the names and scores
        RTS

.RESET  CLR     PLAY1S         ; Clear player 1 score
        CLR     PLAY2S         ; Clear player 2 score 
        CLR     PLAYERS        ; Clear variable indicating there are no player names       
        LDAA    #32            ; Load AccA with a space
        LDAB    #14            ; 14 characters in "PLAYER1PLAYER2"
        LDX     #PLAY1N        ; Get initial location of player's names
.CLRLWP STAA    0,X            ; Clear a character from the players name
        INX                    ; Increment to see next character
        DECB                   ; Compare with end of player's names
        BNE     .CLRLWP        ; If not - go again
        JSR     RSTR           ; Load stored A/B/X
        BRA     .LOOP          ; When done, go back to the main loop
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
        LDAB    DISPLY         ; Y-coordinate for O- and X-piece display
        LDAA    DISPLO         ; X-coordinate for O-piece display
        JSR     PRNTO          ; Print a large O-piece
        RTS
.CROSS  LDAB    DISPLY         ; Y-coordinate for O- and X-piece display
        LDAA    DISPLX         ; X-coordinate for X-piece display
        JSR     PRNTX          ; Print a large X-piece
        
        JSR     HOME           ; Print the help message top left of the board
        LDX     #HLPMSG
        JSR     PUTMSG


        LDX     #PLAY1N
        CLR     CURSX
        LDAB    #6
        STAB    CURSY
        LDAB    CURSY
        JSR     PPLYN

        LDX     #PLAY2N
        CLR     CURSX
        LDAB    #12
        STAB    CURSY
        JSR     PPLYN

        LDAB    #8
        LDAA    PLAY1S
        ADDA    #48
        STAA    XYCHA
        LDAA    #3
        JSR     PRTXY

        LDAA    PLAY2S
        ADDA    #48
        STAA    XYCHA
        LDAA    #3
        LDAB    #10
        JSR     PRTXY

        RTS
;===============================================================================================


;===============================================================================================
; PPLYN: Print a player's name at a specific location

PPLYN                          ; Display "Player name"
        LDAA    0,X
        STAA    XYCHA
        LDAA    CURSX
        CMPA    #7
        BEQ     .PPDN
        JSR     PRTXY
        INX
        INC     CURSX
        BRA     PPLYN

.PPDN
        RTS
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
.DOX    JSR     .COMMON        ; This is Cross's turn so go get the X/Y positions

        JSR     PRNTX          ; Print Cross at correct location

        JSR     .OXOD          ; Pop it in the board matrix
        LDAA    CROSS          ; Get the cross symbol
        STAA    0,X            ; Store it in the board matrix
        ;LDAA    CROSS
        LDAA    DISPLX
        LDAB    DISPLY
        JSR     PRNTB          ; Remove old symbol
        LDAA    DISPLO
        LDAB    DISPLY        
        JSR     PRNTO          ; Print large Nought
        CLR     TURN           ; Reset the TURN to zero (indicating next is nought's turn)
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
        LDAA    #1
        STAA    TURN
        LDAA    NOUGHT
        
        LDAA    DISPLO
        LDAB    DISPLY
        JSR     PRNTB          ; Remove old symbol
        LDAA    DISPLX
        LDAB    DISPLY
        JSR     PRNTX          ; Print large Cross
                               ; Falls through to .COMMON

.COMMON LDAA    CURSX          ; Load current cursor x- co-ordinate
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
        LDAB    DISPLY         ; Y-coordinate for O- and X-piece display
        LDAA    DISPLO         ; X-coordinate for O-piece display
        JSR     PRNTO          ; Print a nought symbol
        LDAB    DISPLY         ; Y-coordinate for O- and X-piece display
        LDAA    DISPLX         ; X-coordinate for X-piece display
        JSR     PRNTX          ; Print a cross symbol

        JSR     GETCHRB        ; Wait for a key press
        JSR     RSTR           ; Restore A/B/X
        RTS
;===============================================================================================


;===============================================================================================
; WINMSG: Show Win message
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

        LDAA    TURN           ; See who has won
        CMPA    #1             ; O's has won
        BEQ     .N
        LDAA    CROSS          ; Pop cross symbol into AccA
        BRA     .STRMSG
.N      LDAA    NOUGHT         ; Pop nought symbol into AccA
          
.STRMSG JSR     HOME           ; Put the cursor at (0,0)
        LDX     #WINLN         ; Get the address of the line of text to produce 
        STAA    0,X            ; Store appropriate symbol into first character of win message
        JSR     PUTMSG         ; Print the win line
        JSR     GETCHRB        ; Await a keypress
        JSR     RSTR           ; Restore the A/B/X registers
        RTS