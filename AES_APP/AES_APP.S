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

main:
	jsr		AES_appl_init
	jsr		AES_graf_handle
	jsr		VDI_get_screen_res	
	jsr		VDI_opnvwk
    jsr     AES_wind_get_desk_xywh
	jsr		AES_wind_create
	jsr		AES_wind_set_title
	jsr		AES_wind_set_info
	jsr		AES_wind_open
	
main_loop:
	jsr		AES_event_messag
	
main_check_sized:
	move.w	AES_MESSAGE,d1
	cmpi.w	#EVENT_WM_SIZED,d1
	bne		main_check_redraw
	jsr		AES_event_wm_sized
	
main_check_redraw:
	move.w	AES_MESSAGE,d1
	cmpi.w	#EVENT_WM_REDRAW,d1
	bne		main_check_moved
	jsr		AES_event_wm_redraw
	
main_check_moved:
	move.w	AES_MESSAGE,d1
	cmpi.w	#EVENT_WM_MOVED,d1
	bne		main_check_fulled
	jsr		AES_event_wm_moved

main_check_fulled:
	move.w	AES_MESSAGE,d1
	cmpi.w	#EVENT_WM_FULLED,d1
	bne		main_check_close
	jsr		AES_wind_get_full_xywh
	jsr		AES_event_wm_fulled
	jsr		AES_wind_get_prev_xywh
	
main_check_close:	
	move.w	AES_MESSAGE,d1
	cmpi.w	#EVENT_WM_CLOSED,d1
	beq		main_exit
	
main_next:
	jmp		main_loop
	
main_exit:
	jsr		AES_wind_close
	jsr		AES_wind_delete
	jsr		VDI_clsvwk
	jsr		AES_appl_exit
	move.w	#GEMDOS_PTERM0,-(sp)
	trap	#TRAP_GEMDOS
	rts
	
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
	pea		VDI_CONTROL
	move.w	#VDI_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#VDI_OPNVWK,VDI_CONTROL
	move.w	#11,VDI_CONTROL+VDI_CTRL_INT_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_IN
	move.w	AES_PHYS_HANDLE,VDI_CONTROL+VDI_CTRL_DEV_HANDLE
	pea		VDI_INT_IN
	move.w	#VDI_ARRAY_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	pea		VDI_INT_IN
	move.w	#VDI_ARRAY_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	lea		VDI_INT_IN,a0
	move.w	#9,d0
_VDI_opnvwk_int_in_init_loop:
	move.w	#1,(a0)+
	dbra	d0,_VDI_opnvwk_int_in_init_loop
	move.w	SCREEN_RES,VDI_INT_IN
	move.w	#RASTER_COORDS,VDI_INT_IN+20
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
	pea 	VDI_CONTROL
	move.w	#VDI_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#VDI_CLRWK,VDI_CONTROL
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_INT_IN
	jsr		_call_VDI
	rts

	
VDI_clsvwk:
	pea 	VDI_CONTROL
	move.w	#VDI_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#VDI_CLSWK,VDI_CONTROL
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_INT_IN
	jsr		_call_VDI
	rts


VDI_set_bg_white:
	pea 	VDI_CONTROL
	move.w	#VDI_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#VSF_COLOR,VDI_CONTROL
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_OUT
	move.w	#1,VDI_CONTROL+VDI_CTRL_INT_IN
	move.w	#1,VDI_CONTROL+VDI_CTRL_INT_OUT
	move.w	VDI_WK_HANDLE,VDI_CONTROL+VDI_CTRL_DEV_HANDLE
	move.w	#0,VDI_INT_IN
	jsr 	_call_VDI
	rts

	
VDI_fill_bg_rect:
	pea 	VDI_CONTROL
	move.w	#VDI_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#VR_RECFL,VDI_CONTROL
	move.w	#2,VDI_CONTROL+VDI_CTRL_PTS_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_OUT
	move.w	#0,VDI_CONTROL+VDI_CTRL_INT_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_INT_OUT
	move.w	VDI_WK_HANDLE,VDI_CONTROL+VDI_CTRL_DEV_HANDLE
	move.w	WORK_X,VDI_PTS_IN
	move.w	WORK_Y,VDI_PTS_IN+2
	move.w	WORK_X,d0
	add.w	WORK_W,d0
	move.w	d0,VDI_PTS_IN+4
	move.w	WORK_Y,d0		
	add.w	WORK_H,d0
	move.w	d0,VDI_PTS_IN+6
	jsr		_call_VDI
	rts


