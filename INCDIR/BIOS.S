;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk      
;
;   BIOS.S 
;       Atari ST BIOS Function Definitions

TRAP_BIOS       equ $0D

; ----------------------------
; Functions
; ----------------------------

BIOS_GETMPB     equ	$00
BIOS_BCONSTAT	equ	$01
BIOS_BCONIN	    equ	$02
BIOS_BCONOUT	equ	$03
BIOS_RWABS	    equ	$04
BIOS_SETEXC	    equ	$05
BIOS_TICKCAL	equ	$06
BIOS_GETBPB	    equ	$07
BIOS_BCOSTAT	equ	$08
BIOS_MEDIACH	equ	$09
BIOS_DRVMAP	    equ	$0A
BIOS_KBSHIFT	equ	$0B

