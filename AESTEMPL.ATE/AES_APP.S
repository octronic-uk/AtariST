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
	jsr		VDI_open_v_ws
	jsr		AES_wind_create
	jsr		AES_wind_set_title
	jsr		AES_wind_set_info
	jsr		AES_wind_open
	
main_loop:
	jsr		AES_event_messag
	
main_check_sized:
	move.w	AES_MESSAGE,d1
	cmpi.w	#27,d1
	bne		main_check_redraw
	jsr		AES_event_wm_sized
	
main_check_redraw:
	move.w	AES_MESSAGE,d1
	cmpi.w	#20,d1
	bne		main_check_moved
	jsr		AES_event_wm_redraw
	
main_check_moved:
	move.w	AES_MESSAGE,d1
	cmpi.w	#28,d1
	bne		main_check_close
	jsr		AES_event_wm_moved
	
main_check_close:	
	move.w	AES_MESSAGE,d1
	cmpi.w	#22,d1	; wm_closed
	beq		main_exit
	
main_next:
	; Loop	
	jmp		main_loop
	
main_exit:
	jsr		AES_wind_close
	jsr		AES_wind_delete
	jsr		VDI_close_v_ws
	jsr		AES_appl_exit
	move.w	#GEMDOS_PTERM0,-(sp)
	trap	#TRAP_GEMDOS
	

;--------------------------------------
; GEM/VDI Library Functions
;--------------------------------------
VDI_open_v_ws:
	move.w	#XBIOS_GETRES,-(sp)		; Call XBIOS to get resolution
	trap	#TRAP_XBIOS
	addq.l	#2,sp
	addq.w	#2,d0					; Add 2 to correct res. Just cos?
	move.w	d0,VDI_SCREEN_DEVICE
	; Setup VDI work_in
	movea.l	#VDI_WORK_IN,a0			; VDI Input block in a0
	move.w	VDI_SCREEN_DEVICE,(a0)	; Move into VDI Input Args
	move.w	#1,2(a0)
	move.w	#1,4(a0)
	move.w	#1,6(a0)
	move.w	#1,8(a0)
	move.w	#2,10(a0)				; Select raster coordinates mode
	; Setup VDI control block
	movea.l	#VDI_CONTROL,a0
	move.w	#VDI_OPNVWK,(a0)		; Set Opcode
	move.w	#0,VDI_CTRL_PTS_IN(a0)	; No pts in
	move.w	#0,VDI_CTRL_INT_IN(a0)	; no ints in
	move.w	VDI_SCREEN_DEVICE,VDI_CTRL_DEV_HANDLE(a0)
	move.l	#VDI_WORK_IN,14(a0)
	move.l	AES_PHYS_HANDLE,18(a0)
	move.l	#VDI_WORK_OUT,22(a0)	
	jsr		_call_VDI
	rts

VDI_close_v_ws:
	movea.l	#VDI_CONTROL,a0
	move.w	#101,(a0)				; v_clsvwk opcode
	move.w	#0,2(a0)
	move.w	#0,6(a0)
	jsr		_call_VDI
	rts

VDI_Debug:	
	clr.l	d0		 				; Store strlen in d0
	movea.l	4(sp),a0 				; Get string address
	movea.l	#VDI_INT_IN,a1			; Copy string into int_in

_VDI_Debug_strlen:
	addq.l	#1,a1
	move.b	(a0)+,(a1)+
	addq.l	#1,d0 					; strlen
	cmpi.b	#0,(a0)					; Is next char \0 ?
	beq		_VDI_Debug_strlen_done
	jmp		_VDI_Debug_strlen

_VDI_Debug_strlen_done:	
	movea.l	#VDI_CONTROL,a0
	move.w	#VDI_CURTEXT,(a0)
	move.w	#0,VDI_CTRL_PTS_IN(a0)
	move.w	#0,VDI_CTRL_PTS_OUT(a0)
	subq.w	#1,d0
	move.w	d0,VDI_CTRL_INT_IN(a0)	; String Length
	move.w	#0,VDI_CTRL_INT_OUT(a0)
	move.w	#VDI_CURTEXT_SUB,VDI_CTRL_SUB_FUNC(a0)
	move.w	VDI_SCREEN_DEVICE,VDI_CTRL_DEV_HANDLE(a0)
	jsr		_call_VDI
	rts

