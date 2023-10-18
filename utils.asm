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
; CVT: Convert (X,Y) coordinates into a position on the board
;

; CURSX,CURSY : Contains the current location of the cursor (X,Y)
; POSIT       : Will contain the position number on the board

CVT     JSR     STR
        LDAB	#1      ; Initialise AccB to store position
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
        JSR     RSTR
        RTS


;===============================================================================================
; CHKWD: Check if a win or a draw
;

; 
; PIECES       : Number of pieces on the board

CHKWD             
        ; If TURN = 1, then check O's else check X's
        ; Note that this is the reverse of what is usual, since the pieces
        ; are inverted to determine who's turn it is before this check is done.
        LDAA    TURN
        BEQ     .XS 
        LDAA    NOUGHT
        STAA    PCE 
        BRA     .CHK
.XS     LDAA    CROSS
        STAA    PCE

        ; Now the piece to check for is known - start the check of winning combinations
        ; Check top row
.CHK    LDX     #IBOARD
        LDAA    0,X
        CMPA    PCE
        BNE     .MIDDLE

        LDAA    1,X
        CMPA    PCE
        BNE     .MIDDLE
        
        LDAA    2,X
        CMPA    PCE
        BNE     .MIDDLE

        JMP     .WIN 
.MIDDLE
        LDAA    3,X
        CMPA    PCE
        BNE     .BOTTOM

        LDAA    4,X
        CMPA    PCE
        BNE     .BOTTOM
        
        LDAA    5,X
        CMPA    PCE
        BNE     .BOTTOM

        JMP     .WIN 

.BOTTOM 
        LDAA    6,X
        CMPA    PCE
        BNE     .LEFT

        LDAA    7,X
        CMPA    PCE
        BNE     .LEFT
        
        LDAA    8,X
        CMPA    PCE
        BNE     .LEFT

        JMP     .WIN 
.LEFT
        LDAA    0,X
        CMPA    PCE
        BNE     .MID

        LDAA    3,X
        CMPA    PCE
        BNE     .MID
        
        LDAA    6,X
        CMPA    PCE
        BNE     .MID

        JMP     .WIN 

.MID   
        LDAA    1,X
        CMPA    PCE
        BNE     .RIGHT

        LDAA    4,X
        CMPA    PCE
        BNE     .RIGHT
        
        LDAA    7,X
        CMPA    PCE
        BNE     .RIGHT

        JMP     .WIN 

.RIGHT
        LDAA    2,X
        CMPA    PCE
        BNE     .DIAG1

        LDAA    5,X
        CMPA    PCE
        BNE     .DIAG1
        
        LDAA    8,X
        CMPA    PCE
        BNE     .DIAG1

        JMP     .WIN 

.DIAG1
        LDAA    0,X
        CMPA    PCE
        BNE     .DIAG2

        LDAA    4,X
        CMPA    PCE
        BNE     .DIAG2
        
        LDAA    8,X
        CMPA    PCE
        BNE     .DIAG2

        JMP     .WIN  

.DIAG2
        LDAA    2,X
        CMPA    PCE
        BNE     .CHKDR

        LDAA    4,X
        CMPA    PCE
        BNE     .CHKDR
        
        LDAA    6,X
        CMPA    PCE
        BNE     .CHKDR

        JMP     .WIN        
; END OF CONSTRUCTION



; Check for a draw if a win hasnt been detected.
.CHKDR  CLR     WDSTAT
        LDAA    PIECES
        CMPA    #9
        BNE     .X
        COM     WDSTAT
        BRA     .X
.WIN
        CLR     WDSTAT    
        INC     WDSTAT    ; WDSTAT = 1 indicates a win 
        
.X        
        RTS
  
;===============================================================================================
; CHOCC: Check to see if square is occupied
; 
; POSIT  : Contains the square number
; IBOARD : Contains the pieces of the board
;
; SPCOCC : 0 if is free, 1 if it's occupied.

CHOCC   JSR     STR
        CLR     SPCOCC   ; Assume space is free
        CLRA
        CLRB
        LDX     #IBOARD

.CHLP   INCA
        CMPA    POSIT
        BEQ     .DONE
        INX        
        BRA     .CHLP
.DONE
        LDAA    0,X
        CMPA    DASH     ; If there's a dash then the place is free
        BEQ     .FREE
        COMB             ; Compliment A if the space is occupied
.FREE   STAB    SPCOCC
        JSR     RSTR
        RTS

;===============================================================================================
; INIT: Initialise a game
; 

INIT    
        LDAA    SPACE           ; Initial "CHARAT" value
        STAA    CHARAT

        LDAA    #1              ; Cross's turn first
        STAA    TURN            ; 

                                ; Show Game title (and how to get help)

        CLR     SHOWHLP         ; Reset "show help"
        CLR     PIECES          ; Reset number of pieces on the board
                                
        CLRA                    ; Reset IBOARD to all dashes
        LDAB    DASH
        LDX     #IBOARD
.RILP   STAB    0,X
        INCA
        INX
        CMPA     #9
        BNE     .RILP

        JSR     INSTR           ; Show Instructions if needed

        LDAA    CURSOR          ; Cursor character value
        STAA    XYCHA
        LDAA    ICURSX
        STAA    CURSX
        LDAB    ICURSY
        STAB    CURSY           ; Store initial cursor position
        JSR     PRTXY           ; Print the cursor there
        RTS
