;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk      
;
    section text

;   jsr     call_aes
call_aes:
	move.l	#AES_PARAM_BLOCK,d1
	move.l	#AES_ID,d0
	trap	#2
	rts

;   jsr     AES_zero_arrays
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

;   jsr     AES_zero_global
AES_zero_global:
    pea		AES_GLOBAL
	move.w	#AES_GLOBAL_SZ,-(sp)
	jsr		ZERO_ARRAY
	addq.l	#6,sp
    rts

;   jsr     ASE_zero_message
AES_zero_message:
    move.w  #15,d0
    lea     AES_MESSAGE,a0
.AES_zero_message_next:
    move.w  #0,(a0)+ 
    dbra    d0,.AES_zero_message_next
    rts

;   jsr     AES_appl_init
AES_appl_init:
    jsr     AES_zero_arrays
    jsr     AES_zero_global
	move.w	#AES_APPL_INIT,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	jsr		call_aes
	move.w	AES_INT_OUT,AES_APP_ID
	rts

;   jsr     AES_appl_exit
AES_appl_exit:
    jsr     AES_zero_arrays
	move.w	#AES_APPL_EXIT,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	jsr		call_aes
	rts

;   jsr     AES_event_multi
AES_event_multi:
    jsr     AES_zero_arrays
    jsr     AES_zero_message
    ; AES_CONTROL
    move.w  #AES_EVENT_MULTI,AES_CONTROL
    move.w  #16,AES_CONTROL+AES_CTRL_INT_IN
    move.w  #7,AES_CONTROL+AES_CTRL_INT_OUT
    move.w  #1,AES_CONTROL+AES_CTRL_ADDR_IN
    move.w  #0,AES_CONTROL+AES_CTRL_ADDR_OUT
    ; AES_INT_IN
    move.w  #AES_EVENT_MULTI_FLAGS,AES_INT_IN
    ; Mouse
    move.w  #1,AES_INT_IN+2 ; 1 click
    move.w  #1,AES_INT_IN+4 ; Mouse button 1
    move.w  #1,AES_INT_IN+6 ; mb1 pressed
    ; Rectangle 1
    move.w  #0,AES_INT_IN+8
    move.w  #0,AES_INT_IN+10
    move.w  #0,AES_INT_IN+12
    move.w  #0,AES_INT_IN+14
    move.w  #0,AES_INT_IN+16
    ; Recrangle 2
    move.w  #0,AES_INT_IN+18
    move.w  #0,AES_INT_IN+20
    move.w  #0,AES_INT_IN+22
    move.w  #0,AES_INT_IN+24
    move.w  #0,AES_INT_IN+26
    ; Timer
    move.w  #0,AES_INT_IN+28
    move.w  #0,AES_INT_IN+30
    ; AES_ADDR_IN
    move.l  #AES_MESSAGE,AES_ADDR_IN
    ; Make call
    jsr     call_aes
    ; AES_INT_OUT
    move.w  AES_INT_OUT+2,AES_EV_MMOX 
    move.w  AES_INT_OUT+4,AES_EV_MMOY
    move.w  AES_INT_OUT+6,AES_EV_MMBUTTON
    move.w  AES_INT_OUT+8,AES_EV_MMOKSTATE 
    move.w  AES_INT_OUT+10,AES_EV_MKRETURN
    move.w  AES_INT_OUT+12,AES_EV_MBRETURN
    rts

;   jsr     AES_event_messag
AES_event_messag:
    jsr     AES_zero_arrays
	move.w	#AES_EVENT_MESSAG,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#1,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.l	#AES_MESSAGE,AES_ADDR_IN
	jsr		call_aes
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	rts

;   jsr     AES_event_wm_sized
AES_event_wm_sized:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_SET,AES_CONTROL
	move.w	#6,AES_CONTROL+AES_CTRL_INT_IN
	move.w	AES_MESSAGE+6,AES_INT_IN
	move.w	#AES_WF_CURRXYWH,AES_INT_IN+2
	move.w	AES_MESSAGE+8,AES_INT_IN+4
	move.w	AES_MESSAGE+10,AES_INT_IN+6
	move.w	AES_MESSAGE+12,AES_INT_IN+8
	move.w	AES_MESSAGE+14,AES_INT_IN+10
	jsr		call_aes
	rts

