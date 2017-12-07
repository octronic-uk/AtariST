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
    ; Get Address of NameTxt TEDINFO
    move.w  #NAME_TXT,-(sp)
    move.w  #AES_RSRC_TEDINFO,-(sp)
    jsr     AES_rsrc_gaddr
    addq.l  #4,sp
    cmpi.w  #0,AES_INT_OUT
    beq     main_exit
    move.l  AES_ADDR_OUT,NAME_TXT_TEDINFO_PTR
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
    move.w  #0,-(sp)
    jsr     AES_form_do
    addq.l  #6,sp
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
    rts

handle_main_all_btn:
    move.w  #ASCII_ASTERISK,SELECTED_LETTER
    rts

handle_main_a_btn:
    move.w  #ASCII_A,SELECTED_LETTER
    rts 

handle_main_b_btn:
    move.w  #ASCII_B,SELECTED_LETTER
    rts 

handle_main_c_btn:
    move.w  #ASCII_C,SELECTED_LETTER
    rts 

handle_main_d_btn:
    move.w  #ASCII_D,SELECTED_LETTER
    rts 

handle_main_e_btn:
    move.w  #ASCII_E,SELECTED_LETTER
    rts 

handle_main_f_btn:
    move.w  #ASCII_F,SELECTED_LETTER
    rts 

handle_main_g_btn:
    move.w  #ASCII_G,SELECTED_LETTER
    rts 

handle_main_h_btn:
    move.w  #ASCII_H,SELECTED_LETTER
    rts 

handle_main_i_btn:
    move.w  #ASCII_I,SELECTED_LETTER
    rts 

handle_main_j_btn:
    move.w  #ASCII_J,SELECTED_LETTER
    rts 

handle_main_k_btn:
    move.w  #ASCII_K,SELECTED_LETTER
    rts 

handle_main_l_btn:
    move.w  #ASCII_L,SELECTED_LETTER
    rts 

handle_main_m_btn:
    move.w  #ASCII_M,SELECTED_LETTER
    rts 

handle_main_n_btn:
    move.w  #ASCII_N,SELECTED_LETTER
    rts 

handle_main_o_btn:
    move.w  #ASCII_O,SELECTED_LETTER
    rts 

handle_main_p_btn:
    move.w  #ASCII_P,SELECTED_LETTER
    rts 

handle_main_q_btn:
    move.w  #ASCII_Q,SELECTED_LETTER
    rts 

handle_main_r_btn:
    move.w  #ASCII_R,SELECTED_LETTER
    rts 

handle_main_s_btn:
    move.w  #ASCII_S,SELECTED_LETTER
    rts 

handle_main_t_btn:
    move.w  #ASCII_T,SELECTED_LETTER
    rts 

handle_main_u_btn:
    move.w  #ASCII_U,SELECTED_LETTER
    rts 

handle_main_v_btn:
    move.w  #ASCII_V,SELECTED_LETTER
    rts 

handle_main_w_btn:
    move.w  #ASCII_W,SELECTED_LETTER
    rts 

handle_main_x_btn:
    move.w  #ASCII_X,SELECTED_LETTER
    rts 

handle_main_y_btn:
    move.w  #ASCII_Y,SELECTED_LETTER
    rts 

handle_main_z_btn:
    move.w  #ASCII_Z,SELECTED_LETTER
    rts 

handle_main_num_btn:
    move.w  #ASCII_HASH,SELECTED_LETTER
    rts 

handle_main_add_btn:
    jsr     main_form_close
handle_main_add_btn_next:
    jsr     new_item_open
    jsr     new_item_do
    jsr     new_item_close
    ; check result
    cmpi.w  #FSEL_BTN,NEW_ITEM_RETVAL
    beq     new_item_do_fsel
    cmpi.w  #OK_BTN,NEW_ITEM_RETVAL
    beq     new_item_do_ok
    cmpi.w  #CANCEL_BTN,NEW_ITEM_RETVAL    
    beq     new_item_do_cancel
    jmp     new_item_do_done
new_item_do_fsel:
    move.l  #PATH_BUFFER,-(sp)
    move.l  #FILE_BUFFER,-(sp)
    jsr     AES_fsel_input
    addq.l  #8,sp
    move.l  #PATH_BUFFER,-(sp)
    jsr     DEBUG
    addq.l  #4,sp
    move.l  #FILE_BUFFER,-(sp)
    jsr     DEBUG
    addq.l  #4,sp
    jmp     handle_main_add_btn_next
new_item_do_ok:
    move.l  NAME_TXT_TEDINFO_PTR,-(sp)
    jsr     DEBUG
    addq.l  #4,sp
    jmp     new_item_do_done
new_item_do_cancel:
new_item_do_done:
    jsr     main_form_open
    rts 

handle_main_remove_btn:
     rts 

handle_main_save_btn:
     rts 

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
    ; done
    rts

new_item_do:

    move.l  NEW_ITEM_TREE_PTR,-(sp)
    move.w  #NAME_TXT,-(sp)
    jsr     AES_form_do
    addq.l  #6,sp

    move.w  AES_INT_OUT,NEW_ITEM_RETVAL
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
NAME_TXT_TEDINFO_PTR:   ds.l    1

MAIN_FORM_CENTER_X:     ds.w    1
MAIN_FORM_CENTER_Y:     ds.w    1
MAIN_FORM_CENTER_W:     ds.w    1
MAIN_FORM_CENTER_H:     ds.w    1

NEW_ITEM_CENTER_X:      ds.w    1
NEW_ITEM_CENTER_Y:      ds.w    1
NEW_ITEM_CENTER_W:      ds.w    1
NEW_ITEM_CENTER_H:      ds.w    1

NEW_ITEM_RETVAL:        ds.w    1

SELECTED_LETTER:        ds.w    1

PATH_BUFFER:            ds.w    64
FILE_BUFFER:            ds.w    7


;--------------------------------------
	section data
;--------------------------------------

; Strings

	even
STR_RESOURCE_FILE:
    dc.b    "LAUNCH.RSC",ASCII_NUL

NAME_TXT_BUFFER_SZ     equ 128

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
