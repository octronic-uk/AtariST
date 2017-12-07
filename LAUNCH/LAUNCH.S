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

app_main:
    ; AES app init
	jsr		AES_appl_init
    cmpi.w  #-1,AES_APP_ID
    beq     main_exit
    ; AES Graphics handle
	jsr		AES_graf_handle
    cmpi.w  #0,AES_PHYS_HANDLE
    beq     main_exit
    ; Get screen res
	jsr		XB_get_screen_res	
    cmpi.w  #0,XB_SCREEN_RES
    beq     main_exit
    ; Open VDI Workstation
	jsr		VDI_opnvwk
    cmpi.w  #0,VDI_WK_HANDLE
    beq     main_exit
    ; Load Resource File
    move.l  #STR_RESOURCE_FILE,-(sp)
    jsr     AES_rsrc_load
    addq.l  #4,sp
    cmpi.w  #0,AES_INT_OUT
    ; Get Address of main form
    move.w  #MAIN,-(sp)
    move.w  #AES_RSRC_TREE,-(sp)
    jsr     AES_rsrc_gaddr
    addq.l  #4,sp
    cmpi.w  #0,AES_INT_OUT
    beq     main_exit
    move.l  AES_ADDR_OUT,MAIN_FORM_TREE_PTR
    ; Get Address of New Item form
    move.w  #NEW_ITEM,-(sp)
    move.w  #AES_RSRC_TREE,-(sp)
    jsr     AES_rsrc_gaddr
    addq.l  #4,sp
    cmpi.w  #0,AES_INT_OUT
    beq     main_exit
    move.l  AES_ADDR_OUT,NEW_ITEM_TREE_PTR
    ; Set mouse to arrow (from bee)
    jsr     AES_graf_mouse_arrow

main_form_open:
    ; Get form center
    move.l  MAIN_FORM_TREE_PTR,-(sp)
    jsr     AES_form_center
    addq.l  #4,sp
    move.w  AES_INT_OUT+2,MAIN_FORM_CENTER_X
    move.w  AES_INT_OUT+4,MAIN_FORM_CENTER_Y
    move.w  AES_INT_OUT+6,MAIN_FORM_CENTER_W
    move.w  AES_INT_OUT+8,MAIN_FORM_CENTER_H
    ; Start dialog
    move.w  MAIN_FORM_CENTER_X,-(sp) 
    move.w  MAIN_FORM_CENTER_Y,-(sp) 
    move.w  MAIN_FORM_CENTER_W,-(sp) 
    move.w  MAIN_FORM_CENTER_H,-(sp) 
    jsr     AES_form_dial_start
    addq.l  #8,sp
    ; draw dialog
    move.l  MAIN_FORM_TREE_PTR,-(sp)
    move.w  #FORM_ROOT,-(sp)
    move.w  MAIN_FORM_CENTER_X,-(sp)
    move.w  MAIN_FORM_CENTER_Y,-(sp)
    move.w  MAIN_FORM_CENTER_W,-(sp)
    move.w  MAIN_FORM_CENTER_H,-(sp)
    jsr     AES_objc_draw
    add.l  #14,sp

main_form_loop:
    ; hand over to form_do
    move.l  MAIN_FORM_TREE_PTR,-(sp)
    jsr     AES_form_do
    addq.l  #4,sp
    move.w  AES_INT_OUT,d0
    ; process result
    jsr     handle_main_form_do_result
    ; reiterate
    jmp     main_form_loop

main_exit:
    jsr     main_form_close
    jsr     AES_rsrc_free
	jsr		VDI_clsvwk
	jsr		AES_appl_exit
	move.w	#GEMDOS_PTERM0,-(sp)
	trap	#TRAP_GEMDOS

main_form_close:
    move.w  MAIN_FORM_CENTER_X,-(sp) 
    move.w  MAIN_FORM_CENTER_Y,-(sp) 
    move.w  MAIN_FORM_CENTER_W,-(sp) 
    move.w  MAIN_FORM_CENTER_H,-(sp) 
    jsr     AES_form_dial_finish
    addq.l  #8,sp
    rts

