;===============================================================================================
; GETCHRB : Get a character from the keyboard without flashing the cursor
;     
; A Accumulator contains the typed character
;  
GETCHRB LDAA    #$40       ; Load a mask for CA2 flag.
        BITA    KBDPIA+1    ; See if a character has been typed in.
        BEQ     GETCHRB     ; Try again if a character hasn't been entered.
        LDAA    KBDPIA      ; Load AccA with the typed character
        RTS                 
