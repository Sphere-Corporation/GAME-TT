        .CR 6800                ; LOAD MC6800 CROSS OVERLAY
        .TF ttt.exe,BIN         ; OUTPUT FILE TO TARGET.BIN IN BINARY FORMAT
        .OR $0200               ; START OF ASSEMBLY ADDRESS
        .LI OFF                 ; SWITCH OFF ASSEMBLY LISTING (EXCEPT ERRORS)

; Assembled with sbasm3 (www.sbprojects.net)
; All directives are specific to sbasm3, and may need to be changed for other assemblers

        BRA     START   ;       Go to the start of the program - skip the variables

; PDS Workspace

CSRPTR  .EQU     $1C            ; Current cursor location

; Program Constants

; Symbols
CROSS   .AS    #88      ; Cross symbol
NOUGHT  .AS    #79      ; Nought symbol
CURSOR  .AS    #$40     ; Cursor Symbol
SPACE   .AS    #32      ; Space Character
DASH    .AS    #$2D     ; Dash character
HELPU   .AS    #$48     ; Upper case "H"


; Keycodes
ARROWL  .AS    #$14     ; Left cursor
ARROWU  .AS    #$11     ; Up cursor
ARROWR  .AS    #$12     ; Right cursor
ARROWD  .AS    #$13     ; Down cursor
ENTER   .AS    #$0D     ; ENTER Key
ESCCHR  .AS    #$1B     ; ESCape Key

; Board Initial Cursor Positions
ICURSX   .DA     #16
ICURSY   .DA     #9
CURCHR   .DA     #SPACE
IPIECE   .DA     #5
LBOARD   .AZ    /---------/

DISPLY   .DA     #13    ; Y-coordinate for O- and X-piece display
DISPLX   .DA     #29    ; X-coordinate for X-piece display
DISPLO   .DA     #3     ; X-coordinate for O-piece display


; Program Variables
SCRTCHA  .DA     1,1           ; Space for AccA
SCRTCHB  .DA     1,1           ; Space for AccB
SCRTCHX  .DA     1,1           ; Space for X register
TURN     .DA     1             ; 0 for nought's turn, 1 for cross's turn
SHOWHLP  .DA     1             ; 0 for no help, 1 for help

; Board Cursor position (+co-ordinates)
CURSX   .DA     #16
CURSY   .DA     #9
INITCUR .DA     #5      ; Cursor space position

; Board Layout
IBOARD   .AZ    /---------/      ; Initial content for the board i.e. all spaces
PIECE    .AS     #5              ; Initial square number
POSIT    .AS     #0              ; Position of the current cursor on the board
;
;               1  |  2  |  3
;             -----+-----+-----
;               4  |  5  |  6
;             -----+-----+-----
;               7  |  8  |  9
;
;    Starting position is ALWAYS #5 (Centre)

; Constants
ZERO    .AS     #0              ; Constant for zero

; Firmware entry points (PDS-V3N)

HOME    .EQU     $FC37       ; Cursor to top left
CLEAR   .EQU     $FC3D       ; Clear screen contents
GETCHR  .EQU     $FC4A       ; Input character (no echo)
PUTCHR  .EQU     $FCBC       ; Print character at cursor
KBDPIA  .EQU     $F040       ; Address if PIA for KBD/2
;KEYBOARD PIA ADDRESS FOR OLD KEYBOARD (KBD/1A) IS F000.

; Not used as yet.....
INPCHR  .EQU     $FE71       ; Input character (with echo)
PNTBYT  .EQU     $FF02       ; Print a byte as two hex digits
ASCBIN  .EQU     $FF22       ; Convert text string to number

; START: Main entry point
;
START   LDS     #$1FF       ; Stack below program
                            ; MUST be first line of code

        JSR     SPLASH      ; Splash Screen
        JSR     GETCHRB
        JSR     BOARD       ; Display Board
        JSR     INIT        ; Initialise the game
        JSR     GLOOP       ; Main Loop
        BRA     START


; Subroutines
        .IN input            ; Include input-related Subroutines
        .IN output           ; Include output-related Subroutines
        .IN utils            ; Include utilities
        