VDI_fill_bg_white:
	; Set colour to white
	movea.l	#VDI_CONTROL,a0
	move.w	#25,(a0)				; vsf_color
	move.w	#0,VDI_CTRL_PTS_IN(a0)
	move.w	#0,VDI_CTRL_PTS_OUT(a0)
	move.w	#1,VDI_CTRL_INT_IN(a0)
	move.w	#1,VDI_CTRL_INT_OUT(a0)
	move.w	VDI_SCREEN_DEVICE,VDI_CTRL_DEV_HANDLE(a0)
	move.w	#0,VDI_INT_IN
	jsr _call_VDI
	
	; Make call to vr_recfl
	movea.l	#VDI_CONTROL,a0
	move.w	#114,(a0)				; vr_recfl (rectangle fill)
	move.w	#2,VDI_CTRL_PTS_IN(a0)
	move.w	#0,VDI_CTRL_PTS_OUT(a0)
	move.w	#0,VDI_CTRL_INT_IN(a0)
	move.w	#0,VDI_CTRL_INT_OUT(a0)
	move.w	VDI_SCREEN_DEVICE,VDI_CTRL_DEV_HANDLE(a0)
	movea.l	#VDI_PTS_IN,a0
	move.w	WORK_X,(a0)				; Draw From	X,	Y
	move.w	WORK_Y,2(a0)			; Draw To 	X+W,Y+H
	move.w	WORK_X,d0
	add.w	WORK_W,d0
	move.w	d0,4(a0)
	move.w	WORK_Y,d0
	add.w	WORK_H,d0
	move.w	d0,6(a0)	
	jsr		_call_VDI
	rts

;--------------------------------------
;	AES Library Functions
;--------------------------------------

AES_appl_init:
	movea.l	#AES_CONTROL,a0
	move.w	#AES_APPL_INIT,(a0)
	move.w	#0,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	jsr		_call_AES
	rts

AES_appl_exit:
	movea.l	#AES_CONTROL,a0
	move.w	#AES_APPL_EXIT,(a0)
	move.w	#0,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	jsr		_call_AES
	rts
	
AES_event_messag:
	movea.l	#AES_CONTROL,a0
	move.w	#23,(a0)		; event_messag
	move.w	#0,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#1,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	move.l	#AES_MESSAGE,AES_ADDR_IN
	jsr		_call_AES
	movea.l	#AES_CONTROL,a0
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	rts

AES_event_wm_sized:
	movea.l	#AES_CONTROL,a0
	move.w	#AES_WIND_SET,(a0)
	move.w	#6,AES_CTRL_INT_IN(a0)
	movea.l	#AES_INT_IN,a0
	movea.l	#AES_MESSAGE,a1
	move.w	6(a1),(a0)		; window handle
	move.w	#5,2(a0)		;set size subcommand
	move.w	8(a1),4(a0)
	move.w	10(a1),6(a0)
	move.w	12(a1),8(a0)
	move.w	14(a1),10(a0)
	jsr		_call_AES
	rts

AES_event_wm_moved:
	movea.l	#AES_CONTROL,a0
	move.w	#AES_WIND_SET,(a0)
	move.w	#6,AES_CTRL_INT_IN(a0)
	movea.l	#AES_INT_IN,a0
	movea.l	#AES_MESSAGE,a1
	move.w	6(a1),(a0)		; window handle
	move.w	#5,2(a0)		;set size subcommand
	move.w	8(a1),4(a0)
	move.w	10(a1),6(a0)
	move.w	12(a1),8(a0)
	move.w	14(a1),10(a0)
	jsr		_call_AES
	rts

AES_event_wm_redraw:	
	; Lock AES
	jsr		AES_graf_mouse_hide
	jsr		AES_wind_update_begin
	; Perform Refresh
	jsr		AES_wind_get_work_xywh
	jsr		VDI_fill_bg_white
	; Unlock AES
	jsr		AES_wind_update_end
	jsr		AES_graf_mouse_show
	rts

AES_wind_update_begin:
	movea.l	#AES_CONTROL,a0
	move.w	#107,(a0)				; wind_update
	move.w	#1,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#1,AES_INT_IN			; BEG_UPDATE
	jsr		_call_AES
	rts
	
AES_wind_update_end:
	movea.l	#AES_CONTROL,a0
	move.w	#107,(a0)
	move.w	#1,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_INT_IN
	jsr		_call_AES
	rts

AES_graf_mouse_hide:
	movea.l	#AES_CONTROL,a0				; Setup control block
	move.w	#AES_GRAF_MOUSE,(a0)
	move.w	#1,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#256,AES_INT_IN
	jsr		_call_AES
	rts
	
AES_graf_mouse_show:
	movea.l	#AES_CONTROL,a0				; Setup control block
	move.w	#AES_GRAF_MOUSE,(a0)
	move.w	#1,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#257,AES_INT_IN
	jsr		_call_AES
	rts

