;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk      
;

    section text

_call_AES:
	move.l	#AES_PARAM_BLOCK,d1
	move.l	#AES_ID,d0
	trap	#2
	rts

;--------------------------------------
; AES Constants
;--------------------------------------
    section bss

; AES Parameter Vector

AES_PARAM_BLOCK:	
	dc.l	AES_CONTROL
    dc.l    AES_GLOBAL
	dc.l	AES_INT_IN
    dc.l    AES_INT_OUT
	dc.l	AES_ADDR_IN,AES_ADDR_OUT

; AES Arrays

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
AES_MESSAGE:			ds.w	8

AES_MENU_PTR:           ds.w    1    

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

;---------------------------------------
; Constants
;---------------------------------------

AES_ID                      EQU	200
AES_APPL_INIT               EQU 10
AES_APPL_EXIT               EQU	19
AES_GRAF_HANDLE             EQU	77
AES_GRAF_MOUSE              EQU	78
AES_WIND_CREATE             EQU	100
AES_WIND_OPEN               EQU 101
AES_WIND_CLOSE              EQU	102
AES_WIND_DELETE             EQU	103
AES_WIND_GET                EQU	104
AES_WIND_SET                EQU	105
AES_WIND_UPDATE             EQU 107
AES_RSRC_LOAD               EQU 110
AES_RSRC_FREE               EQU 111
AES_RSRC_GADDR              EQU 112

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

AES_EVENT_MESSAG            EQU 23
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
