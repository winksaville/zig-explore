	.text
	.file	"optional.i32"
	.globl	entry
	.p2align	4, 0x90
	.type	entry,@function
entry:
	movq	__unnamed_1(%rip), %rax
	movq	%rax, gResult(%rip)
	cmpb	$1, gResult+4(%rip)
	jne	.LBB0_2
	movl	gResult(%rip), %eax
.LBB0_2:
	movq	__unnamed_2(%rip), %rax
	movq	%rax, gResult(%rip)
	movl	$-2147483648, %eax
	cmpb	$1, gResult+4(%rip)
	jne	.LBB0_4
	movl	gResult(%rip), %eax
.LBB0_4:
	retq
.Lfunc_end0:
	.size	entry, .Lfunc_end0-entry

	.type	gResult,@object
	.local	gResult
	.comm	gResult,8,4
	.type	__unnamed_1,@object
	.section	.rodata.cst8,"aM",@progbits,8
	.p2align	2
__unnamed_1:
	.long	4
	.byte	1
	.zero	3
	.size	__unnamed_1, 8

	.type	__unnamed_2,@object
	.p2align	2
__unnamed_2:
	.zero	4
	.byte	0
	.zero	3
	.size	__unnamed_2, 8


	.section	".note.GNU-stack","",@progbits