AES_graf_handle:
	movea.l	#AES_CONTROL,a0				; Setup control block
	move.w	#AES_GRAF_HANDLE,(a0)
	move.w	#0,AES_CTRL_INT_IN(a0)
	move.w	#5,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	jsr		_call_AES
	movea.l	#AES_INT_OUT,a0				; Store return values
	move.w	(a0),AES_PHYS_HANDLE	
	move.w	2(a0),AES_CHAR_W
	move.w	4(a0),AES_CHAR_H
	move.w	6(a0),AES_BOX_W
	move.w	8(a0),AES_BOX_H
	rts
	
AES_wind_create:
	movea.l	#AES_CONTROL,a0				; Set up Control Block
	move.w	#AES_WIND_CREATE,(a0)
	move.w	#5,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	movea.l	#AES_INT_IN,a0				; Set up int_in block
	move.w	#AES_DEF_WINDOW_FLAGS,(a0)	; wi_crkind	- Window Kind
	move.w	#AES_DEF_WINDOW_X,2(a0)		; wi_crwx - Window X
	move.w	#AES_DEF_WINDOW_H,4(a0)		; wi_crwy - Window Y
	move.w	#AES_DEF_WINDOW_W,6(a0)		; wi_crww - Window Width
	move.w	#AES_DEF_WINDOW_H,8(a0) 	; wi_crwh - Window Height
	move.w	#0,AES_INT_OUT				; Set up int_out block
	jsr		_call_AES
	move.w	AES_INT_OUT,AES_WINDOW_HANDLE
	rts

AES_wind_open:
	movea.l	#AES_CONTROL,a0
	move.w	#AES_WIND_OPEN,(a0)
	move.w	#5,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	movea.l	#AES_INT_IN,a0
	move.w	AES_WINDOW_HANDLE,(a0)
	move.w	#AES_DEF_WINDOW_X,2(a0)
	move.w	#AES_DEF_WINDOW_Y,4(a0)
	move.w	#AES_DEF_WINDOW_W,6(a0)
	move.w	#AES_DEF_WINDOW_H,8(a0)
	jsr		_call_AES
	rts

AES_wind_set_title:
	movea.l	#AES_CONTROL,a0
	move.w	#AES_WIND_SET,(a0)
	move.w	#6,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	
	movea.l	#AES_INT_IN,a0
	move.w	AES_WINDOW_HANDLE,(a0)	
	move.w	#2,2(a0) ; WF_NAME
	move.l	#STR_WINDOW_TITLE,4(a0)
	move.w	#0,8(a0)
	move.w	#0,10(a0)
	jsr		_call_AES
	rts
	
AES_wind_set_info:
	movea.l	#AES_CONTROL,a0
	move.w	#AES_WIND_SET,(a0)
	move.w	#6,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	
	movea.l	#AES_INT_IN,a0
	move.w	AES_WINDOW_HANDLE,(a0)	
	move.w	#3,2(a0) ; WF_INFO
	move.l	#STR_WINDOW_INFO,4(a0)
	move.w	#0,8(a0)
	move.w	#0,10(a0)
	jsr		_call_AES
	rts

AES_wind_close:
	movea.l	#AES_CONTROL,a0
	move.w	#AES_WIND_CLOSE,(a0)
	move.w	#1,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	jsr		_call_AES
	rts
	
AES_wind_delete:
	movea.l	#AES_CONTROL,a0
	move.w	#AES_WIND_DELETE,(a0)
	move.w	#1,AES_CTRL_INT_IN(a0)
	move.w	#1,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	jsr		_call_AES
	rts
	
AES_wind_get_work_xywh:
	movea.l	#AES_CONTROL,a0
	move.w	#AES_WIND_GET,(a0)
	move.w	#2,AES_CTRL_INT_IN(a0)
	move.w	#5,AES_CTRL_INT_OUT(a0)
	move.w	#0,AES_CTRL_ADDR_IN(a0)
	move.w	#0,AES_CTRL_ADDR_OUT(a0)
	
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	move.w	#4,AES_INT_IN+2			; WF_WORKXYWH
	
	jsr		_call_AES
	
	; Save Results
	move.w	AES_INT_OUT+2,WORK_X
	move.w	AES_INT_OUT+4,WORK_Y
	move.w	AES_INT_OUT+6,WORK_W
	move.w	AES_INT_OUT+8,WORK_H	
	
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
	section data
;--------------------------------------

; AES Parameter Vector

AES_PARAM_BLOCK:	
	dc.l	AES_CONTROL
	dc.l	AES_GLOBAL
	dc.l	AES_INT_IN
	dc.l	AES_INT_OUT
	dc.l	AES_ADDR_IN
	dc.l	AES_ADDR_OUT


; VDI Parameter Vector

VDI_PARAM_BLOCK:
	dc.l	VDI_CONTROL
	dc.l	VDI_INT_IN
	dc.l	VDI_PTS_IN
	dc.l	VDI_INT_OUT
	dc.l	VDI_PTS_OUT

; Strings

