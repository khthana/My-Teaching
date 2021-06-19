	.global	_start		@ Provide program starting address to linker

_start:	ldr	R6,=tstval	@ Point to list of test values.

	vldr	S8,[R6]		@ Load pair of floating point numbers to test

	vldr	S16,[R6,#4]	@ 

	vldr	S9,[R6,#8]	@* Load second pair of numbers.

	vldr	S17,[R6,#12]	@* 

	vldr	S10,[R6,#16]	@* Load third pair of numbers.

	vldr	S18,[R6,#20]	@* 

	vmrs	R0,FPSCR	@* Copy floating point PSCR to update it.

	mov	R1,#2		@* Number of "simultaneous" operations - 1

	orr	R0,R1, lsl #16	@* Fill the "length" field into FPSCR with 3-1

	vmsr	FPSCR,R0	@* Restore the floating point PSR.

	vmul.f32 S24,S8,S16	@ Multiply the three pairs of floating point operands

	

	vmov	R0,S24		@ Move product to ARM register for display.

	bl	v_flt		@ Display floating point number.

	ldr	R1,=nl		@ Pointer to line ending characters.

	bl	v_ascz		@ Separate test values with new lines.

	vmov	R0,S25		@* Move product to ARM register for display.

	bl	v_flt		@* Display floating point number.

	bl	v_ascz		@* Separate test values with new lines.

	vmov	R0,S26		@* Move product to ARM register for display.

	bl	v_flt		@* Display floating point number.

	bl	v_ascz		@* Separate test values with new lines.



	mov	R0,#0		@ Status code 0 indicates "normal completion"

	mov	R7,#1		@ Command code 1 will terminate program

	svc	0		@ Issue Linux command to terminate program

	





@	Subroutine v_flt will display a floating point number in decimal digits.

@		R0: contains the number to be displayed

@		LR: Contains the return address

@		All register contents will be preserved



v_flt:	push	{R0-R8,LR}	@ Save contents of registers R0 - R8, LR.



@	Output a "minus sign" if number is negative



	ldr		R1,=minus	@ Negative sign character "message"

	mov		R2,#1		@ Number of characters in message.

	movs	R6,R0,lsl #1	@ Move sign bit into "C" flag

	blcs	v_asc		@ Display the "-" if sign bit was set.



@	Initialize the whole number in R0 and fraction in R3.



	mov		R3, R0,lsl #8	@ Left justify normalized mantissa to R3.

	orr		R3,#0x80000000	@ Set the "assumed" high order bit.

	mov		R0,#0		@ Whole part = 0 (Number < .9999...)

	cmp		R6,#0		@ Test if both mantissa and exp = 0.

	beq		disp		@ Go display 0.0 if both mantissa and exp = 0.



@	Get the exponent and remove its bias



	mov		R6,R6,lsr #24	@ Right justify biased exponent.

	subs	R6, #126	@ Remove the exponent bias.

	beq		disp		@ If exponent = 0, need no shifting.

	blt		shiftr		@ Values <.5 must be shifted right.



@	Shift mantissa left: floating point number is greater than (or eq) 1.0



	rsb		R5,R6,#32	@ Convert left shift to right shift count.

	mov		R0,R3,lsr R5	@ Get the whole number potion of the number.

	lsl		R3,R6		@ Get the fractional part of the number

	b		disp		@ Go display both whole number and fraction.



@	Shift mantissa right (floating point number is less than .5).



shiftr:	

	rsb		R6,R6,#0	@ Calculate positive shift count (to right).

	lsr		R3,R6		@ "Divide by 2" for each bit shifted.



@	The floating point number is now divided into two registers:

@		R0: Has the whole number (left of the decimal point)

@		R3: Has the fraction (right of the decimal point)



@	Display the whole number in base 10.



disp:	

	bl		v_dec		@ Display the number in R0 in decimal digits.



@	Display decimal point separating the whole number from the fraction.



	ldr		R1,=point	@ Pointer to decimal point.

	bl		v_asc		@ Put decimal point into display.



@	Display the fraction in base 10



	mov		R4,#10		@ Base 10 used to "shift" over each digit.

	ldr		R5,=dig		@ Set R5 pointing to "0123456789" string



@	Loop through powers of 10 and display each digit.



nxtdfd:	

	umull	R3,R1,R4,R3	@ "Shift" next decimal digit into R1.

	add		R1,R5		@ Set pointer to digit in "0123456789"

	bl		v_asc		@ Write out one digit.

	cmp		R3,#0		@ Set Z flag if mantissa is now zero.

	bne		nxtdfd		@ Go display next decimal digit.



	pop		{R0-R8,LR}	@ Restore saved register contents.

	bx		LR		@ return to the calling program

	

v_dec:	

	push	{R0-R7}		@ Save contents of registers R0 through R7

	mov		R3,R0		@ R3 will hold a copy of input word to be displayed.

	mov		R2,#1		@ Number of characters to be displayed at a time.

	mov		R0,#1		@ Code for stdout (standard output, i.e., monitor display)

	mov		R7,#4		@ Linux service command code to write string.



@	If bit-31 is set, then register contains a negative number and "-" should be output.



	cmp		R3,#0		@ Determine if minus sign is needed.

	bge		absval		@ If positive number, then just display it.

	ldr		R1,=minus	@ Address of minus sign in memory

	svc		0			@ Service call to write string to stdout device

	

	rsb		R3,R3,#0	@ Get absolute value (negative of negative) for display.

absval:	

	cmp		R3,#10		@ Test whether only one's column is needed

	blt		onecol		@ Go output "final" column of display



@	Get highest power of ten this number will use (i.e., is it greater than 10?, 100?, ...)



	ldr		R6,=pow10+8	@ Point to hundred's column of power of ten table.

high10:	

	ldr		R5,[R6],#4	@ Load next higher power of ten

	cmp		R3,R5		@ Test if we've reached the highest power of ten needed

	bge		high10		@ Continue search for power of ten that is greater.

	sub		R6,#8		@ We stepped two integers too far.



@	Loop through powers of 10 and output each to the standard output (stdout) monitor display.



nxtdec:	

	ldr		R1,=dig-1	@ Point to 1 byte before "0123456789" string

	ldr		R5,[R6],#-4	@ Load next lower power of 10 (move right 1 dec column) 



@	Loop through the next base ten digit to be displayed (i.e., thousands, hundreds, ...)



mod10:	

	add		R1,#1		@ Set R1 pointing to the next higher digit '0' through '9'.

	subs	R3,R5		@ Do a count down to find the correct digit.

	bge		mod10		@ Keep subtracting current decimal column value

	addlt	R3,R5		@ We counted one too many (went negative)

	svc		0			@ Write the next digit to display

	

	cmp		R5,#10		@ Test if we've gone all the way to the one's column.

	bgt		nxtdec		@ If 1's column, go output rightmost digit and return.



@	Finish decimal display by calculating the one's digit.



onecol:	

	ldr		R1,=dig		@ Pointer to "0123456789"

	add		R1,R3		@ Generate offset into "0123456789" for one's digit.

	svc		0			@ Write out the final digit.



	pop		{R0-R7}			@ Restore saved register contents

	bx		LR				@ Return to the calling program



v_asc:	

	push	{R0-R8,LR}

	mov		R0,#1			@ Code for stdout (standard output, i.e., monitor display)

	mov		R7,#4			@ Linux service command code to write string.

	svc		0				@ Issue command to display string on stdout

	pop		{R0-R8,LR}

	bx		LR				@ Return to the calling program	

	

v_ascz: 

	push	{R0-R8,LR}		@ Save contents of registers R0 through R8, LR

	sub		R2,R1,#1		@ R2 will be index while searching string for null.

hunt4z:	

	ldrb	R0,[R2,#1]!		@ Load next character from string (and increment R2 by 1)

	cmp		R0,#0			@ Set Z status bit if null found

	bne		hunt4z			@ If not null, go examine next character.

	sub		R2,R1			@ Get number of bytes in message (not counting null)

	mov		R0,#1			@ Code for stdout (standard output, i.e., monitor display)

	mov		R7,#4			@ Linux service command code to write string.

	svc		0				@ Issue command to display string on stdout

	

	pop	{R0-R8,LR}			@ Restore saved register contents

	bx	LR					@ Return to the calling program	



	.data

	

tstval:	

		.float	101.0625, 100.0	@*

	.float	-3.5, 10.5	@ Floating point test values



	.float	-5.25, -200.0	@*	



tstval2:	.float	0.5		@ .5      (1/2)

	.float	0.25		@ .25     (1/4)

	.float	-1.0

	.float	100.0

	.float	1234.567

	.float	-9876.543

	.float	7070.7070

	.float	3.3333

	.float	694.3e-9

	.float	6.0221e2

	.float	6.0221e23

	.word	0		@ End of list

nl:	.asciz	"\n"		@ Line ending characters.

dig:	.ascii	"0123456789"	@ ASCII string of digits 0 through 9.

minus:	.ascii	"-"		@ Negative sign

point:	.ascii	"."		@ Decimal point

pow10:	.word	1		@ 10^0

	.word	10		@ 10^1

	.word	100		@ 10^2

	.word	1000		@ 10^3  (thousand)

	.word	10000		@ 10^4

	.word	100000		@ 10^5

	.word	1000000		@ 10^6  (million)

	.word	10000000	@ 10^7

	.word	100000000	@ 10^8

	.word	1000000000	@ 10^9  (billion)

	.word	0x7FFFFFFF	@ Largest integer in 31 bits (2,147,483,647)

	.end