;   jsr     AES_event_wm_fulled
AES_event_wm_fulled:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_SET,AES_CONTROL
	move.w	#6,AES_CONTROL+AES_CTRL_INT_IN
	move.w	AES_MESSAGE+6,AES_INT_IN
	move.w	#AES_WF_CURRXYWH,AES_INT_IN+2
    cmpi.w  #FALSE,AES_IS_FULLED
    bne     AES_event_wm_fulled_unfull
	move.w	AES_DESK_X,AES_INT_IN+4
	move.w	AES_DESK_Y,AES_INT_IN+6
	move.w	AES_DESK_W,AES_INT_IN+8
	move.w	AES_DESK_H,AES_INT_IN+10
    move.w  #TRUE,AES_IS_FULLED
    jmp     AES_event_wm_fulled_apply
AES_event_wm_fulled_unfull:
    move.w	AES_PREV_X,AES_INT_IN+4
	move.w	AES_PREV_Y,AES_INT_IN+6
	move.w	AES_PREV_W,AES_INT_IN+8
	move.w	AES_PREV_H,AES_INT_IN+10
    move.w  #FALSE,AES_IS_FULLED
AES_event_wm_fulled_apply:
	jsr		call_aes
	rts

;   jsr     AES_event_wm_moved
AES_event_wm_moved:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_SET,AES_CONTROL
	move.w	#6,AES_CONTROL+AES_CTRL_INT_IN
	move.w	AES_MESSAGE+6,AES_INT_IN
	move.w	#AES_WF_CURRXYWH,AES_INT_IN+2
	move.w	AES_MESSAGE+8,AES_INT_IN+4
	move.w	AES_MESSAGE+10,AES_INT_IN+6
	move.w	AES_MESSAGE+12,AES_INT_IN+8
	move.w	AES_MESSAGE+14,AES_INT_IN+10
	jsr		call_aes
	rts

;   pea     TreePtr        (6)
;   move.w  ObjectID,-(sp) (4)
;   jsr     AES_rsrc_objfix
;   addq.l  #6,sp
AES_rsrc_objfix:
    jsr     AES_zero_arrays
    ; CONTROL
    move.w  #AES_RSRC_OBJFIX,AES_CONTROL
    move.w  #1,AES_CONTROL+AES_CTRL_INT_IN
    move.w  #1,AES_CONTROL+AES_CTRL_INT_OUT
    move.w  #1,AES_CONTROL+AES_CTRL_ADDR_IN
    move.w  #0,AES_CONTROL+AES_CTRL_ADDR_OUT
    ; INT_IN
    move.w  4(sp),AES_INT_IN
    ; ADDR_IN
    move.l  6(sp),AES_ADDR_IN
    ; Call
    jsr     call_aes
    rts

; pea       ObjectAddress   (14)
; move.w    ObjectID,-(sp)  (12)
; move.w    X,-(sp)         (10)
; move.w    Y,-(sp)         (8)
; move.w    W,-(sp)         (6)
; move.w    H,-(sp)         (4)
; jsr       AES_objc_draw
; add.l     #14,sp
AES_objc_draw:
    jsr     AES_zero_arrays
    ; AES_CONTROL
    move.w  #AES_OBJC_DRAW,AES_CONTROL 
    move.w  #6,AES_CONTROL+AES_CTRL_INT_IN
    move.w  #1,AES_CONTROL+AES_CTRL_INT_OUT
    move.w  #1,AES_CONTROL+AES_CTRL_ADDR_IN
    move.w  #0,AES_CONTROL+AES_CTRL_ADDR_OUT
    ; AES_INT_IN
    move.w  12(sp),AES_INT_IN
    move.w  #2,AES_INT_IN+2
    move.w  10(sp),AES_INT_IN+4
    move.w  8(sp),AES_INT_IN+6
    move.w  6(sp),AES_INT_IN+8
    move.w  4(sp),AES_INT_IN+10
    ; AES_ADDR_IN
    move.l  14(sp),AES_ADDR_IN
    jsr     call_aes
    rts

