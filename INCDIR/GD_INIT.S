
	section text
	
memory_init:                            ; Set base page address in a5
    move.l a7,a5                        ; Save a7 so we can get the base page address 
    move.l BASE_PAGE_PTR(a5),a5         ; a5 = basepage addressk
                                        ; Calculate the total amount of memory used by
                                        ; our program (including stack space) in d0
                                        ; total memory used =
    move.l  CODE_SZ(a5),d0              ; length of code segment
    add.l   DATA_SZ(a5),d0              ; + length of data segment
    add.l   BSS_SZ(a5),d0               ; + length of uninitialized storage segment 
    add.l   #STACK_SZ+BASE_PAGE_SZ,d0   ; + (size of the base page + our stack)
                                        ; Calculate the size of our stack and move it to the stack pointer
                                        ; stack address =
    move.l d0,d1                        ;   size of program memory
    add.l a5,d1                         ; + program's base address,
    and.l #-2,d1                        ; pick off odd bit to make sure that the  
                                        ; stack starts on a word boundary (it must).  
    move.l d1,a7                        ; set stack pointer to our stack
                                        ; which is stk bytes above end of BSS
                                        ; Use the GEMD0S SETBLOCK call to reserve the area of memory 
                                        ; actually used for the program and stack, and release the 
                                        ; rest back to the free memory pool.
    move.l  d0,-(sp)                    ; push the size of program memory
                                        ; (first SETBLOCK parameter) on the stack.
    move.l  a5,-(sp)                    ; push the beginning address of the
                                        ; program memory area (2nd SETBLOCK parameter), 
    clr.w   -(sp)                       ; clear a dummy place-holder word
    move.w  #GEMDOS_MSHRINK,-(sp)       ; finally, push the GEMDOS command number
                                        ; for the SETBLOCK function
    trap    #TRAP_GEMDOS                ; call GEMDOS
    add.l   #12,sp                      ; and clear our arguments off the stack,

BASE_PAGE_PTR           EQU 4       ; Stack offset to base page address
CODE_SZ                 EQU 12      ; Base page offset to Code segment length
DATA_SZ                 EQU 20      ; Base page offset to Data segment length n
BSS_SZ                  EQU 28      ; Base page offset to BSS segment length
STACK_SZ                EQU $400    ; size of our stack (IK)
BASE_PAGE_SZ            EQU $100    ; size of base page
