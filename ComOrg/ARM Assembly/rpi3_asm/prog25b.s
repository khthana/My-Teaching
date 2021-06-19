/* GPIO PIN access via memory mapping file to Controller */
/* This example sets GPI0 17 after first initialising    */

	.global main
main:
	SUB	sp, sp, #16		

openfile:	
	LDR	R0, .addr_file	
	LDR	R1, .flags		
	BL	open			
map:	
	STR	R0, [SP, #12]		
	LDR	R3, [SP, #12]		
	STR	R3, [SP, #0]		
	LDR	R3, .gpiobase		
	STR	R3, [SP, #4]		
	MOV	R0, #0			
	MOV	R1, #4096		
	MOV	R2, #3			
	MOV	R3, #1			
	BL	mmap

Close:	
	STR	R0, [SP, #16]		
	LDR	R3, [SP, #16]		
	ADD	R3, R3, #4	@ add 4 for block 1
	LDR	R2, [SP, #16]		
	ADD	R2, R2, #4	@ add 4 for block 1
	LDR	R2, [R2, #0]		
	BIC	R2, R2, #0b111<<21	@ Bitwise clear of three bits
	STR	R2, [R3, #0]		
	LDR	R3, [SP, #16]		
	ADD	R3, R3, #4	@ Add 4 for block 1
	LDR	R2, [SP, #16]		
	ADD	R2, R2, #4	@ add 4 for block 1
	LDR	R2, [R2, #0]		
	ORR	R2, R2, #1<<21	@ Set bit....
	STR	R2, [R3, #0]		
	LDR	R3, [SP, #16]		
	ADD	R3, R3, #28	@ add 28 – use 40 to clear
	MOV	R4, #1			
	MOV	R2, R4, LSL#17	@ Shift by pin no for bit location
	STR	R2, [R3, #0]		
	LDR	R0, [SP, #12]		
	BL	close			

	ADD	SP, SP, #16		
	
	MOV R7, #1
	SWI 0

.addr_file:	.word	.file
.flags:	.word	1576962
.gpiobase:	.word	0x3F200000	@ GPIO_Base for RPi 3 & 2
@.gpiobase:	.word	0x20200000	@ GPIO_Base for RPi Zero & 1

.data
.file:	.ascii "/dev/mem\000"

