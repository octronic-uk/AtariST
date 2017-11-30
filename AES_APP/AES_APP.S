;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk
;
;	AES_APP.S
;		Header for an AES Application


 
;--------------------------------------
; Application Starts Here
;--------------------------------------

	section text

memory_init:                            ; Set base page address in a5
    move.l a7,a5                        ; Save a7 so we can get the base page address 
    move.l BASE_PAGE_PTR(a5),a5         ; a5 = basepage addressk
                                        ; Calculate the total amount of memory used by
                                        ; our program (including stack space) in d0
                                        ; total memory used =
    move.l  CODE_SZ(a5),d0              ; length of code segment
    add.l   DATA_SZ(a5),d0              ; + length of data segment
    add.l   BSS_SZ(a5),d0               ; + length of uninitialized storage segment 
    add.l   #STACK_SZ+BASE_PAGE_SZ,d0   ; + (size of the base page + our stack)
                                        ; Calculate the size of our stack and move it to the stack pointer
                                        ; stack address =
    move.l d0,d1                        ;   size of program memory
    add.l a5,d1                         ; + program's base address,
    and.l #-2,d1                        ; pick off odd bit to make sure that the  
                                        ; stack starts on a word boundary (it must).  
    move.l d1,a7                        ; set stack pointer to our stack
                                        ; which is stk bytes above end of BSS
                                        ; Use the GEMD0S SETBLOCK call to reserve the area of memory 
                                        ; actually used for the program and stack, and release the 
                                        ; rest back to the free memory pool.
    move.l  d0,-(sp)                    ; push the size of program memory
                                        ; (first SETBLOCK parameter) on the stack.
    move.l  a5,-(sp)                    ; push the beginning address of the
                                        ; program memory area (2nd SETBLOCK parameter), 
    clr.w   -(sp)                       ; clear a dummy place-holder word
    move.w  #GEMDOS_MSHRINK,-(sp)       ; finally, push the GEMDOS command number
                                        ; for the SETBLOCK function
    trap    #TRAP_GEMDOS                ; call GEMDOS
    add.l   #12,sp                      ; and clear our arguments off the stack,

main:
	jsr		AES_appl_init
	jsr		AES_graf_handle
	jsr		VDI_get_screen_res	
	jsr		VDI_opnvwk
    jsr     AES_rsrc_load
    jsr     AES_wind_get_desk_xywh
	jsr		AES_wind_create
	jsr		AES_wind_set_title
	jsr		AES_wind_set_info
    jsr     AES_rsrc_get_menu_ptr
    jsr     AES_rsrc_get_form_ptr
	jsr		AES_wind_open
    jsr     AES_show_menu_bar
main_loop:
	jsr		AES_event_messag
main_check_sized:
	cmpi.w	#AES_EVENT_WM_SIZED,AES_MESSAGE
	bne		main_check_redraw
	jsr		AES_event_wm_sized
    jmp     main_loop
main_check_redraw:
	cmpi.w	#AES_EVENT_WM_REDRAW,AES_MESSAGE
	bne		main_check_moved
	jsr		AES_event_wm_redraw
    jmp     main_loop
main_check_moved:
	cmpi.w	#AES_EVENT_WM_MOVED,AES_MESSAGE
	bne		main_check_fulled
	jsr		AES_event_wm_moved
    jmp     main_loop
main_check_fulled:
	cmpi.w	#AES_EVENT_WM_FULLED,AES_MESSAGE
	bne		main_check_menu_selected
	jsr		AES_wind_get_full_xywh
	jsr		AES_event_wm_fulled
	jsr		AES_wind_get_prev_xywh
    jmp     main_loop
main_check_menu_selected:
    cmpi.w  #AES_EVENT_MN_SELECTED,AES_MESSAGE
    bne     main_check_close
    jsr     AES_event_mn_selected
    jmp     main_loop
main_check_close:	
	cmpi.w	#AES_EVENT_WM_CLOSED,AES_MESSAGE
	beq		main_exit
	jmp		main_loop
main_exit:
	jsr		AES_wind_close
    jsr     AES_hide_menu_bar
    jsr     AES_rsrc_free
	jsr		AES_wind_delete
	jsr		VDI_clsvwk
	jsr		AES_appl_exit
	move.w	#GEMDOS_PTERM0,-(sp)
	trap	#TRAP_GEMDOS

