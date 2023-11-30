;
;
; Library functions 
;
;

; List of functions to include in final assembly file. 
; Define function name preceded by an underscore, with:
;                                                .EQ 1 to include
;                                                .EQ 0 to exclude
_GTCHRAT        .EQ     1
_MLTCHR         .EQ     1
_GETCHRB        .EQ     1
_PUTMSG         .EQ     1
_CRLF           .EQ     1
_MULTCR         .EQ     0
_PRTXY          .EQ     1
_CURXY          .EQ     1
_CLS            .EQ     1

;
; Excluding functions not used can significantly reduce the executable size.
;
        .DO     _GTCHRAT=1
;===============================================================================================
; GTCHRAT: Get the character at the cursor position stored as below
; 
; Entry:
;       CURSX       Contains the X coordinate
;       CURSY       Contains the Y coordinate
; 
; Exit:
;       CHARAT      Contains the character at the supplied coordinates (on exit)
;
; External definitions:
;
;       CURSX:      1 byte
;       CURSY:      1 byte
;
; Dependencies:
;
;       CURXY   
;       RSTR
;       STR
;
; Notes:
;
;       N/A 

CHARAT  .DA     1              ; Storage for character at (X,Y)

GTCHRAT             
        JSR     STR            ; Store A/B/X
        LDAA    CURSX          ; Get the X co-ordinate of the cursor position
        LDAB    CURSY          ; Get the Y co-ordinate of the cursor position
        JSR     CURXY          ; Ensure pointing at the current cursor position
        LDAA    0,X            ; Get character from screen
        STAA    CHARAT         ; Store character at cursor position
        JSR     RSTR           ; Restore A/B/X
        RTS
;===============================================================================================
        .FI

        .DO     _MLTCHR=1
;===============================================================================================
; MLTCHR: Prints a given char (n) times
;
; A Accumulator contains the character for multiple printings goes here.
; B Accumulator contains the multiple (n)
; Entry:
;   
;       AccA            Contains the character for multiple printing
;       AccB            Contains the multiple (n)
;
; Exit:
;       N/A
;  
; External definitions:
;      
;       N/A
;
; Dependencies:
;
;       PUTCHR  (System)
;
; Notes:
;
;       AccB will lose its value

MLTCHR
.MLOOP  BEQ      .FINAL
        JSR      PUTCHR
        DECB
        BRA      .MLOOP
.FINAL  RTS
;===============================================================================================
        .FI

        .DO     _GETCHRB=1
;===============================================================================================
; GETCHRB : Get a character from the keyboard without flashing the cursor
;     
; Entry:
;   
;       N/A
;
; Exit:
;       AccA        Contains the typed character
;  
; External definitions:
;      
;       KBDPIA: Address of PIA for KBD/2 (Only supports KBD/2)
;
; Dependencies:
;
;       N/A
;
; Notes:
;
;       N/A 

GETCHRB LDAA    #$40           ; Load a mask for CA2 flag.
        BITA    KBDPIA+1       ; See if a character has been typed in.
        BEQ     GETCHRB        ; Try again if a character hasn't been entered.
        LDAA    KBDPIA         ; Load AccA with the typed character
        RTS              
;===============================================================================================
        .FI

        .DO     _PUTMSG=1        
;===============================================================================================
; PUTMSG: Prints a zero-terminated message  
;
; Entry:
;   
;       X           Contains the start address of the message
;
; Exit:
;       N/A
;  
; External definitions:
;      
;       N/A
;
; Dependencies:
;
;       PUTCHR  (System)
;       RSTR
;       STR
;
; Notes:
;
;       N/A

PUTMSG  JSR     STR            ; Store A/B/X
        LDAA    0,X            ; Start at the beginning of the message
        BEQ     .PMEXT         ; Quit if the message is complete
        STX     .MSGIDX        ; Store the current position in the message
        JSR     PUTCHR         ; Print the current character (Uses X)
        LDX     .MSGIDX        ; Restore the current position in the message
        INX                    ; Increment the message position
        BRA     PUTMSG         ; Go to the next character
.PMEXT  JSR     RSTR           ; Restore A/B/X
        RTS

; Space to store the index register
.MSGIDX  .DA     1             ; Reserved space for local variable
;===============================================================================================
        .FI

        .DO     _CRLF=1
;===============================================================================================
; CRLF: Emits a carriage return
;
; Entry:
;   
;       N/A
;
; Exit:
;       N/A
;  
; External definitions:
;      
;       N/A
;
; Dependencies:
;
;       PUTCHR  (System)
;       RSTR
;       STR
;
; Notes:
;
;       N/A

