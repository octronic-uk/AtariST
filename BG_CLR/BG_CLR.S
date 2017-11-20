; Change the background colour or something...

    include "../INCLUDE/TRAPS.S"
    include "../INCLUDE/GFX.S"

BG_COLOUR equ $0700

main:
    ; Super Init
    move.l  #0,-(sp) 
    move.w  #TRAP_GD_SU,-(sp) 
    trap    #TRAP_GEMDOS
    addq.l  #6,sp
    move.l  d0,super_old_stack
    ; Set BG
    move.w  #BG_COLOUR,-(sp)
    jsr     change_bg
    addq.l  #2,sp
    ; Super Restore
    pea     super_old_stack 
    move.w  #TRAP_GD_SU,-(sp)
    trap    #TRAP_GEMDOS
    addq.l  #6,sp
    ; Exit
    move.l  #0,-(sp)
    trap    #TRAP_GEMDOS

; Usage
;   move.w  #$707,-(sp) ; Push colour
;   jsr change_bg_colour_raw
;   addq.l  #4,sp
change_bg:
    move.w  4(sp),d0
    move.w  d0,PALETTE_REG_0    ; red bg colour
    rts

super_old_stack: dc.l 0