ZERO_ARRAY:
	move.w	4(sp),d0	; size
	movea.l	6(sp),a0	; pointer
	subq.w	#1,d0		; size-1
_ZERO_ARRAY_next:
	move.w	#0,(a0)+
	dbra	d0,_ZERO_ARRAY_next
	rts

FATAL_ERROR:
	move.l	4(sp),-(sp)	
	move.w	#GEMDOS_CCONWS,-(sp)
	trap	#TRAP_GEMDOS
	addq.l	#6,sp
	move.w	#GEMDOS_CCONIN,-(sp)
	trap	#TRAP_GEMDOS
	addq.l	#2,sp
	move.w	#GEMDOS_PTERM0,-(sp)
	trap	#TRAP_GEMDOS

DEBUG:
	move.l	4(sp),-(sp)	
	move.w	#GEMDOS_CCONWS,-(sp)
	trap	#TRAP_GEMDOS
	addq.l	#6,sp
	move.w	#GEMDOS_CCONIN,-(sp)
	trap	#TRAP_GEMDOS
	addq.l	#2,sp
	rts


;--------------------------------------
; GEM/VDI Library Functions
;--------------------------------------

VDI_get_screen_res:
	move.w	#XBIOS_GETRES,-(sp)
	trap	#TRAP_XBIOS
	addq.l	#2,sp
	addq.w	#2,d0					; Add 2 to correct res
	move.w	d0,SCREEN_RES
	beq		_VDI_get_screen_res_error
	rts
_VDI_get_screen_res_error:
	pea		SCREEN_RES
	pea		STR_BUFFER
	jsr		ASCII_itoa
	addq.l	#8,sp
	pea		STR_BUFFER
	jsr		DEBUG
	addq.l	#4,sp
	rts
	
VDI_opnvwk:
    jsr     VDI_zero_arrays
	move.w	#VDI_OPNVWK,VDI_CONTROL
	move.w	#11,VDI_CONTROL+VDI_CTRL_INT_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_IN
	move.w	AES_PHYS_HANDLE,VDI_CONTROL+VDI_CTRL_DEV_HANDLE
	lea		VDI_INT_IN,a0
	move.w	#9,d0
_VDI_opnvwk_int_in_init_loop:
	move.w	#1,(a0)+
	dbra	d0,_VDI_opnvwk_int_in_init_loop
	move.w	SCREEN_RES,VDI_INT_IN
	move.w	#VDI_RASTER_COORDS,VDI_INT_IN+20
	jsr		_call_VDI
	move.w	VDI_CONTROL+VDI_CTRL_DEV_HANDLE,VDI_WK_HANDLE
	cmpi.w	#0,VDI_WK_HANDLE
	beq		_VDI_openvwk_error
	rts
_VDI_openvwk_error:
	pea		STR_VDI_OPNVWK_ERROR	
	jsr 	DEBUG
	addq.l	#4,sp
	pea		VDI_WK_HANDLE
	pea		STR_BUFFER
	jsr		ASCII_itoa
	addq.l	#8,sp
	pea		STR_BUFFER
	jsr		FATAL_ERROR
	addq.l	#4,sp
	rts

VDI_clrwk:
    jsr     VDI_zero_arrays
	move.w	#VDI_CLRWK,VDI_CONTROL
	move.w	#0,VDI_CONTROL+VDI_CTRL_INT_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_INT_OUT
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_OUT
	jsr		_call_VDI
	rts
	
VDI_clsvwk:
    jsr     VDI_zero_arrays
	move.w	#VDI_CLSVWK,VDI_CONTROL
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_OUT
	move.w	#0,VDI_CONTROL+VDI_CTRL_INT_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_INT_OUT
    move.w  VDI_WK_HANDLE,VDI_CONTROL+VDI_CTRL_DEV_HANDLE
	jsr		_call_VDI
	rts

