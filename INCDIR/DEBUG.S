
    section text
    
FATAL_ERROR:
    move.w  #ASCII_CR,-(sp)
    move.w  #GEMDOS_CCONOUT,-(sp)
    trap    #TRAP_GEMDOS
    addq.l  #4,sp
    move.w  #ASCII_LF,-(sp)
    move.w  #GEMDOS_CCONOUT,-(sp)
    trap    #TRAP_GEMDOS
    addq.l  #4,sp
	move.l	4(sp),-(sp)	
	move.w	#GEMDOS_CCONWS,-(sp)
	trap	#TRAP_GEMDOS
	addq.l	#6,sp
	move.w	#GEMDOS_CCONIN,-(sp)
	trap	#TRAP_GEMDOS
	addq.l	#2,sp
	move.w	#GEMDOS_PTERM0,-(sp)
	trap	#TRAP_GEMDOS

DEBUG:
    move.w  #ASCII_CR,-(sp)
    move.w  #GEMDOS_CCONOUT,-(sp)
    trap    #TRAP_GEMDOS
    addq.l  #4,sp
    move.w  #ASCII_LF,-(sp)
    move.w  #GEMDOS_CCONOUT,-(sp)
    trap    #TRAP_GEMDOS
    addq.l  #4,sp
	move.l	4(sp),-(sp)	
	move.w	#GEMDOS_CCONWS,-(sp)
	trap	#TRAP_GEMDOS
	addq.l	#6,sp
	move.w	#GEMDOS_CCONIN,-(sp)
	trap	#TRAP_GEMDOS
	addq.l	#2,sp
	rts


