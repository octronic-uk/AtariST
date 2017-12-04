;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk      
;
    section text

;--------------------------------------
; GEM/VDI Library Functions
;--------------------------------------

call_vdi:
	move.l	#VDI_PARAM_BLOCK,d1
	move.w	#VDI_OPCODE,d0
	trap	#2
	rts

VDI_get_screen_res:
	move.w	#XBIOS_GETRES,-(sp)
	trap	#TRAP_XBIOS
	addq.l	#2,sp
	addq.w	#2,d0					; Add 2 to correct res
	move.w	d0,VDI_SCREEN_RES
	rts
	
; Sets VDI_WK_HANDLE
VDI_opnvwk:
    jsr     VDI_zero_arrays
	move.w	#VDI_OPNVWK,VDI_CONTROL
	move.w	#11,VDI_CONTROL+VDI_CTRL_INT_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_IN
	move.w	AES_PHYS_HANDLE(sp),VDI_CONTROL+VDI_CTRL_DEV_HANDLE
	lea		VDI_INT_IN,a0
	move.w	#9,d0
.VDI_opnvwk_int_in_init_loop:
	move.w	#1,(a0)+
	dbra	d0,.VDI_opnvwk_int_in_init_loop
	move.w	VDI_SCREEN_RES,VDI_INT_IN
	move.w	#VDI_RASTER_COORDS,VDI_INT_IN+20
	jsr		call_vdi
	move.w	VDI_CONTROL+VDI_CTRL_DEV_HANDLE,VDI_WK_HANDLE
	rts

; Clear Workstation
VDI_clrwk:
    jsr     VDI_zero_arrays
	move.w	#VDI_CLRWK,VDI_CONTROL
	move.w	#0,VDI_CONTROL+VDI_CTRL_INT_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_INT_OUT
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_OUT
	jsr		call_vdi
	rts
	
; Closes VDI_WK_HANDLE
VDI_clsvwk:
    jsr     VDI_zero_arrays
	move.w	#VDI_CLSVWK,VDI_CONTROL
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_OUT
	move.w	#0,VDI_CONTROL+VDI_CTRL_INT_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_INT_OUT
    move.w  VDI_WK_HANDLE,VDI_CONTROL+VDI_CTRL_DEV_HANDLE
	jsr		call_vdi
	rts

; Set Background White
VDI_set_bg_white:
    jsr     VDI_zero_arrays
	move.w	#VDI_VSF_COLOR,VDI_CONTROL
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_IN
	move.w	#0,VDI_CONTROL+VDI_CTRL_PTS_OUT
	move.w	#1,VDI_CONTROL+VDI_CTRL_INT_IN
	move.w	#1,VDI_CONTROL+VDI_CTRL_INT_OUT
	move.w	VDI_WK_HANDLE,VDI_CONTROL+VDI_CTRL_DEV_HANDLE
	move.w	#0,VDI_INT_IN
	jsr 	call_vdi
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
	jsr		call_vdi
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

    section data

; VDI Parameter Vector	

VDI_PARAM_BLOCK:
	dc.l	VDI_CONTROL
	dc.l	VDI_INT_IN
    dc.l    VDI_PTS_IN
	dc.l	VDI_INT_OUT
    dc.l    VDI_PTS_OUT

	section bss

; VDI Arrays

VDI_WK_HANDLE:			ds.w	1

VDI_CONTROL:			ds.w	12


VDI_INT_IN:				ds.w	128
VDI_PTS_IN:				ds.w	128
VDI_INT_OUT:			ds.w	128
VDI_PTS_OUT:			ds.w	128

VDI_SCREEN_RES:				ds.w	1

;--------------------------------------
; VDI Constants
;--------------------------------------


VDI_CLRWK                   EQU 3
VDI_CURTEXT                 EQU	5
VDI_CURTEXT_SUB             EQU	12

VDI_OPNVWK                  EQU	100
VDI_CLSVWK                  EQU 101
VDI_OPCODE                  EQU	115

VDI_VSF_COLOR               EQU 25
VDI_VR_RECFL                EQU 114
VDI_HIDE_MOUSE              EQU 256
VDI_SHOW_MOUSE              EQU 257

VDI_NDC_COORDS              EQU 0
VDI_RASTER_COORDS           EQU 2

; Control Offsets

VDI_CTRL_OPCODE             EQU	0
VDI_CTRL_PTS_IN             EQU	2
VDI_CTRL_PTS_OUT            EQU	4
VDI_CTRL_INT_IN             EQU	6
VDI_CTRL_INT_OUT            EQU	8
VDI_CTRL_SUB_FUNC           EQU	10
VDI_CTRL_DEV_HANDLE         EQU	12

; Array Sizes

VDI_ARRAY_SZ                EQU	128
VDI_CONTROL_SZ              EQU	12
