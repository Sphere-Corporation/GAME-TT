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
; ADDTOX: Add a number to the X(Index) Register
;

; 
; X     : Current value of Index register
; AccA  : AccA number to add
;
; On exit, X= Initial X + AccA

ADDTOX  STAB    SCRTCHB
        CLRB            ; Set AccB to zero
.ROUND  CBA
        BEQ     .DONE
        INCB
        INX
        BRA     .ROUND
        LDAB    SCRTCHB
.DONE   RTS