;   pea     TreePointer         10
;   move.w  #OBJECT_ID,-(sp)    8
;   move.w  #X_POS,-(sp)        6
;   move.w  #Y_POS,-(sp)        4
;   jsr     AES_objc_find
AES_objc_find:
    jsr     AES_zero_arrays
    ; Control
    move.w  #AES_OBJC_FIND,AES_CONTROL
    move.w  #4,AES_CONTROL+AES_CTRL_INT_IN
    move.w  #1,AES_CONTROL+AES_CTRL_INT_OUT
    move.w  #1,AES_CONTROL+AES_CTRL_ADDR_IN
    move.w  #1,AES_CONTROL+AES_CTRL_ADDR_OUT
    ; Int In
    move.w  8(sp),AES_INT_IN  
    move.w  #7,AES_INT_IN+2     ; Search 7 generations
    move.w  6(sp),AES_INT_IN+4
    move.w  4(sp),AES_INT_IN+6
    ; Addr In
    move.l  10(sp),AES_ADDR_IN
    ; Call
    jsr     call_aes
    rts

;   pea     TreePointer
;   jsr     AES_form_center
;   addq.l  #4,sp
AES_form_center:
    jsr     AES_zero_arrays
    ; AES_CONTROL
    move.w  #AES_FORM_CENTER,AES_CONTROL 
    move.w  #0,AES_CONTROL+AES_CTRL_INT_IN
    move.w  #5,AES_CONTROL+AES_CTRL_INT_OUT
    move.w  #1,AES_CONTROL+AES_CTRL_ADDR_IN
    move.w  #0,AES_CONTROL+AES_CTRL_ADDR_OUT
    ; AES_ADDR_IN
    move.l  4(sp),AES_ADDR_IN
    jsr     call_aes
    
    rts

;   move.w  X,-(sp) 10
;   move.w  Y,-(sp) 8
;   move.w  W,-(sp) 6
;   move.w  H,-(sp) 4
;   jsr     AES_form_dial_start
;   addq.l  #10,sp
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
    move.w  10(sp),AES_INT_IN+10
    move.w  8(sp),AES_INT_IN+12
    move.w  6(sp),AES_INT_IN+14
    move.w  4(sp),AES_INT_IN+16
    jsr     call_aes
    rts

;   move.w  X,-(sp) 10
;   move.w  Y,-(sp) 8
;   move.w  W,-(sp) 6
;   move.w  H,-(sp) 4
;   jsr     AES_form_dial_start
;   addq.l  #10,sp
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
    move.w  10(sp),AES_INT_IN+10
    move.w  8(sp),AES_INT_IN+12
    move.w  6(sp),AES_INT_IN+14
    move.w  4(sp),AES_INT_IN+16
    jsr     call_aes
    rts

;   pea     TreePointer
;   jsr     AES_form_do
;   addq.l  #4,sp
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
    move.l  4(sp),AES_ADDR_IN
    jsr     call_aes
    rts

;   jsr AES_wind_update_begin
AES_wind_update_begin:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_UPDATE,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#AES_BEG_UPDATE,AES_INT_IN
	jsr		call_aes
	rts

;   jsr AES_wind_update_end
AES_wind_update_end:	
    jsr     AES_zero_arrays
	move.w	#AES_WIND_UPDATE,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#AES_END_UPDATE,AES_INT_IN
	jsr		call_aes
	rts

;   jsr AES_graf_mouse_arrow
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
	
;   jsr AES_graf_mouse_hide
AES_graf_mouse_hide:
    jsr     AES_zero_arrays
	move.w	#AES_GRAF_MOUSE,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#VDI_HIDE_MOUSE,AES_INT_IN
	jsr		call_aes
	rts
	
;   jsr AES_graf_mouse_show
AES_graf_mouse_show:
    jsr     AES_zero_arrays
	move.w	#AES_GRAF_MOUSE,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#VDI_SHOW_MOUSE,AES_INT_IN
	jsr		call_aes
	rts

;   jsr  AES_graf_handle
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

;   move.w  WindowFlags,-(sp)   12
;   move.w  X,-(sp)             10
;   move.w  Y,-(sp)             8
;   move.w  W,-(sp)             6
;   move.w  H,-(sp)             4
;   jsr     AES_wind_create
;   addq.l  #
AES_wind_create:	
    jsr     AES_zero_arrays
	move.w	#AES_WIND_CREATE,AES_CONTROL
	move.w	#5,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	12(sp),AES_INT_IN
	move.w	10(sp),AES_INT_IN+2
	move.w	8(sp),AES_INT_IN+4
	move.w	6(sp),AES_INT_IN+6
	move.w	4(sp),AES_INT_IN+8
	jsr		call_aes
	move.w	AES_INT_OUT,AES_WINDOW_HANDLE
	rts

