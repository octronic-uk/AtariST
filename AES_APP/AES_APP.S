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
	jsr		AES_wind_get_prev_xywh
	jsr		AES_wind_get_full_xywh
	jsr		AES_event_wm_fulled
	
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

	move.w	#XBIOS_GETRES,-(sp)		; Call XBIOS to get resolution
	trap	#TRAP_XBIOS
	addq.l	#2,sp
	addq.w	#2,d0					; Add 2 to correct res
	move.w	d0,SCREEN_RES			; Store screen res
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
	pea		VDI_CONTROL			; Zero VDI_CONTROL
	move.w	#VDI_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
		
	lea		VDI_CONTROL,a0
	move.w	#VDI_OPNVWK,(a0)
	move.w	#11,VDI_CTRL_INT_IN(a0)
	move.w	#0,VDI_CTRL_PTS_IN(a0)
	move.w	AES_PHYS_HANDLE,12(a0)
	
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
	move.w	#2,VDI_INT_IN+20   ; Raster Coordinates
	jsr		_call_VDI
	
	move.w	VDI_CONTROL+12,VDI_WK_HANDLE
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
	
	move.w	#3,VDI_CONTROL
	move.w	#0,VDI_CONTROL+2
	move.w	#0,VDI_CONTROL+6
	jsr		_call_VDI
	rts

	
VDI_clsvwk:

	pea 	VDI_CONTROL
	move.w	#VDI_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	lea		VDI_CONTROL,a0
	move.w	#101,(a0)				; v_clsvwk opcode
	move.w	#0,2(a0)
	move.w	#0,6(a0)
	jsr		_call_VDI
	rts


VDI_set_bg_white:

	; Set colour to white
	
	pea 	VDI_CONTROL
	move.w	#VDI_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	lea		VDI_CONTROL,a0
	move.w	#25,(a0)				; vsf_color
	move.w	#0,VDI_CTRL_PTS_IN(a0)
	move.w	#0,VDI_CTRL_PTS_OUT(a0)
	move.w	#1,VDI_CTRL_INT_IN(a0)
	move.w	#1,VDI_CTRL_INT_OUT(a0)
	move.w	VDI_WK_HANDLE,VDI_CTRL_DEV_HANDLE(a0)
	move.w	#0,VDI_INT_IN
	
	jsr 	_call_VDI
	
	rts

	
VDI_fill_bg_rect:
	; Make call to vr_recfl
	
	pea 	VDI_CONTROL
	move.w	#VDI_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	lea		VDI_CONTROL,a0
	move.w	#114,(a0)				; vr_recfl (rectangle fill)
	move.w	#2,VDI_CTRL_PTS_IN(a0)
	move.w	#0,VDI_CTRL_PTS_OUT(a0)
	move.w	#0,VDI_CTRL_INT_IN(a0)
	move.w	#0,VDI_CTRL_INT_OUT(a0)
	move.w	VDI_WK_HANDLE,VDI_CTRL_DEV_HANDLE(a0)
	
	lea		VDI_PTS_IN,a0	
	move.w	WORK_X,(a0)		; X
	move.w	WORK_Y,2(a0)	; Y
	move.w	WORK_X,d0		; W
	add.w	WORK_W,d0
	move.w	d0,4(a0)
	move.w	WORK_Y,d0		; H
	add.w	WORK_H,d0
	move.w	d0,6(a0)	
	
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

	lea		AES_CONTROL,a0
	move.w	#AES_APPL_INIT,(a0)
	move.w	#0,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	
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
	
	lea		AES_CONTROL,a0
	move.w	#AES_APPL_EXIT,(a0)
	move.w	#0,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	jsr		_call_AES
	rts
	
AES_event_messag:
	
	pea 	AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	lea		AES_CONTROL,a0
	move.w	#23,(a0)		; event_messag
	move.w	#0,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#1,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	move.l	#AES_MESSAGE,AES_ADDR_IN
	
	jsr		_call_AES
	
	lea		AES_CONTROL,a0
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	rts

AES_event_wm_sized:

	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp

	lea		AES_CONTROL,a0
	move.w	#AES_WIND_SET,(a0)
	move.w	#6,AES_CTRL_INT_IN(a0)
	
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	lea		AES_INT_IN,a0
	
	lea		AES_MESSAGE,a1
	move.w	6(a1),(a0)		; window handle
	move.w	#5,2(a0)		; set size subcommand
	move.w	8(a1),4(a0)
	move.w	10(a1),6(a0)
	move.w	12(a1),8(a0)
	move.w	14(a1),10(a0)
	jsr		_call_AES
	rts
	
