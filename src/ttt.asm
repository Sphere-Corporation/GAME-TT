
; Assembled with sbasm3 (https://www.sbprojects.net/sbasm/)
; All directives are specific to sbasm3, and may need to be changed for other assemblers

        .CR 6800               ; LOAD MC6800 CROSS OVERLAY
        .TF ttt.exe,BIN        ; OUTPUT FILE TO TARGET.BIN IN BINARY FORMAT
        .OR $0200              ; START OF ASSEMBLY ADDRESS
        .LI OFF                ; SWITCH OFF ASSEMBLY LISTING (EXCEPT ERRORS)
        .SF SYMBOLS.SYM        ; CREATE SYMBOL FILE

; START : Main entry point
;         Contains controller for the complete game; all other subroutines are called (in)directly from this.

START   LDS     #$1FF          ; Stack below program
                               ; MUST be first line of code

        JSR     SPLASH         ; Splash Screen
        CLR     TURN
                               ; AccA contains the key pressed
        CMPA    NOUGHT         ; What key did the user press ?
        BEQ     .NOUGHT
        INC     TURN           ; Cross's turn first
        
.NOUGHT JSR     BOARD          ; Display Board
        JSR     INIT           ; Initialise the game
        JSR     GLOOP          ; Main Loop
        BRA     START          ; Go again

; Main game loop
        .IN gameloop           ; Main Game Loop

; Subroutines
        .IN output             ; Include output-related Subroutines
        .IN utils              ; Include utilities
        .IN library            ; Include library routines
        
; Constants and Variables
        .IN constants          ; Include constants
        .IN variables          ; Include variables for the program
END

