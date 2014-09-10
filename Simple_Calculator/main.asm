;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

            .data

ANSWER:		.space	20
ADD_OP:		.equ	0x11
SUB_OP:		.equ	0x22
CLR_OP:		.equ	0x44
END_OP:		.equ	0x55
MUL_OP:		.equ	0x33
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
Calc_Instr: .byte	0x09, 0x11, 0x01, 0x22, 0x05, 0x55		        ; section


;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
                                            ; Main loop here

    		mov.w	#Calc_Instr, r4
    		mov.w		#ANSWER, r5

    		mov.b 	0(r4), r8			;The first number that we want to manipulate
    		inc		r4
main   		mov.b   0(r4), r6
			inc		r4

    		cmp		#ADD_OP, r6
    		jz		ADD

    		cmp		#SUB_OP, r6
    		jz		SUB

    		cmp		#CLR_OP, r6
    		jz		CLR

    		cmp		#MUL_OP, r6
    		jz		MULT

    		cmp		#END_OP, r6
    		jmp		forever

;--------------------------End of If Statement Testing---------------------------------------;

ADD
			mov.b	0(r4), r7
			inc		r4

			add.b	r8, r7
			mov.b	r7, 0(r5)
			mov.b	r7, r8   			;r8 will hold the previous value and the first value as seen before
			inc		r5

			cmp		#255, r8
			jz		setHigh

			jmp		main
SUB
			mov.b	0(r4), r7
			inc		r4

			sub.b	r7, r8
			mov.b	r8, 0(r5)
			inc		r5

			cmp		#0, r8
			jz		setHigh

			jmp		main

CLR
			mov.b	#0, r8
			mov.b	r8, 0(r5)
			inc		r5
			jmp		main

MULT								;r8  x  r7...   r9 = # of iterations... r10 = summer
			mov.b	0(r4), r7
			inc		r4
			mov		r7, r11			;r11 will be the one that we are manipulating in the multLoop
			mov		#0, r3			;keep track of how many left shifts
			mov		#0, r10

			mov		r7, r9
			clrc
			rrc		r9			;now r9 equals the number of iterations
									;we have to go through mult loop
			mov		#1, r12 		;r12 will be my count up for bit to "and" with
			jmp 	multLoop

multLoop
			mov		r7, r11
			and.w	#r12, r11
			cmp		#1, r11
			jnz		addLeftS
			jmp		addZero
comeBack
			rla.w	r12
			inc		r3
			cmp		r3, r9
			jnz		multLoop		;if not done with iterations, continue

			mov.b	r10, r8
			mov.b	r8, 0(r5)
			inc		r5
			jmp		main			;otherwise, store everything and jump back to main


addLeftS
			tst		r3
			jnz		onWard
			add		r8, r10
			jmp		comeBack
onWard												;something still wrong with # of shift lefts.
			rla.w	r8
			add		r8, r10
			jmp		comeBack

addZero		jmp		multLoop			;here just for consistency and thought process


setHigh
			mov.b	#255, r8
			mov.b	r8, 0(r5)
			jmp		main

setLow
			mov.b	#0, r8
			mov.b	r8, 0(r5)
			jmp		main


forever		jmp		forever



;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
