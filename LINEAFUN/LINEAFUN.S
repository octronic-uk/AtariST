;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk      
;
;   LINEAFUN.S
;		Plebbing around with Line A Graphics
;		Functions
;
;	move_a_dot:
;		Moves a dot with the cursor keys, 
;		starting at 0,0. Esc to quit.
;
		
; Includes
	include "GEMDOS.I"
    include "LINEA.I"
	include "INPUT.I"

move_a_dot:
    jsr linea_init
move_a_dot_loop:
    jsr put_pixel
    jsr read_key
    jsr check_key
    jmp move_a_dot_loop

linea_init:
    dc.w    LINEA_INIT	        ; Call Init
    move.l  LINEA_INTIN(a0),a3	; Addr of INTIN
    move.l  LINEA_PTSIN(a0),a4	; Addr of PTSIN
    rts

put_pixel:
    move.w	X_POS,(a4)	        ; X Coord
    move.w	Y_POS,2(a4)         ; Y Coord
    move.w	#1,(a3)		        ; Colour set, pixel set 0 erase pixel
    dc.w    LINEA_PUT_PIXEL	    ; Set the pixel
    rts

read_key:
    move.w	#GEMDOS_CCONIN,-(sp)	; Wait for keypress
    trap 	#TRAP_GEMDOS
    addq.l	#2,sp
    swap    d0
    move.w  d0,LAST_CHAR
    rts
    
check_key:
    cmpi.w  #UP_SCANCODE,LAST_CHAR
    bne     check_key_not_up
    subq.w  #1,Y_POS
    jmp     check_key_done
check_key_not_up:   
    cmpi.w  #DOWN_SCANCODE,LAST_CHAR
    bne     check_key_not_down
    addq.w  #1,Y_POS
    jmp     check_key_done
check_key_not_down:
    cmpi.w  #LEFT_SCANCODE,LAST_CHAR
    bne     check_key_not_left
    subq.w  #1,X_POS
    jmp     check_key_done
check_key_not_left:
    cmpi.w  #RIGHT_SCANCODE,LAST_CHAR
    bne     check_key_not_right
    addq.w  #1,X_POS
   	jmp		check_key_done
check_key_not_right:
	cmpi.w	#ESC_SCANCODE,LAST_CHAR
	bne		check_key_done
	jmp		done
check_key_done:
    rts
    
done:
    move.w	#GEMDOS_PTERM0,-(sp)	; GTFO
    trap	#TRAP_GEMDOS

    section data

X_POS:      ds.w    1
Y_POS:      ds.w    1
LAST_CHAR:  ds.w    1