VDI_set_bg_white:
    jsr     VDI_zero_arrays
	move.w	#VDI_VSF_COLOR,VDI_CONTROL
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_OUT
	move.w	#1,VDI_CONTROL+VDI_CTRL_INT_IN
	move.w	#1,VDI_CONTROL+VDI_CTRL_INT_OUT
	move.w	VDI_WK_HANDLE,VDI_CONTROL+VDI_CTRL_DEV_HANDLE
	move.w	#0,VDI_INT_IN
	jsr 	_call_VDI
	rts
	
VDI_fill_bg_rect:
    jsr     VDI_zero_arrays
	move.w	#VDI_VR_RECFL,VDI_CONTROL
	move.w	#2,VDI_CONTROL+VDI_CTRL_PTS_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_OUT
	move.w	#0,VDI_CONTROL+VDI_CTRL_INT_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_INT_OUT
	move.w	VDI_WK_HANDLE,VDI_CONTROL+VDI_CTRL_DEV_HANDLE
	move.w	AES_WORK_X,VDI_PTS_IN
	move.w	AES_WORK_Y,VDI_PTS_IN+2
	move.w	AES_WORK_X,d0
	add.w	AES_WORK_W,d0
	move.w	d0,VDI_PTS_IN+4
	move.w	AES_WORK_Y,d0		
	add.w	AES_WORK_H,d0
	move.w	d0,VDI_PTS_IN+6
	jsr		_call_VDI
	rts

VDI_zero_arrays:
    pea 	VDI_CONTROL
	move.w	#VDI_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
    pea 	VDI_INT_IN
	move.w	#VDI_ARRAY_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
    pea 	VDI_INT_OUT
	move.w	#VDI_ARRAY_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
    pea 	VDI_PTS_IN
	move.w	#VDI_ARRAY_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
    pea 	VDI_PTS_OUT
	move.w	#VDI_ARRAY_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
    rts

;--------------------------------------
;	AES Library Functions
;--------------------------------------

AES_appl_init:
    jsr     AES_zero_arrays
    jsr     AES_zero_global
	move.w	#AES_APPL_INIT,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	jsr		_call_AES
	move.w	AES_INT_OUT,APP_ID
	cmpi.w	#$FFFF,APP_ID
	beq 	_AES_appl_init_error
	rts
_AES_appl_init_error:
	pea		STR_AES_APPL_INIT_ERROR
	jsr		FATAL_ERROR
	addq.l	#4,sp

AES_appl_exit:
    jsr     AES_zero_arrays
	move.w	#AES_APPL_EXIT,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	jsr		_call_AES
	rts

AES_event_messag:
    jsr     AES_zero_arrays
	move.w	#AES_EVENT_MESSAG,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#1,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.l	#AES_MESSAGE,AES_ADDR_IN
	jsr		_call_AES
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	rts

AES_event_wm_sized:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_SET,AES_CONTROL
	move.w	#6,AES_CONTROL+AES_CTRL_INT_IN
	move.w	AES_MESSAGE+6,AES_INT_IN
	move.w	#AES_WF_CURRXYWH,AES_INT_IN+2
	move.w	AES_MESSAGE+8,AES_INT_IN+4
	move.w	AES_MESSAGE+10,AES_INT_IN+6
	move.w	AES_MESSAGE+12,AES_INT_IN+8
	move.w	AES_MESSAGE+14,AES_INT_IN+10
	jsr		_call_AES
	rts

AES_event_wm_fulled:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_SET,AES_CONTROL
	move.w	#6,AES_CONTROL+AES_CTRL_INT_IN
	move.w	AES_MESSAGE+6,AES_INT_IN
	move.w	#AES_WF_CURRXYWH,AES_INT_IN+2
    cmpi.w  #FALSE,IS_FULLED
    bne     AES_event_wm_fulled_unfull
	move.w	AES_DESK_X,AES_INT_IN+4
	move.w	AES_DESK_Y,AES_INT_IN+6
	move.w	AES_DESK_W,AES_INT_IN+8
	move.w	AES_DESK_H,AES_INT_IN+10
    move.w  #TRUE,IS_FULLED
    jmp     AES_event_wm_fulled_apply
AES_event_wm_fulled_unfull:
    move.w	AES_PREV_X,AES_INT_IN+4
	move.w	AES_PREV_Y,AES_INT_IN+6
	move.w	AES_PREV_W,AES_INT_IN+8
	move.w	AES_PREV_H,AES_INT_IN+10
    move.w  #FALSE,IS_FULLED
