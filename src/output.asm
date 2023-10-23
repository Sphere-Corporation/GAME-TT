;
; Output subroutines used within ttt.asm
;


;===============================================================================================
; SPLASH: Print Splash screen
;
SPLASH  JSR     STR
        JSR     CLS             ; Clear the screen and output two lines of banner
        LDAB    #2              ; Produce 2 blank lines
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
        JSR     PUTMSG      ; ... and wait for a keypress
        JSR     RSTR
        RTS

;===============================================================================================
; BOARD: Display the board and set the cursor to the centre square

BOARD   JSR     CLS            ; Clear the screen ready to show board
        LDAB    #15

.LOOP1  LDX     #BLINEV        ; Display top set of vertical lines of the play area
        DECB
        JSR     CRLF
        CMPB    #1
        BEQ     .EXIT1
        CMPB    #4
        BEQ     .HORIZ
        CMPB    #10
        BEQ     .HORIZ
        JSR     PUTMSG
        BRA     .LOOP1
.HORIZ  LDX     #BLINEH 
        JSR     PUTMSG
        BRA     .LOOP1
.EXIT1  JSR     PUTMSG         ; Output the final vertical line
        LDAA    SPACE          ; Use an " " character
        LDAB    #12            ; Print it 12 times
        JSR     MLTCHR
        LDX     #HLPMSG        ; Output the Help message
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
        RTS

;===============================================================================================
; PUTPCE: Determine which piece to place at CURSX/CURSY
;
; CURSX,CURSY : Contains the current location of the cursor (X,Y)
; TURN        : Contains the current turn : 0 for Noughts, 1 for Crosses
; POSIT       : Contains the "square number" being targetted  

PUTPCE  

        INC     PIECES         ; Increment the number of pieces on the board
        LDAA    TURN
        BEQ     .DO0
.DOX    JSR     .COMMON

        JSR     PRNTX          ; Print Cross at correct location

        JSR     .OXOD          ; Pop it in the board matrix
        LDAA    CROSS
        STAA    0,X
        CLRA    TURN
        LDAA    CROSS
        LDAA    DISPLX
        LDAB    DISPLY
        JSR     PRNTB          ; Remove old symbol
        LDAA    DISPLO
        LDAB    DISPLY        
        JSR     PRNTO          ; Print large Nought
        CLR     TURN     
        BRA     .COMMON
        
.OXOD   LDX     #IBOARD
        LDAA    POSIT
.DOXOL  INX
        DECA
        BNE     .DOXOL
        DEX
        RTS

.DO0    JSR     .COMMON

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

.COMMON LDAA    CURSX
        LDAB    CURSY
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
        JSR     RSTR           ; Restore X/B/X
        RTS

;===============================================================================================
; PRNTB: Prints a BIG blank space over where the nought/cross indicator was  
;
; A Accumulator contains the X coordinate of the centre of the space
; B Accumulator contains the Y coordinate of the centre of the space


PRNTB   JSR     STR            ; Store A/B/X
        ;STAA    SCRTCHA
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
        LDAA    SPACE          ; Use a " " character
        LDAB    #39            ; Print it 39 times to erase "Help" text
        JSR     MLTCHR
        BRA     .XINSTR
.SHOW   JSR     PUTMSG
        JSR     RSTR
.XINSTR RTS

;===============================================================================================
; RSTCHA: Restore the character at the current cursor position
; 
; CHARAT: Contains the character to restore

RSTCHA
        JSR     STR
        LDAA    CHARAT
        STAA    XYCHA
        LDAA    CURSX
        JSR     PRTXY
        JSR     RSTR
        RTS
        
;===============================================================================================
; DRAW: Game is a draw
;

DRAW                           ; Output Draw message and wait for a key
        JSR     STR
        JSR     HOME
        LDX     #DRWMSG
        JSR     PUTMSG
        JSR     GETCHRB
        JSR     RSTR
        RTS

;===============================================================================================
; WINMSG: Show Win message
;
; TURN: 0 = nought has won
;       1 = cross has won

WIN     JSR     STR
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
          
.STRMSG LDX     #WINLN
        STAA    0,X            ; Store appropriate symbol into first character of win message
        JSR     HOME
        LDX     #WINLN
        JSR     PUTMSG         ; Print the win line
        JSR     GETCHRB        ; Await a keypress
        JSR     RSTR
        RTS