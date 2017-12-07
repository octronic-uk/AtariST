;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/
; 
;      ash@octronic.co.uk      
;
;   XBIOS.S 
;       Atari ST XBIOS Function List

    section text

XB_get_screen_res:
	move.w	#XBIOS_GETRES,-(sp)
	trap	#TRAP_XBIOS
	addq.l	#2,sp
	addq.w	#2,d0					; Add 2 to correct res
	move.w	d0,XB_SCREEN_RES
	rts


    section bss

XB_SCREEN_RES:		ds.w	1

TRAP_XBIOS          equ $0E

;-----------------------------
; Functions
;-----------------------------

XBIOS_INITMOUSE     equ	$00
XBIOS_SSBRK         equ	$01
XBIOS_PHYSBASE      equ	$02
XBIOS_LOGBASE       equ	$03
XBIOS_GETRES        equ	$04
XBIOS_SETSCREEN     equ	$05
XBIOS_SETPALETTE    equ	$06
XBIOS_SETCOLOR      equ	$07
XBIOS_FLOPRD        equ	$08
XBIOS_FLOPWR        equ	$09
XBIOS_FLOPFMT       equ	$0A
XBIOS_MIDIWS        equ	$0C
XBIOS_MFPINT        equ	$0D
XBIOS_IOREC         equ	$0E
XBIOS_RSCONF        equ	$0F
XBIOS_KEYTBL        equ	$10
XBIOS_RANDOM        equ	$11
XBIOS_PROTOBT       equ	$12
XBIOS_FLOPVER       equ	$13
XBIOS_SCRDMP        equ	$14
XBIOS_CURSCONF      equ	$15
XBIOS_SETTIME       equ	$16
XBIOS_GETTIME       equ	$17
XBIOS_BIOSKEYS      equ	$18
XBIOS_IKBDWS        equ	$19
XBIOS_JDISINT       equ	$1A
XBIOS_JENABINT      equ	$1B
XBIOS_GIACCESS      equ	$1C
XBIOS_OFFGIBIT      equ	$1D
XBIOS_ONGIBIT       equ	$1E
XBIOS_XBTIMER       equ	$1F
XBIOS_DOSOUND       equ	$20
XBIOS_SETPRT        equ	$21
XBIOS_KBDVBASE      equ	$22
XBIOS_KBRATE        equ	$23
XBIOS_PRTBLK        equ	$24
XBIOS_VSYNC         equ	$25
XBIOS_SUPEXEC       equ	$26
XBIOS_PUNTAES       equ	$27
XBIOS_FLOPRATE      equ	$29
XBIOS_DMAREAD       equ	$2A
XBIOS_DMAWRITE      equ	$2B
XBIOS_BCONMAP       equ	$2C
XBIOS_NVMACCESS     equ	$2E
XBIOS_WAKETIME      equ	$2F
XBIOS_BLITMODE      equ	$40
XBIOS_ESETSHIFT     equ	$50
XBIOS_EGETSHIFT     equ	$51
XBIOS_ESETBANK      equ	$52
XBIOS_ESETCOLOR     equ	$53
XBIOS_ESETPALETTE   equ	$54
XBIOS_EGETPALETTE   equ	$55
XBIOS_ESETGRAY      equ	$56
XBIOS_ESETSMEAR     equ	$57
XBIOS_VSETMASK      equ	$96
