        .CR 6800                ; LOAD MC6800 CROSS OVERLAY
        .TF ttt.exe,BIN         ; OUTPUT FILE TO TARGET.BIN IN BINARY FORMAT
        .OR $0200               ; START OF ASSEMBLY ADDRESS
        .LI OFF                 ; SWITCH OFF ASSEMBLY LISTING (EXCEPT ERRORS)
        .SF symbols.sym

; Assembled with sbasm3 (https://www.sbprojects.net/sbasm/)
; All directives are specific to sbasm3, and may need to be changed for other assemblers

        BRA     START   ;       Go to the start of the program - skip the variables



; Program Variables
SCRTCHA  .DA     1,1            ; Space for AccA
SCRTCHB  .DA     1,1            ; Space for AccB
SCRTCHX  .DA     1,1            ; Space for X register
TURN     .DA     1              ; 0 for nought's turn, 1 for cross's turn
SHOWHLP  .DA     1              ; 0 for no help, 1 for help

; Board Cursor position (+co-ordinates)
CURSX   .DA     #16
CURSY   .DA     #9
INITCUR .DA     #5              ; Cursor space position

; Board Layout
IBOARD   .AZ    /---------/     ;$0236 ; Initial content for the board i.e. all spaces
PIECE    .AS     #5             ; Initial square number
POSIT    .AS     #0             ; Position of the current cursor on the board
;
;               1  |  2  |  3
;             -----+-----+-----
;               4  |  5  |  6
;             -----+-----+-----
;               7  |  8  |  9
;
;    Starting position is ALWAYS #5 (Centre)

PIECES  .DA     #0              ; Number of pieces placed on the board
WDSTAT  .DA     #0              ; Win/Draw status
SPCOCC  .DA     #0              ; Space Occupied ? 0 = No, 1 = Yes

; START: Main entry point
;
START   LDS     #$1FF           ; Stack below program
                                ; MUST be first line of code

        JSR     SPLASH          ; Splash Screen
        JSR     GETCHRB         ; Wait for a keypress
        JSR     BOARD           ; Display Board
        JSR     INIT            ; Initialise the game
        JSR     GLOOP           ; Main Loop
        BRA     START           ; Go again

; Subroutines
        .IN input               ; Include input-related Subroutines
        .IN output              ; Include output-related Subroutines
        .IN utils               ; Include utilities
        
INIT    
        LDAA    SPACE           ; Initial "CHARAT" value
        STAA    CHARAT

        LDAA    #1              ; Cross's turn first
        STAA    TURN            ; 

                                ; Show Game title (and how to get help)

        CLR     SHOWHLP         ; Reset "show help"
        CLR     PIECES          ; Reset number of pieces on the board

                                ; Reset IBOARD here from LBOARD
                
        CLRA                    ; CAN WE REUSE AN "ADD TO IDX REGISTER" FUNCTION?
        LDAB    DASH
        LDX     #IBOARD
.RILP   STAB    0,X
        INCA
        INX
        CMPA     #9
        BNE     .RILP

        JSR     INSTR

        LDAA    CURSOR      ; Cursor character value
        STAA    XYCHA
        LDAA    ICURSX
        STAA    CURSX
        LDAB    ICURSY
        STAB    CURSY       ; Store initial cursor position
        JSR     PRTXY       ; Print the cursor there
        RTS


GLOOP                        ; Main Game Loop

ROUND   JSR     STR
        JSR     CHKWD        ; Check for win/draw
        LDAB    #$FF         ; Look at the status coming back - $FF is a draw
        CMPB    WDSTAT
        BEQ     .JDRAW   
        JSR     RSTR
        BRA     .START
.JDRAW  JMP     DRAW
.START  JSR     GETCHRB      ; Key pressed is returned in AccA
        CMPA    ESCCHR       ; ESCape character
        BNE     .RNXT        ; Continue testing for keystrokes
        JMP     DONE         ; Exit back to the start screen
.RNXT   CMPA    HELPU        ; "H" for Help has been called
        BEQ     .INST
        CMPA    ENTER       
        BEQ     .ENT         ; ENTER Key
        CMPA    ARROWR
        BEQ     .ARRR        ; Arrow Right
        CMPA    WASDD
        BEQ     .ARRR        ; WASD-D Right
        CMPA    ARROWL
        BEQ     .ARRL        ; Arrow Left
        CMPA    WASDA
        BEQ     .ARRL        ; WASD-A Left
        CMPA    ARROWU
        BEQ     .ARRU        ; Arrow Up
        CMPA    WASDW
        BEQ     .ARRU        ; WASD-W Up
        CMPA    ARROWD
        BEQ     .ARRD        ; Arrow Down
        CMPA    WASDS
        BEQ     .ARRD        ; WASD-W Down
        BRA     ROUND
; End of main game loop - subroutines in game loop appear below.

.INST   JSR     INSTR
        BRA     .AROUND

.ENT    JSR     CVT      ; convert cursor position to the position on the board
                         ; Position is now in POSIT
        
        JSR     CHOCC    ; Check for occupation of the square
        LDAA    #$FF
        CMPA    SPCOCC          ; Check if space is occupied
        BEQ     .AGAIN          ; No piece is required.


        JSR     PUTPCE   ; Determine which piece to place in CURSX/CURSY
        BRA     .AROUND

.ARRD   LDAB    CURSY       ; Ensure that we don't go down below the board.
        CMPB    #15
        BEQ     .AGAIN
        JSR     RSTCHA
        
        ; Restore character in CHARAT in place before moving cursor onward
        ADDB    #6          ; Cursor position already in AccA/AccB, so move down
        STAB    CURSY
        BRA     .AROUND

.ARRU   LDAB    CURSY       ; Ensure that we don't go up above the board.
        CMPB    #3
        BEQ     .AGAIN
        JSR     RSTCHA
       
        ; Restore character in CHARAT in place before moving cursor onward
        SUBB    #6          ; Cursor position already in AccA/AccB, so move up
        STAB    CURSY
        BRA     .AROUND

.ARRR   LDAA    CURSX      ; Ensure that we don't go to the right of the board.
        CMPA    #22
        BEQ     .AGAIN
        JSR     RSTCHA
       
        ; Restore character in CHARAT in place before moving cursor onward
        LDAA    CURSX
        ADDA    #6           ; Cursor position already in AccA/AccB, so move right
        STAA    CURSX
        BRA     .AROUND       

.ARRL   LDAA    CURSX      
        CMPA    #10
        BEQ     .AGAIN
        JSR     RSTCHA
        
        ; Restore character in CHARAT in place before moving cursor onward
        LDAA    CURSX
        SUBA    #6          ; Cursor position already in AccA/AccB, so move left
        STAA    CURSX
        BRA     .AROUND   

.AROUND
        JSR     GTCHRAT         ; Store character under where cursor will be in CHARAT
        LDAA    CURSOR
        STAA    XYCHA
        LDAA    CURSX
        LDAB    CURSY     
        JSR     PRTXY           ; Cursor's moved to the correct location
        JSR     CVT          ; Get position on the board

.AGAIN  JMP     ROUND

DONE    RTS                 ; Exit Game Loop subroutine

; Constants and Variables
        .IN constants       ; Include constants

END

