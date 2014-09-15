Lab_1_SimpleCalc
================

This is a simple calculator that will add, subtract, multiply, and clear when certain instructions are sent to the MSP430


##Pseudocode

The first step for creating the calculator in assemply Code Composer Studio was to make pseudocode to get an idea of 
what subroutines I would have to create and in what order my program would flow.

Below is a picture of the pseudocode that I wrote out by hand:

![alt text](https://raw.githubusercontent.com/JarrodWooden/Lab_1_SimpleCalc/master/IMG_0105.jpg "Simulation Picture for Part Two")

Multiplication Ideas:
  
  The most difficult subroutine for the calculator was going to be creating a method for the multiply operation.
  Therefore I began by writing ideas of how to multiply two numbers together in assembly
  
  I started by just multiplying two numbers together in binary and trying to figure out how the 
      process works.
      
  After I figured out a process for multiplying to binary numbers together, I began to think about how I could implement
    that same process with the instrucitons given in the MSP430.
    
  Below is the ideas I came up with and what I used for the multiplication subroutine:
    
![alt text](https://raw.githubusercontent.com/JarrodWooden/Lab_1_SimpleCalc/master/IMG_0106.JPG "Simulation Picture for Part Two")

##Requried Functionality: Addition, Subtraction, Clearing, Ending

####Main Loop

The main loop here decides which operation we are supposed to do and will jump to the proper subroutine.

```
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
```

Very Basic, just jump to the subroutine that you need to do if the operand matches the operand given in the program.

####Addition

Addition is straight forward. It takes the previous value r8 and adds it to the next value in the program using the instruction
for addition in assembly.

An example of how I did the operation in assembly is below.

```
			mov.b	0(r4), r7
			inc		r4          ;The pointer to the next value in the program

			add.w	r8, r7
			
			mov.b	r7, 0(r5)     ;r5 is the pointer to the answers in RAM
			mov.b	r7, r8   			;r8 will hold the previous value and the first value
			inc		r5
```

####Subtraction

Subtraction is very similar to addition in that it just uses the `sub.b	r7, r8` to subtract the current value "typed" into the
calculator from the previous value held in the calculator.

####Clearing

The Clear routine will set the answer to zero and it will increment the instruction pointer.
The reason for incrementing the instruciton pointer is to "load up" the next value into the calculator
that will be incremented.

Debugging: It took me a while to figure out that the calculator needed to increment the pointer to the program to take in the 
value of the next number in the program before jumping back to main to figure out what subroutine was next.

My clear subroutine is below:

```
CLR
			mov.b	#0, r8
			mov.b	r8, 0(r5)
			mov.b	0(r4), r8
			inc		r5
			inc		r4
			jmp		main
```

####End

The end method simply traps the CPU in loop.

##B Functionality: Creating Boundaries for the Calculator

For 'B' Functionality all we had to do was to set boundaries for the calculator. The lower boundary was zero, and the upper 
boundary was 255. If the calculator performed an operation in which the program either exceeded 255 or fell below 0, then the
calculator would set the answer at either 255 or 0 respectively. 

I simply called these subroutines setHigh and setLow.

Here are my subroutines:

```
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
```

##A Functionality: Subroutine Multiply





