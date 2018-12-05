# Testing generated code for @floatToInt

The Makefile takes floattoint.zig and converts it to assembler code.
To force zig to generate code we must `export` a function,
`export fn floattoint() bool` in this case.

This is in response to a [question](https://github.com/ziglang/zig/pull/1817#issuecomment-444340739)
"So would you get this by calling@floatToInt(u1, f32(x))?"
from @thejoshwolfe to my [PR #1817 Workaround fixuint causing compiler segfault with u1](https://github.com/ziglang/zig/pull/1817)

The answer is it depends on the target, if the target architecture
supports float to int directly then its used, otherwise `__fixunssfsi`
which calls fixuint:
```
const fixuint = @import("fixuint.zig").fixuint;
const builtin = @import("builtin");

pub extern fn __fixunssfsi(a: f32) u32 {
    @setRuntimeSafety(builtin.is_test);
    return fixuint(f32, u32, a);
}

test "import fixunssfsi" {
    _ = @import("fixunssfsi_test.zig");
}
```

So with arch=x86_64 the conversion is supported natively and `__fixunssfsi`
is not called:
```
$ make arch=x86_64 -B
zig build-obj --strip --emit asm --release-fast floattoint.zig --target-arch x86_64 --target-os freestanding --target-environ unknown

$ cat -n floattoint.s
     1		.text
     2		.file	"floattoint"
     3		.globl	floatToInt
     4		.p2align	4, 0x90
     5		.type	floatToInt,@function
     6	floatToInt:
     7		cvttss2si	vF32(%rip), %eax
     8		movb	%al, result(%rip)
     9		cvttss2si	vF32(%rip), %eax
    10		xorb	$1, %al
    11		movb	%al, result(%rip)
    12		movb	result(%rip), %al
    13		retq
    14	.Lfunc_end0:
    15		.size	floatToInt, .Lfunc_end0-floatToInt
    16	
    17		.type	result,@object
    18		.local	result
    19		.comm	result,1,1
    20		.type	vF32,@object
    21		.data
    22		.p2align	2
    23	vF32:
    24		.long	1065353216
    25		.size	vF32, 4
    26	
    27	
    28		.section	".note.GNU-stack","",@progbits
```

But with arch=armv5 it is called:
```
$ make arch=armv5 -B
zig build-obj --strip --emit asm --release-fast floattoint.zig --target-arch armv5 --target-os freestanding --target-environ unknown

$ cat -n floattoint.s
     1		.text
     2		.syntax unified
     3		.eabi_attribute	67, "2.09"
     4		.eabi_attribute	6, 3
     5		.eabi_attribute	8, 1
     6		.eabi_attribute	9, 1
     7		.eabi_attribute	34, 1
     8		.eabi_attribute	15, 1
     9		.eabi_attribute	16, 1
    10		.eabi_attribute	17, 2
    11		.eabi_attribute	20, 1
    12		.eabi_attribute	21, 1
    13		.eabi_attribute	23, 3
    14		.eabi_attribute	24, 1
    15		.eabi_attribute	25, 1
    16		.eabi_attribute	38, 1
    17		.eabi_attribute	14, 0
    18		.file	"floattoint"
    19		.globl	floatToInt
    20		.p2align	2
    21		.type	floatToInt,%function
    22		.code	32
    23	floatToInt:
    24		.fnstart
    25		push	{r4, lr}
    26		ldr	r0, .LCPI0_0
    27	.LPC0_0:
    28		ldr	r0, [pc, r0]
    29		bl	__fixunssfsi
    30		ldr	r4, .LCPI0_1
    31	.LPC0_1:
    32		add	r4, pc, r4
    33		strb	r0, [r4]
    34		ldr	r0, .LCPI0_2
    35	.LPC0_2:
    36		ldr	r0, [pc, r0]
    37		bl	__fixunssfsi
    38		eor	r0, r0, #1
    39		strb	r0, [r4]
    40		ldrb	r0, [r4]
    41		pop	{r4, pc}
    42		.p2align	2
    43	.LCPI0_0:
    44		.long	vF32-(.LPC0_0+8)
    45	.LCPI0_1:
    46		.long	result-(.LPC0_1+8)
    47	.LCPI0_2:
    48		.long	vF32-(.LPC0_2+8)
    49	.Lfunc_end0:
    50		.size	floatToInt, .Lfunc_end0-floatToInt
    51		.cantunwind
    52		.fnend
    53	
    54		.type	result,%object
    55		.local	result
    56		.comm	result,1,1
    57		.type	vF32,%object
    58		.data
    59		.p2align	2
    60	vF32:
    61		.long	1065353216
    62		.size	vF32, 4
    63	
    64	
    65		.section	".note.GNU-stack","",%progbits
```

# Tests

Current test "broken" is skipped because it causes compiler to segfault.
If the compiler is fixed or my [PR #1817](https://github.com/ziglang/zig/pull/1817) is
accepted it can be enabled.
```
zig test floattoint
```
$ zig test floattoint.zig
Test 1/3 floattoint...OK
Test 2/3 broken...SKIP
Test 3/3 workaround...OK
2 passed; 1 skipped.
```
The diff between broken and workaround is:
```
$ diff -Naur fixuint_u1_broken.zig fixuint_u1_workaround.zig
--- fixuint_u1_broken.zig	2018-12-05 10:30:33.790147403 -0800
+++ fixuint_u1_workaround.zig	2018-12-05 10:31:55.914936362 -0800
@@ -4,6 +4,12 @@
 pub fn fixuint(comptime fp_t: type, comptime fixuint_t: type, a: fp_t) fixuint_t {
     @setRuntimeSafety(is_test);
 
+    // Special case u1 otherwise compiler segfaults
+    switch (fixuint_t) {
+        u1 => return if (a <= 0.0) return fixuint_t(0) else fixuint_t(1),
+        else => {},
+    }
+
     const rep_t = switch (fp_t) {
         f32 => u32,
         f64 => u64,
```
