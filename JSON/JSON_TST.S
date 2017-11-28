;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk      
;
;   JSON_TST.S
;       JSON Parser Testing Suite

	section text

JSONTest_Main:
   	
   	; Welcome 
    jsr		_JSONTest_Intro
    
    ; Test Functionality
    jsr     _JSONTest_Object
    jsr     _JSONTest_Array
    jsr     _JSONTest_String
    jsr     _JSONTest_Number
    jsr     _JSONTest_Bool
    jsr     _JSONTest_Null
    
    ; Exit Application
    move.w	#GEMDOS_PTERM0,-(sp)
    trap	#TRAP_GEMDOS
    
    
_JSONTest_Intro:
	jsr		_NEWLINE
	pea 	_STR_INTRO_MSG	
    jsr		_DEBUG
    jsr		_ANY_KEY
    addq.l	#_DEBUG_ALIGN,sp
    rts

; Object Test Functions ----------------    
    
_JSONTest_Object:
	jsr		_NEWLINE
	pea		_STR_TEST_OBJECT_MSG
	jsr		_DEBUG
	jsr		_JSONTest_Object_Type
	rts
	
	
_JSONTest_Object_Type:
	
	jsr		_NEWLINE
	pea		_STR_TEST_OBJECT_TYPE_MSG
	jsr		_DEBUG
	
	move.l	#_STR_JSON_TEST_OBJECT,_JSON_TEST_WORK_INPUT_PTR
	move.w	#0,_JSON_TEST_WORK_TYPE
	
	pea		_JSON_TEST_WORK_START
	jsr		JSON_Parse
	addq.l	#JSON_PARSE_ALIGN,sp
	
	cmpi.w	#JSON_TYPE_OBJECT,_JSON_TEST_WORK_TYPE
	beq		_JSONTest_Object_Type_Passed
	
_JSONTest_Object_Type_Failed:
	pea		_STR_FAILED_MSG
	jmp		_JSONTest_Object_Type_Output

_JSONTest_Object_Type_Passed:
	pea		_STR_PASSED_MSG
	
_JSONTest_Object_Type_Output:
	jsr		_DEBUG
	addq.l	#_DEBUG_ALIGN,sp
	jsr		_NEWLINE
	jsr		_ANY_KEY
	rts

; Array Test Functions -----------------

_JSONTest_Array:
	jsr		_JSONTest_Array_Type
    jsr     _JSONTest_Array_Numbers
    jsr     _JSONTest_Array_String
    rts


_JSONTest_Array_Type:
	
	move.l	#_STR_JSON_TEST_NUM_ARRAY,_JSON_TEST_WORK_INPUT_PTR
	move.w	#0,_JSON_TEST_WORK_TYPE
	
	pea		_JSON_TEST_WORK_START
	jsr		JSON_Parse
	addq.l	#JSON_PARSE_ALIGN,sp
	
	cmpi.w	#JSON_TYPE_ARRAY,_JSON_TEST_WORK_TYPE
	beq		_JSONTest_Array_Type_Passed

	
_JSONTest_Array_Type_Failed:
	jmp		_JSONTest_Array_Type_Failed

_JSONTest_Array_Type_Passed:
	rts


_JSONTest_Array_Numbers:
	rts


_JSONTest_Array_String:
	rts


; String Test Functions ----------------

_JSONTest_String:
    rts
    
    
; Number Test Functions ----------------

_JSONTest_Number:
    jsr     _JSONTest_Number_Int
    jsr     _JSONTest_Number_Int_Neg
    jsr     _JSONTest_Number_Real
    jsr     _JSONTest_Number_Real_Neg
    jsr     _JSONTest_Number_Sci
    jsr     _JSONTest_Number_Sci_Neg
    rts


_JSONTest_Number_Int:
	rts

	
_JSONTest_Number_Int_Neg:
	rts


_JSONTest_Number_Real:
	rts

	
_JSONTest_Number_Real_Neg:
	rts

	
_JSONTest_Number_Sci:
	rts

	
_JSONTest_Number_Sci_Neg:
    rts


; Bool Test Functions ------------------

_JSONTest_Bool:
    jsr     _JSONTest_Bool_True
    jsr     _JSONTest_Bool_False
    rts