AES_event_wm_fulled_apply:
	jsr		_call_AES
	rts

AES_event_wm_moved:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_SET,AES_CONTROL
	move.w	#6,AES_CONTROL+AES_CTRL_INT_IN
	move.w	AES_MESSAGE+6,AES_INT_IN
	move.w	#AES_WF_CURRXYWH,AES_INT_IN+2
	move.w	AES_MESSAGE+8,AES_INT_IN+4
	move.w	AES_MESSAGE+10,AES_INT_IN+6
	move.w	AES_MESSAGE+12,AES_INT_IN+8
	move.w	AES_MESSAGE+14,AES_INT_IN+10
	jsr		_call_AES
	rts

AES_event_wm_redraw:		
	jsr		AES_graf_mouse_hide
	jsr		AES_wind_update_begin
	jsr		AES_wind_get_work_xywh
	jsr		VDI_set_bg_white
	jsr		VDI_fill_bg_rect
	jsr		AES_wind_update_end
	jsr		AES_graf_mouse_show
    jsr     AES_graf_mouse_arrow
	rts

AES_event_mn_selected:
    cmpi.w  #M_DESK,AES_MESSAGE+6
    beq     AES_event_mn_selected_jsr_desk
    cmpi.w  #M_FILE,AES_MESSAGE+6
    beq     AES_event_mn_selected_jsr_file
    rts
AES_event_mn_selected_jsr_desk:
    jsr     AES_event_mn_selected_desk     
    rts
AES_event_mn_selected_jsr_file:
    jsr     AES_event_mn_selected_file     
    rts

AES_event_mn_selected_desk:
    cmpi.w  #M_DESK_INFO,AES_MESSAGE+8
    beq     AES_event_mn_selected_desk_jsr_info
    rts
AES_event_mn_selected_desk_jsr_info:
    jsr     AES_event_mn_selected_desk_info     
    rts

AES_event_mn_selected_desk_info:
    ; Display Form
    jsr     AES_form_center
    jsr     AES_form_dial_start
    jsr     AES_objc_draw
    jsr     AES_form_do
    jsr     AES_form_dial_finish
    rts

AES_event_mn_selected_file:
    cmpi.w  #M_FILE_QUIT,AES_MESSAGE+8
    beq     AES_event_mn_selected_file_jsr_quit
    rts
AES_event_mn_selected_file_jsr_quit:
    jsr     AES_event_mn_selected_file_quit
    rts

AES_event_mn_selected_file_quit:
    jmp     main_exit

AES_objc_draw:
    jsr     AES_zero_arrays
    ; AES_CONTROL
    move.w  #AES_OBJC_DRAW,AES_CONTROL 
    move.w  #6,AES_CONTROL+AES_CTRL_INT_IN
    move.w  #1,AES_CONTROL+AES_CTRL_INT_OUT
    move.w  #1,AES_CONTROL+AES_CTRL_ADDR_IN
    move.w  #0,AES_CONTROL+AES_CTRL_ADDR_OUT
    ; AES_INT_IN
    move.w  #FORM_ROOT,AES_INT_IN
    move.w  #2,AES_INT_IN+2
    move.w  FORM_CENTER_X,AES_INT_IN+4
    move.w  FORM_CENTER_Y,AES_INT_IN+6
    move.w  FORM_CENTER_W,AES_INT_IN+8
    move.w  FORM_CENTER_H,AES_INT_IN+10
    ; AES_ADDR_IN
    move.l  FORM_PTR,AES_ADDR_IN
    jsr     _call_AES
    cmpi.w  #0,AES_INT_OUT
    beq     AES_objc_draw_failed
    rts
AES_objc_draw_failed:
    pea     STR_AES_OBJC_DRAW_FAILED
    jsr     FATAL_ERROR