;--------------------------------------
;	AES Library Functions
;--------------------------------------

AES_appl_init:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_APPL_INIT,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	pea		AES_GLOBAL
	move.w	#AES_GLOBAL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	pea		AES_INT_OUT
	move.w	#AES_INT_OUT_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
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
	pea 	AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_APPL_EXIT,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	jsr		_call_AES
	rts
	

AES_event_messag:
	pea 	AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#EVENT_MESSAG,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#1,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.l	#AES_MESSAGE,AES_ADDR_IN
	jsr		_call_AES
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	rts


AES_event_wm_sized:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_WIND_SET,AES_CONTROL
	move.w	#6,AES_CONTROL+AES_CTRL_INT_IN
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	AES_MESSAGE+6,AES_INT_IN
	move.w	#WF_CURRXYWH,AES_INT_IN+2
	move.w	AES_MESSAGE+8,AES_INT_IN+4
	move.w	AES_MESSAGE+10,AES_INT_IN+6
	move.w	AES_MESSAGE+12,AES_INT_IN+8
	move.w	AES_MESSAGE+14,AES_INT_IN+10
	jsr		_call_AES
	rts
	

AES_event_wm_fulled:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_WIND_SET,AES_CONTROL
	move.w	#6,AES_CONTROL+AES_CTRL_INT_IN
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	AES_MESSAGE+6,AES_INT_IN
	move.w	#WF_CURRXYWH,AES_INT_IN+2
    
    cmpi.w  #FALSE,IS_FULLED
    bne     AES_event_wm_fulled_unfull

	move.w	DESK_X,AES_INT_IN+4
	move.w	DESK_Y,AES_INT_IN+6
	move.w	DESK_W,AES_INT_IN+8
	move.w	DESK_H,AES_INT_IN+10
    move.w  #TRUE,IS_FULLED
    jmp     AES_event_wm_fulled_apply
AES_event_wm_fulled_unfull:
    move.w	PREV_X,AES_INT_IN+4
	move.w	PREV_Y,AES_INT_IN+6
	move.w	PREV_W,AES_INT_IN+8
	move.w	PREV_H,AES_INT_IN+10
    move.w  #FALSE,IS_FULLED
AES_event_wm_fulled_apply:
	jsr		_call_AES
	rts


AES_event_wm_moved:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_WIND_SET,AES_CONTROL
	move.w	#6,AES_CONTROL+AES_CTRL_INT_IN
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	AES_MESSAGE+6,AES_INT_IN
	move.w	#WF_CURRXYWH,AES_INT_IN+2
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


AES_wind_update_begin:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_WIND_UPDATE,AES_CONTROL
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#BEG_UPDATE,AES_INT_IN
	jsr		_call_AES
	rts

	
AES_wind_update_end:	
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_WIND_UPDATE,AES_CONTROL
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#END_UPDATE,AES_INT_IN
	jsr		_call_AES
	rts

AES_graf_mouse_arrow:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_GRAF_MOUSE,AES_CONTROL
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#MOUSE_ARROW,AES_INT_IN
	jsr		_call_AES
	rts
	
	
AES_graf_mouse_hide:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_GRAF_MOUSE,AES_CONTROL
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#HIDE_MOUSE,AES_INT_IN
	jsr		_call_AES
	rts
	
	
AES_graf_mouse_show:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_GRAF_MOUSE,AES_CONTROL
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#SHOW_MOUSE,AES_INT_IN
	jsr		_call_AES
	rts


AES_graf_handle:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_GRAF_HANDLE,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#5,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	pea		AES_INT_OUT
	move.w	#AES_INT_OUT_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	jsr		_call_AES
	move.w	AES_INT_OUT,AES_PHYS_HANDLE	
	move.w	AES_INT_OUT+2,AES_CHAR_W
	move.w	AES_INT_OUT+4,AES_CHAR_H
	move.w	AES_INT_OUT+6,AES_BOX_W
	move.w	AES_INT_OUT+8,AES_BOX_H
	rts

	
