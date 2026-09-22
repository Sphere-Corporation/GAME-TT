
; Assembled with sbasm3 (https://www.sbprojects.net/sbasm/)
; All directives are specific to sbasm3, and may need to be changed for other assemblers

        .CR 6800               ; LOAD MC6800 CROSS OVERLAY
        .TF ttt.exe,BIN        ; OUTPUT FILE IN BINARY FORMAT
        .OR $0200              ; START OF ASSEMBLY ADDRESS
        .LI OFF                ; SWITCH OFF ASSEMBLY LISTING (EXCEPT ERRORS)
        .SF SYMBOLS.SYM        ; CREATE SYMBOL FILE

; Main entry point
;         Contains controller for the complete game; all other subroutines are called (in)directly from this.

        LDS     #$1FF          ; Stack below program
                               ; MUST be first line of code

        LDAA    #2             ; Initial (not to be reset) default is player 1
        STAA    PLAYER         ; (NEEDS TO BE SET TO 2 since there is a SWPPLR call prior to display)

START   JSR     MSPLSH         ; Display main splash screen
        JSR     BOARD          ; Display Board
        JSR     INIT           ; Initialise the game
        LDAA    MODE           ; Find out what game mode we are playing
        CMPA    #$46           ; If we are playing 2-players i.e. MODE='F'
        BEQ     .PL2           ; 
        JSR     GLOOPC         ; Play against the Computer
        BRA     START     
.PL2    JSR     GLOOP          ; Main Loop for 2 players
        BRA     START          ; Go again

; Main game loop
        .IN gameloop           ; Main Game Loop for 2 Player game
        .IN computer           ; Main Game Loop for Player vs Computer
; Subroutines
        .IN splash             ; Include main splash screens
        .IN output             ; Include output-related Subroutines
        .IN utils              ; Include utilities
        .IN library            ; Include library routines
        
; Constants and Variables
        .IN constants          ; Include constants
        .IN variables          ; Include variables for the program
.EN