AES_form_center:
    jsr     AES_zero_arrays
    ; AES_CONTROL
    move.w  #AES_FORM_CENTER,AES_CONTROL 
    move.w  #0,AES_CONTROL+AES_CTRL_INT_IN
    move.w  #5,AES_CONTROL+AES_CTRL_INT_OUT
    move.w  #1,AES_CONTROL+AES_CTRL_ADDR_IN
    move.w  #0,AES_CONTROL+AES_CTRL_ADDR_OUT
    ; AES_ADDR_IN
    move.l  FORM_PTR,AES_ADDR_IN
    jsr     _call_AES
    ; AES_INT_OUT
    move.w  AES_INT_OUT+2,FORM_CENTER_X
    move.w  AES_INT_OUT+4,FORM_CENTER_Y
    move.w  AES_INT_OUT+6,FORM_CENTER_W
    move.w  AES_INT_OUT+8,FORM_CENTER_H
    rts

AES_form_dial_start:
    jsr     AES_zero_arrays
    ; AES_CONTROL
    move.w  #AES_FORM_DIAL,AES_CONTROL 
    move.w  #9,AES_CONTROL+AES_CTRL_INT_IN
    move.w  #1,AES_CONTROL+AES_CTRL_INT_OUT
    move.w  #0,AES_CONTROL+AES_CTRL_ADDR_IN
    move.w  #0,AES_CONTROL+AES_CTRL_ADDR_OUT
    ; AES_INT_IN
    move.w  #AES_FMD_START,AES_INT_IN
    move.w  #0,AES_INT_IN+2
    move.w  #0,AES_INT_IN+4
    move.w  #0,AES_INT_IN+6
    move.w  #0,AES_INT_IN+8
    move.w  FORM_CENTER_X,AES_INT_IN+10
    move.w  FORM_CENTER_Y,AES_INT_IN+12
    move.w  FORM_CENTER_W,AES_INT_IN+14
    move.w  FORM_CENTER_H,AES_INT_IN+16
    jsr     _call_AES
    rts

AES_form_dial_finish:
    jsr     AES_zero_arrays
    ; AES_CONTROL
    move.w  #AES_FORM_DIAL,AES_CONTROL 
    move.w  #9,AES_CONTROL+AES_CTRL_INT_IN
    move.w  #1,AES_CONTROL+AES_CTRL_INT_OUT
    move.w  #0,AES_CONTROL+AES_CTRL_ADDR_IN
    move.w  #0,AES_CONTROL+AES_CTRL_ADDR_OUT
    ; AES_INT_IN
    move.w  #AES_FMD_FINISH,AES_INT_IN
    move.w  #0,AES_INT_IN+2
    move.w  #0,AES_INT_IN+4
    move.w  #0,AES_INT_IN+6
    move.w  #0,AES_INT_IN+8
    move.w  FORM_CENTER_X,AES_INT_IN+10
    move.w  FORM_CENTER_Y,AES_INT_IN+12
    move.w  FORM_CENTER_W,AES_INT_IN+14
    move.w  FORM_CENTER_H,AES_INT_IN+16
    jsr     _call_AES
    rts

AES_form_do:
    jsr     AES_zero_arrays
    ; AES_CONTROL
    move.w  #AES_FORM_DO,AES_CONTROL 
    move.w  #1,AES_CONTROL+AES_CTRL_INT_IN
    move.w  #1,AES_CONTROL+AES_CTRL_INT_OUT
    move.w  #1,AES_CONTROL+AES_CTRL_ADDR_IN
    move.w  #0,AES_CONTROL+AES_CTRL_ADDR_OUT
    ; AES_INT_IN
    move.w  #0,AES_INT_IN
    ; AES_ADDR_IN
    move.l  FORM_PTR,AES_ADDR_IN
    jsr     _call_AES
    rts

AES_wind_update_begin:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_UPDATE,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#AES_BEG_UPDATE,AES_INT_IN
	jsr		_call_AES
	rts

AES_wind_update_end:	
    jsr     AES_zero_arrays
	move.w	#AES_WIND_UPDATE,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#AES_END_UPDATE,AES_INT_IN
	jsr		_call_AES
	rts

AES_graf_mouse_arrow:
    jsr     AES_zero_arrays
	move.w	#AES_GRAF_MOUSE,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#AES_MOUSE_ARROW,AES_INT_IN
	jsr		_call_AES
	rts
	
