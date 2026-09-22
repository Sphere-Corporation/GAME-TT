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
        
        INC     COUNTER        ; Increment Computer Player counter.....

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
        BEQ     SPLASH2
        CMPA    #$43           ; Should we play the computer ? i.e. has the user pressed a "C"?
        BEQ     .PLCMP
        JMP     .AGAIN         ; If keypress <> "C" or "F" loop again
.PLCMP  JMP     SPLASHC


        
;===============================================================================================

;===============================================================================================
; SPLASH2: Print Splash screen for 2 players
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

SPLASH2 STAA    MODE           ; Store the game mode (at this stage it will be #$46 - "F")
        JSR     STR            ; Store A/B/X
        JSR     CLS            
        LDX     #SPLSH1        ; Output the Title of the program
        JSR     PUTMSG
        LDX     #BUILD         ; Show the build/version number
        JSR     PUTMSG
        LDX     #MSGAG1        
        JSR     PUTMSG         
        LDX     #MSGAG2        
        JSR     PUTMSG         ; ... and wait for a keypress

        JSR     STR
        LDX     #PLAY1N        ; Load X with the start of Player name 1
        LDAA    #1             ; Set the X co-ordinate to be 1
        STAA    CURSX          ; Store it in CURSX
        LDAB    #16            ; Set the Y co-ordinate to be 16,
        STAB    CURSY          ; Store it in CURSY
        JSR     PPLYN          ; Display the player 1 name

        LDX     #PLAY2N        ; Load X with the start of Player name 2
        LDAA    #24
        STAA    CURSX          ; Set the X co-ordinate to be 25
        LDAB    #16            ; Set the Y co-ordinate to be 6,
        STAB    CURSY          ; Store it in CURSY
        JSR     PPLYN          ; Display the player 1 name

        JSR     .DOSCORE       ; Display players scores on the splash screen
        
        LDAA    PLAYER         ; Determine which is the player to select on first entry to the splash screen
        CMPA    #2
        BEQ     .S2 
        JMP     .S1 
.S2     JSR     .SEL1
        BRA     .LOOP
.S1     JSR     .SEL2          


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
        
        INC     COUNTER        ; Increment Computer Player counter.....

        LDX     #10000         ; Delay by 10000 microseconds
.DLY    DEX                    ;        (1/100th second)
        BNE     .DLY
                               ; Get keypresss.....        
        LDAA    #$40           ; Load a mask for CA2 flag.
        BITA    KBDPIA+1       ; See if a character has been typed in.
        BNE     .OUT
        BRA     .LOOP          ; Loop around.......

.OUT    JSR     HOME
        LDAA    #65
        STAA    XYCHA
        CLRA
        CLRB
        JSR     PRTXY


        JSR     RSTR           ; Restore the A/B/X values
        LDAA    KBDPIA         ; Load the keypress value
        CMPA    RESET          ; Did they press "R" ?
        BEQ     .RESET         ; If so, reset the names and scores
        CMPA    EQUALS         ; Did they press "="
        BEQ     .SELPLY        ; If so, toggle the "Player" indicator.
        CMPA    NOUGHT         ; Did they press "O" ?
        BEQ     .NOUGHT
        CMPA    CROSS          ; Did they press "X" ?
        BEQ     .CROSS
        BRA     .LOOP
.CROSS  LDAA    #1             ; Cross's turn first
        STAA    TURN           ; Store that cross is going first
        RTS
.NOUGHT
        CLR     TURN
        RTS

.RESET  CLR     PLAY1S         ; Clear player 1 score
        CLR     PLAY2S         ; Clear player 2 score 
        JSR     .DOSCORE       ; Display the scores again
        BRA     .LOOP          ; When done, go back to the main loop

.DISPQ  JSR     PRTXY          ; Display a "Selected" indicator around a specific player
        ADDA    #8             ; After outputting the first symbol, add 8 to the X co-ordinate 
        JSR     PRTXY          ; Output the second "Selected" symbol 
        RTS

.SELPLY LDAB    #16            ; Load AccB with the row number of the Player 1 name
        LDAA    PLAYER         ; Switch selection between players
        CMPA    #1
        BEQ     .SEL2          ; If Player 1 is current, then switch to Player 2
                        
.SEL1   LDAA    SPACE          ; Switch to Player 1 
        JSR     .P2
        LDAA    EQUALS
        JSR     .P1
        LDAA    #1
        STAA    PLAYER
        JMP     .LOOP
        
.SEL2   LDAA    SPACE          ; Switch to Player 2
        JSR     .P1
        LDAA    EQUALS
        JSR     .P2
        LDAA    #2
        STAA    PLAYER
        JMP     .LOOP

.P1     STAA    XYCHA          ; Store the equals character in XYCHA
        CLRA                   ; For Player 1, set the X co-ordinate
        JSR     .DISPQ         ; Display the player selection
        RTS

.P2     STAA    XYCHA          ; Store the equals character in XYCHA
        LDAA    #23            ; For Player 2, set the X co-ordinate
        JSR     .DISPQ         ; Display the player selection
        RTS
.DOSCORE        
        LDAB    #16            ; Set Y co-ordinate of Player 1 score
        LDAA    PLAY1S         ; Get Player 1 score
        ADDA    #48            ; Add 48 to the score to give an ASCII value
        STAA    XYCHA          ; Store the ASCII score character in XYCHA
        LDAA    #13            ; Set the X co-ordinate of the Player 1 score
        JSR     PRTXY          ; Output XYCHA at (13,16)

        LDAA    PLAY2S         ; Get Player 2 score
        ADDA    #48            ; Add 48 to the score to give an ASCII value
        STAA    XYCHA          ; Store the ASCII score character in XYCHA
        LDAA    #18            ; Set the X co-ordinate of the Player 2 score
        LDAB    #16            ; Set Y co-ordinate of Player 2 score
        JSR     PRTXY          ; Output XYCHA at (18,16)
        RTS
;===============================================================================================

;===============================================================================================
; SPLSHC: Print Player vs Computer Splash Screen
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
;       PLAYCN          Computer name
;       PLAYCS          Computer Player score
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

SPLASHC STAA    MODE           ; Store the game mode (at this stage it will be #$43 - "C")
        JSR     STR            ; Store A/B/X
        JSR     CLS            
        LDX     #SPLSH1        ; Output the Title of the program
        JSR     PUTMSG
        LDX     #BUILD         ; Show the build/version number
        JSR     PUTMSG
        LDX     #MSGAG1        
        JSR     PUTMSG         
        LDX     #MSGAG2        
        JSR     PUTMSG         ; ... and wait for a keypress

        JSR     STR
        LDX     #PLAY1N        ; Load X with the start of Player name 1
        LDAA    #1             ; Set the X co-ordinate to be 1
        STAA    CURSX          ; Store it in CURSX
        LDAB    #16            ; Set the Y co-ordinate to be 16,
        STAB    CURSY          ; Store it in CURSY
        JSR     PPLYN          ; Display the player 1 name

        LDX     #PLAYCN        ; Load X with the start of Computer Name
        LDAA    #24
        STAA    CURSX          ; Set the X co-ordinate to be 25
        LDAB    #16            ; Set the Y co-ordinate to be 6,
        STAB    CURSY          ; Store it in CURSY
        JSR     PPLYN          ; Display the player 1 name

        JSR     .DOSCORE       ; Display players scores on the splash screen
        
        LDAA    PLAYER         ; Determine which is the player to select on first entry to the splash screen
        CMPA    #2
        BEQ     .S2 
        JMP     .S1 
.S2     JSR     .SEL1
        BRA     .LOOP
.S1     JSR     .SELC          


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
        
        INC     COUNTER        ; Increment Computer Player counter.....
                
        LDX     #10000         ; Delay by 10000 microseconds
.DLY    DEX                    ;        (1/100th second)
        BNE     .DLY
                               ; Get keypresss.....        
        LDAA    #$40           ; Load a mask for CA2 flag.
        BITA    KBDPIA+1       ; See if a character has been typed in.
        BNE     .OUT
        BRA     .LOOP          ; Loop around.......

.OUT    JSR     HOME
        LDAA    #65
        STAA    XYCHA
        CLRA
        CLRB
        JSR     PRTXY


        JSR     RSTR           ; Restore the A/B/X values
        LDAA    KBDPIA         ; Load the keypress value
        CMPA    RESET          ; Did they press "R" ?
        BEQ     .RESET         ; If so, reset the names and scores
        CMPA    EQUALS         ; Did they press "="
        BEQ     .SELPLY        ; If so, toggle the "Player" indicator.
        CMPA    NOUGHT         ; Did they press "O" ?
        BEQ     .NOUGHT
        CMPA    CROSS          ; Did they press "X" ?
        BEQ     .CROSS
        BRA     .LOOP
.CROSS  LDAA    #1             ; Cross's turn first
        STAA    TURN           ; Store that cross is going first
        RTS
.NOUGHT
        CLR     TURN
        RTS

.RESET  CLR     PLAY1S         ; Clear player 1 score
        CLR     PLAYCS         ; Clear Computer player score 
        JSR     .DOSCORE       ; Display the scores again
        BRA     .LOOP          ; When done, go back to the main loop

.DISPQ  JSR     PRTXY          ; Display a "Selected" indicator around a specific player
        ADDA    #8             ; After outputting the first symbol, add 8 to the X co-ordinate 
        JSR     PRTXY          ; Output the second "Selected" symbol 
        RTS

.SELPLY LDAB    #16            ; Load AccB with the row number of the Player 1 name
        LDAA    PLAYER         ; Switch selection between players
        CMPA    #1
        BEQ     .SELC          ; If Player 1 is current, then switch to Computer
                        
.SEL1   LDAA    SPACE          ; Switch to Player 1 
        JSR     .PC
        LDAA    EQUALS
        JSR     .P1
        LDAA    #1
        STAA    PLAYER
        JMP     .LOOP
        
.SELC   LDAA    SPACE          ; Switch to Computer Player
        JSR     .P1
        LDAA    EQUALS
        JSR     .PC
        LDAA    #2
        STAA    PLAYER
        JMP     .LOOP

.P1     STAA    XYCHA          ; Store the equals character in XYCHA
        CLRA                   ; For Player 1, set the X co-ordinate
        JSR     .DISPQ         ; Display the player selection
        RTS

.PC     STAA    XYCHA          ; Store the equals character in XYCHA
        LDAA    #23            ; For Computer, set the X co-ordinate
        JSR     .DISPQ         ; Display the player selection
        RTS
.DOSCORE        
        LDAB    #16            ; Set Y co-ordinate of Player 1 score
        LDAA    PLAY1S         ; Get Player 1 score
        ADDA    #48            ; Add 48 to the score to give an ASCII value
        STAA    XYCHA          ; Store the ASCII score character in XYCHA
        LDAA    #13            ; Set the X co-ordinate of the Player 1 score
        JSR     PRTXY          ; Output XYCHA at (13,16)

        LDAA    PLAYCS         ; Get Computer score
        ADDA    #48            ; Add 48 to the score to give an ASCII value
        STAA    XYCHA          ; Store the ASCII score character in XYCHA
        LDAA    #18            ; Set the X co-ordinate of the Player 2 score
        LDAB    #16            ; Set Y co-ordinate of Player 2 score
        JSR     PRTXY          ; Output XYCHA at (18,16)
        RTS
;===============================================================================================
