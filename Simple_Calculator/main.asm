;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;By: Jarrod M Wooden, USAFA 2016, CS-20
;Teacher: Dr. York, DFEC, ECE382, M2
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
Calc_Instr: .byte	0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0xDD, 0x44, 0x08, 0x22, 0x09, 0x44, 0xFF, 0x22, 0xFD, 0x55		        ; section
;The above is the program that we want the calculator to execute

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
                                            ; Main loop here

;The main loop here decides which operation we are supposed to do and will jump to
; the proper operation

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

;The Operation Add is First: Add will first add the previous value with the current value that was entered into the calculator
; and will also check to make sure the calculator doesn't exceed our operating limit of 255.

ADD
			mov.b	0(r4), r7
			inc		r4

			add.w	r8, r7
			cmp		#256, r7
			jge		setHigh

			mov.b	r7, 0(r5)
			mov.b	r7, r8   			;r8 will hold the previous value and the first value as seen before
			inc		r5

			jmp		main

;-------------------------End of Add Subroutine----------------------------------------------;

;The SUB -- subroutine will make just it compares the operands to see if it will go negative and
;set the answer to the lower limit if necessary. Otherwise it will subtract the two and put the answer
;into the next spot in the answer pointer


SUB
			mov.b	0(r4), r7
			inc		r4

			cmp		r8, r7				;first check if the answer will be negative before you perform the operation
			jge		setLow
			sub.b	r7, r8
			mov.b	r8, 0(r5)
			inc		r5
			jmp		main

;-------------------------End of Subtact Subroutine----------------------------------------------;

;The Clear routine will set the answer to zero and it will increment the instruction pointer
;The reason for incrementing the instruciton pointer is to "load up" the next value into the calculator
;that will be incremented
;
CLR
			mov.b	#0, r8
			mov.b	r8, 0(r5)
			mov.b	0(r4), r8
			inc		r5
			inc		r4
			jmp		main

;-------------------------End of Clear Subroutine----------------------------------------------;
;
;I came up with the multiply subroutine all on my own. I knew that I had to figure out a way of how to calculate
;the number of iterations the program will have to go through to do the correct number of shift lefts and
;additions in order to get the correct answer. The reason this is important is to make sure that my program for
;multiply will be O(log(N)) instead of O(N). I kept track of the number of iterations necessary and
;and temporary registers to keep the original numbers we started with because we will have to manipulate the
;original operands multiple times through each iteration before we reach the answer.
;
;multLoop (the routine that will do most of the repeating work of the Multiply subroutine)

;comeBack (is the small method that will determine if we need to do another iteration in the multiply routine
;				or if we are done and we can jump back to main.)

;addLeftS (is method that if we need to do a shift left it will determine if it is the first iteration through to determine if
;				if we do '0' shifts or if we do more than '0' shifts because it is an important distinction)
;
;onWard (will do the shift lefts for us)
;
;sumIt (will just add up the the left shifts from each iteration)
;
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
;------------------------------End of Multiply Subroutine------------------------------;
;
;setHigh -- this subroutine will simply set the answer to 0xff if the value in any operation exceeds
;this value (this is our upper limit)
;
;
setHigh
			mov.b	#0xff, r8
			mov.b	r8, 0(r5)
			inc		r5
			jmp		main
;------------------------------End of set High----------------------------------;

;setLow -- this subroutine will simply set the answer to 0x00 if the value in any operation is less than
;this value (this is our lower limit)

setLow
			mov.b	#0, r8
			mov.b	r8, 0(r5)
			inc		r5
			jmp		main

;--------------------------End of set Low-------------------------------;

;Then just trap the CPU

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