;   move.w  X,-(sp) 10
;   move.w  Y,-(sp) 8
;   move.w  W,-(sp) 6
;   move.w  H,-(sp) 4
;   jsr     AES_wind_open
;   addq.l  #10,sp
AES_wind_open:	
    jsr     AES_zero_arrays
    move.w  #FALSE,AES_IS_FULLED
	move.w	#AES_WIND_OPEN,AES_CONTROL
	move.w	#5,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	move.w	10(sp),AES_INT_IN+2
	move.w	8(sp),AES_INT_IN+4
	move.w	6(sp),AES_INT_IN+6
	move.w	4(sp),AES_INT_IN+8
	jsr		call_aes
	rts

;   pea     STR_WINDOW_TITLE
;   jsr     AES_wind_set_title 
;   addq.l  #4,sp
AES_wind_set_title:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_SET,AES_CONTROL
	move.w	#6,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	AES_WINDOW_HANDLE,AES_INT_IN	
	move.w	#AES_WF_NAME,AES_INT_IN+2
	move.l	4(sp),AES_INT_IN+4
	move.w	#0,AES_INT_IN+8
	move.w	#0,AES_INT_IN+10
	jsr		call_aes
	rts
	
;   pea     STR_WINDOW_TITLE
;   jsr     AES_wind_set_info
;   addq.l  #4,sp
AES_wind_set_info:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_SET,AES_CONTROL
	move.w	#6,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	AES_WINDOW_HANDLE,AES_INT_IN	
	move.w	#AES_WF_INFO,AES_INT_IN+2
	move.l	4(sp),AES_INT_IN+4
	move.w	#0,AES_INT_IN+8
	move.w	#0,AES_INT_IN+10
	jsr		call_aes
	rts

;   jsr AES_wind_close
AES_wind_close:	
    jsr     AES_zero_arrays
	move.w	#AES_WIND_CLOSE,AES_CONTROL
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	jsr		call_aes
	rts
	
;   jsr     AES_wind_delete
AES_wind_delete:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_DELETE,AES_CONTROL
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	jsr		call_aes
	rts
	
;   jsr AES_wind_get_work_xywh
AES_wind_get_work_xywh:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_GET,AES_CONTROL
	move.w	#2,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#5,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	move.w	#AES_WF_WORKXYWH,AES_INT_IN+2
	jsr		call_aes
	move.w	AES_INT_OUT+2,AES_WORK_X
	move.w	AES_INT_OUT+4,AES_WORK_Y
	move.w	AES_INT_OUT+6,AES_WORK_W
    subq.w  #1,AES_WORK_W
	move.w	AES_INT_OUT+8,AES_WORK_H	
    subq.w  #1,AES_WORK_H
	rts

;   jsr     AES_wind_get_prev_xywh
AES_wind_get_prev_xywh:
    jsr     AES_zero_arrays
	move.w	#AES_WIND_GET,AES_CONTROL
	move.w	#2,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#5,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.w	AES_WINDOW_HANDLE,AES_INT_IN
	move.w	#AES_WF_PREVXYWH,AES_INT_IN+2
	jsr		call_aes
	move.w	AES_INT_OUT+2,AES_PREV_X
	move.w	AES_INT_OUT+4,AES_PREV_Y
	move.w	AES_INT_OUT+6,AES_PREV_W
	move.w	AES_INT_OUT+8,AES_PREV_H	
	rts

;   jsr     AES_wind_get_full_xywh
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

;   jsr     AES_wind_get_desk_xywh
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

;   pea     STR_RESOURCE_FILE
;   jsr     AES_rsrc_load
;   addq.l  #4,sp
AES_rsrc_load:
    jsr     AES_zero_arrays
	move.w	#AES_RSRC_LOAD,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#1,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	move.l  4(sp),AES_ADDR_IN
	jsr		call_aes
    rts

;   jsr     AES_rsrc_free
AES_rsrc_free:
    jsr     AES_zero_arrays
    move.w	#AES_RSRC_FREE,AES_CONTROL
	move.w	#0,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
	jsr		call_aes
    rts

;   move.w  #INDEX          6 
;   move.w  #TYPE           4
;   jsr     AES_rsrc_get_ptr
;   addq.l  #4,sp 
AES_rsrc_gaddr:
    jsr     AES_zero_arrays
    move.w	#AES_RSRC_GADDR,AES_CONTROL
	move.w	#2,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#1,AES_CONTROL+AES_CTRL_ADDR_OUT
    move.w  4(sp),AES_INT_IN
    move.w  6(sp),AES_INT_IN+2
	jsr		call_aes
    rts

