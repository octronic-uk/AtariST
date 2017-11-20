;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk      
;
;   OSLIB.S 
;
    include "../INCLUDE/TRAPS.S"

; set supervisor
super_init:
    move.l  #0,-(sp) 
    move.w  #TRAP_GD_SU,-(sp) 
    trap    #TRAP_GEMDOS
    addq.l  #6,sp
    move.l  d0,super_old_stack
    rts

; set user mode again
super_restore:
    pea     super_old_stack 
    move.w  #TRAP_GD_SU,-(sp)
    trap    #TRAP_GEMDOS
    addq.l  #6,sp
    rts

exit_app:
    move.l  #0,-(sp)
    trap    #TRAP_GEMDOS

section data 

super_old_stack:
     dc.l 0