AES_graf_mouse_hide:
    jsr     AES_zero_arrays
	move.w	#AES_GRAF_MOUSE,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#VDI_HIDE_MOUSE,AES_INT_IN
	jsr		_call_AES
	rts
	
AES_graf_mouse_show:
    jsr     AES_zero_arrays
	move.w	#AES_GRAF_MOUSE,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#VDI_SHOW_MOUSE,AES_INT_IN
	jsr		_call_AES
	rts

AES_graf_handle:
    jsr     AES_zero_arrays
	move.w	#AES_GRAF_HANDLE,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#5,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	jsr		_call_AES
	move.w	AES_INT_OUT,AES_PHYS_HANDLE	
	move.w	AES_INT_OUT+2,AES_CHAR_W
	move.w	AES_INT_OUT+4,AES_CHAR_H
	move.w	AES_INT_OUT+6,AES_BOX_W
	move.w	AES_INT_OUT+8,AES_BOX_H
	rts

AES_wind_create:	
    jsr     AES_zero_arrays
	move.w	#AES_WIND_CREATE,AES_CONTROL
	move.w	#5,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	#DEF_WINDOW_FLAGS,AES_INT_IN
	move.w	AES_DESK_X,AES_INT_IN+2
	move.w	AES_DESK_Y,AES_INT_IN+4
	move.w	AES_DESK_W,AES_INT_IN+6
	move.w	AES_DESK_H,AES_INT_IN+8
	jsr		_call_AES
	move.w	AES_INT_OUT,AES_WINDOW_HANDLE
	rts

AES_wind_open:	
    jsr     AES_zero_arrays
    move.w  #FALSE,IS_FULLED
	move.w	#AES_WIND_OPEN,AES_CONTROL
	move.w	#5,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	move.w	#DEF_WINDOW_X,AES_INT_IN+2
	move.w	#DEF_WINDOW_Y,AES_INT_IN+4
	move.w	#DEF_WINDOW_W,AES_INT_IN+6
	move.w	#DEF_WINDOW_H,AES_INT_IN+8
	jsr		_call_AES
	rts

AES_wind_set_title:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_SET,AES_CONTROL
	move.w	#6,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	AES_WINDOW_HANDLE,AES_INT_IN	
	move.w	#AES_WF_NAME,AES_INT_IN+2
	move.l	#STR_WINDOW_TITLE,AES_INT_IN+4
	move.w	#0,AES_INT_IN+8
	move.w	#0,AES_INT_IN+10
	jsr		_call_AES
	rts
	
AES_wind_set_info:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_SET,AES_CONTROL
	move.w	#6,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	AES_WINDOW_HANDLE,AES_INT_IN	
	move.w	#AES_WF_INFO,AES_INT_IN+2
	move.l	#STR_WINDOW_INFO,AES_INT_IN+4
	move.w	#0,AES_INT_IN+8
	move.w	#0,AES_INT_IN+10
	jsr		_call_AES
	rts

AES_wind_close:	
    jsr     AES_zero_arrays
	move.w	#AES_WIND_CLOSE,AES_CONTROL
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	jsr		_call_AES
	rts
	
AES_wind_delete:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_DELETE,AES_CONTROL
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	jsr		_call_AES
	rts
	
AES_wind_get_work_xywh:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_GET,AES_CONTROL
	move.w	#2,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#5,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	move.w	#AES_WF_WORKXYWH,AES_INT_IN+2
	jsr		_call_AES
	move.w	AES_INT_OUT+2,AES_WORK_X
	move.w	AES_INT_OUT+4,AES_WORK_Y
	move.w	AES_INT_OUT+6,AES_WORK_W
    subq.w  #1,AES_WORK_W
	move.w	AES_INT_OUT+8,AES_WORK_H	
    subq.w  #1,AES_WORK_H
	rts

AES_wind_get_prev_xywh:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_GET,AES_CONTROL
	move.w	#2,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#5,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	move.w	#AES_WF_PREVXYWH,AES_INT_IN+2
	jsr		_call_AES
	move.w	AES_INT_OUT+2,AES_PREV_X
	move.w	AES_INT_OUT+4,AES_PREV_Y
	move.w	AES_INT_OUT+6,AES_PREV_W
	move.w	AES_INT_OUT+8,AES_PREV_H	
	rts