;   pea     MenuPointer         4
;   jsr     AES_show_menu_bar
;   addq.l  #4,sp
AES_show_menu_bar:
    jsr     AES_zero_arrays
    move.w	#AES_MENU_BAR,AES_CONTROL
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#1,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
    move.w  #AES_MENU_SHOW,AES_INT_IN
    move.l  AES_MENU_PTR,AES_ADDR_IN
    jsr     call_aes
    rts

;   pea     MenuPointer         4
;   jsr     AES_hide_menu_bar
;   addq.l  #4,sp
AES_hide_menu_bar:
    jsr     AES_zero_arrays
    move.w	#AES_MENU_BAR,AES_CONTROL
	move.w	#1,AES_CONTROL+AES_CTRL_INT_IN
	move.w	#1,AES_CONTROL+AES_CTRL_INT_OUT
	move.w	#1,AES_CONTROL+AES_CTRL_ADDR_IN
	move.w	#0,AES_CONTROL+AES_CTRL_ADDR_OUT
    move.w  #AES_MENU_HIDE,AES_INT_IN
    move.l  4(sp),AES_ADDR_IN
    jsr     call_aes
    rts

;   pea PATH_BUFFER
;   pea FILE_BUFFER
;   jsr AES_fsel_input
;   addq.l  #8,sp
AES_fsel_input:
    jsr     AES_zero_arrays
    ; Control
    move.w  #AES_FSEL_INPUT,AES_CONTROL
    move.w  #0,AES_CONTROL+AES_CTRL_INT_IN
    move.w  #2,AES_CONTROL+AES_CTRL_INT_OUT
    move.w  #2,AES_CONTROL+AES_CTRL_ADDR_IN
    move.w  #0,AES_CONTROL+AES_CTRL_ADDR_OUT
    ; Addr in
    move.l  8(sp),AES_ADDR_IN
    move.l  4(sp),AES_ADDR_IN+4
    jsr     call_aes
    rts
;--------------------------------------
; AES Constants
;--------------------------------------
  
  section bss  

; AES Arrays

    even
AES_CONTROL:			ds.w	5
AES_GLOBAL:				ds.w	9
AES_INT_OUT:			ds.w	8
AES_INT_IN:				ds.w	18
AES_ADDR_IN:			ds.l	3
AES_ADDR_OUT:			ds.l	2

AES_PHYS_HANDLE:		ds.w	1
AES_BOX_W:				ds.w	1
AES_BOX_H:				ds.w	1
AES_CHAR_W:				ds.w	1
AES_CHAR_H:				ds.w	1
	
AES_WINDOW_HANDLE:		ds.w	1
AES_WIND_CREATE_RESULT:	ds.w	1
AES_MESSAGE:			ds.b	16

AES_MENU_PTR:           ds.l    1    

; Window Dimensions

AES_WORK_X:				ds.w	1
AES_WORK_Y:				ds.w	1
AES_WORK_W:				ds.w	1
AES_WORK_H:				ds.w	1

AES_PREV_X:				ds.w	1
AES_PREV_Y:				ds.w	1
AES_PREV_W:				ds.w	1
AES_PREV_H:				ds.w	1

AES_FULL_X:				ds.w	1
AES_FULL_Y:				ds.w	1
AES_FULL_W:				ds.w	1
AES_FULL_H:				ds.w	1

AES_DESK_X:				ds.w	1
AES_DESK_Y:				ds.w	1
AES_DESK_W:				ds.w	1
AES_DESK_H:				ds.w	1

AES_APP_ID:             ds.w    1

AES_EV_MMOX:            ds.w    1
AES_EV_MMOY:            ds.w    1
AES_EV_MMBUTTON:        ds.w    1
AES_EV_MMOKSTATE:       ds.w    1
AES_EV_MKRETURN:        ds.w    1
AES_EV_MBRETURN:        ds.w    1
AES_IS_FULLED:          ds.w    1

; AES Parameter Vector

	section data

    even
AES_PARAM_BLOCK:	
	dc.l	AES_CONTROL
    dc.l    AES_GLOBAL
	dc.l	AES_INT_IN
    dc.l    AES_INT_OUT
	dc.l	AES_ADDR_IN,AES_ADDR_OUT

;---------------------------------------
; Constants
;---------------------------------------

