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
	jsr		AES_appl_init
	jsr		AES_graf_handle	
	jsr		VDI_open_v_workstation
	jsr		AES_wind_create
	jsr		AES_wind_set
	jsr		AES_wind_open
	jsr		AES_appl_exit
main_exit:
	move.w	#GEMDOS_PTERM0,-(sp)
	trap	#TRAP_GEMDOS

read_key:
    move.w	#GEMDOS_CCONIN,-(sp)	; Wait for keypress
    trap 	#TRAP_GEMDOS
    addq.l	#2,sp
    rts

;--------------------------------------
; GEM/VDI Library Functions
;--------------------------------------
VDI_open_v_workstation:
	move.w	#XBIOS_GETRES,-(sp)	; Call XBIOS to get resolution
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
	
AES_wind_set:

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

	even

AES_PHYS_HANDLE:		ds.w	1
AES_BOX_W:				ds.w	1
AES_BOX_H:				ds.w	1
AES_CHAR_W:				ds.w	1
AES_CHAR_H:				ds.w	1

	even
	
AES_WINDOW_HANDLE		ds.w	1
AES_WIND_CREATE_RESULT:	ds.w	1	

	even

; VDI Other

VDI_SCREEN_DEVICE:		ds.w	1

; VDI Arrays

VDI_WORK_IN:			ds.w	12
VDI_WORK_OUT:			ds.w	57
VDI_HANDLE:				ds.w	1

	even

VDI_CONTROL:			ds.w	12
VDI_PTS_IN:				ds.w	128
VDI_PTS_OUT:			ds.w	128
VDI_INT_IN:				ds.w	128
VDI_INT_OUT:			ds.w	128

	even

;--------------------------------------
; AES Constants
;--------------------------------------

AES_ID					EQU	200
AES_APPL_INIT			EQU 10
AES_APPL_EXIT			EQU	19
AES_GRAF_HANDLE			EQU	77
AES_WIND_CREATE			EQU	100
AES_WIND_OPEN			EQU 101
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
AES_DEF_WINDOW_FLAGS	EQU $3E

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
;	Includes
;--------------------------------------

	include	"GEMDOS.S"
	include	"XBIOS.S"