handle_main_form_do_result:
    cmpi.w  #ALL_BTN,d0
    beq     handle_main_all_btn
    cmpi.w  #A_BTN,d0
    beq     handle_main_a_btn
    cmpi.w  #B_BTN,d0
    beq     handle_main_b_btn
    cmpi.w  #C_BTN,d0
    beq     handle_main_c_btn
    cmpi.w  #D_BTN,d0
    beq     handle_main_d_btn
    cmpi.w  #E_BTN,d0
    beq     handle_main_e_btn
    cmpi.w  #F_BTN,d0
    beq     handle_main_f_btn
    cmpi.w  #G_BTN,d0
    beq     handle_main_g_btn
    cmpi.w  #H_BTN,d0
    beq     handle_main_h_btn
    cmpi.w  #I_BTN,d0
    beq     handle_main_i_btn
    cmpi.w  #J_BTN,d0
    beq     handle_main_j_btn
    cmpi.w  #K_BTN,d0
    beq     handle_main_k_btn
    cmpi.w  #L_BTN,d0
    beq     handle_main_l_btn
    cmpi.w  #M_BTN,d0
    beq     handle_main_m_btn
    cmpi.w  #N_BTN,d0
    beq     handle_main_n_btn
    cmpi.w  #O_BTN,d0
    beq     handle_main_o_btn
    cmpi.w  #P_BTN,d0
    beq     handle_main_p_btn
    cmpi.w  #Q_BTN,d0
    beq     handle_main_q_btn
    cmpi.w  #R_BTN,d0
    beq     handle_main_r_btn
    cmpi.w  #S_BTN,d0
    beq     handle_main_s_btn
    cmpi.w  #T_BTN,d0
    beq     handle_main_t_btn
    cmpi.w  #U_BTN,d0
    beq     handle_main_u_btn
    cmpi.w  #V_BTN,d0
    beq     handle_main_v_btn
    cmpi.w  #W_BTN,d0
    beq     handle_main_w_btn
    cmpi.w  #X_BTN,d0
    beq     handle_main_x_btn
    cmpi.w  #Y_BTN,d0
    beq     handle_main_y_btn
    cmpi.w  #Z_BTN,d0
    beq     handle_main_z_btn
    cmpi.w  #NUM_BTN,d0
    beq     handle_main_num_btn
    cmpi.w	#ADD_BTN,d0
    beq     handle_main_add_btn
    cmpi.w	#RM_BTN,d0
    beq     handle_main_remove_btn
    cmpi.w	#SAVE_BTN,d0
    beq     handle_main_save_btn
    cmpi.w  #QUIT_BTN,d0
    beq     main_exit
handle_main_form_do_result_done:
    rts

handle_main_all_btn:
    jmp handle_main_form_do_result_done

handle_main_a_btn:
    jmp  handle_main_form_do_result_done 

handle_main_b_btn:
    jmp  handle_main_form_do_result_done 

handle_main_c_btn:
    jmp  handle_main_form_do_result_done 

handle_main_d_btn:
    jmp  handle_main_form_do_result_done 

handle_main_e_btn:
    jmp  handle_main_form_do_result_done 

handle_main_f_btn:
    jmp  handle_main_form_do_result_done 

handle_main_g_btn:
    jmp  handle_main_form_do_result_done 

handle_main_h_btn:
    jmp  handle_main_form_do_result_done 

handle_main_i_btn:
    jmp  handle_main_form_do_result_done 

handle_main_j_btn:
    jmp  handle_main_form_do_result_done 

handle_main_k_btn:
    jmp  handle_main_form_do_result_done 

handle_main_l_btn:
    jmp  handle_main_form_do_result_done 

handle_main_m_btn:
    jmp  handle_main_form_do_result_done 

handle_main_n_btn:
    jmp  handle_main_form_do_result_done 

handle_main_o_btn:
    jmp  handle_main_form_do_result_done 

handle_main_p_btn:
    jmp  handle_main_form_do_result_done 

handle_main_q_btn:
    jmp  handle_main_form_do_result_done 

handle_main_r_btn:
    jmp  handle_main_form_do_result_done 

handle_main_s_btn:
    jmp  handle_main_form_do_result_done 

handle_main_t_btn:
    jmp  handle_main_form_do_result_done 

handle_main_u_btn:
    jmp  handle_main_form_do_result_done 

handle_main_v_btn:
    jmp  handle_main_form_do_result_done 

handle_main_w_btn:
    jmp  handle_main_form_do_result_done 

handle_main_x_btn:
    jmp  handle_main_form_do_result_done 

handle_main_y_btn:
    jmp  handle_main_form_do_result_done 

handle_main_z_btn:
    jmp  handle_main_form_do_result_done 