AES_wind_create:	
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_WIND_CREATE,AES_CONTROL
	move.w	#5,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_DEF_WINDOW_FLAGS,AES_INT_IN
	move.w	DESK_X,AES_INT_IN+2
	move.w	DESK_Y,AES_INT_IN+4
	move.w	DESK_W,AES_INT_IN+6
	move.w	DESK_H,AES_INT_IN+8
	jsr		_call_AES
	move.w	AES_INT_OUT,AES_WINDOW_HANDLE
	rts


AES_wind_open:	
    move.w  #FALSE,IS_FULLED
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_WIND_OPEN,AES_CONTROL
	move.w	#5,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	move.w	#AES_DEF_WINDOW_X,AES_INT_IN+2
	move.w	#AES_DEF_WINDOW_Y,AES_INT_IN+4
	move.w	#AES_DEF_WINDOW_W,AES_INT_IN+6
	move.w	#AES_DEF_WINDOW_H,AES_INT_IN+8
	jsr		_call_AES
	rts


AES_wind_set_title:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_WIND_SET,AES_CONTROL
	move.w	#6,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	AES_WINDOW_HANDLE,AES_INT_IN	
	move.w	#WF_NAME,AES_INT_IN+2
	move.l	#STR_WINDOW_TITLE,AES_INT_IN+4
	move.w	#0,AES_INT_IN+8
	move.w	#0,AES_INT_IN+10
	jsr		_call_AES
	rts
	

AES_wind_set_info:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_WIND_SET,AES_CONTROL
	move.w	#6,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	AES_WINDOW_HANDLE,AES_INT_IN	
	move.w	#WF_INFO,AES_INT_IN+2
	move.l	#STR_WINDOW_INFO,AES_INT_IN+4
	move.w	#0,AES_INT_IN+8
	move.w	#0,AES_INT_IN+10
	jsr		_call_AES
	rts


AES_wind_close:	
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_WIND_CLOSE,AES_CONTROL
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	jsr		_call_AES
	rts
	
	
AES_wind_delete:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_WIND_DELETE,AES_CONTROL
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	jsr		_call_AES
	rts
	
	
AES_wind_get_work_xywh:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_WIND_GET,AES_CONTROL
	move.w	#2,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#5,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	move.w	#WF_WORKXYWH,AES_INT_IN+2
	jsr		_call_AES
	move.w	AES_INT_OUT+2,WORK_X
	move.w	AES_INT_OUT+4,WORK_Y
	move.w	AES_INT_OUT+6,WORK_W
	move.w	AES_INT_OUT+8,WORK_H	
	rts


AES_wind_get_prev_xywh:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_WIND_GET,AES_CONTROL
	move.w	#2,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#5,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	move.w	#WF_PREVXYWH,AES_INT_IN+2
	jsr		_call_AES
	move.w	AES_INT_OUT+2,PREV_X
	move.w	AES_INT_OUT+4,PREV_Y
	move.w	AES_INT_OUT+6,PREV_W
	move.w	AES_INT_OUT+8,PREV_H	
	rts

	
AES_wind_get_full_xywh:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_WIND_GET,AES_CONTROL
	move.w	#2,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#5,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	move.w	#WF_FULLXYWH,AES_INT_IN+2
	jsr		_call_AES
	move.w	AES_INT_OUT+2,FULL_X
	move.w	AES_INT_OUT+4,FULL_Y
	move.w	AES_INT_OUT+6,FULL_W
	move.w	AES_INT_OUT+8,FULL_H
	rts


AES_wind_get_desk_xywh:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#AES_WIND_GET,AES_CONTROL
	move.w	#2,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#5,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	move.w	#0,AES_INT_IN
	move.w	#WF_WORKXYWH,AES_INT_IN+2
	jsr		_call_AES
	move.w	AES_INT_OUT+2,DESK_X
	move.w	AES_INT_OUT+4,DESK_Y
	move.w	AES_INT_OUT+6,DESK_W
	move.w	AES_INT_OUT+8,DESK_H
	rts


;--------------------------------------
; OS Call Routines
;--------------------------------------
	

_call_AES:
	move.l	#AES_PARAM_BLOCK,d1
	move.l	#AES_ID,d0
	trap	#2
	rts


