;
; Output subroutines used within ttt.asm
;


;===============================================================================================
; SPLASH: Print Splash screen
;
SPLASH  JSR     STR
        JSR     CLS        ; Clear the screen and output two lines of banner
        LDAB    #2          ; Produce 2 blank lines
        JSR     MULTCR
        LDX     #.SPLSH1    ; Output the Title of the program
        JSR     PUTMSG
        LDAB    #8          ; Produce 8 blank lines
        JSR     MULTCR
        LDX     #.SPLSH2    ; Then the copyright message
        JSR     PUTMSG
        LDX     #.BUILD      ; Display Build information
        JSR     PUTMSG
        LDAB    #3          ; Produce 2 blank lines
        JSR     MULTCR
        LDX     #.MSGAGN    ; ... and wait for a keypress
        JSR     PUTMSG
        JSR     RSTR
.FINAL  RTS

; Static messages for the subroutine
;
.SPLSH1  .AZ  /     == NOUGHTS & CROSSES ==/
.SPLSH2  .AZ  /     (C) ANDREW SHAPTON 2023/
.MSGAGN  .AZ  /          PRESS ANY KEY/
        
        .IN build            ; Include dynamic Build information

;===============================================================================================
; PUTMSG: Prints a zero-terminated message  
;
; X contains the start address of the message
; Example:
;    LDX     #MSG2
;    JSR     PUTMSG
;
;    MSG2    .AZ  /Informational Message/

PUTMSG  JSR     STR           ; Store A/B/X
        LDAA    0, X
        BEQ     .PMEXT
        STX     .MSGIDX
        JSR     PUTCHR
        LDX     .MSGIDX
        INX
        BRA     PUTMSG
.PMEXT  JSR     RSTR          ; Restore A/B/X
.FINAL  RTS

; Space to store the index register
.MSGIDX  .DA     1,1           ; Reserved space for local temp variable


;===============================================================================================
; MLTCHR: Prints a given char (n) times
;
; A Accumulator contains the character for multiple printings goes here.
; B Accumulator contains the multiple (n)
; Example:
;
;        LDAA    #$40           ; Use an "@" character
;        LDAB    #$15           ; Print it $15 times
;        JSR     MLTCHR         ; Call the routine
MLTCHR
.MLOOP  BEQ      .FINAL
        JSR      PUTCHR
        DECB
        BRA      .MLOOP
.FINAL  RTS


;===============================================================================================
; MULTCR: Emits multiple blank lines
;
; B Accumulator contains the number of blank lines to print


MULTCR  JSR     STR           ; Store A/B/X
.AGAIN  DECB
        BEQ     .OUT
        STAB    .MCRB
        JSR     CRLF          ; Output a CR at the current cursor position
        LDAB    .MCRB
        BRA     .AGAIN
.OUT    JSR     RSTR         ; Restore X/B/X
.FINAL  RTS

.MCRB  .DA     1              ; Scratch store for AccB

;===============================================================================================
; CRLF: Emits a carriage return
;
CRLF    JSR     STR           ; Store A/B/X    
        LDAA    #$0D
        JSR     PUTCHR        ; Output a CR at the current cursor position
        JSR     RSTR          ; Restore X/B/X
.FINAL  RTS


;===============================================================================================
; BOARD: Display the board and set the cursor to the centre square

BOARD   JSR     CLS        ; Clear the screen ready to show board
        LDAB    #15

.LOOP1  LDX     #.BLINEV    ; Display top set of vertical lines of the play area
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
.HORIZ  LDX     #.BLINEH 
        JSR     PUTMSG
        BRA     .LOOP1
.EXIT1  JSR     PUTMSG      ; Output the final vertical line
        LDAA    #SPACE           ; Use an "@" character
        LDAB    #12          ; Print it $15 times
        JSR     MLTCHR
        LDX     #.HLPMSG    ; Output the Help message
        JSR     PUTMSG
        LDAB    DISPLY ; Y-coordinate for O- and X-piece display
        LDAA    DISPLX ; X-coordinate for X-piece display
        JSR     PRNTX  ; Print a large X-piece
