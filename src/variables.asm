; Program Variables
SCRTCHA  .DA     1             ; Space for AccA
SCRTCHB  .DA     1             ; Space for AccB
SCRTCHX  .DA     1             ; Space for X register
TURN     .DA     1             ; 0 for nought's turn, 1 for cross's turn
SHOWHLP  .DA     1             ; 0 for no help, 1 for help
PCE      .DA     #$FF          ; Piece to check for a win

; Board Cursor position (+co-ordinates)
CURSX   .DA     #16            ; Current cursor X position
CURSY   .DA     #9             ; Current cursor Y position

; Board Layout
IBOARD  .AZ     /---------/    ; Initial content for the board i.e. all spaces
POSIT   .DA     #0             ; Position of the current cursor on the board

PIECES  .DA     #0             ; Number of pieces placed on the board
WDSTAT  .DA     #0             ; Win/Draw status
SPCOCC  .DA     #0             ; Space Occupied ? 0 = No, 1 = Yes

; Player information
PLAY1N  .AZ     /PLAYER1/      ; Name of player 1
PLAY2N  .AZ     /PLAYER2/      ; Name of player 2
PLAY1S  .DA     #0             ; Player 1 score
PLAY2S  .DA     #0             ; Player 2 score
PLAYER  .DA     #0             ; 0 = Player 1 is selected
                               ; 1 = Player 2 is selected