STR_WIND_CREATE_FAIL: 	
	dc.b	"Failed to create window",0
	even
	
STR_WIND_CREATE_SUCC:	
	dc.b	"Created window!",0
	even
	
STR_WINDOW_TITLE:
	dc.b	"Window Title",0
	even

STR_WINDOW_INFO:
	dc.b	"Window Information",0
	even

;--------------------------------------		
	section bss
;--------------------------------------

; AES Arrays

AES_GLOBAL:				ds.w	15
AES_CONTROL:			ds.w	5
AES_INT_IN:				ds.w	16
AES_ADDR_IN:			ds.l	2
AES_INT_OUT:			ds.w	7
AES_ADDR_OUT:			ds.l	1

AES_PHYS_HANDLE:		ds.w	1
AES_BOX_W:				ds.w	1
AES_BOX_H:				ds.w	1
AES_CHAR_W:				ds.w	1
AES_CHAR_H:				ds.w	1
	
AES_WINDOW_HANDLE		ds.w	1
AES_WIND_CREATE_RESULT:	ds.w	1	

AES_MESSAGE				ds.w	8

; Window Dimensions

WORK_X:					ds.w	1
WORK_Y:					ds.w	1
WORK_W:					ds.w	1
WORK_H:					ds.w	1

; VDI Other

VDI_SCREEN_DEVICE:		ds.w	1

; VDI Arrays

VDI_WORK_IN:			ds.w	12
VDI_WORK_OUT:			ds.w	57
VDI_HANDLE:				ds.w	1

VDI_CONTROL:			ds.w	12
VDI_PTS_IN:				ds.w	128
VDI_PTS_OUT:			ds.w	128
VDI_INT_IN:				ds.w	128
VDI_INT_OUT:			ds.w	128

;--------------------------------------
; AES Constants
;--------------------------------------

AES_ID					EQU	200
AES_APPL_INIT			EQU 10
AES_APPL_EXIT			EQU	19
AES_GRAF_HANDLE			EQU	77
AES_GRAF_MOUSE			EQU	78
AES_WIND_CREATE			EQU	100
AES_WIND_OPEN			EQU 101
AES_WIND_CLOSE			EQU	102
AES_WIND_DELETE			EQU	103
AES_WIND_GET			EQU	104
AES_WIND_SET			EQU	105

; Global Array Offests

AES_AP_VERSION 			EQU 0
AES_AP_COUNT			EQU 2
AES_AP_ID				EQU 4
AES_AP_PRIVATE			EQU 6
AES_AP_PTREE			EQU	10
AES_AP_1RESV			EQU 14
AES_AP_2RESV			EQU	18
AES_AP_3RESV			EQU	22
AES_AP_4RESV			EQU	26

; Control Array Offsets

AES_CTRL_OPCODE			EQU	0
AES_CTRL_INT_IN			EQU	2
AES_CTRL_INT_OUT		EQU	4
AES_CTRL_ADDR_IN		EQU	6
AES_CTRL_ADDR_OUT		EQU	8

; Default Window Args

AES_DEF_WINDOW_X 		EQU 20
AES_DEF_WINDOW_Y 		EQU 20
AES_DEF_WINDOW_W		EQU 200
AES_DEF_WINDOW_H		EQU 200
AES_DEF_WINDOW_FLAGS	EQU $2F

;--------------------------------------
; VDI Constants
;--------------------------------------

VDI_CURTEXT				EQU	5
VDI_CURTEXT_SUB			EQU	12
VDI_OPNVWK				EQU	100
VDI_OPCODE				EQU	115

; VDI contrl offsets

VDI_CTRL_OPCODE			EQU	0
VDI_CTRL_PTS_IN			EQU 2
VDI_CTRL_PTS_OUT		EQU	4
VDI_CTRL_INT_IN			EQU	6
VDI_CTRL_INT_OUT		EQU	8
VDI_CTRL_SUB_FUNC		EQU	10
VDI_CTRL_DEV_HANDLE		EQU	12

;--------------------------------------
; Events
;--------------------------------------

EVENT_MN_SELECTED	EQU 10
EVENT_WM_REDRAW		EQU	20
EVENT_WM_TOPPED		EQU	21
EVENT_WM_CLOSED		EQU	22
EVENT_WM_FULLED		EQU	23
EVENT_WM_ARROWED	EQU	24
EVENT_WM_HSLID		EQU	25
EVENT_WM_VSLID		EQU	26
EVENT_WM_SIZED		EQU	27
EVENT_WM_MOVED		EQU	28
EVENT_WM_NEWTOP		EQU	29
EVENT_AC_OPEN		EQU	40
EVENT_AC_CLOSE		EQU	41

;--------------------------------------
;	Includes
;--------------------------------------

	include	"GEMDOS.S"
	include	"XBIOS.S"