.FINAL  RTS


; Text to be used as part of the board 
.BLINEV  .AZ  /             !     !/
.BLINEH  .AZ  /        -----+-----+-----/
.HLPMSG  .AZ  /H-HELP       !     !/
;===============================================================================================
; PRTXY: Prints a given char at co-ordinates (X,Y) on the screen (0,0) is top left
;
; A Accumulator contains the X coordinate
; B Accumulator contains the Y coordinate
; XYCHA contains the character to print

XYCHA   .DA     #0             ; Storage for character to print
PRTXY   JSR     STR
        JSR     CURXY   ; Move the cursor to the correct loctation
        LDAA    XYCHA   ; Load character into AccA
        STAA    0,X     ; Send to screen
        JSR     RSTR
        RTS

;===============================================================================================
; PUTPCE: Determine which piece to place at CURSX/CURSY
;
; CURSX,CURSY : Contains the current location of the cursor (X,Y)
; TURN        : Contains the current turn : 0 for Noughts, 1 for Crosses

PUTPCE  LDAA    TURN
        CMPA    #0
        BEQ     .DO0
.DOX    JSR     .COMMON
        JSR     PRNTX           ; Print Cross at correct location

        JSR     .OXOD           ; Pop it in the board matrix
        LDAA    CROSS
        
        STAA    0,X
        LDAA    #0
        STAA    TURN

        LDAA    DISPLX
        LDAB    DISPLY
        JSR     PRNTB           ; Remove old symbol
        LDAA    DISPLO
        LDAB    DISPLY        
        JSR     PRNTO           ; Print large Nought
        BRA     .COMMON
        
.OXOD   LDX     #IBOARD
        LDAA    POSIT
.DOXOL  INX
        DECA
        CMPA    #0
        BNE     .DOXOL
        DEX
        RTS

.DO0    JSR     .COMMON
        JSR     PRNTO           ; Print Nought at correct location
        JSR     .OXOD
        LDAA    NOUGHT
        STAA    0,X
        LDAA    #1
        STAA    TURN
        LDAA    DISPLO
        LDAB    DISPLY
        JSR     PRNTB           ; Remove old symbol
        LDAA    DISPLX
        LDAB    DISPLY
        JSR     PRNTX           ; Print large Cross
                                ; Falls through to .COMMON

.COMMON LDAA    CURSX
        LDAB    CURSY
XPUTPCE RTS

;===============================================================================================
; PRNTX: Prints a cross  
;
; A Accumulator contains the X coordinate of the centre of the cross
; B Accumulator contains the Y coordinate of the centre of the cross


PRNTX   JSR     STR           ; Store A/B/X
        LDAA    CROSS
        STAA    CHARAT        ; Store piece to display
        STAA    XYCHA         ; also store in "previous character"
        LDAA    SCRTCHA
        JSR     PRTXY         ; Move cursor to centre of cross
        DECA
        DECB
        JSR     PRTXY
        ADDA    #2
        JSR     PRTXY
        ADDB    #2    
        JSR     PRTXY
        SUBA    #2
        JSR     PRTXY
XPRNTX  JSR     RSTR          ; Restore X/B/X
        RTS

;===============================================================================================
; PRNTO: Prints a nought  
;
; A Accumulator contains the X coordinate of the centre of the nought
; B Accumulator contains the Y coordinate of the centre of the nought


PRNTO   JSR     STR           ; Store A/B/X
        LDAA    NOUGHT
        STAA    XYCHA
        LDAA    SPACE
        STAA    CHARAT        ; Store previous character as it will be
        LDAA    SCRTCHA
        DECA
        DECB
        JSR     PRTXY         ; Move cursor to TOP LEFT of the nought
        INCA
        JSR     PRTXY         ; Top middle
        INCA
        JSR     PRTXY         ; Top right
        INCB
        JSR     PRTXY         ; Middle right
        INCB
        JSR     PRTXY         ; Bottom right
        DECA
        JSR     PRTXY         ; Bottom middle
        DECA
        JSR     PRTXY         ; Bottom left
        DECB
        JSR     PRTXY         ; Middle left
