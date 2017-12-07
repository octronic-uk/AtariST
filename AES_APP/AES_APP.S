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
    jsr     AES_event_multi
    move.w  AES_RETVAL,d0
    btst.w  #AES_EVENT_MU_MESAG_BIT,d0
    bne     main_check_msgs
    btst.w  #AES_EVENT_MU_BUTTON_BIT,d0
    bne     main_check_mouse_button
    jmp     main_loop

main_check_mouse_button:
    ;pea     STR_MOUSE_BUTTON_MSG
    ;jsr     DEBUG
    ;addq.l  #4,sp
    jsr     _handle_mouse_click 
    jmp     main_loop

main_check_msgs:
main_check_msg_sized:
	cmpi.w	#AES_EVENT_WM_SIZED,AES_MESSAGE
	bne		main_check_msg_redraw
	jsr		AES_event_wm_sized
    jmp     main_loop
main_check_msg_redraw:
	cmpi.w	#AES_EVENT_WM_REDRAW,AES_MESSAGE
	bne		main_check_msg_moved
	jsr		AES_event_wm_redraw
    jmp     main_loop
main_check_msg_moved:
	cmpi.w	#AES_EVENT_WM_MOVED,AES_MESSAGE
	bne		main_check_msg_fulled
	jsr		AES_event_wm_moved
    jmp     main_loop
main_check_msg_fulled:
	cmpi.w	#AES_EVENT_WM_FULLED,AES_MESSAGE
	bne		main_check_msg_menu_selected
	jsr		AES_wind_get_full_xywh
	jsr		AES_event_wm_fulled
	jsr		AES_wind_get_prev_xywh
    jmp     main_loop
main_check_msg_menu_selected:
    cmpi.w  #AES_EVENT_MN_SELECTED,AES_MESSAGE
    bne     main_check_msg_close
    jsr     AES_event_mn_selected
    jmp     main_loop
main_check_msg_close:	
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

_handle_mouse_click:
    jsr     AES_objc_find
    jsr     _highlight_selected_object
    rts

_highlight_selected_object:
    jsr     AES_zero_arrays
    ; CONTROL
    move.w  #AES_OBJC_CHANGE,AES_CONTROL
    move.w  #8,AES_CONTROL+AES_CTRL_INT_IN
    move.w  #1,AES_CONTROL+AES_CTRL_INT_OUT
    move.w  #1,AES_CONTROL+AES_CTRL_ADDR_IN
    move.w  #0,AES_CONTROL+AES_CTRL_ADDR_OUT
    ; INT_IN
    move.w  SELECTED_OBJECT,AES_INT_IN
    move.w  #0,AES_INT_IN+2
    move.w  AES_WORK_X,AES_INT_IN+4
    move.w  AES_WORK_Y,AES_INT_IN+6
    move.w  AES_WORK_W,AES_INT_IN+8
    move.w  AES_WORK_H,AES_INT_IN+10
    move.w  #1,AES_INT_IN+12
    move.w  #1,AES_INT_IN+14
    ; ADDR_IN
    move.l  FORM_PTR,AES_ADDR_IN
    ; Call
    jsr     _call_AES
    rts

;--------------------------------------
;	AES Library Functions
;--------------------------------------
_set_form_position:
    movea.l FORM_PTR,a0
    move.w  AES_WORK_X,(16,a0)
    move.w  AES_WORK_Y,(18,a0)
    move.w  AES_WORK_W,(20,a0)
    move.w  AES_WORK_H,(22,a0)

    jsr     AES_zero_arrays
    ; CONTROL
    move.w  #AES_OBJC_CHANGE,AES_CONTROL
    move.w  #8,AES_CONTROL+AES_CTRL_INT_IN
    move.w  #1,AES_CONTROL+AES_CTRL_INT_OUT
    move.w  #1,AES_CONTROL+AES_CTRL_ADDR_IN
    move.w  #0,AES_CONTROL+AES_CTRL_ADDR_OUT
    ; INT_IN
    move.w  #FORM_ROOT,AES_INT_IN
    move.w  #0,AES_INT_IN+2
    move.w  AES_WORK_X,AES_INT_IN+4
    move.w  AES_WORK_Y,AES_INT_IN+6
    move.w  AES_WORK_W,AES_INT_IN+8
    move.w  AES_WORK_H,AES_INT_IN+10
    move.w  #0,AES_INT_IN+12
    move.w  #1,AES_INT_IN+14
    ; ADDR_IN
    move.l  FORM_PTR,AES_ADDR_IN
    ; Call
    jsr     _call_AES
    rts
    jsr     AES_rsrc_objfix
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

    even
STR_MOUSE_BUTTON_MSG:
    dc.b    ASCII_CR,"Mouse Button Event",ASCII_NUL

;-------------------------------------
; Other Stuff
;-------------------------------------

; Default Window Args

DEF_WINDOW_X            EQU 20
DEF_WINDOW_Y            EQU 20
DEF_WINDOW_W            EQU 344
DEF_WINDOW_H            EQU 250
DEF_WINDOW_FLAGS        EQU $000B

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
