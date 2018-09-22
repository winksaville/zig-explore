const ArrayU1 = @import("array-u1.zig").ArrayU1;
extern var global_bit_array: ArrayU1(1024);

/// home/wink/prgs/ziglang/zig-array-u1/xx.zig:4:24: error: invalid token: '.'
//extern fn ArrayU1(1024).r(bit_array: ArrayU1(1024), bit_offset: usize) usize;

//$ zig test xx.zig --object global_bit_array.o
//zig: ../src/analyze.cpp:6355: uint32_t get_abi_alignment(CodeGen *, ZigType *): Assertion `type_is_resolved(type_entry, ResolveStatusAlignmentKnown)' failed.
//Aborted (core dumped)
extern fn r(bit_array: ArrayU1(1024), bit_offset: usize) usize;

fn test_extern_global_bit_array() void {
    const assert = @import("std").debug.assert;
    var original = ArrayU1(1024).r(global_bit_array, 0);
    assert(original == 0);
}

test "xx" {
    test_extern_global_bit_array();
}

