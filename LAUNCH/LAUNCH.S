;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk
;
;   LAUNCH.S
;		HDD Launcher
;
;   AES Form only version
;       An attempt to get something functional
;       before having to reimplement form_do...
;       Thanks AES developers /s
;

    include "GD_INIT.S"
 
;--------------------------------------
; Application Starts Here
;--------------------------------------
    section text

main:
	jsr		AES_appl_init
	jsr		AES_graf_handle
	jsr		VDI_get_screen_res	
	jsr		VDI_opnvwk
    jsr     AES_rsrc_load
    jsr     AES_rsrc_get_form_ptr
    jsr     AES_graf_mouse_arrow
main_loop:
    jsr     AES_form_center
    jsr     AES_form_dial_start
    jsr     AES_objc_draw
    jsr     AES_form_do
    jsr     main_loop
    
main_exit:
    jsr     AES_form_dial_finish
    jsr     AES_rsrc_free
	jsr		VDI_clsvwk
	jsr		AES_appl_exit
	move.w	#GEMDOS_PTERM0,-(sp)
	trap	#TRAP_GEMDOS

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
    move.w  AES_WORK_X,AES_INT_IN+4
    move.w  AES_WORK_Y,AES_INT_IN+6
    move.w  AES_WORK_W,AES_INT_IN+8
    move.w  AES_WORK_H,AES_INT_IN+10
    ; AES_ADDR_IN
    move.l  FORM_PTR,AES_ADDR_IN
    jsr     _call_AES
    cmpi.w  #0,AES_INT_OUT
    beq     AES_objc_draw_failed
    rts
AES_objc_draw_failed:
    pea     STR_AES_OBJC_DRAW_FAILED
    jsr     FATAL_ERROR

AES_objc_find:
    jsr     AES_zero_arrays
    move.w  #-1,SELECTED_OBJECT
    ; Control
    move.w  #AES_OBJC_FIND,AES_CONTROL
    move.w  #4,AES_CONTROL+AES_CTRL_INT_IN
    move.w  #1,AES_CONTROL+AES_CTRL_INT_OUT
    move.w  #1,AES_CONTROL+AES_CTRL_ADDR_IN
    move.w  #1,AES_CONTROL+AES_CTRL_ADDR_OUT
    ; Int In
    move.w  #FORM_ROOT,AES_INT_IN   ; Start at form root
    move.w  #7,AES_INT_IN+2         ; Search 7 generations
    move.w  EV_MMOX,AES_INT_IN+4
    move.w  EV_MMOY,AES_INT_IN+6
    ; Addr In
    move.l  FORM_PTR,AES_ADDR_IN
    ; Call
    jsr     _call_AES
    move.w  AES_INT_OUT,SELECTED_OBJECT
    rts

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

AES_zero_message:
    move.w  #15,d0
    lea     AES_MESSAGE,a0
_AES_zero_message_next:
    move.w  #0,(a0)+ 
    dbra    d0,_AES_zero_message_next
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

EV_MMOX:                ds.w    1
EV_MMOY:                ds.w    1
EV_MMBUTTON:            ds.w    1
EV_MMOKSTATE:           ds.w    1
EV_MKRETURN:            ds.w    1
EV_MBRETURN:            ds.w    1

SELECTED_OBJECT:        ds.w    1

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
	dc.b	"Ash's HD Luncher",ASCII_NUL
	
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
    dc.b    "LAUNCH.RSC",ASCII_NUL

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

    even
STR_MOUSE_BUTTON_MSG:
    dc.b    ASCII_CR,"Mouse Button Event",ASCII_NUL

;--------------------------------------
;	Includes
;--------------------------------------

	include	"ASCII.S"
	include	"AES.S"
	include	"VDI.S"
	include	"GEMDOS.S"
	include	"XBIOS.S"
    include "RSRC.S"
    include "DEBUG.S"
    include "UTIL.S"
    include "BOOL.S"

   end
