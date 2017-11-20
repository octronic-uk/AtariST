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
; Your Application Here
;--------------------------------------
main:
	jsr AES_appl_init
	jsr AES_graf_handle	
	jsr	VDI_open_v_workstation
	JSR	AES_wind_create
	jsr AES_appl_exit
	
exit_from_main:
	move.w	#GEMDOS_PTERM0,-(sp)
	trap	#TRAP_GEMDOS

;--------------------------------------
; GEM/VDI Library Functions
;--------------------------------------
VDI_open_v_workstation:
	move.w	#XBIOS_GETRES,-(sp)	; Call XBIOS to get resolution
	trap	#TRAP_XBIOS
	addq.l	#2,sp
	addq.w	#2,d0				; Add 2 to correct res. Just cos?
	move.w	d0,SCREEN_DEVICE
	
	; Setup VDI work_in
	
	movea.l	#VDI_WORK_IN,a0		; VDI Input block in a0
	move.w	SCREEN_DEVICE,(a0)	; Move into VDI Input Args
	move.w	#1,2(a0)
	move.w	#1,4(a0)
	move.w	#1,6(a0)
	move.w	#1,8(a0)
	move.w	#2,10(a0)			; Select raster coordinates mode
	
	; Setup VDI control block
	movea.l	#VDI_CONTROL,a0
	move.w	#VDI_OPNVWK,(a0)		; Set Opcode
	move.w	#0,VDI_CTRL_PTS_IN(a0)	; No pts in
	move.w	#0,VDI_CTRL_INT_IN(a0)	; no ints in
	move.w	SCREEN_DEVICE,VDI_CTRL_DEV_HANDLE(a0)
	
	move.l	#VDI_WORK_IN,14(a0)
	move.l	AES_PHYS_HANDLE,18(a0)
	move.l	#VDI_WORK_OUT,22(a0)
	
	jsr	_call_VDI
	
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
	
	movea.l	#AES_CONTROL,a0			; Set up Control Block
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
	
	move.w	AES_INT_OUT,AES_WIND_CREATE_RESULT
	rts

AES_wind_handle:
	rts

AES_wind_open:
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

;--------------------------------------		
	section bss
;--------------------------------------

; AES Arrays
AES_GLOBAL:			ds.w	15
AES_CONTROL:		ds.w	5
AES_INT_IN:			ds.w	16
AES_ADDR_IN:		ds.l	2
AES_INT_OUT:		ds.w	7
AES_ADDR_OUT:		ds.l	1

AES_PHYS_HANDLE:		ds.w	1
AES_BOX_W:				ds.w	1
AES_BOX_H:				ds.w	1
AES_CHAR_W:				ds.w	1
AES_CHAR_H:				ds.w	1

AES_WINDOW_HANDLE		ds.w	1
AES_WIND_CREATE_RESULT:	ds.w	1	
; Other
SCREEN_DEVICE:			ds.w	1

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

AES_ID				EQU	200
AES_APPL_INIT		EQU 10
AES_APPL_EXIT		EQU	19
AES_GRAF_HANDLE		EQU	77
AES_WIND_CREATE		EQU	100
; Global Array Offests
AES_AP_VERSION 		EQU 0
AES_AP_COUNT		EQU 2
AES_AP_ID			EQU 4
AES_AP_PRIVATE		EQU 6
AES_AP_PTREE		EQU	10
AES_AP_1RESV		EQU 14
AES_AP_2RESV		EQU	18
AES_AP_3RESV		EQU	22
AES_AP_4RESV		EQU	26

; Control Array Offsets
AES_CTRL_OPCODE		EQU	0
AES_CTRL_INT_IN		EQU	2
AES_CTRL_INT_OUT	EQU	4
AES_CTRL_ADDR_IN	EQU	6
AES_CTRL_ADDR_OUT	EQU	8

; Default Window Flags
AES_DEF_WINDOW_X 		equ 20
AES_DEF_WINDOW_Y 		equ 20
AES_DEF_WINDOW_W		equ 20
AES_DEF_WINDOW_H		equ 20
AES_DEF_WINDOW_FLAGS	EQU $3E

;--------------------------------------
; VDI Constants
;--------------------------------------

VDI_OPNVWK			EQU	100
VDI_OPCODE			EQU	115

; VDI contrl offsets
VDI_CTRL_OPCODE		EQU	0
VDI_CTRL_PTS_IN		EQU 2
VDI_CTRL_PTS_OUT	EQU	4
VDI_CTRL_INT_IN		EQU	6
VDI_CTRL_INT_OUT	EQU	8
VDI_CTRL_SUB_FUNC	EQU	10
VDI_CTRL_DEV_HANDLE	EQU	12

;--------------------------------------
;	Includes
;--------------------------------------

	include 		"GEMDOS.S"
	include			"XBIOS.S"