; Application
AES_APPL_INIT               EQU 10
AES_APPL_EXIT               EQU	19
; EVENT
AES_EVENT_MESSAG            EQU 23
AES_EVENT_MULTI             EQU 25
; Menu
AES_MENU_BAR                EQU 30
; Object
AES_OBJC_DRAW               EQU 42
AES_OBJC_FIND               EQU 43
AES_OBJC_CHANGE             EQU 47
; Form
AES_FORM_DO                 EQU 50
AES_FORM_DIAL               EQU 51
AES_FORM_CENTER             EQU 54
; Graphics
AES_GRAF_HANDLE             EQU	77
AES_GRAF_MOUSE              EQU	78
; File Selector
AES_FSEL_INPUT              EQU 90
; Window
AES_WIND_CREATE             EQU	100
AES_WIND_OPEN               EQU 101
AES_WIND_CLOSE              EQU	102
AES_WIND_DELETE             EQU	103
AES_WIND_GET                EQU	104
AES_WIND_SET                EQU	105
AES_WIND_UPDATE             EQU 107
; Resource
AES_RSRC_LOAD               EQU 110
AES_RSRC_FREE               EQU 111
AES_RSRC_GADDR              EQU 112
AES_RSRC_OBJFIX             EQU 114
AES_RSRC_RCFIX              EQU 115
; ID
AES_ID                      EQU	200

; Global Array Offests

AES_AP_VERSION              EQU 0
AES_AP_COUNT                EQU 2
AES_AP_ID                   EQU 4
AES_AP_PRIVATE              EQU 6
AES_AP_PTREE                EQU	10
AES_AP_1RESV                EQU 14
AES_AP_2RESV                EQU	18
AES_AP_3RESV                EQU	22
AES_AP_4RESV                EQU	26

; Control Array Offsets

AES_CTRL_OPCODE             EQU	0
AES_CTRL_INT_IN             EQU	2
AES_CTRL_INT_OUT            EQU	4
AES_CTRL_ADDR_IN            EQU	6
AES_CTRL_ADDR_OUT           EQU	8


; Array Sizes

AES_MESSAGE_SZ              EQU	8
AES_CONTROL_SZ              EQU	5
AES_GLOBAL_SZ               EQU	9
AES_INT_OUT_SZ              EQU	8
AES_INT_IN_SZ               EQU	18
AES_ADDR_IN_SZ              EQU	3
AES_ADDR_OUT_SZ             EQU	2

; Events

AES_EVENT_MN_SELECTED		EQU 10
AES_EVENT_WM_REDRAW			EQU	20
AES_EVENT_WM_TOPPED			EQU	21
AES_EVENT_WM_CLOSED			EQU	22
AES_EVENT_WM_FULLED			EQU	23
AES_EVENT_WM_ARROWED		EQU	24
AES_EVENT_WM_HSLID			EQU	25
AES_EVENT_WM_VSLID			EQU	26
AES_EVENT_WM_SIZED			EQU	27
AES_EVENT_WM_MOVED			EQU	28
AES_EVENT_WM_NEWTOP			EQU	29
AES_EVENT_AC_OPEN			EQU	40
AES_EVENT_AC_CLOSE			EQU	41

AES_EVENT_MU_KEYBD          EQU $0001 ; Keybord event 
AES_EVENT_MU_BUTTON         EQU $0002 ; Button event 
AES_EVENT_MU_M1             EQU $0004 ; Mouse event 1 
AES_EVENT_MU_M2             EQU $0008 ; Mouse event 2 
AES_EVENT_MU_MESAG          EQU $0010 ; Messages 
AES_EVENT_MU_TIMER          EQU $0020 ; Timer events 
AES_EVENT_MU_WHEEL          EQU $0040 ; Mouse-wheel, XaAES 
AES_EVENT_MU_MX             EQU $0080 ; Mouse movement, XaAES 
AES_EVENT_MU_KEYBD4         EQU $0100 ; GEM/4 
AES_EVENT_MU_NORM_KEYBD     EQU $0100 ; Normalized key-codes, XaAES 
AES_EVENT_MU_DYNAMIC_KEYBD  EQU $0200 ; XaAES, not yet implemented 
AES_EVENT_X_MU_DIALOG       EQU $4000 ; (Geneva)

