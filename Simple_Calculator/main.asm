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
Calc_Instr: .byte	0x22, 0x11, 0x22, 0x22, 0x33, 0x33, 0x08, 0x44, 0x08, 0x22, 0x09, 0x44, 0xff, 0x11, 0xff, 0x44, 0xcc, 0x33, 0x02, 0x33, 0x00, 0x44, 0x33, 0x33, 0x08, 0x55		        ; section


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

			cmp		#256, r8
			jge		setHigh

			jmp		main
SUB
			mov.b	0(r4), r7
			inc		r4

			cmp		r8, r7				;first check if the answer will be negative before you perform the operation
			jge		setLow
			sub.b	r7, r8
			mov.b	r8, 0(r5)
			inc		r5
			jmp		main

CLR
			inc		r4
			mov.b	#0, r8
			mov.b	r8, 0(r5)
			inc		r5
			jmp		main

MULT								;r8  x  r7...   r9 = # of iterations... r10 = summer
			mov.b	0(r4), r7
			inc		r4
			mov		r7, r11			;r11 will be the one that we are manipulating in the multLoop
			mov		#0, r14			;r14 will keep track of how many left shifts
			mov		#0, r10

			tst		r8
			jz		setHigh

			tst		r7
			jz		setLow

			mov		r7, r9
			clrc
			rrc		r9
			add		#1, r9			;now r9 equals the number of iterations
									;we have to go through mult loop
			mov		#1, r12 		;r12 will be my count up for bit to "and" with
			jmp 	multLoop

multLoop
			mov		r14,	r6				;r6 will decrement while adding left shifts to get the correct number of left shifts
			mov		r8, r13
			mov		r7, r11
			and.w	r12, r11
			cmp		r12, r11
			jz		addLeftS
			jmp		comeBack
comeBack
			rla.w	r12
			inc		r14
			cmp		r14, r7
			jnz		multLoop		;if not done with iterations, continue

			mov.b	r10, r8
			mov.b	r8, 0(r5)
			inc		r5
			jmp		main			;otherwise, store everything and jump back to main


addLeftS
			tst		r14
			jnz		onWard		;(not a zero) so if one or more left shifts are necessary jump to onWard
			jmp		sumIt
onWard
			tst		r6
			jz		sumIt										;something still wrong with # of shift lefts.
			rla.w	r13
			dec		r6
			jmp		onWard

sumIt
			add		r13, r10
			cmp		#256, r10
			jge		setHigh
			jmp		comeBack


setHigh
			mov.b	#0xff, r8
			mov.b	r8, 0(r5)
			inc		r5
			jmp		main

setLow
			mov.b	#0, r8
			mov.b	r8, 0(r5)
			inc		r5
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
