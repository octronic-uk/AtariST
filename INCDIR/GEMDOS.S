;  ______   ______   __  __
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk      
;
;   GEMDOS.S 
;       Atari ST GEMDOS Functions

TRAP_GEMDOS     equ $01   

; ----------------------------
; Functions
; ----------------------------

GEMDOS_PTERM0	equ	$00
GEMDOS_CCONIN	equ	$01
GEMDOS_CCONOUT	equ	$02
GEMDOS_CAUXIN	equ	$03
GEMDOS_CAUXOUT	equ	$04
GEMDOS_CPRNOUT	equ	$05
GEMDOS_CRAWIO	equ	$06
GEMDOS_CRAWCIN	equ	$07
GEMDOS_CNECIN	equ	$08
GEMDOS_CCONWS	equ	$09
GEMDOS_CCONRS	equ	$0A
GEMDOS_CCONIS	equ	$0B
GEMDOS_DSETDRV	equ	$0E
GEMDOS_CCONOS	equ	$10
GEMDOS_CPRNOS	equ	$11
GEMDOS_CAUXIS	equ	$12
GEMDOS_CAUXOS	equ	$13
GEMDOS_MADDALT	equ	$14
GEMDOS_DGETDRV	equ	$19
GEMDOS_FSETDTA	equ	$1A
GEMDOS_SUPER	equ	$20
GEMDOS_TGETDATE	equ	$2A
GEMDOS_TSETDATE	equ	$2B
GEMDOS_TGETTIME	equ	$2C
GEMDOS_TSETTIME	equ	$2D
GEMDOS_FGETDTA	equ	$2F
GEMDOS_SVERSION	equ	$30
GEMDOS_PTERMRES	equ	$31
GEMDOS_DFREE	equ	$36
GEMDOS_DCREATE	equ	$39
GEMDOS_DDELETE	equ	$3A
GEMDOS_DSETPATH	equ	$3B
GEMDOS_FCREATE	equ	$3C
GEMDOS_FOPEN	equ	$3D
GEMDOS_FCLOSE	equ	$3E
GEMDOS_FREAD	equ	$3F
GEMDOS_FWRITE	equ	$40
GEMDOS_FDELETE	equ	$41
GEMDOS_FSEEK	equ	$42
GEMDOS_FATTRIB	equ	$43
GEMDOS_MXALLOC	equ	$44
GEMDOS_FDUP     equ	$45
GEMDOS_FFORCE	equ	$46
GEMDOS_DGETPATH	equ	$47
GEMDOS_MALLOC	equ	$48
GEMDOS_MFREE	equ	$49
GEMDOS_MSHRINK	equ	$4A
GEMDOS_PEXEC	equ	$4B
GEMDOS_PTERM	equ	$4C
GEMDOS_FSFIRST	equ	$4E
GEMDOS_FSNEXT	equ	$4F
GEMDOS_FRENAME	equ	$56
GEMDOS_FDATIME	equ	$57
