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

####Addition

```
			mov.b	0(r4), r7
			inc		r4          ;The pointer to the next value in the program

			add.w	r8, r7
			
			mov.b	r7, 0(r5)     ;r5 is the pointer to the answers in RAM
			mov.b	r7, r8   			;r8 will hold the previous value and the first value
			inc		r5
```

####Subtraction

####Clearing

####End