AES_wind_get_full_xywh:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_GET,AES_CONTROL
	move.w	#2,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#5,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	move.w	#AES_WF_FULLXYWH,AES_INT_IN+2
	jsr		_call_AES
	move.w	AES_INT_OUT+2,AES_FULL_X
	move.w	AES_INT_OUT+4,AES_FULL_Y
	move.w	AES_INT_OUT+6,AES_FULL_W
	move.w	AES_INT_OUT+8,AES_FULL_H
	rts

AES_wind_get_desk_xywh:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_GET,AES_CONTROL
	move.w	#2,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#5,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	#0,AES_INT_IN
	move.w	#AES_WF_WORKXYWH,AES_INT_IN+2
	jsr		_call_AES
	move.w	AES_INT_OUT+2,AES_DESK_X
	move.w	AES_INT_OUT+4,AES_DESK_Y
	move.w	AES_INT_OUT+6,AES_DESK_W
	move.w	AES_INT_OUT+8,AES_DESK_H
	rts

AES_rsrc_load:
    jsr     AES_zero_arrays
	move.w	#AES_RSRC_LOAD,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#1,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.l  #STR_RESOURCE_FILE,AES_ADDR_IN
	jsr		_call_AES
    cmpi.w  #0,AES_INT_OUT
    beq     _AES_rscs_load_error
    rts
_AES_rscs_load_error:
    pea     STR_AES_RSRC_LOAD_FAILED
    jsr     FATAL_ERROR

AES_rsrc_free:
    jsr     AES_zero_arrays
    move.w	#AES_RSRC_FREE,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	jsr		_call_AES
    rts

AES_rsrc_get_menu_ptr:
    jsr     AES_zero_arrays
    move.w	#AES_RSRC_GADDR,AES_CONTROL
	move.w	#2,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#1,AES_CONTROL+AES_CTRL_ADDR_OUT
    move.w  #AES_RSRC_TREE,AES_INT_IN
    move.w  #MENU,AES_INT_IN+2
	jsr		_call_AES
    cmpi.w  #0,AES_INT_OUT
    beq     AES_rsrc_get_menu_ptr_failed
    move.l  AES_ADDR_OUT,AES_MENU_PTR
    rts
AES_rsrc_get_menu_ptr_failed:
    pea     STR_AES_GET_MENU_PTR_FAILED
    jsr     FATAL_ERROR

AES_rsrc_get_form_ptr:
    jsr     AES_zero_arrays
    move.w	#AES_RSRC_GADDR,AES_CONTROL
	move.w	#2,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#1,AES_CONTROL+AES_CTRL_ADDR_OUT
    move.w  #AES_RSRC_TREE,AES_INT_IN
    move.w  #FORM,AES_INT_IN+2
	jsr		_call_AES
    cmpi.w  #0,AES_INT_OUT
    beq     AES_rsrc_get_form_ptr_failed
    move.l  AES_ADDR_OUT,FORM_PTR
    rts
AES_rsrc_get_form_ptr_failed:
    pea     STR_AES_GET_FORM_PTR_FAILED
    jsr     FATAL_ERROR

AES_show_menu_bar:
    jsr     AES_zero_arrays
    move.w	#AES_MENU_BAR,AES_CONTROL
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#1,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
    move.w  #AES_MENU_SHOW,AES_INT_IN
    move.l  AES_MENU_PTR,AES_ADDR_IN
    jsr     _call_AES
    cmpi.w  #0,AES_INT_OUT
    beq     AES_show_menu_bar_failed
    rts
AES_show_menu_bar_failed:
    pea     STR_AES_SHOW_MENU_FAILED
    jsr     FATAL_ERROR

AES_hide_menu_bar:
    jsr     AES_zero_arrays
    move.w	#AES_MENU_BAR,AES_CONTROL
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#1,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
    move.w  #AES_MENU_HIDE,AES_INT_IN
    move.l  AES_MENU_PTR,AES_ADDR_IN
    jsr     _call_AES
    cmpi.w  #0,AES_INT_OUT
    beq     AES_hide_menu_bar_failed
    rts
AES_hide_menu_bar_failed:
    pea     STR_AES_HIDE_MENU_FAILED
    jsr     FATAL_ERROR

