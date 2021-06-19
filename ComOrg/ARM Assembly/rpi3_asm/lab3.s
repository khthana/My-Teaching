	.global _start

	_start:

	MOV 	R7, #4			@ Print Input String1
	MOV 	R0, #1
	MOV 	R2, #21
	LDR 	R1,=string1
	SWI 	0

	MOV 	R7, #3			@ Read 2 Char into input1
 	MOV 	R0, #0
	MOV 	R2, #3
	LDR 	R1,=input1
	SWI 	0

	LDR	R1, =input1		@ Convert String Input1 to int
	LDRB 	R0, [R1, #0]		@ First Byte
	SUB	R0, R0, #48
	LDRB	R2, [R1, #1]		@ Second Byte
	SUB	R2, R2, #48
	MOV	R3, #10
	MLA	R4, R0, R3, R2
	MOV	R9, R4			@ First Number in R9

	MOV 	R7, #4			@ Print Input String 2
	MOV 	R0, #1
	MOV 	R2, #22
	LDR 	R1,=string2
	SWI 	0

	MOV 	R7, #3			@ Read 2 Char to Input 2
 	MOV 	R0, #0
 	MOV 	R2, #3
	LDR 	R1,=input2
	SWI 	0

	LDR	R1, =input2		@ Convert String Input2 to int
	LDRB 	R0, [R1, #0]		@ First Byte
	SUB	R0, R0, #48
	LDRB	R2, [R1, #1]		@ Second Byte
	SUB	R2, R2, #48
	MOV	R3, #10
	MLA	R4, R0, R3, R2
	MOV	R10, R4			@ Second Number in R10

	ADD	R9, R9, R10		@ Result of Addision in R9

	MOV 	R7, #4			@ Print Output String
 	MOV 	R0, #1
	MOV 	R2, #9
	LDR 	R1,=string3
	SWI 	0

	MOV	R0, #0			@ Counter for result
div:	CMP	R9, #10
	BLT	finish
	SUB	R9, #10
	ADD	R0, R0, #1
	B	div
finish:	ADD	R9, #48			@ reminder
	ADD	R0, #48			@ Quotient 
	LDR	R1, =output
	STRB	R0, [R1, #0]
	STRB	R9, [R1, #1]

	MOV 	R7, #4			@ Print Result
 	MOV 	R0, #1
	MOV 	R2, #3
	LDR 	R1,=output
	SWI 0

_exit: 
     @ exit syscall
	MOV R7, #1
	SWI 0


		.data
string1:	.ascii "Enter First Number : \n"
input1:		.ascii "      "
string2:	.ascii "Enter Second Number : \n"
input2:		.ascii "      "
string3:	.ascii "Output : "
output:		.ascii "33\n"
