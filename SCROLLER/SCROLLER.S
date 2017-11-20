
	include "GEMDOS.S" 
	include "XBIOS.S" 

	jsr	    initialise

	movem.l	font_data+2,d0-d7
	movem.l	d0-d7,$ff8240
	; get physbase
	move.w	#XBIOS_PHYSBASE,-(sp)	    
	trap	#TRAP_XBIOS
	addq.l	#2,sp	
    ; store screen memory
	move.l	d0,screen_ptr      	 				
	
main:
    ; wait vbl
	move.w	#XBIOS_VSYNC,-(sp)	
	trap	#TRAP_XBIOS
	addq.l	#2,sp	
    ; check if new character in message
	cmp	    #0,font_counter 
    ; if not, skip get new character
	bne	    has_character   
    ; reset font_counter
	move.w	#2,font_counter	

    ; we need to point to a new characetr in the font
    ; pointer into the message
	move.l	message_ptr,a0	
    ; clear, just to be sure
	clr.l	d0		        
    ; put letter ascii value in d0
	move.b	(a0),d0		    
    ; end of message?
	cmp	    #0,d0           
    ; if not, branch
	bne	    not_end	        
	; reset message_pointer
	move.l	#message_data,message_ptr	
    ; clear, just to be sure
	move.l	message_ptr,a0
	clr.l	d0		                    
    ; put letter ascii value in d0
	move.b	(a0),d0		                
	
not_end:
    ; now we have a character in d0 for sure
    ; point to next character
	add.l	#1,message_ptr		
    ; align ascii with font number
	sub.b	#$20,d0	        	
    ; 10 letters per row
	divu	#10,d0		    	
    ; d1 contains y value
	move.w	d0,d1		    	
	swap	d0
    ; d2 contains x value
	move.w	d0,d2		    	
    ; 16 bytes for each letter
	mulu	#16,d2		    	
    ; 32 lines per row
	mulu	#32,d1		    	
    ; 160 bytes per row
	mulu	#160,d1		    	
    ; put font screen start in a0
	move.l	#font_data+34,a0    
    ; add x and y value together
	add.l	d2,d1		        
    ; a0 points to correct letter
	add.l	d1,a0		        
    ; store calculated pointer
	move.l	a0,font_addr	    
		
has_character:
	sub.w	#1,font_counter	
	move.l	screen_ptr,a0
	move.l	screen_ptr,a1
	move.l	font_addr,a2
    ; put a1 16 pixels ahead of a0
	add.l	#8,a1		    
    ; 32 lines to scroll
	move.l	#31,d1		    
    ; 19 16 pixel clusters + font part
	move.l	#18,d0		    
scroll:
	move.w	(a1)+,(a0)+	
	move.w	(a1)+,(a0)+	
	move.w	(a1)+,(a0)+
    ; 16 pixels moved
	move.w	(a1)+,(a0)+	    
    ; keep moving 16 pixel clusters
	dbf	    d0,scroll	    
    ; reset loop counter
	move.l	#18,d0		    
    ; 16 pixels of the font
    ; character moved in
	move.w	(a2),(a0)+
	move.w	2(a2),(a0)+
	move.w	4(a2),(a0)+	     
	move.w	6(a2),(a0)+	    	
    ; increment screen pointer, align with a0
	add.l	#8,a1		    
    ; next line of font
	add.l	#160,a2		    
    ; do another line
	dbf	    d1,scroll	    
    ; move 16 pixels forward in font
	add.l	#8,font_addr	

is_space_pressed:
    ; space pressed?
	cmp.b	#$39,$fffc02	
    ; if not, repeat main
	bne	    main			

we_done_here:
	jsr		restore
	clr.l	-(sp)
	trap	#TRAP_GEMDOS

	include	"INIT.S"

	section data

font_data:	
    incbin	"FONT.PI1"

screen_ptr:     dc.l	0
font_addr:      dc.l	0
font_counter:   dc.w	0

message_data:
	dc.b	"A  COOL  SCROLLER!    BUT  A  BIT  FAST,"
	dc.b	"  SCROLLING  16  PIXELS  EACH  VBL."
	dc.b	"    THAT'S 2.5 SCREENS EACH SECOND!"
	dc.b	"             ",0

message_ptr:
    dc.l	message_data
