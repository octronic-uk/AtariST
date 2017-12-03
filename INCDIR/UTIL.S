
    section text 

ZERO_ARRAY:
	move.w	4(sp),d0	; size
	movea.l	6(sp),a0	; pointer
	subq.w	#1,d0		; size-1
_ZERO_ARRAY_next:
	move.w	#0,(a0)+
	dbra	d0,_ZERO_ARRAY_next
	rts


