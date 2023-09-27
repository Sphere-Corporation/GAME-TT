;
; Small utilities used within larger programs
;


;===============================================================================================
; STR: Store A/B/X prior to a subroutine
;
STR     STAA    SCRTCHA
        STAB    SCRTCHB
        STX     SCRTCHX
        RTS

;===============================================================================================
; RSTR: Restore A/B/X prior to returning from a subroutine
;
RSTR    LDAA    SCRTCHA
        LDAB    SCRTCHB
        LDX     SCRTCHX
        RTS

;===============================================================================================
; GCAXY: Gets the current given character at co-ordinates (X,Y) on the screen (0,0) is top left
;
; A Accumulator contains the X coordinate
; B Accumulator contains the Y coordinate

; CHARAT contains the character on Return

CHARAT  .DA     1,1       ; Storage for character at (X,Y)
GCAXY   JSR     STR
        JSR     CURXY   ; Move the cursor to the correct location
        LDAA    0,X     ; Get character from screen
        STAA    CHARAT  ; Store character
        JSR     RSTR
        RTS


;===============================================================================================
; CVT: Convert (X,Y) coordinates into a position on the board
;

; CURSX,CURSY : Contains the current location of the cursor (X,Y)
; POSIT       : Will contain the position number on the board

CVT     LDAB	#1      ; Initialise AccB to store position
        LDAA    CURSX
        CMPA    #16
        BNE     .COL2
        LDAB    #2
.COL2   CMPA    #22
        BNE     .ROWS
        LDAB    #3
        
.ROWS   LDAA    CURSY
        CMPA    #9
        BNE     .ROW2
        ADDB    #3
.ROW2   CMPA    #15
        BNE     .DONE
        ADDB    #6

.DONE   STAB	POSIT   ; Store in pre-determined location
        RTS