XPRNTO  JSR     RSTR          ; Restore X/B/X
        RTS

;===============================================================================================
; PRNTB: Prints a BIG blank space over where the nought/cross indicator was  
;
; A Accumulator contains the X coordinate of the centre of the space
; B Accumulator contains the Y coordinate of the centre of the space


PRNTB   JSR     STR           ; Store A/B/X
        STAA    SCRTCHA
        LDAA    SPACE
        STAA    XYCHA
        LDAA    SCRTCHA
        JSR     PRTXY
        DECA
        DECB
        JSR     PRTXY         ; Move cursor to TOP LEFT of the square
        INCA
        JSR     PRTXY         ; Top middle
        INCA
        JSR     PRTXY         ; Top right
        INCB
        JSR     PRTXY         ; Middle right
        INCB
        JSR     PRTXY         ; Bottom right
        DECA
        JSR     PRTXY         ; Bottom middle
        DECA
        JSR     PRTXY         ; Bottom left
        DECB
        JSR     PRTXY         ; Middle left
        DECB
        JSR     PRTXY
.XPRNTB JSR     RSTR          ; Restore X/B/X
        RTS
;===============================================================================================
; CURXY: Move the cursor to co-ordinates (X,Y) on the screen (0,0) is top left
;
; A Accumulator contains the X coordinate
; B Accumulator contains the Y coordinate

; Returns in the X register the correct cursor offset

XCRD   .DA     $FF        ; Storage for X coordinate
YCRD   .DA     $FF        ; Storage for Y coordinate

; Logic:
; Multiply the Y co-ordinate by 32 (line length) - repeatedly INX 32 times per line
; Add the X co-ordinate to give offset
; Memory location to store character = CSRPTR (CURSOR POINTER)

CURXY   STAA    XCRD    ; Store AccA/AccB scratch locations
        DECB            ; BUT decrement Y co-ordinate to make it zero-based first
        STAB    YCRD
        JSR     HOME    ; Send CRSPTR to "Home" to register as (0,0)                        

; Start incrementing the X index register
        LDX     CSRPTR  ; Load current Cursor position (0,0) into X register

; Add 32 (1 line) to the X register
.NXTLN  CLRA
        LDAB    #32
         
.YAGAIN BEQ     .OUTY
        INX
        DECB
        BRA     .YAGAIN
.OUTY        

; Prepare for the next line by decrementing the Y coordinate until zero
        LDAA    YCRD
        DECA
        CMPA    #0
        BEQ     TOX
        STAA    YCRD
        BRA     .NXTLN

; Add the X coordinate by decrementing the supplied X coordinate until zero
TOX     LDAB    XCRD
.XAGAIN CMPB    #0
        BEQ     XCURXY
        INX
        DECB
        BRA     .XAGAIN
XCURXY  RTS


;===============================================================================================
; INSTR: Show line of instructions
;
; 

INSTR   JSR     STR
        JSR     HOME
        LDAA    SHOWHLP
        CMPA    #0
        BEQ     .NOHELP
        LDX     #.INSLN
        BRA     .SHOW
.NOHELP LDAA    #SPACE       ; Use a " " character
        LDAB    #31          ; Print it $31 times
        JSR     MLTCHR
        BRA     .XINSTR
.SHOW   JSR     PUTMSG
        JSR     RSTR
.XINSTR COM     SHOWHLP
        RTS

.INSLN   .AZ  /ARROWS-MOVE,ENT-PLACE,ESC-RESET/


;===============================================================================================
; CLS: Clear the screen (make sure cursor starts of top left first)
;
; 
CLS     JSR     HOME    ; Move cursor to top left
        JSR     CLEAR   ; Clear the screen
        RTS