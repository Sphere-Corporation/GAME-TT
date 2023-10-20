; Firmware entry points (PDS-V3N)

HOME    .EQU     $FC37         ; Cursor to top left
CLEAR   .EQU     $FC3D         ; Clear screen contents
PUTCHR  .EQU     $FCBC         ; Print character at cursor
KBDPIA  .EQU     $F040         ; Address of PIA for KBD/2 (Only supports KBD/2)

; PDS Workspace

CSRPTR  .EQU     $1C           ; Current cursor location