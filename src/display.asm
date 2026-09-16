;
; Main display subroutines used within ttt.asm
;


;===============================================================================================
; MSPLSH: Print Main Splash screen
;
; Entry:
;       N/A
;
; Exit:
;       XYCHA           Character to store the first character to go to the last character
;  
; External definitions:
;
;       BUILD           Label for the build information
;       MSGAG1          Label for the "Press a key" lines
;       SPLSH1          Label for the title of the program
;       PLAY1N          Player 1 name
;       PLAY1S          Player 1 score
;       PLAY2N          Player 2 name
;       PLAY2S          Player 2 score
;       PLAYER          Current player
;       XYCHA           Character to store the first character to go to the last character
;       KBDPIA          Address of PIA for KBD/2 (Only supports KBD/2)
;
; Dependencies:
;
;       CLS
;       CRLF
;       HOME    (System)
;       MLTCHR
;       PPLYN
;       PUTMSG
;       RSTR
;       STR
;
; Notes:
;
;       The "BUILD" label is inserted by an external command prior to assembling the code.
;       It must contain a centered "VERSION: " literal, followed by the build or version number.

MSPLSH  JSR     STR            ; Store A/B/X
        JSR     CLS            
        LDX     #SPLSH1        ; Output the Title of the program
        JSR     PUTMSG
        LDX     #BUILD         ; Show the build/version number
        JSR     PUTMSG
        LDX     #MSGAG1        
        JSR     PUTMSG          
        LDX     #MSGAG3        
        JSR     PUTMSG         ; ... and and show a message about player selection

.LOOP   JSR     HOME           ; Place the cursor top left (and the corresponding CSRPTR value in X)
        LDAA    39,X           ; Get the first character and stash it
        STAA    XYCHA

        LDAB    #17            ; There are 17 characters in the whole message
.AGAIN  LDAA    40,X           ; Get the "second" character
        STAA    39,X           ; Store in the "first" character
        INX                    ; Increment the X register
        DECB                   ; Decrement the AccB
        CMPB    #0             ; Has AccB reached 0 ?
        BNE     .AGAIN         ; If not, loop again

        LDAA    XYCHA          ; Get first character
        JSR     HOME           ; and make it the last character
        STAA    56,X           ; by sending directly to the screen
        
        LDX     #10000         ; Delay by 10000 microseconds
.DLY    DEX                    ;        (1/100th second)
        BNE     .DLY
                               ; Get keypresss.....        
        LDAA    #$40           ; Load a mask for CA2 flag.
        BITA    KBDPIA+1       ; See if a character has been typed in.
        BNE     .OUT
        BRA     .LOOP          ; Loop around.......

.OUT    LDAA    KBDPIA         ; Load that character into AccA
        CMPA    #$46           ; Should we play a friend ? i.e. has the user pressed a "F"?
        BEQ     SPLASH
        CMPA    #$43           ; Should we play the computer ? i.e. has the user pressed a "C"?
        BEQ     .DONE
        JMP     .AGAIN         ; If keypress <> "C" or "F" loop again

.DONE
        RTS

        
;===============================================================================================
