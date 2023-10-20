; Assembled with sbasm3 (https://www.sbprojects.net/sbasm/)
; All directives are specific to sbasm3, and may need to be changed for other assemblers

        .CR 6800               ; LOAD MC6800 CROSS OVERLAY
        .TF ttt.exe,BIN        ; OUTPUT FILE TO TARGET.BIN IN BINARY FORMAT
        .OR $0200              ; START OF ASSEMBLY ADDRESS
        .LI OFF                ; SWITCH OFF ASSEMBLY LISTING (EXCEPT ERRORS)

; START: Main entry point

START   LDS     #$1FF          ; Stack below program
                               ; MUST be first line of code

        JSR     SPLASH         ; Splash Screen
        JSR     GETCHRB        ; Wait for a keypress
        JSR     BOARD          ; Display Board
        JSR     INIT           ; Initialise the game
        JSR     GLOOP          ; Main Loop
        BRA     START          ; Go again

; Subroutines
        .IN output             ; Include output-related Subroutines
        .IN utils              ; Include utilities
        .IN library            ; Include library routines
        
GLOOP                          ; Main Game Loop

ROUND   JSR     STR
        JSR     CHKWD          ; Check for win/draw
        LDAB    #$FF           ; Look at the status coming back - $FF is a draw
        CMPB    WDSTAT
        BEQ     .JDRAW   
        LDAB    #1             ; a 1 indicates a Win
        CMPB    WDSTAT
        BEQ     .JWIN
        JSR     RSTR
        BRA     .START
.JDRAW  JMP     DRAW
.JWIN   JMP     WIN
.START  JSR     GETCHRB        ; Key pressed is returned in AccA
        CMPA    ESCCHR         ; ESCape character
        BNE     .RNXT          ; Continue testing for keystrokes
        JMP     DONE           ; Exit back to the start screen
.RNXT   CMPA    HELPU          ; "H" for Help has been called
        BEQ     .INST
        CMPA    ENTER       
        BEQ     .ENT           ; ENTER Key
        CMPA    ARROWR
        BEQ     .ARRR          ; Arrow Right
        CMPA    WASDD
        BEQ     .ARRR          ; WASD-D Right
        CMPA    ARROWL
        BEQ     .ARRL          ; Arrow Left
        CMPA    WASDA
        BEQ     .ARRL          ; WASD-A Left
        CMPA    ARROWU
        BEQ     .ARRU          ; Arrow Up
        CMPA    WASDW
        BEQ     .ARRU          ; WASD-W Up
        CMPA    ARROWD
        BEQ     .ARRD          ; Arrow Down
        CMPA    WASDS
        BEQ     .ARRD          ; WASD-W Down
        BRA     ROUND
; End of main game loop - subroutines in game loop appear below.

.INST   JSR     INSTR
        BRA     .AROUND

.ENT    JSR     CVT            ; convert cursor position to the position on the board
                               ; Position is now in POSIT
        JSR     CHOCC          ; Check for occupation of the square
        LDAA    #$FF
        CMPA    SPCOCC         ; Check if space is occupied
        BEQ     .AGAIN         ; No piece is required.
        JSR     PUTPCE         ; Determine which piece to place in CURSX/CURSY
        BRA     .AROUND

.ARRD   LDAB    CURSY          ; Ensure that we don't go down below the board.
        CMPB    #15
        BEQ     .AGAIN
        JSR     RSTCHA
        
; Restore character in CHARAT in place before moving cursor onward
        ADDB    #6             ; Cursor position already in AccA/AccB, so move down
        STAB    CURSY
        BRA     .AROUND

.ARRU   LDAB    CURSY          ; Ensure that we don't go up above the board.
        CMPB    #3
        BEQ     .AGAIN
        JSR     RSTCHA
       
; Restore character in CHARAT in place before moving cursor onward
        SUBB    #6             ; Cursor position already in AccA/AccB, so move up
        STAB    CURSY
        BRA     .AROUND

.ARRR   LDAA    CURSX          ; Ensure that we don't go to the right of the board.
        CMPA    #22
        BEQ     .AGAIN
        JSR     RSTCHA
       
; Restore character in CHARAT in place before moving cursor onward
        LDAA    CURSX
        ADDA    #6             ; Cursor position already in AccA/AccB, so move right
        STAA    CURSX
        BRA     .AROUND       

.ARRL   LDAA    CURSX      
        CMPA    #10
        BEQ     .AGAIN
        JSR     RSTCHA
        
; Restore character in CHARAT in place before moving cursor onward
        LDAA    CURSX
        SUBA    #6             ; Cursor position already in AccA/AccB, so move left
        STAA    CURSX
        BRA     .AROUND   

.AROUND
        JSR     GTCHRAT        ; Store character under where cursor will be in CHARAT
        LDAA    CURSOR
        STAA    XYCHA
        LDAA    CURSX
        LDAB    CURSY     
        JSR     PRTXY          ; Cursor's moved to the correct location
        JSR     CVT            ; Get position on the board

.AGAIN  JMP     ROUND

DONE    RTS                    ; Exit Game Loop subroutine

; Constants and Variables
        .IN constants          ; Include constants
        .IN variables          ; Include variables for the program
END