handle_main_num_btn:
    jmp  handle_main_form_do_result_done 

handle_main_add_btn:
    jsr     main_form_close
    jsr     new_item_open
    jmp     main_form_open

handle_main_remove_btn:
     jmp  handle_main_form_do_result_done 

handle_main_save_btn:
     jmp  handle_main_form_do_result_done 

new_item_open:
    move.l  NEW_ITEM_TREE_PTR,-(sp)
    jsr     AES_form_center
    addq.l  #4,sp
    ; Get form center from AES_INT_OUT
    move.w  AES_INT_OUT+2,NEW_ITEM_CENTER_X
    move.w  AES_INT_OUT+4,NEW_ITEM_CENTER_Y
    move.w  AES_INT_OUT+6,NEW_ITEM_CENTER_W
    move.w  AES_INT_OUT+8,NEW_ITEM_CENTER_H
    ; setup form dial start
    move.w  NEW_ITEM_CENTER_X,-(sp) 
    move.w  NEW_ITEM_CENTER_Y,-(sp) 
    move.w  NEW_ITEM_CENTER_W,-(sp) 
    move.w  NEW_ITEM_CENTER_H,-(sp) 
    jsr     AES_form_dial_start
    addq.l  #8,sp
    ; setup objc_draw
    move.l  NEW_ITEM_TREE_PTR,-(sp)
    move.w  #NEW_ITEM_ROOT,-(sp)
    move.w  NEW_ITEM_CENTER_X,-(sp)
    move.w  NEW_ITEM_CENTER_Y,-(sp)
    move.w  NEW_ITEM_CENTER_W,-(sp)
    move.w  NEW_ITEM_CENTER_H,-(sp)
    jsr     AES_objc_draw
    add.l  #14,sp
    ; do
    jsr     new_item_do
    ; done
    jmp new_item_open
    rts

new_item_do:
    move.l  NEW_ITEM_TREE_PTR,-(sp)
    jsr     AES_form_do
    addq.l  #4,sp
    clr.l   d0
    move.w  AES_INT_OUT,d0
    jsr     handle_new_item_form_result
    jsr     new_item_close
    rts

handle_new_item_form_result:
    cmpi.w  #OK_BTN,d0
    beq     handle_new_item_ok

    cmpi.w  #CANCEL_BTN,d0
    beq     handle_new_item_cancel

    cmpi.w  #FSEL_BTN,d0
    beq     handle_new_item_fsel

    rts

handle_new_item_ok:
    rts

handle_new_item_cancel:
    rts

handle_new_item_fsel:
    move.l  #PATH_BUFFER,-(sp)
    move.l  #FILE_BUFFER,-(sp)
    jsr     AES_fsel_input
    addq.l  #8,sp
    rts

new_item_close:
    move.w  NEW_ITEM_CENTER_X,-(sp) 
    move.w  NEW_ITEM_CENTER_Y,-(sp) 
    move.w  NEW_ITEM_CENTER_W,-(sp) 
    move.w  NEW_ITEM_CENTER_H,-(sp) 
    jsr     AES_form_dial_finish
    addq.l  #8,sp
    rts

;--------------------------------------		
	 section bss
;--------------------------------------

MAIN_FORM_TREE_PTR:     ds.l    1
NEW_ITEM_TREE_PTR:      ds.l    1

MAIN_FORM_CENTER_X:     ds.w    1
MAIN_FORM_CENTER_Y:     ds.w    1
MAIN_FORM_CENTER_W:     ds.w    1
MAIN_FORM_CENTER_H:     ds.w    1

NEW_ITEM_CENTER_X:      ds.w    1
NEW_ITEM_CENTER_Y:      ds.w    1
NEW_ITEM_CENTER_W:      ds.w    1
NEW_ITEM_CENTER_H:      ds.w    1

SELECTED_OBJECT:        ds.w    1

PATH_BUFFER:            ds.w    64
FILE_BUFFER:            ds.w    7

;--------------------------------------
	section data
;--------------------------------------

; Strings

	even
STR_RESOURCE_FILE:
    dc.b    "LAUNCH.RSC",ASCII_NUL

;--------------------------------------
;	Includes
;--------------------------------------

	include "UTIL.S"
	include	"ASCII.S"
	include	"AES.S"
	include	"VDI.S"
	include	"GEMDOS.S"
	include	"XBIOS.S"
    include "RSRC.S"
    include "DEBUG.S"
    include "BOOL.S"

   end