_call_VDI:
	move.l	#VDI_PARAM_BLOCK,d1
	move.w	#VDI_OPCODE,d0
	trap	#2
	rts


;--------------------------------------		
	 section bss
;--------------------------------------

	even

STR_BUFFER:             ds.b	128			

	even

APP_ID:					ds.w	1

; AES Arrays

AES_CONTROL:			ds.w	5
AES_CONTROL_SZ			equ		5

AES_GLOBAL:				ds.w	9
AES_GLOBAL_SZ			equ		9

AES_INT_OUT:			ds.w	8
AES_INT_OUT_SZ			equ		8

AES_INT_IN:				ds.w	18
AES_INT_IN_SZ			equ		18

AES_ADDR_IN:			ds.l	3
AES_ADDR_IN_SZ			equ		3

AES_ADDR_OUT:			ds.l	2
AES_ADDR_OUT_SZ			equ		2

AES_PHYS_HANDLE:		ds.w	1
AES_BOX_W:				ds.w	1
AES_BOX_H:				ds.w	1
AES_CHAR_W:				ds.w	1
AES_CHAR_H:				ds.w	1
	
AES_WINDOW_HANDLE:		ds.w	1
AES_WIND_CREATE_RESULT:	ds.w	1
	
AES_MESSAGE:			ds.w	8
AES_MESSAGE_SZ			equ		8

; Window Dimensions

WORK_X:					ds.w	1
WORK_Y:					ds.w	1
WORK_W:					ds.w	1
WORK_H:					ds.w	1

PREV_X:					ds.w	1
PREV_Y:					ds.w	1
PREV_W:					ds.w	1
PREV_H:					ds.w	1

FULL_X:					ds.w	1
FULL_Y:					ds.w	1
FULL_W:					ds.w	1
FULL_H:					ds.w	1

DESK_X:					ds.w	1
DESK_Y:					ds.w	1
DESK_W:					ds.w	1
DESK_H:					ds.w	1

; VDI Other

SCREEN_RES:				ds.w	1
IS_FULLED:              ds.w    1

; VDI Arrays

VDI_WK_HANDLE:			ds.w	1

VDI_CONTROL:			ds.w	12
VDI_CONTROL_SZ			equ		12

VDI_ARRAY_SZ			equ		128

VDI_INT_IN:				ds.w	128
VDI_PTS_IN:				ds.w	128
VDI_INT_OUT:			ds.w	128
VDI_PTS_OUT:			ds.w	128


;--------------------------------------
	section data
;--------------------------------------

; Strings

	even

STR_WIND_CREATE_FAIL: 	
	dc.b	13,"Failed to create window",0
	
	even

STR_WIND_CREATE_SUCC:	
	dc.b	13,"Created window!",0
	
	even

STR_WINDOW_TITLE:
	dc.b	"Ash's AES Masterpiece",0
	
	even

STR_WINDOW_INFO:
	dc.b	"Glorious Informaty",0
	
	even

STR_AES_APPL_INIT_ERROR:
	dc.b	13,"Error in appl_init",0
	
	even

STR_VDI_OPNVWK_ERROR:
	dc.b	13,"Error in opnvwk",0
	
	even

; AES Parameter Vector

AES_PARAM_BLOCK:	
	dc.l	AES_CONTROL
    dc.l    AES_GLOBAL
	dc.l	AES_INT_IN
    dc.l    AES_INT_OUT
	dc.l	AES_ADDR_IN,AES_ADDR_OUT

; VDI Parameter Vector	

VDI_PARAM_BLOCK:
	dc.l	VDI_CONTROL
	dc.l	VDI_INT_IN
    dc.l    VDI_PTS_IN
	dc.l	VDI_INT_OUT
    dc.l    VDI_PTS_OUT


;--------------------------------------
; AES Constants
;--------------------------------------

AES_ID					EQU		200
AES_APPL_INIT			EQU 	10
AES_APPL_EXIT			EQU		19
AES_GRAF_HANDLE			EQU		77
AES_GRAF_MOUSE			EQU		78
AES_WIND_CREATE			EQU		100
AES_WIND_OPEN			EQU 	101
AES_WIND_CLOSE			EQU		102
AES_WIND_DELETE			EQU		103
AES_WIND_GET			EQU		104
AES_WIND_SET			EQU		105
AES_WIND_UPDATE         EQU     107

