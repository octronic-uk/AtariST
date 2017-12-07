;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk      
;
;   LINEA.S 

;----------------------------
; Line-A Functions
;----------------------------
LINEA_INIT              equ $A000
LINEA_PUT_PIXEL         equ $A001
LINEA_GET_PIXEL         equ $A002
LINEA_ARB_LINE          equ $A003
LINEA_HORIZ_LINE        equ $A004
LINEA_FILLED_RECT       equ $A005
LINEA_FILLED_POLY       equ $A006
LINEA_BIT_BLK_TX        equ $A007
LINEA_TEXT_BLK_TX       equ $A008
LINEA_SHOW_MOUSE        equ $A009
LINEA_HIDE_MOUSE        equ $A00A
LINEA_TRANSFORM_MOUSE   equ $A00B
LINEA_UNDRAW_SPRITE     equ $A00C
LINEA_DRAW_SPRITE       equ $A00D
LINEA_COPY_RASTER_FORM  equ $A00E
LINEA_SEEDFILL          equ $A00F

;----------------------------
; Line-A Structure Offsets
;----------------------------
LINEA_V_PLANES          equ 0   ;   # of bit planes (1, 2 or 4)     
LINEA_V_LIN_WR          equ 2   ;   # of bytes/scanline             
LINEA_CONTRL            equ 4   ;   contrl pointer
LINEA_INTIN             equ 8   ;   intin pointer
LINEA_PTSIN             equ 12  ;   ptsin pointer            
LINEA_INTOUT            equ 16  ;   intout pointer
LINEA_PTSOUT            equ 20  ;   ptsout pointer        
LINEA_FG_BP_1           equ 24  ;   Plane 0                      
LINEA_FG_BP_2           equ 26  ;   Plane 1                      
LINEA_FG_BP_3           equ 28  ;   Plane 2                      
LINEA_FG_BP_4           equ 30  ;   Plane 3                      
LINEA_LSTLIN            equ 32  ;   Draw last pixel of a line (1) or don't draw it (0)     
LINEA_LN_MASK           equ 34  ;   Line pattern                 
LINEA_WRT_MODE          equ 36  ;   Writing modes                
LINEA_X1                equ 38  ;   Coordinate
LINEA_Y1                equ 40  ;   Coordinate
LINEA_X2                equ 42  ;   Coordinate
LINEA_Y2                equ 44  ;   Coordinate                   
LINEA_PATPTR            equ 46  ;   Fill pattern                 
LINEA_PATMSK            equ 50  ;   Fill pattern "mask"          
LINEA_MULTIFILL         equ 52  ;   Fill pattern for planes      
LINEA_CLIP              equ 54  ;   Flag for clipping            
LINEA_XMN_CLIP          equ 56  ;   Clipping rectangle x-min
LINEA_YMN_CLIP          equ 58  ;   Clipping rectangle y-min
LINEA_XMX_CLIP          equ 60  ;   Clipping rectangle x-max
LINEA_YMX_CLIP          equ 62  ;   Clipping rectangle y-max
LINEA_XACC_DDA          equ 64  ;   Set to 0x8000 before text output                       
LINEA_DDA_INC           equ 66  ;   Scaling increment            
LINEA_T_SCLSTS          equ 68  ;   Scaling direction            
LINEA_MONO_STATUS       equ 70  ;   Proportional font            
LINEA_SOURCEX           equ 72  ;   x Coordinates in font
LINEA_SOURCEY           equ 74  ;   y Coordinates in font        
LINEA_DESTX             equ 76  ;   x Screen coordinates
LINEA_DESTY             equ 78  ;   x Screen coordinates            
LINEA_DELX              equ 80  ;   Width of character
LINEA_DELY              equ 82  ;   Height of character
LINEA_FBASE             equ 84  ;   Pointer to font data         
LINEA_FWIDTH            equ 88  ;   Width of font form           
LINEA_STYLE             equ 90  ;   Font style effect            
LINEA_LITEMASK          equ 92  ;   Mask for light               
LINEA_SKEWMASK          equ 94  ;   Mask for italic              
LINEA_WEIGHT            equ 96  ;   Width for bold               
LINEA_R_OFF             equ 98  ;   Italic offset right          
LINEA_L_OFF             equ 100 ;   Italic offset left           
LINEA_SCALE             equ 102 ;   Scaling flag yes/no          
LINEA_CHUP              equ 104 ;   Character rotation angle *10 
LINEA_TEXT_FG           equ 106 ;   Text foreground colour       
LINEA_SCRTCHP           equ 108 ;   Pointer to 2 contiguous scratch buffers              
LINEA_SCRPT2            equ 112 ;   Index in buffer              
LINEA_TEXT_BG           equ 114 ;   Unused                       
LINEA_COPY_TRAN         equ 116 ;   --                           
LINEA_FILL_ABORT        equ 118 ;   Tests seedfill               

;---------------------------------------
; Line-A Negative Offsets
;---------------------------------------
LINEA_N_RESERVED6    EQU    -$38E   ; Reserved                     
LINEA_N_CUR_FONT     EQU    -$38A   ; Pointer->current font header 
LINEA_N_RESERVED5    EQU    -$386   ; Reserved                     
LINEA_N_M_POS_HX     EQU    -$358   ; X-coordinate mouse hot-spot  
LINEA_N_M_POS_HY     EQU    -$356   ; Y-coordinate mouse hot-spot  
LINEA_N_M_PLANES     EQU    -$354   ; Write mode for mouse pointer 
                                    ;   1=Replace, -1=XOR mode       
