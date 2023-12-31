
; Program Constants

; Symbols
CROSS   .AS     #88            ; Cross symbol
NOUGHT  .AS     #79            ; Nought symbol
CURSOR  .AS     #$FF           ; Cursor Symbol
SPACE   .AS     #32            ; Space Character
DASH    .AS     #$2D           ; Dash character
EQUALS  .AS     #$3D           ; = character

; Keycodes

ENTER   .AS     #$0D           ; ENTER Key
ESCCHR  .AS     #$1B           ; ESCape Key
HELPU   .AS     #$48           ; Upper case "H"
RESET   .AS     #$53           ; "S" Character

; Board Initial Cursor Positions
ICURSX   .AS     #16           ; X-position
ICURSY   .AS     #9            ; Y-position

; Board Display Positions for large symbols
DISPLY   .AS     #15           ; Y-coordinate for O- and X-piece display
DISPLX   .AS     #29           ; X-coordinate for X-piece display
DISPLO   .AS     #3            ; X-coordinate for O-piece display

; Board Positions
PIECE    .AS     #5            ; Initial square number
;
;               1  |  2  |  3
;             -----+-----+-----
;               4  |  5  |  6
;             -----+-----+-----
;               7  |  8  |  9
;
;    Starting position is ALWAYS #5 (Centre)

; Strings
DRWMSG  .AZ     /      DRAW GAME - PRESS A KEY        /  ; Game is a draw
INSLN   .AZ     /ARROWS-MOVE,ENT-PLACE,ESC-RESET  WASD/  ; Instructions line 

BLINEV  .AZ    /             !     !/                    ;
BLINEH  .AZ    /        -----+-----+-----/               ; Text to be used as part of the board 
HLPMSG  .AZ    /H-HELP ON/,#$2F,/OFF/                    ;

SPLSH1  .AZ    #$0D,/    == NOUGHTS & CROSSES  ==/,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D,/    (C) ANDREW SHAPTON  2023/,#$0D                         ; Text for the splash screen
MSGAGN  .AZ    #$0D,/HTTP:/,#$2F,#$2F,/TINYURL.COM/,#$2F,/SPHERE-GAMETT/,#$0D,/ TO START A GAME USE "O" OR "X" "S" RESET SCORES,"=" SWAP FIRST/   ; Rest of the text for the splash screen

WINLN   .AZ     /  WINS!-PRESS A KEY FOR NEW GAME      / ; Win line

        .IN firmware                                     ; Include firmware constants
        .IN build                                        ; Include dynamic Build information