AES_EVENT_MU_KEYBD_BIT          EQU 0  ; Keybord event 
AES_EVENT_MU_BUTTON_BIT         EQU 1  ; Button event 
AES_EVENT_MU_M1_BIT             EQU 2  ; Mouse event 1 
AES_EVENT_MU_M2_BIT             EQU 3  ; Mouse event 2 
AES_EVENT_MU_MESAG_BIT          EQU 4  ; Messages 
AES_EVENT_MU_TIMER_BIT          EQU 5  ; Timer events 
AES_EVENT_MU_WHEEL_BIT          EQU 6  ; Mouse-wheel, XaAES 
AES_EVENT_MU_MX_BIT             EQU 7  ; Mouse movement, XaAES 
AES_EVENT_MU_KEYBD4_BIT         EQU 8  ; GEM/4 
AES_EVENT_MU_NORM_KEYBD_BIT     EQU 8  ; Normalized key-codes, XaAES 
AES_EVENT_MU_DYNAMIC_KEYBD_BIT  EQU 9 ; XaAES, not yet implemented 
AES_EVENT_X_MU_DIALOG_BIT       EQU 12 ; (Geneva)

AES_EVENT_MULTI_FLAGS       EQU $1F   ; AES_EVENT_MU_KEYBD + AES_EVENT_MU_BUTTON + AES+EVENT_MU_M1 + AES_EVENT_MU_M2 + AES_EVENT_MU_MESAG 

; WF_STUFF

AES_WF_KIND					EQU	1
AES_WF_NAME					EQU	2
AES_WF_INFO					EQU	3
AES_WF_WORKXYWH				EQU	4
AES_WF_CURRXYWH				EQU	5
AES_WF_PREVXYWH				EQU	6
AES_WF_FULLXYWH				EQU	7

; graf_update

AES_END_UPDATE              EQU 0
AES_BEG_UPDATE              EQU 1

; Mouse 

AES_MOUSE_ARROW             EQU 0	;   Arrow
AES_MOUSE_TEXT_CRSR         EQU 1	;   Text cursor
AES_MOUSE_HOURGLASS         EQU 2	;   Hourglass, bee
AES_MOUSE_BUSY_BEE          EQU 2	;   See HOURGLASS
AES_MOUSE_BUSYBEE           EQU 2	;   See HOURGLASS
AES_MOUSE_POINT_HAND        EQU 3	;   Pointing hand
AES_MOUSE_FLAT_HAND         EQU 4	;   Flat hand
AES_MOUSE_THIN_CROSS        EQU 5	;   Thin crosshairs
AES_MOUSE_THICK_CROSS       EQU 6	;   Thick crosshairs
AES_MOUSE_OUTLN_CROSS       EQU 7	;   Outlined crosshairs

; Resource

AES_RSRC_TREE               EQU 0   ; Object tree
AES_RSRC_OBJECT             EQU 1   ; Individual OBJECT
AES_RSRC_TEDINFO            EQU 2   ; TEDINFO structure
AES_RSRC_ICONBLK            EQU 3   ; ICONBLK structure
AES_RSRC_BITBLK             EQU 4   ; BITBLK structure
AES_RSRC_STRING             EQU 5   ; Free string data
AES_RSRC_IMAGEDATA          EQU 6   ; Free image data
AES_RSRC_OBSPEC             EQU 7   ; ob_spec field in OBJECT
AES_RSRC_TEPTEXT            EQU 8   ; te_ptext in TEDINFO
AES_RSRC_TEPTMPLT           EQU 9   ; te_ptmplt in TEDINFO
AES_RSRC_TEPVALID           EQU 10  ; te_pvalid in TEDINFO
AES_RSRC_IBPMASK            EQU 11  ; ib_pmask in ICONBLK
AES_RSRC_IBPDATA            EQU 12  ; ib_pdata in ICONBLK
AES_RSRC_IBPTEXT            EQU 13  ; ib_ptext in ICONBLK
AES_RSRC_BIPDATA            EQU 14  ; ib_pdate in BITBLK
AES_RSRC_FRSTR              EQU 15  ; ad_frstr free string
AES_RSRC_FRIMG              EQU 16  ; ad_frimg free image

; Menu
AES_MENU_HIDE               EQU 0
AES_MENU_SHOW               EQU 1
AES_MENU_INSTALL            EQU 100

; Form
AES_FMD_START               EQU 0
AES_FMD_GROW                EQU 1
AES_FMD_SHRINK              EQU 2
AES_FMD_FINISH              EQU 3
