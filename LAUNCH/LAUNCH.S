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
    jsr     handle_form_do_result
    jmp     main_loop
main_exit:
    jsr     AES_form_dial_finish
    jsr     AES_rsrc_free
	jsr		VDI_clsvwk
	jsr		AES_appl_exit
	move.w	#GEMDOS_PTERM0,-(sp)
	trap	#TRAP_GEMDOS

handle_form_do_result:
    move.w  AES_RETVAL,d0       ; save some memory access
    cmpi.w  #ALL_BTN,d0
    beq     handle_all_btn
    cmpi.w  #A_BTN,d0
    beq     handle_a_btn
    cmpi.w  #B_BTN,d0
    beq     handle_b_btn
    cmpi.w  #C_BTN,d0
    beq     handle_c_btn
    cmpi.w  #D_BTN,d0
    beq     handle_d_btn
    cmpi.w  #E_BTN,d0
    beq     handle_e_btn
    cmpi.w  #F_BTN,d0
    beq     handle_f_btn
    cmpi.w  #G_BTN,d0
    beq     handle_g_btn
    cmpi.w  #H_BTN,d0
    beq     handle_h_btn
    cmpi.w  #I_BTN,d0
    beq     handle_i_btn
    cmpi.w  #J_BTN,d0
    beq     handle_j_btn
    cmpi.w  #K_BTN,d0
    beq     handle_k_btn
    cmpi.w  #L_BTN,d0
    beq     handle_l_btn
    cmpi.w  #M_BTN,d0
    beq     handle_m_btn
    cmpi.w  #N_BTN,d0
    beq     handle_n_btn
    cmpi.w  #O_BTN,d0
    beq     handle_o_btn
    cmpi.w  #P_BTN,d0
    beq     handle_p_btn
    cmpi.w  #Q_BTN,d0
    beq     handle_q_btn
    cmpi.w  #R_BTN,d0
    beq     handle_r_btn
    cmpi.w  #S_BTN,d0
    beq     handle_s_btn
    cmpi.w  #T_BTN,d0
    beq     handle_t_btn
    cmpi.w  #U_BTN,d0
    beq     handle_u_btn
    cmpi.w  #V_BTN,d0
    beq     handle_v_btn
    cmpi.w  #W_BTN,d0
    beq     handle_w_btn
    cmpi.w  #X_BTN,d0
    beq     handle_x_btn
    cmpi.w  #Y_BTN,d0
    beq     handle_y_btn
    cmpi.w  #Z_BTN,d0
    beq     handle_z_btn
    cmpi.w  #NUM_BTN,d0
    beq     handle_num_btn
    cmpi.w  #CONF_BTN,d0
    beq     handle_config_btn
    cmpi.w  #QUIT_BTN,d0
    beq     main_exit
    rts

handle_all_btn:
   jsr  main_loop 

handle_a_btn:
   jsr  main_loop 

handle_b_btn:
   jsr  main_loop 

handle_c_btn:
   jsr  main_loop 

handle_d_btn:
   jsr  main_loop 

handle_e_btn:
   jsr  main_loop 

handle_f_btn:
   jsr  main_loop 

handle_g_btn:
   jsr  main_loop 

handle_h_btn:
   jsr  main_loop 

handle_i_btn:
   jsr  main_loop 

handle_j_btn:
   jsr  main_loop 

handle_k_btn:
   jsr  main_loop 

handle_l_btn:
   jsr  main_loop 

handle_m_btn:
   jsr  main_loop 

handle_n_btn:
   jsr  main_loop 

handle_o_btn:
   jsr  main_loop 

handle_p_btn:
   jsr  main_loop 

handle_q_btn:
   jsr  main_loop 

handle_r_btn:
   jsr  main_loop 

handle_s_btn:
   jsr  main_loop 

handle_t_btn:
   jsr  main_loop 

handle_u_btn:
   jsr  main_loop 

handle_v_btn:
   jsr  main_loop 

handle_w_btn:
   jsr  main_loop 

handle_x_btn:
   jsr  main_loop 

handle_y_btn:
   jsr  main_loop 

handle_z_btn:
   jsr  main_loop 

handle_num_btn:
   jsr  main_loop 

handle_config_btn:
   jsr  main_loop 


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
	jsr		call_aes
	move.w	AES_INT_OUT,APP_ID
	cmpi.w	#$FFFF,APP_ID
	beq 	.AES_appl_init_error
	rts
.AES_appl_init_error:
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
	jsr		call_aes
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
    jsr     call_aes
    cmpi.w  #0,AES_INT_OUT
    beq     .AES_objc_draw_failed
    rts
.AES_objc_draw_failed:
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
    jsr     call_aes
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
    jsr     call_aes
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
    jsr     call_aes
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
    jsr     call_aes
    move.w  AES_INT_OUT,AES_RETVAL
    rts

AES_graf_mouse_arrow:
    jsr     AES_zero_arrays
	move.w	#AES_GRAF_MOUSE,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#AES_MOUSE_ARROW,AES_INT_IN
	jsr		call_aes
	rts
	
AES_graf_handle:
    jsr     AES_zero_arrays
	move.w	#AES_GRAF_HANDLE,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#5,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	jsr		call_aes
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
	jsr		call_aes
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
	jsr		call_aes
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
	jsr		call_aes
    cmpi.w  #0,AES_INT_OUT
    beq     .AES_rscs_load_error
    rts
.AES_rscs_load_error:
    pea     STR_AES_RSRC_LOAD_FAILED
    jsr     FATAL_ERROR

AES_rsrc_free:
    jsr     AES_zero_arrays
    move.w	#AES_RSRC_FREE,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	jsr		call_aes
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
	jsr		call_aes
    cmpi.w  #0,AES_INT_OUT
    beq     AES_rsrc_get_form_ptr_failed
    move.l  AES_ADDR_OUT,FORM_PTR
    rts
AES_rsrc_get_form_ptr_failed:
    pea     STR_AES_GET_FORM_PTR_FAILED
    jsr     FATAL_ERROR

;--------------------------------------		
	 section bss
;--------------------------------------

STR_BUFFER:             ds.b	128			
APP_ID:					ds.w	1
FORM_PTR:               ds.l    1

FORM_CENTER_X:          ds.w    1
FORM_CENTER_Y:          ds.w    1
FORM_CENTER_W:          ds.w    1
FORM_CENTER_H:          ds.w    1

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
