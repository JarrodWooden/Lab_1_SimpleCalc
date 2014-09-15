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

I came up with the multiply subroutine all on my own. I knew that I had to figure out a way of how to calculate
the number of iterations the program will have to go through to do the correct number of shift lefts and
additions in order to get the correct answer. The reason this is important is to make sure that my program for
multiply will be O(log(N)) instead of O(N). I kept track of the number of iterations necessary and
and temporary registers to keep the original numbers we started with because we will have to manipulate the
original operands multiple times through each iteration before we reach the answer.

multLoop (the routine that will do most of the repeating work of the Multiply subroutine)

comeBack (is the small method that will determine if we need to do another iteration in the multiply routine
				or if we are done and we can jump back to main.)

addLeftS (is method that if we need to do a shift left it will determine if it is the first iteration through to determine if
				if we do '0' shifts or if we do more than '0' shifts because it is an important distinction)

onWard (will do the shift lefts for us)

sumIt (will just add up the the left shifts from each iteration)

Key methods in the Multiply subroutine:

Below figures out the number of iterations that the program will need to go through the multiply subroutine until the program
adds up to the correct value: This creates the speed of O(log(n)), which was needed to get full credit on the A functionality.

It takes the value of the second operation ( ex: some number times r9 ) and divides by two and adds one to get the iterations.

```
	rrc		r9
	add		#1, r9
```

Also something needed to keep track of whether or not the current iteration for whichever number bit we were on was a one or a
zero. If it was a zero we would do nothing and move on to the next bit. If it was a one we would perform the left shifts
(depending on what bit we were on) and add it to the total value in the multiply subroutine.

For the number of left shifts of the begining first value that you want to multiply and to be added to the final value is
shown below:

```
			tst		r6
			jz		sumIt
			
			rla.w	r13
			dec		r6
```

So r6 will keep track of how many left shifts we have done and if we are finished it will go ahead and add it to the final 
value jumping to "sumIt"

##Bugs in the Program

The program will jump to the forever loop if it the calculator is given a value that doesn't match up with an operation. 
Like if you start with 0xFF or something like that. So the program for instruction to the calculator must be in a specific
order.

##Documentation:
NONE

#Have a great Air Force Day