CRLF    JSR     STR            ; Store A/B/X    
        LDAA    #$0D
        JSR     PUTCHR         ; Output a CR at the current cursor position
        JSR     RSTR           ; Restore X/B/X
        RTS
;===============================================================================================
        .FI

        .DO     _MULTCR=1
;===============================================================================================
; MULTCR: Emits multiple blank lines
;
; Entry:
;   
;       AccB            Contains the number of blank lines to print
;
; Exit:
;       N/A
;  
; External definitions:
;      
;       N/A
;
; Dependencies:
;
;       CRLF  
;       RSTR
;       STR
;
; Notes:
;
;       N/A     

MULTCR  JSR     STR            ; Store A/B/X
.AGAIN  DECB
        BEQ     .OUT
        STAB    .MCRB
        JSR     CRLF           ; Output a CR at the current cursor position
        LDAB    .MCRB
        BRA     .AGAIN
.OUT    JSR     RSTR           ; Restore X/B/X
        RTS

.MCRB  .DA     1               ; Scratch store for AccB

;===============================================================================================
        .FI

        .DO     _PRTXY=1
;===============================================================================================
; PRTXY: Prints a given char at co-ordinates (X,Y) on the screen (0,0) is top left
; 
; Entry:
;       AccA            Contains the X coordinate
;       AccB            Contains the Y coordinate
;       XYCHA           Contains the character to print
;
; Exit:
;       N/A
;  
; External definitions:
;      
;       XYCHA           1 byte
;
; Dependencies:
;
;       CURXY  
;       RSTR
;       STR
;
; Notes:
;
;       N/A     

PRTXY   JSR     STR
        JSR     CURXY          ; Move the cursor to the correct loctation
        LDAA    XYCHA          ; Load character into AccA
        STAA    0,X            ; Send to screen
        JSR     RSTR
        RTS

XYCHA   .DA     #0             ; Storage for character to print
;===============================================================================================
        .FI

        .DO     _CURXY=1
;===============================================================================================
; CURXY: Move the cursor to co-ordinates (X,Y) on the screen (0,0) is top left
;
; Entry:
;       AccA            Contains the X coordinate
;       AccB            Contains the Y coordinate
;
; Exit:
;       X               Correct cursor position offset
;  
; External definitions:
;       CSRPTR          (System - Cursor Pointer)
;       XCRD, YCRD      1 byte each
; Dependencies:
;
;       HOME    (System)  
;
; Notes:
;
;       Logic:
;       Multiply the Y co-ordinate by 32 (line length) - repeatedly INX 32 times per line
;       Add the X co-ordinate to give offset
;       Memory location to store character = CSRPTR (CURSOR POINTER)
    
XCRD   .DA     $FF             ; Storage for X coordinate
YCRD   .DA     $FF             ; Storage for Y coordinate

CURXY   STAA    XCRD           ; Store AccA/AccB scratch locations
        DECB                   ; BUT decrement Y co-ordinate to make it zero-based first
        STAB    YCRD
        JSR     HOME           ; Send CRSPTR to "Home" to register as (0,0)                        

; Start incrementing the X index register
        LDX     CSRPTR         ; Load current Cursor position (0,0) into X register

.NXTLN  CLRA
        LDAB    #32            ; Add 32 (1 line) to the X register
         
.YAGAIN BEQ     .OUTY
        INX
        DECB
        BRA     .YAGAIN
.OUTY        

; Prepare for the next line by decrementing the Y coordinate until zero
        LDAA    YCRD
        DECA
        BEQ     TOX
        STAA    YCRD
        BRA     .NXTLN

; Add the X coordinate by decrementing the supplied X coordinate until zero
TOX     LDAB    XCRD
.XAGAIN BEQ     XCURXY
        INX
        DECB
        BRA     .XAGAIN
XCURXY  RTS
;===============================================================================================
        .FI

        .DO     _CLS=1
;===============================================================================================
; CLS: Clear the screen (make sure cursor starts of top left first)
;
; Entry:
;       N/A
;
; Exit:
;       N/A
;  
; External definitions:
;       N/A
;
; Dependencies:
;
;       HOME    (System)
;       CLEAR   (System)
;
; Notes:
;       N/A
; 
CLS     JSR     HOME           ; Move cursor to top left
        JSR     CLEAR          ; Clear the screen
        RTS
;===============================================================================================
        .FI