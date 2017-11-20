;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk      
;
;   INIT.S 
;       Atari ST Initialisation Helper

; set supervisor
initialise:
    ; prepare for user mode
	clr.l	-(a7)			
    ; call gemdos
	move.w	#32,-(a7)		
	trap	#1			    
    ; clean up stack
	addq.l	#6,a7			
    ; backup old stack pointer
	move.l	d0,old_stack	
    ; end set supervisor

    ; save the old palette; old_palette
    ; put backup address in a0
	move.l	#old_palette,a0		
    ; all palettes in d0-d7
	movem.l	$ffff8240,d0-d7		
    ; move data into old_palette
	movem.l	d0-d7,(a0)		
    ; end palette save
    ; saves the old screen adress
    ; get physbase
	move.w	#2,-(a7)		
	trap	#14
	addq.l	#2,a7
    ; save old screen address
	move.l	d0,old_screen		
    ; end screen save
    ; save the old resolution into old_resolution
    ; and change resolution to low (0)
    ; get resolution
	move.w	#4,-(a7)		
	trap	#14
	addq.l	#2,a7
    ; save resolution
	move.w	d0,old_resolution	
	; low resolution
	move.w	#0,-(a7)		
    ; keep physbase
	move.l	#-1,-(a7)		
    ; keep logbase
	move.l	#-1,-(a7)		
    ; change screen
	move.w	#5,-(a7)		
	trap	#14
	add.l	#12,a7
    ; end resolution save	
	rts

restore:	
    ; restores the old resolution and screen adress
    ; res in d0
	move.w	old_resolution,d0	
    ; push resolution
	move.w	d0,-(a7)		
    ; screen in d0
	move.l	old_screen,d0		
    ; push physbase
	move.l	d0,-(a7)		
    ; push logbase
	move.l	d0,-(a7)		
    ; change screen
	move.w	#5,-(a7)		
	trap	#14
	add.l	#12,a7
    ; end resolution and screen adress restore
    ; restores the old palette
    ; palette pointer in a0
	move.l	#old_palette,a0		
    ; move palette data
	movem.l	(a0),d0-d7		    
    ; smack palette in
	movem.l	d0-d7,$ffff8240		
    ; end palette restore
    ; set user mode again
    ; restore old stack pointer
	move.l	old_stack,-(a7)		
    ; back to user mode
	move.w	#32,-(a7)		
    ; call gemdos
	trap	#1			
    ; clear stack
	addq.l	#6,a7			
    ; end set user
	rts

	section data

old_resolution: dc.w	0
old_stack:      dc.l	0
old_screen:     dc.l	0

	section bss

old_palette:    ds.l	8
