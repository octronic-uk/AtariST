;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk      
;
    section text

_call_VDI:
	move.l	#VDI_PARAM_BLOCK,d1
	move.w	#VDI_OPCODE,d0
	trap	#2
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

;--------------------------------------
; VDI Constants
;--------------------------------------


VDI_CLRWK                   EQU 3
VDI_CURTEXT                 EQU	5
VDI_CURTEXT_SUB             EQU	12

VDI_OPNVWK                  EQU	100
VDI_CLSWK                   EQU 101
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
