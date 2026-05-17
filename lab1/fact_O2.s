# Грекова Я.В., группа 02271-ДБ
	.file	"fact_calc.c"
	.text
	.p2align 4
	.globl	fact_calc
	.def	fact_calc;	.scl	2;	.type	32;	.endef
	.seh_proc	fact_calc
fact_calc:
	cmpl	$1, %ecx
	jle	.L4
	pushq	%rbx
	.seh_pushreg	%rbx
	subq	$32, %rsp
	.seh_stackalloc	32
	.seh_endprologue
	movl	%ecx, %ebx
	leal	-1(%rcx), %ecx
	call	fact_calc
	imull	%ebx, %eax
	addq	$32, %rsp
	popq	%rbx
	ret
	.p2align 4
.L4:
	movl	$1, %eax
	ret
	.seh_endproc
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	subq	$40, %rsp
	.seh_stackalloc	40
	.seh_endprologue
	call	__main
	movl	$7, %ecx
	call	fact_calc
	movl	%eax, %edx
	leaq	.LC0(%rip), %rcx
	call	printf
	xorl	%eax, %eax
	addq	$40, %rsp
	ret
	.seh_endproc
	.section .rdata,"dr"
.LC0:
	.ascii "%d\12\0"
	.ident	"GCC: (x86_64-posix-seh-rev0, Built by MinGW-W64 project) 8.1.0"
	.def	__main;	.scl	2;	.type	32;	.endef
	.def	printf;	.scl	2;	.type	32;	.endef