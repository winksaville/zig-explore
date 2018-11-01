# Emit assembler

## Using build-obj and --emit asm:
```
$ zig build-obj --output-h /dev/null --release-fast --strip --emit asm optional.i32.zig
wink@wink-desktop:~/prgs/ziglang/zig-explore/emit-asm-example (master)
$ cat -n optional.i32.s
     1		.text
     2		.file	"optional.i32"
     3		.globl	entry
     4		.p2align	4, 0x90
     5		.type	entry,@function
     6	entry:
     7		movq	__unnamed_1(%rip), %rax
     8		movq	%rax, gResult(%rip)
     9		cmpb	$1, gResult+4(%rip)
    10		jne	.LBB0_2
    11		movl	gResult(%rip), %eax
    12	.LBB0_2:
    13		movq	__unnamed_2(%rip), %rax
    14		movq	%rax, gResult(%rip)
    15		movl	$-2147483648, %eax
    16		cmpb	$1, gResult+4(%rip)
    17		jne	.LBB0_4
    18		movl	gResult(%rip), %eax
    19	.LBB0_4:
    20		retq
    21	.Lfunc_end0:
    22		.size	entry, .Lfunc_end0-entry
    23	
    24		.type	gResult,@object
    25		.local	gResult
    26		.comm	gResult,8,4
    27		.type	__unnamed_1,@object
    28		.section	.rodata.cst8,"aM",@progbits,8
    29		.p2align	2
    30	__unnamed_1:
    31		.long	4
    32		.byte	1
    33		.zero	3
    34		.size	__unnamed_1, 8
    35	
    36		.type	__unnamed_2,@object
    37		.p2align	2
    38	__unnamed_2:
    39		.zero	4
    40		.byte	0
    41		.zero	3
    42		.size	__unnamed_2, 8
    43	
    44	
    45		.section	".note.GNU-stack","",@progbits
```

## Using build-obj and objdump:
This gives inline source code which can be nice:
```
$ zig build-obj --release-fast emit-asm-example/optional.i32.zig && objdump --source -d -M intel optional.i32.o > emit-asm-example/optional.i32.src.s
$ cat -n emit-asm-example/optional.i32.src.s 
     1	
     2	optional.i32.o:     file format elf64-x86-64
     3	
     4	
     5	Disassembly of section .text:
     6	
     7	0000000000000000 <entry>:
     8	/// A function or any other code you'd like to see the its asm.
     9	fn aFunc() i32 {
    10	    var pResult: *volatile ?i32 = &gResult;
    11	    var value: i32 = undefined;
    12	
    13	    pResult.* = 4;
    14	   0:	48 8b 05 00 00 00 00 	mov    rax,QWORD PTR [rip+0x0]        # 7 <entry+0x7>
    15	   7:	48 89 05 00 00 00 00 	mov    QWORD PTR [rip+0x0],rax        # e <entry+0xe>
    16	    value = if (pResult.* == null) math.minInt(i32) else pResult.*.?;
    17	   e:	80 3d 00 00 00 00 01 	cmp    BYTE PTR [rip+0x0],0x1        # 15 <entry+0x15>
    18	  15:	75 06                	jne    1d <entry+0x1d>
    19	  17:	8b 05 00 00 00 00    	mov    eax,DWORD PTR [rip+0x0]        # 1d <entry+0x1d>
    20	    assert(value == 4);
    21	    pResult.* = null;
    22	  1d:	48 8b 05 00 00 00 00 	mov    rax,QWORD PTR [rip+0x0]        # 24 <entry+0x24>
    23	  24:	48 89 05 00 00 00 00 	mov    QWORD PTR [rip+0x0],rax        # 2b <entry+0x2b>
    24	  2b:	b8 00 00 00 80       	mov    eax,0x80000000
    25	    value = if (pResult.* == null) math.minInt(i32) else pResult.*.?;
    26	  30:	80 3d 00 00 00 00 01 	cmp    BYTE PTR [rip+0x0],0x1        # 37 <entry+0x37>
    27	  37:	75 06                	jne    3f <entry+0x3f>
    28	  39:	8b 05 00 00 00 00    	mov    eax,DWORD PTR [rip+0x0]        # 3f <entry+0x3f>
    29	    return value;
    30	}
    31	
    32	/// An exported function otherwise no code is generated when build-obj
    33	export fn entry() i32 {
    34	    return aFunc();
    35	  3f:	c3                   	ret  
```

## Notes on how ?i32 works:

See doc comment in optional.i32.zig for more information. But my current
understanding of Zig is that the compiler can do anything it wishes and in
general there is aggressive optimizations. But basically there are two pieces
of information a "tag" representing if its null or not and then a value.

So you can't assume any particular layout between val and tag or the type
of the tag nor its values. The only thing you can assume is that the ?i32
is not null then the it will resolve to an i32 type.