_JSONTest_Bool_True:
	rts

	
_JSONTest_Bool_False:
	rts


; Null Test Functions ------------------


_JSONTest_Null:
    rts


; Output Functions ---------------------


_FATAL_ERROR:
	move.l	4(sp),-(sp)	
	move.w	#GEMDOS_CCONWS,-(sp)
	trap	#TRAP_GEMDOS
	addq.l	#6,sp
	move.w	#GEMDOS_CCONIN,-(sp)
	trap	#TRAP_GEMDOS
	addq.l	#2,sp
	move.w	#GEMDOS_PTERM0,-(sp)
	trap	#TRAP_GEMDOS


_DEBUG:
	move.l	4(sp),-(sp)	
	move.w	#GEMDOS_CCONWS,-(sp)
	trap	#TRAP_GEMDOS
	addq.l	#6,sp
	rts
	
_ANY_KEY
	move.w	#GEMDOS_CCONIN,-(sp)
	trap	#TRAP_GEMDOS
	addq.l	#2,sp
	rts


_NEWLINE:
	pea		_STR_NEWLINE
	move.w	#GEMDOS_CCONWS,-(sp)
	trap	#TRAP_GEMDOS
	addq.l	#6,sp
	rts

_DEBUG_ALIGN				EQU 4
_FATAL_ERROR_ALIGN			EQU 4


; Data Section -------------------------

    section data

; Debug Messages -----------------------

	even
_STR_NEWLINE:
	dc.b	ASCII_CR,ASCII_LF,0
	
	even
_STR_INTRO_MSG:			 
	dc.b	"JSON Library Test Suite. Press any key to get it over with...",0

	even
_STR_TEST_OBJECT_MSG:
	dc.b	"Testing Object Functions... ",0
	
	even
_STR_TEST_OBJECT_TYPE_MSG
	dc.b	"Testing Object Type Identification... ",0
	
	even
_STR_PASSED_MSG:
	dc.b	"Passed!",0
	
	even
_STR_FAILED_MSG:
	dc.b	"Failed!",0
	
; Test JSON Strings --------------------
	
    even
_STR_JSON_TEST_OBJECT:       
	dc.b    '{ "key" : "value" }',0

    even
_STR_JSON_TEST_NUM_ARRAY:    
	dc.b    '[1,2,3,4,5]',0

    even
_STR_JSON_TEST_STR_ARRAY:    
	dc.b    '["ONE","TWO","3","FOUR"4]',0

    even
_STR_JSON_TEST_INT:          
	dc.b    '1432',0

    even
_STR_JSON_TEST_REAL:         
	dc.b    '143.245',0

    even
_STR_JSON_TEST_NEG_INT:      
	dc.b    '-1432',0

    even
_STR_JSON_TEST_NEG_REAL:     
	dc.b    '-182.345',0

    even
_STR_JSON_TEST_SCI:      	
	dc.b    '6.4e+4',0

    even
_STR_JSON_TEST_NEG_SCI:  	
	dc.b    '1.4e-10',0

	even
_STR_JSON_TEST_BOOL_TRUE:	
	dc.b	"true",0

	even
_STR_JSON_TEST_BOOL_FALSE:	
	dc.b	"false",0

	even
_STR_JSON_TEST_NULL:		
	dc.b	"null",0

	even
_STR_JSON_TEST_STRING:		
	dc.b	'"Double Quote String"',0

; JSON Work Area Size ------------------

	even
_JSON_TEST_WORK_SIZE:       
	dc.l    _JSON_TEST_WORK_END-_JSON_TEST_WORK_START

; BSS ----------------------------------

    section bss

_JSON_TEST_WORK_START:        
_JSON_TEST_WORK_INPUT_PTR:  	ds.l	1
_JSON_TEST_WORK_TYPE:			ds.w	1
_JSON_TEST_WORK_VALUE_START:	ds.l	1
_JSON_TEST_WORK_VALUE_END:		ds.l	1
_JSON_TEST_WORK_END:

; Includes -----------------------------

	include "ASCII.S"
	include "GEMDOS.S"
	include "JSON.S"

; End of File --------------------------
	
	end