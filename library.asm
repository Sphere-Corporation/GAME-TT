;
;
; Library functions 
;
;

;===============================================================================================
; GTCHRAT: Get the character at the cursor position stored as below
; 
; AccA  contains the X coordinate
; AccB  contains the Y coordinate
;
; CHARAT Contains the character at the supplied coordinates (on exit)
;
; Dependencies:
;   CURXY
;   RSTR
;   STR

CHARAT  .DA     1,1            ; Storage for character at (X,Y)

GTCHRAT             
        JSR     STR
        LDAA    CURSX
        LDAB    CURSY
        JSR     CURXY          ; Ensure pointing at the current cursor position
        LDAA    0,X            ; Get character from screen
        STAA    CHARAT         ; Store character at cursor position
        JSR     RSTR
        RTS

;===============================================================================================
; GETCHRB : Get a character from the keyboard without flashing the cursor
;     
; AccA contains the typed character
;  
GETCHRB LDAA    #$40           ; Load a mask for CA2 flag.
        BITA    KBDPIA+1       ; See if a character has been typed in.
        BEQ     GETCHRB        ; Try again if a character hasn't been entered.
        LDAA    KBDPIA         ; Load AccA with the typed character
        RTS                 
