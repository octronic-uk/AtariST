;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk      
;
;   JSON.S
;       JSON Parser

    section text

;---------------------------------------
; Constants
;---------------------------------------

; Types
JSON_TYPE_INVALID   equ 0
JSON_TYPE_OBJECT    equ 1
JSON_TYPE_ARRAY     equ 2
JSON_TYPE_STRING    equ 3
JSON_TYPE_BOOL      equ 4
JSON_TYPE_NULL      equ 5
JSON_TYPE_NUMBER    equ 6

; Work Offsets
JSON_WORK_INPUT_PTR equ 0
JSON_WORK_TYPE      equ 4

;---------------------------------------
; Functions
;---------------------------------------

; Usage
;   pea			JSON_STRING
;   jsr			JSON_Parse
;   addq.l		#JSON_PARSE_ALIGN,sp
;
JSON_ARG_WORK_PTR   equ 4
JSON_PARSE_ALIGN    equ 4

JSON_Parse:
    movea.l     JSON_ARG_WORK_PTR(sp),a0
    movea.l     JSON_WORK_INPUT_PTR(a0),a1 
    jsr         JSON_ParseType
    rts

JSON_Parse_NextChar:
    addq.l      #1,a1
    rts

JSON_ParseType:
    
    cmpi.b      #ASCII_CURLY_L,(a1)         ; Check for '{'
    beq         _JSON_ParseType_CurlyL  
    
    cmpi.b      #ASCII_SQUARE_L,(a1)         ; Check for '['
    beq         _JSON_ParseType_SquareL
    
    cmpi.b      #ASCII_DOUBLE_QUOTE,(a1)    ; Check for '"'
    beq         _JSON_ParseType_DoubleQuote
    
    cmpi.b      #ASCII_t,(a1)               ; Check for 't'  
    beq         _JSON_ParseType_LowerT
    
    cmpi.b      #ASCII_f,(a1)               ; Check for 'f'  
    beq         _JSON_ParseType_LowerF
    
    cmpi.b      #ASCII_n,(a1)               ; Check for 'n'  
    beq         _JSON_ParseType_LowerN  
    
    cmpi.b      #ASCII_MINUS,(a1)           ; Check for '-'
    beq         _JSON_ParseType_Minus
    
    cmpi.b      #ASCII_0,(a1)               ; Check number range
    blt         _JSON_ParseType_LessThanZero
    
    cmpi.b      #ASCII_9,(a1)
    ble         _JSON_ParseType_NineOrLess
    
_JSON_ParseType_LessThanZero:
    jmp     	_JSON_ParseType_Invalid

_JSON_ParseType_NineOrLess:
    move.w  	#JSON_TYPE_NUMBER,JSON_WORK_TYPE(a0)
    jmp     	_JSON_ParseType_Done

_JSON_ParseType_CurlyL:
    move.w  	#JSON_TYPE_OBJECT,JSON_WORK_TYPE(a0)
    jmp     	_JSON_ParseType_Done

_JSON_ParseType_SquareL:
    move.w  	#JSON_TYPE_ARRAY,JSON_WORK_TYPE(a0)
    jmp     	_JSON_ParseType_Done

_JSON_ParseType_DoubleQuote:
    move.w  	#JSON_TYPE_STRING,JSON_WORK_TYPE(a0)
    jmp     	_JSON_ParseType_Done

_JSON_ParseType_LowerT:
    move.w  	#JSON_TYPE_BOOL,JSON_WORK_TYPE(a0)
    jmp     	_JSON_ParseType_Done

_JSON_ParseType_LowerF:
    move.w  	#JSON_TYPE_BOOL,JSON_WORK_TYPE(a0)
    jmp     	_JSON_ParseType_Done

_JSON_ParseType_LowerN:
    move.w  	#JSON_TYPE_NULL,JSON_WORK_TYPE(a0)
    jmp     	_JSON_ParseType_Done

_JSON_ParseType_Minus:
    move.w  	#JSON_TYPE_NUMBER,JSON_WORK_TYPE(a0)
    jmp     	_JSON_ParseType_Done

_JSON_ParseType_Invalid:
    move.w  	#JSON_TYPE_INVALID,JSON_WORK_TYPE(a0)

_JSON_ParseType_Done:
    rts

    include "ASCII.S"