AES_event_wm_fulled:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp

	lea		AES_CONTROL,a0
	move.w	#AES_WIND_SET,(a0)
	move.w	#6,AES_CTRL_INT_IN(a0)
	
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	move.w	AES_MESSAGE+6,AES_INT_IN	; window handle
	move.w	#WF_CURRXYWH,AES_INT_IN+2	; set size subcommand
	move.w	FULL_Y,AES_INT_IN+4
	move.w	FULL_H,AES_INT_IN+6
	move.w	FULL_X,AES_INT_IN+8
	move.w	FULL_W,AES_INT_IN+10
	
	jsr		_call_AES
	
	rts


AES_event_wm_moved:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	lea		AES_CONTROL,a0
	move.w	#AES_WIND_SET,(a0)
	move.w	#6,AES_CTRL_INT_IN(a0)
	
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	lea	AES_INT_IN,a0
	lea AES_MESSAGE,a1
	move.w	6(a1),(a0)		; window handle
	move.w	#5,2(a0)		;set size subcommand
	move.w	8(a1),4(a0)
	move.w	10(a1),6(a0)
	move.w	12(a1),8(a0)
	move.w	14(a1),10(a0)
	jsr		_call_AES
	rts


AES_event_wm_redraw:		
	jsr		AES_graf_mouse_hide     ; Lock AES
	jsr		AES_wind_update_begin   ; Perform Refresh
	jsr		AES_wind_get_work_xywh
	jsr		VDI_set_bg_white
	jsr		VDI_fill_bg_rect
	jsr		AES_wind_update_end     ; Unlock AES
	jsr		AES_graf_mouse_show
	rts


AES_wind_update_begin:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp

	lea		AES_CONTROL,a0
	move.w	#107,(a0)				; wind_update
	move.w	#1,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#1,AES_INT_IN			; BEG_UPDATE
	
	jsr		_call_AES
	
	rts

	
AES_wind_update_end:	
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	lea		AES_CONTROL,a0
	move.w	#107,(a0)				; wind_update
	move.w	#1,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	move.w	#0,AES_INT_IN			; END_UPDATE
	
	jsr		_call_AES
	
	rts


AES_graf_mouse_hide:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	lea		AES_CONTROL,a0
	move.w	#AES_GRAF_MOUSE,(a0)
	move.w	#1,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	move.w	#256,AES_INT_IN
	jsr		_call_AES
	rts
	
	
AES_graf_mouse_show:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	lea		AES_CONTROL,a0
	move.w	#AES_GRAF_MOUSE,(a0)
	move.w	#1,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	move.w	#257,AES_INT_IN
	
	
	jsr		_call_AES
	rts


AES_graf_handle:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp

	lea		AES_CONTROL,a0	
	move.w	#AES_GRAF_HANDLE,(a0)
	move.w	#0,AES_CTRL_INT_IN(a0)
	move.w	#5,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	
	pea		AES_INT_OUT
	move.w	#AES_INT_OUT_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	jsr		_call_AES
	
	lea		AES_INT_OUT,a0	
	move.w	(a0),AES_PHYS_HANDLE	
	move.w	2(a0),AES_CHAR_W
	move.w	4(a0),AES_CHAR_H
	move.w	6(a0),AES_BOX_W
	move.w	8(a0),AES_BOX_H
	
	rts

	
AES_wind_create:	
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp

	lea		AES_CONTROL,a0				; Set up Control Block
	move.w	#AES_WIND_CREATE,(a0)
	move.w	#5,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	lea		AES_INT_IN,a0				; Set up int_in block
	move.w	#AES_DEF_WINDOW_FLAGS,(a0)	; wi_crkind	- Window Kind
	move.w	#AES_DEF_WINDOW_X,2(a0)		; wi_crwx - Window X
	move.w	#AES_DEF_WINDOW_H,4(a0)		; wi_crwy - Window Y
	move.w	#AES_DEF_WINDOW_W,6(a0)		; wi_crww - Window Width
	move.w	#AES_DEF_WINDOW_H,8(a0) 	; wi_crwh - Window Height
	
	;move.w	#0,AES_INT_OUT				; Set up int_out block
	
	jsr		_call_AES
	
	move.w	AES_INT_OUT,AES_WINDOW_HANDLE
	
	rts


