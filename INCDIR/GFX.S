;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk      
;
;   GFX.S 
;       Atari ST Graphics Helper

; Screen Addresses
GFX_SCREEN_MEM_HIGH equ $FF8201
GFX_SCREEN_MEM_LOW  equ $FF8203
; VRAM Address Pointer
GFX_VRAM_HIGH       equ $FF805
GFX_VRAM_MED        equ $FF807
GFX_VRAM_LOW        equ $FF809

GFX_SYNC_MODE       equ $FF820A

GFX_SCREEN_ADDR_HI  equ $FF820D

; Palette Addresses
GFX_PALETTE_0       equ $FF8240
GFX_PALETTE_1       equ $FF8242
GFX_PALETTE_2       equ $FF8244
GFX_PALETTE_3       equ $FF8246
GFX_PALETTE_4       equ $FF8248
GFX_PALETTE_5       equ $FF824A
GFX_PALETTE_6       equ $FF824C
GFX_PALETTE_7       equ $FF824E
GFX_PALETTE_8       equ $FF8250
GFX_PALETTE_9       equ $FF8252
GFX_PALETTE_10      equ $FF8254
GFX_PALETTE_11      equ $FF8256
GFX_PALETTE_12      equ $FF8258
GFX_PALETTE_13      equ $FF825A
GFX_PALETTE_14      equ $FF825C
GFX_PALETTE_15      equ $FF825E

; Resolution
GFX_RESOLUTION      equ $FF8260

