/// Example of a file suitable for inspecting the asm
///
/// An "interesting" fn which I wanted to know how it works.
/// In particular what is the representation of  "optional" TypeId.Int,
/// in this case an `?i32`. A "null" pointer can be a "reserved" value,
/// like 0. But an `?i32` there is no "reserved" values. So how does
/// zig represent a `?i32`?
///
/// Answer a ?i32 is logically 8 byte struct on a x86_64 which looks like:
///   const OptionalI32 = struct {
///       val: i32;         // The value
///       tag: u1;          // tag == 0 then this is "null" (@sizeOf(tag) == 1).
///                         // Actually in Zig there is no gurantee as to the
///                         // placement/alignment/value of tag. Or that it even
///                         // exists as it can be optimized away!!!!
///       padding: [3]u8;   // Ignored;
///   };
///
/// I determined this using code in aFunc which is accessing
/// gResult via a non-volatile pointer. And then looking at the
/// assembly code, optional.i32.s. Below you can see two initialized
/// variables __unnamed_1 and __unnamed_2 which represent how gResult
/// is initialized. Both are 8 bytes long with the first 4 bytes representing
/// the non-null value and the 5th byte representing the tag. In __unnamed_1
/// we see the OptionalI32.val = 4 and OptionalI32.tag = 1. And in
/// __unnamed_2 we see OptionalI32.val = 0 and OptionalI32.tag = 0.
/// 
///   $ zig build-obj --output-h /dev/null --release-fast --strip --emit asm optional.i32.zig
///   $ cat -n optional.i32.s
///        1		.text
///        2		.file	"optional.i32"
///        3		.globl	entry
///        4		.p2align	4, 0x90
///        5		.type	entry,@function
///        6	entry:
///        7		movq	__unnamed_1(%rip), %rax
///        8		movq	%rax, gResult(%rip)
///        9		cmpb	$1, gResult+4(%rip)
///       10		jne	.LBB0_2
///       11		movl	gResult(%rip), %eax
///       12	.LBB0_2:
///       13		movq	__unnamed_2(%rip), %rax
///       14		movq	%rax, gResult(%rip)
///       15		movl	$-2147483648, %eax
///       16		cmpb	$1, gResult+4(%rip)
///       17		jne	.LBB0_4
///       18		movl	gResult(%rip), %eax
///       19	.LBB0_4:
///       20		retq
///       21	.Lfunc_end0:
///       22		.size	entry, .Lfunc_end0-entry
///       23	
///       24		.type	gResult,@object
///       25		.local	gResult
///       26		.comm	gResult,8,4
///       27		.type	__unnamed_1,@object
///       28		.section	.rodata.cst8,"aM",@progbits,8
///       29		.p2align	2
///       30	__unnamed_1:
///       31		.long	4
///       32		.byte	1
///       33		.zero	3
///       34		.size	__unnamed_1, 8
///       35	
///       36		.type	__unnamed_2,@object
///       37		.p2align	2
///       38	__unnamed_2:
///       39		.zero	4
///       40		.byte	0
///       41		.zero	3
///       42		.size	__unnamed_2, 8
///       43	
///       44	
///       45		.section	".note.GNU-stack","",@progbits

const std = @import("std");
const assert = std.debug.assert;

var gResult: ?i32 = undefined;

/// A function or any other code you'd like to see the its asm.
fn aFunc() i32 {
    var pResult: *volatile ?i32 = &gResult;
    var value: i32 = undefined;

    pResult.* = 4;
    value = if (pResult.* == null) @minValue(i32) else pResult.*.?;
    assert(value == 4);
    pResult.* = null;
    value = if (pResult.* == null) @minValue(i32) else pResult.*.?;
    assert(value == @minValue(i32));
    return value;
}

/// An exported function otherwise no code is generated when build-obj
export fn entry() i32 {
    return aFunc();
}

/// Programs that need a fn panic get large because of the code
/// necessary to dump a stack trace. If you enable `pub fn main()`
/// but not `pub fn panic` the output about 16,000 lines of assembly.
///
/// $ zig build-obj --output-h /dev/null --release-safe --strip --emit asm optional.i32.zig
/// $ wc -l optional.i32.s
/// 15896 optional.i32.s
///
/// But if you enable `pub fn panic` below its 61 lines
/// $ zig build-obj --output-h /dev/null --release-safe --strip --emit asm optional.i32.zig
/// $ wc -l optional.i32.s
/// 61 optional.i32.s
///
/// Alos, if you do --release-fast build then it's small as there is no invocation of panic
/// $ zig build-obj --output-h /dev/null --release-fast --strip --emit asm optional.i32.zig
/// $ wc -l optional.i32.s
/// 45 optional.i32.s
var global: i32 = undefined;
pub fn panic(msg: []const u8, stack_trace: ?*@import("builtin").StackTrace) noreturn {
    // Must not return so add endless loop
    var pGlobal: *volatile i32 = &global;
    pGlobal.* = 123;
    while (true) {}
}

test "test.optional.i32" {
    assert(aFunc() == @minValue(i32));
}