LINEA_N_M_CDB_BG     EQU    -$352   ; Mouse pointer backgr. colour 
LINEA_N_M_CDB_FG     EQU    -$350   ; Mouse pointer foregr. colour 
LINEA_N_MASK_FORM    EQU    -$34E   ; Mouse ptr. foregr. and mask  
                                    ;   Alternately 1 WORD           
                                    ;   foreground and mask          
LINEA_N_INQ_TAB      EQU    -$30E   ; As vq_extnd                  
LINEA_N_DEV_TAB      EQU    -$2B4   ; As v_opnwk                   
LINEA_N_GCURX        EQU    -$25A   ; Curr. mouse pointer X-posn.  
LINEA_N_GCURY        EQU    -$258   ; Curr. mouse pointer Y-posn.  
LINEA_N_M_HID_CT     EQU    -$256   ; Number of hide_mouse-calls   
LINEA_N_MOUSE_BT     EQU    -$254   ; Current mouse button status  
LINEA_N_REQ_COL      EQU    -$252   ; Internal data for vq_color   
LINEA_N_SIZ_TAB      EQU    -$1F2   ; As v_opnwk                   
LINEA_N_CUR_WORK     EQU    -$1D0   ; Attributes current workstn.  
LINEA_N_DEF_FONT     EQU    -$1CC   ; Standard system font         
LINEA_N_FONT_RING    EQU    -$1C8   ; System and GDOS font lists   
                                    ;   Chained FONT_HDR structures  
                                    ;   0 as terminator ID           
LINEA_N_FONT_COUNT   EQU    -$1B8   ; Total number of fonts        
LINEA_N_CUR_MS_STAT  EQU    -$15C   ; Mouse status since last      
                                    ;   Bit 0;    Left button (0=up) 
                                    ;   Bit 1;    Right button (0=up)
                                    ;   Bit 2..4; Reserved           
                                    ;   Bit 5;    1=Mouse moved      
                                    ;   Bit 6;    1=State of right   
                                    ;             button changed     
                                    ;   Bit 7;    1=State of left    
                                    ;             button changed     
LINEA_N_V_HID_CNT      EQU  -$15A   ; Number of Hide_cursor calls  
LINEA_N_CUR_X          EQU  -$158   ; X-position for mouse pointer 
LINEA_N_CUR_Y          EQU  -$156   ; Y-position for mouse pointer 
LINEA_N_CUR_FLAG       EQU  -$154   ; != 0; Redraw mouse ptr.in VBL
LINEA_N_MOUSE_FLAG     EQU  -$153   ; != 0; Mouse interrupt on     
LINEA_N_V_SAV_XY       EQU  -$14E   ; X-Y coordinates saved by VT52
LINEA_N_SAVE_LEN       EQU  -$14A   ; Number of screen lines       
LINEA_N_SAVE_ADDR      EQU  -$148   ; First bufered byte in screen 
                                    ;   memory                       
LINEA_N_SAVE_STAT      EQU   -$144  ; Dirty flag                   
                                    ;   Bit 0; 1=Buffer is valid     
                                    ;   Bit 1; 1=Long, 0=Word bufferd
LINEA_N_SAVE_AREA      EQU   -$142  ; Buffer for image under mouse 
LINEA_N_USER_TIM       EQU   -$42   ; Timer interrupt vector       
                                    ;   To terminate should jump to  
                                    ;   next_tim                     
LINEA_N_NEXT_TIM       EQU   -$3E   ; Old timer interrupt          
LINEA_N_USER_BUT       EQU   -$3A   ; Mouse button vector          
LINEA_N_USER_CUR       EQU   -$36   ; Mouse rendering vector       
LINEA_N_USER_MOT       EQU   -$32   ; Mouse movement vector        
LINEA_N_V_CEL_HT       EQU   -$2E   ; Current text cell height     
LINEA_N_V_CEL_MX       EQU   -$2C   ; Maximum column for cursor    
LINEA_N_V_CEL_MY       EQU   -$2A   ; Maximum line for cursor      
LINEA_N_V_CEL_WR       EQU   -$28   ; Bytes betwn. character cells 
LINEA_N_V_COL_BG       EQU   -$26   ; Text background colour       
LINEA_N_V_COL_FG       EQU   -$24   ; Text foreground colour       
LINEA_N_V_CUR_AD       EQU   -$22   ; Address of cursor position   
LINEA_N_V_CUR_OFF      EQU   -$1E   ; Vertical screen offset       
LINEA_N_V_CUR_XY       EQU   -$1C   ; X-Y position of text cursor  
LINEA_N_V_PERIOD       EQU   -$18   ; Current cursor blink rate    
LINEA_N_V_CUR_CT       EQU   -$17   ; Countdown timer for blink    
LINEA_N_V_FNT_AD       EQU   -$16   ; Addr. of monospace font data 
LINEA_N_V_FNT_ND       EQU   -$12   ; Last ASCII code in font      
LINEA_N_V_FNT_ST       EQU   -$10   ; First ASCII code in font     
LINEA_N_V_FNT_WD       EQU   -$E    ; Width of font form in bytes  
LINEA_N_V_REZ_HZ       EQU   -$C    ; Horizontal pixel resolution  
LINEA_N_V_OFF_AD       EQU   -$A    ; Address of font offset table 
LINEA_N_RESERVED       EQU   -$6    ; Cursorflag (TOS 1.00)/res.   
LINEA_N_V_REZ_VT       EQU   -$4    ; Vertical pixel resolution    
LINEA_N_BYTES_LIN      EQU   -$2    ; Bytes per screen line        
