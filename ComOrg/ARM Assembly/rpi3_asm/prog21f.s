/* Create a directory using Syscall */
        .section .rodata

string:
	.ascii "tempdir\000"
	.global _start
	.text
	.align 2
mode:	
	.word 0511
	
_start:
       	@ mkdir syscall
	MOV 	R7, #39
	LDR 	R0,=string
	LDR 	R1,mode
	SVC 	#0	
	
       	@ exit syscall
	MOV 	R7, #1
	MOV 	R0, #0
	SVC 	#0