INIT    
        LDAA    SPACE       ; Initial "CHARAT" value
        STAA    CHARAT

        LDAA    #1          ; Cross's turn first
        STAA    TURN        ; Initialise.....
        
        COMA                ; Show Game title (and how to get help)
        STAA    SHOWHLP

        ;replaced by COMA and STAA above
        ;LDAA    #0          ; Show Game title (and how to get help)
        ;STAA    SHOWHLP



        ; Reset IBOARD here from LBOARD
                            ; AccA STILL haz a zero in it
        ;LDAA    #0
        LDAB    DASH
        LDX     #IBOARD
.RILP   STAB    0,X
        INCA
        INX
        CMPA     #9
        BNE     .RILP


        JSR     INSTR


        LDAA    CURSOR      ; Cursor character value
        STAA    XYCHA
        LDAA    ICURSX
        STAA    CURSX
        LDAB    ICURSY
        STAB    CURSY       ; Store initial cursor position
        JSR     PRTXY       ; Print the cursor there
        RTS


GLOOP                        ; Main Game Loop

ROUND   
        ; section for debug only
        ;JSR     HOME
        ;LDAA    SPACE   
        ;LDAB    #9
        ;JSR     MLTCHR
       ; 
       ; JSR     HOME
       ; LDX     #IBOARD 
       ; JSR     PUTMSG
        ; end of debug section


        JSR     GETCHRB      ; Key pressed is returned in AccA
        CMPA    ESCCHR       ; ESCape character
        BNE     .RNXT        ; Continue testing for keystrokes
        JMP     DONE         ; Exit back to the start screen
.RNXT   CMPA    HELPU        ; "H" for Help has been called
        BEQ     .INST
        CMPA    ENTER       
        BEQ     .ENT         ; ENTER Key
        CMPA    ARROWR
        BEQ     .ARRR        ; Arrow Right
        CMPA    ARROWL
        BEQ     .ARRL        ; Arrow Left
        CMPA    ARROWU
        BEQ     .ARRU        ; Arrow Up
        CMPA    ARROWD
        BEQ     .ARRD        ; Arrow Down
        BRA     ROUND
; End of main game loop - subroutines in game loop appear below.

.INST   JSR     INSTR
        BRA     .AROUND

.ENT    JSR     CVT      ; convert cursor position to the position on the board
                         ; Position is now in POSIT
        JSR     PUTPCE   ; Determine which piece to place in CURSX/CURSY
        BRA     .AROUND

.ARRD   LDAB    CURSY       ; Ensure that we don't go down below the board.
        CMPB    #15
        BEQ     .AGAIN
        ADDB    #6          ; Cursor position already in AccA/AccB, so move down
        STAB    CURSY
        BRA     .AROUND

.ARRU   LDAB    CURSY       ; Ensure that we don't go up above the board.
        CMPB    #3
        BEQ     .AGAIN
        SUBB    #6          ; Cursor position already in AccA/AccB, so move up
        STAB    CURSY
        BRA     .AROUND

.ARRR   LDAA    CURSX      
        CMPA    #22
        BEQ     .AGAIN
        LDAA    CURSX
        ADDA    #6           ; Cursor position already in AccA/AccB, so move right
        STAA    CURSX
        BRA     .AROUND       

.ARRL   LDAA    CURSX      
        CMPA    #10
        BEQ     .AGAIN
        LDAA    CURSX
        SUBA    #6          ; Cursor position already in AccA/AccB, so move left
        STAA    CURSX
        BRA     .AROUND   

.GC     LDAA    CURSX   ; RESTORE THE CHARACTER PRIOR TO THE CURSOR MOVE
        LDAB    CURSY 
        LDX     CHARAT         
        JSR     PRTXY           
        RTS

.AROUND LDAA    CURSOR
        STAA    XYCHA
        LDAA    CURSX
        LDAB    CURSY     
        JSR     PRTXY           ; Cursor's moved to the correct location

.AGAIN  JMP     ROUND

DONE    RTS                 ; Exit Game Loop subroutine

END

