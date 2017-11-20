    jsr     initialise
    move.w  #2,-(sp) ; get physbase
    trap    #14 
    addq.l  #2,a7
    move.l  d0,a0 ; a0 is screen mem pointer

    move.l  #7999,d1 ; size of screen mem
clrscr:
    clr.l   (a0)+ ; all 0's for black
    dbf     d1,clrscr
    move.l  d0,a0 ; reset screen ptr

    move.l  #1199,d0 ; 60 scanlines
fill1:
    move.w  #%1111111111111111,(a0)+ ; p1
    move.w  #%0000000000000000,(a0)+
    move.w  #%0000000000000000,(a0)+
    move.w  #%0000000000000000,(a0)+
    dbf     d0,fill1

    move.l  #1199,d0 ; Next 60 Scanlinew
fill2:
    move.w #%0000000000000000,(a0)+ 
    move.w #%1111111111111111,(a0)+ ; p2
    move.w #%0000000000000000,(a0)+
    move.w #%0000000000000000,(a0)+
    dbf d0,fill2

    move.l #1199,d0 ; Next 60 scanlines
fill3:
    move.w  #%1111111111111111,(a0)+  ; p3
    move.w  #%1111111111111111,(a0)+  ; p3
    move.w  #%0000000000000000,(a0)+ 
    move.w  #%0000000000000000,(a0)+
    dbf     d0,fill3

    move.w  #$000,$ff8240  ; black bg
    move.w  #$700,$ff8242  ; red colour 1
    move.w  #$070,$ff8244  ; green colour 2
    move.w  #$007,$ff8246  ; blue colour 3

    move.l #24,d5  ; 25 vblanks per loop
    move.w #6,d6   ; loop 7 times

main:
    move.w #37,-(a7)  ; wait vbl
    trap #14 
    addq.l #2,a7

    dbf d5,main ; loop vbls

    sub.w #$100,$ff8242 ; red--
    sub.w #$010,$ff8244 ; green--
    sub.w #$001,$ff8246 ; blue--

    move.l #24,d5   ; reset vbl counter
    dbf d6,main     ; end of main loop

    jsr restore

    clr -(a7) 
    trap #1

initialise:
    clr.l -(a7) ; clear stack
    move.w #32,-(a7) ; user mode
    trap #1
    addq.l #6,a7
    move.l d0,old_stack ; backup stack

    move.l #old_palette,a0 ;backup palette
    movem.l $ffff8240,d0-d7
    movem.l d0-d7,(a0)

    move.w #2,-(a7) ; physbase
    trap #14
    addq.l #2,a7
    move.l d0,old_screen ; save old address

    move.w #4,-(a7) ; get resolution and save
    trap #14
    addq.l #2,a7
    move.w d0,old_resolution

    move.w #0,-(a7)  ; low res
    move.l #-1,-(a7) ; keep physbase
    move.l #-1,-(a7) ; keep logbase
    move.w #5,-(a7)  ; change screen
    trap #14
    add.l #12,a7

    rts

restore:
    move.w old_resolution,d0 ; put res in d0
    move.w d0,-(a7)          ; push res
    move.l old_screen,d0     ; screen in d0
    move.l d0,-(a7)          ; push physbase
    move.l d0,-(a7)          ; push logbase
    move.w #5,-(a7)          ; change screen
    trap #14 
    add.l #12,a7

    move.l #old_palette,a0 ; palette ptr
    movem.l (a0),d0-d7     ; move palette data
    movem.l d0-d7,$ffff8240; go

    move.l old_stack,-(a7) ; restore old stack
    move.w #32,-(a7)       ; user mode
    trap #1                ; gemdos
    addq.l #6,a7           ; align
    
    rts

    section data

old_resolution: dc.w    0
old_stack:      dc.l    0
old_screen:     dc.l    0

    section bss

old_palette:    ds.l    8
