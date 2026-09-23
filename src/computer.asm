; Player vs Computer Game Loop

GLOOPC                         ; Main Game Loop for playing vs Computer
        
                               ; Start off with "if the computer goes first" assumption
                               ; Put a piece in the centre square

        
        JSR     STR            ; Store A/B/X

                               
        LDAA    PIECES         ; Check to see if this is the first move
        CMPA    #0
        BEQ     .FRSTMV     

        ;LDAA    COUNTER        ; Get random counter seed
        ;ANDA    #$0F           ; Get lowest 4 bits (number 0 - 8)
        ;INCA                   ; Add 1 to get the first random space.

.FRSTMV LDAA    COUNTER        ; Get random counter seed
        ANDA    #%00000011     ; Get lowest 2 bits (number 0 - 3)
        ; Minimise code 
        ;
        ;               1  |  2  |  3
        ;             -----+-----+-----
        ;               4  |  5  |  6
        ;             -----+-----+-----
        ;               7  |  8  |  9
        ; 
        ; AccA      Corner Mapped
        ;   0             9
        ;   1             1
        ;   2             7
        ;   3             3


        CMPA    #0             ; Is the value 0?
        BEQ     .CASE_0        ; Jump to CASE_0 if true
        CMPA    #1             ; Is the value 1?
        BEQ     .CASE_1        ; Jump to CASE_1 if true
        CMPA    #2             ; Is the value 2?
        BEQ     .CASE_2        ; Jump to CASE_2 if true

; -----------------------------------------------------------------
; If it wasn't 0, 1, or 2, it MUST be 3. The code naturally falls 
; through to CASE_3, saving you an extra comparison instruction.
; -----------------------------------------------------------------

.CASE_3 LDAA    #3
        BRA     .CONT
.CASE_0 LDAA    #9
        BRA     .CONT
.CASE_1 LDAA    #1
        BRA     .CONT
.CASE_2 LDAA    #7
                
                               ; Determine cursor position for piece
.CONT   STAA    POSIT          ; Store piece position                       
        CMPA    #1
        BEQ     .1
        CMPA    #2
        BEQ     .2
        CMPA    #3
        BEQ     .3
        CMPA    #4
        BEQ     .4
        CMPA    #5
        BEQ     .5
        CMPA    #6
        BEQ     .6
        CMPA    #7
        BEQ     .7
        CMPA    #8
        BEQ     .8
.9      LDAA    #22
        LDAB    #15
        JMP     .DOPCE
.8      LDAA    #16
        LDAB    #15
        JMP     .DOPCE    
.7      LDAA    #10
        LDAB    #15
        JMP     .DOPCE
.6      LDAA    #22
        LDAB    #9
        JMP     .DOPCE
.5      LDAA    #16
        LDAB    #9
        JMP     .DOPCE
.4      LDAA    #10
        LDAB    #9
        JMP     .DOPCE
.3      LDAA    #22
        LDAB    #3
        JMP     .DOPCE
.2      LDAA    #16
        LDAB    #22
        JMP     .DOPCE
.1      LDAA    #10
        LDAB    #3
        JMP     .DOPCE
;       CURSX,CURSY : Contains the current location of the cursor (X,Y)
;       TURN        : Contains the current turn : 0 for Noughts, 1 for Crosses
;       POSIT       : Contains the "square number" being targetted  
;       PIECES      : Contains the number of pieces currently on the board
;
.DOPCE  STAA    CURSX
        STAB    CURSY

        JSR     PUTPCE

        jsr     GETCHRB

        RTS
;===============================================================================================

