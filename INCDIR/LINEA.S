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