; Global Array Offests

AES_AP_VERSION 			EQU 	0
AES_AP_COUNT			EQU 	2
AES_AP_ID				EQU 	4
AES_AP_PRIVATE			EQU 	6
AES_AP_PTREE			EQU		10
AES_AP_1RESV			EQU 	14
AES_AP_2RESV			EQU		18
AES_AP_3RESV			EQU		22
AES_AP_4RESV			EQU		26

; Control Array Offsets

AES_CTRL_OPCODE			EQU		0
AES_CTRL_INT_IN			EQU		2
AES_CTRL_INT_OUT		EQU		4
AES_CTRL_ADDR_IN		EQU		6
AES_CTRL_ADDR_OUT		EQU		8

; Default Window Args

AES_DEF_WINDOW_X 		EQU 	20
AES_DEF_WINDOW_Y 		EQU 	20
AES_DEF_WINDOW_W		EQU 	200
AES_DEF_WINDOW_H		EQU 	200
AES_DEF_WINDOW_FLAGS	EQU 	$2F

;--------------------------------------
; VDI Constants
;--------------------------------------

VDI_CLRWK               EQU     3
VDI_CURTEXT				EQU		5
VDI_CURTEXT_SUB			EQU		12

VDI_OPNVWK				EQU		100
VDI_CLSWK               EQU     101
VDI_OPCODE				EQU		115

VSF_COLOR               EQU     25
VR_RECFL                EQU     114
HIDE_MOUSE              EQU     256
SHOW_MOUSE              EQU     257

; VDI contrl offsets

VDI_CTRL_OPCODE			EQU		0
VDI_CTRL_PTS_IN			EQU 	2
VDI_CTRL_PTS_OUT		EQU		4
VDI_CTRL_INT_IN			EQU		6
VDI_CTRL_INT_OUT		EQU		8
VDI_CTRL_SUB_FUNC		EQU		10
VDI_CTRL_DEV_HANDLE		EQU		12

;--------------------------------------
; Events
;--------------------------------------

EVENT_MESSAG            EQU     23
EVENT_MN_SELECTED		EQU 	10
EVENT_WM_REDRAW			EQU		20
EVENT_WM_TOPPED			EQU		21
EVENT_WM_CLOSED			EQU		22
EVENT_WM_FULLED			EQU		23
EVENT_WM_ARROWED		EQU		24
EVENT_WM_HSLID			EQU		25
EVENT_WM_VSLID			EQU		26
EVENT_WM_SIZED			EQU		27
EVENT_WM_MOVED			EQU		28
EVENT_WM_NEWTOP			EQU		29
EVENT_AC_OPEN			EQU		40
EVENT_AC_CLOSE			EQU		41

;--------------------------------------
; WF_STUFF
;--------------------------------------

WF_KIND					EQU		1
WF_NAME					EQU		2
WF_INFO					EQU		3
WF_WORKXYWH				EQU		4
WF_CURRXYWH				EQU		5
WF_PREVXYWH				EQU		6
WF_FULLXYWH				EQU		7

END_UPDATE              EQU     0
BEG_UPDATE              EQU     1

NDC_COORDS              EQU     0
RASTER_COORDS           EQU     2

FALSE                   EQU     $FFFF
TRUE                    EQU     $1111

MOUSE_ARROW             EQU 0	;   Arrow
MOUSE_TEXT_CRSR         EQU 1	;   Text cursor
MOUSE_HOURGLASS         EQU 2	;   Hourglass, bee
MOUSE_BUSY_BEE          EQU 2	;   See HOURGLASS
MOUSE_BUSYBEE           EQU 2	;   See HOURGLASS
MOUSE_POINT_HAND        EQU 3	;   Pointing hand
MOUSE_FLAT_HAND         EQU 4	;   Flat hand
MOUSE_THIN_CROSS        EQU 5	;   Thin crosshairs
MOUSE_THICK_CROSS       EQU 6	;   Thick crosshairs
MOUSE_OUTLN_CROSS       EQU 7	;   Outlined crosshairs

;--------------------------------------
;	Includes
;--------------------------------------

	include	"../INCDIR/ASCII.S"
	include	"../INCDIR/GEMDOS.S"
	include	"../INCDIR/XBIOS.S"