AES_zero_arrays:
    pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
    pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
    pea		AES_INT_OUT
	move.w	#AES_INT_OUT_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
    pea		AES_ADDR_IN
	move.w	#AES_ADDR_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
    pea		AES_ADDR_OUT
	move.w	#AES_ADDR_OUT_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
    rts

AES_zero_global:
    pea		AES_GLOBAL
	move.w	#AES_GLOBAL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
    rts

;--------------------------------------		
	 section bss
;--------------------------------------

STR_BUFFER:             ds.b	128			
APP_ID:					ds.w	1
SCREEN_RES:				ds.w	1
IS_FULLED:              ds.w    1
FORM_PTR:               ds.l    1

FORM_CENTER_X:          ds.w    1
FORM_CENTER_Y:          ds.w    1
FORM_CENTER_W:          ds.w    1
FORM_CENTER_H:          ds.w    1

;--------------------------------------
	section data
;--------------------------------------

; Strings

	even
STR_WIND_CREATE_FAIL: 	
	dc.b	ASCII_CR,"Failed to create window",ASCII_NUL
	
	even
STR_WIND_CREATE_SUCC:	
	dc.b	ASCII_CR,"Created window!",ASCII_NUL
	
	even
STR_WINDOW_TITLE:
	dc.b	"Ash's AES App",ASCII_NUL
	
	even
STR_WINDOW_INFO:
	dc.b	"Glorious Information",ASCII_NUL
	
	even
STR_AES_APPL_INIT_ERROR:
	dc.b	ASCII_CR,"Error in appl_init",ASCII_NUL
	
	even
STR_VDI_OPNVWK_ERROR:
	dc.b	ASCII_CR,"Error in opnvwk",ASCII_NUL
	
	even
STR_RESOURCE_FILE:
    dc.b    "AES_APP.RSC",ASCII_NUL

	even
STR_AES_RSRC_LOAD_FAILED: 	
	dc.b	ASCII_CR,"Failed to load AES resource file",ASCII_NUL

    even
STR_AES_GET_MENU_PTR_FAILED:
    dc.b    ASCII_CR,"Failed to get AES Menu Pointer",ASCII_NUL
	
    even
STR_AES_GET_FORM_PTR_FAILED:
    dc.b    ASCII_CR,"Failed to get AES Form Pointer",ASCII_NUL

	even
STR_AES_SHOW_MENU_FAILED: 	
	dc.b	ASCII_CR,"Failed to show AES menu",ASCII_NUL
	
	even
STR_AES_HIDE_MENU_FAILED: 	
	dc.b	ASCII_CR,"Failed to hide AES menu",ASCII_NUL

	even
STR_AES_OBJC_DRAW_FAILED: 	
	dc.b	ASCII_CR,"Failed to draw AES form",ASCII_NUL

	even
STR_AES_OBJC_DRAW_BEFORE: 	
	dc.b	ASCII_CR,"Before call to draw AES form",ASCII_NUL

	even
STR_AES_OBJC_DRAW_AFTER: 	
	dc.b	ASCII_CR,"After call to draw AES form",ASCII_NUL



;-------------------------------------
; Other Stuff
;-------------------------------------

; Default Window Args

DEF_WINDOW_X            EQU 20
DEF_WINDOW_Y            EQU 20
DEF_WINDOW_W            EQU 300
DEF_WINDOW_H            EQU 200
DEF_WINDOW_FLAGS        EQU $2F

BASE_PAGE_PTR           EQU 4       ; Stack offset to base page address
CODE_SZ                 EQU 12      ; Base page offset to Code segment length
DATA_SZ                 EQU 20      ; Base page offset to Data segment length n
BSS_SZ                  EQU 28      ; Base page offset to BSS segment length
STACK_SZ                EQU $400    ; size of our stack (IK)
BASE_PAGE_SZ            EQU $100    ; size of base page
FALSE                   EQU $FFFF
TRUE                    EQU $1111

;--------------------------------------
;	Includes
;--------------------------------------

	include	"ASCII.S"
	include	"AES.S"
	include	"VDI.S"
	include	"GEMDOS.S"
	include	"XBIOS.S"
    include "RSRC.S"

   end