AES_wind_open:	
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	lea		AES_CONTROL,a0
	move.w	#AES_WIND_OPEN,(a0)
	move.w	#5,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	lea		AES_INT_IN,a0
	move.w	AES_WINDOW_HANDLE,(a0)
	move.w	#AES_DEF_WINDOW_X,2(a0)
	move.w	#AES_DEF_WINDOW_Y,4(a0)
	move.w	#AES_DEF_WINDOW_W,6(a0)
	move.w	#AES_DEF_WINDOW_H,8(a0)
	
	jsr		_call_AES
	
	rts


AES_wind_set_title:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	lea		AES_CONTROL,a0
	move.w	#AES_WIND_SET,(a0)
	move.w	#6,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	lea		AES_INT_IN,a0
	move.w	AES_WINDOW_HANDLE,(a0)	
	move.w	#2,2(a0) ; WF_NAME
	move.l	#STR_WINDOW_TITLE,4(a0)
	move.w	#0,8(a0)
	move.w	#0,10(a0)
	jsr		_call_AES
	rts
	
AES_wind_set_info:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp

	lea		AES_CONTROL,a0
	move.w	#AES_WIND_SET,(a0)
	move.w	#6,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	lea		AES_INT_IN,a0
	move.w	AES_WINDOW_HANDLE,(a0)	
	move.w	#WF_INFO,2(a0) ; 
	move.l	#STR_WINDOW_INFO,4(a0)
	move.w	#0,8(a0)
	move.w	#0,10(a0)
	
	jsr		_call_AES
	
	rts


AES_wind_close:	
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	lea		AES_CONTROL,a0
	move.w	#AES_WIND_CLOSE,(a0)
	move.w	#1,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	
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

	lea		AES_CONTROL,a0
	move.w	#AES_WIND_DELETE,(a0)
	move.w	#1,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	
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

	lea		AES_CONTROL,a0
	move.w	#AES_WIND_GET,(a0)
	move.w	#2,AES_CTRL_INT_IN(a0)
	move.w	#5,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	move.w	#WF_WORKXYWH,AES_INT_IN+2			; 
	
	jsr		_call_AES
	
	move.w	AES_INT_OUT+2,WORK_X    ; Save Results
	move.w	AES_INT_OUT+4,WORK_Y
	move.w	AES_INT_OUT+6,WORK_W
	move.w	AES_INT_OUT+8,WORK_H	
	
	rts


AES_wind_get_prev_xywh:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp

	lea		AES_CONTROL,a0
	move.w	#AES_WIND_GET,(a0)
	move.w	#2,AES_CTRL_INT_IN(a0)
	move.w	#5,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	move.w	#WF_PREVXYWH,AES_INT_IN+2			; 
	
	jsr		_call_AES
	
	move.w	AES_INT_OUT+2,PREV_X    ; Save Results
	move.w	AES_INT_OUT+4,PREV_Y
	move.w	AES_INT_OUT+6,PREV_W
	move.w	AES_INT_OUT+8,PREV_H	
	
	rts

	
AES_wind_get_full_xywh:
	pea		AES_CONTROL
	move.w	#AES_CONTROL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp

	lea		AES_CONTROL,a0
	move.w	#AES_WIND_GET,(a0)
	move.w	#2,AES_CTRL_INT_IN(a0)
	move.w	#5,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	
	pea		AES_INT_IN
	move.w	#AES_INT_IN_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
	
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	move.w	#WF_FULLXYWH,AES_INT_IN+2			; 
	
	jsr		_call_AES
	
	move.w	AES_INT_OUT+2,FULL_X    ; Save Results
	move.w	AES_INT_OUT+4,FULL_Y
	move.w	AES_INT_OUT+6,FULL_W
	move.w	AES_INT_OUT+8,FULL_H	
	
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


; VDI Other

SCREEN_RES:				ds.w	1

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
	dc.b	"Window Title",0
	
	even

STR_WINDOW_INFO:
	dc.b	"Window Information",0
	
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

VDI_CURTEXT				EQU		5
VDI_CURTEXT_SUB			EQU		12
VDI_OPNVWK				EQU		100
VDI_OPCODE				EQU		115

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

;--------------------------------------
;	Includes
;--------------------------------------

	include	"ASCII.S"
	include	"GEMDOS.S"
	include	"XBIOS.S"
