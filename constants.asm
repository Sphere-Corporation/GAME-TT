
; Program Constants

; Symbols
CROSS   .AS     #88            ; Cross symbol
NOUGHT  .AS     #79            ; Nought symbol
CURSOR  .AS     #$FF           ; Cursor Symbol
SPACE   .AS     #32            ; Space Character
DASH    .AS     #$2D           ; Dash character

; Keycodes
ARROWD  .AS     #$13           ; Down cursor
ARROWL  .AS     #$14           ; Left cursor
ARROWR  .AS     #$12           ; Right cursor
ARROWU  .AS     #$11           ; Up cursor
ENTER   .AS     #$0D           ; ENTER Key
ESCCHR  .AS     #$1B           ; ESCape Key
HELPU   .AS     #$48           ; Upper case "H"
WASDA   .AS     #$41           ; A key (WASD) - Left
WASDD   .AS     #$44           ; D key (WASD) - Right 
WASDS   .AS     #$53           ; S key (WASD) - Down
WASDW   .AS     #$57           ; W key (WASD) - Up

; Board Initial Cursor Positions
ICURSX   .AS     #16           ; X-position
ICURSY   .AS     #9            ; Y-position

; Board Display Positions for large symbols
DISPLY   .AS     #13           ; Y-coordinate for O- and X-piece display
DISPLX   .AS     #29           ; X-coordinate for X-piece display
DISPLO   .AS     #3            ; X-coordinate for O-piece display

; Strings
DRWMSG  .AZ     /      DRAW GAME - PRESS A KEY        /  ; Game is a draw
INSLN   .AZ     /ARROWS-MOVE,ENT-PLACE,ESC-RESET  WASD/  ; Instructions line 

BLINEV  .AZ    /             !     !/                    ;
BLINEH  .AZ    /        -----+-----+-----/               ; Text to be used as part of the board 
HLPMSG  .AZ    /H-HELP       !     !/                    ;

SPLSH1  .AZ    /    == NOUGHTS & CROSSES ==/             ; 
SPLSH2  .AZ    /    (C) ANDREW SHAPTON 2023/             ; Text for the splash screen
MSGAGN  .AZ    /          PRESS A KEY/                   ;

WINLN   .AZ     /  WINS!-PRESS A KEY FOR NEW GAME      / ; Win line

        .IN build                                        ; Include dynamic Build information
        .IN firmware                                     ; Include firmware constants


