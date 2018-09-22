const ArrayU1 = @import("../../zig-array-u1/array-u1.zig").ArrayU1;
export var singleton_bit_array = ArrayU1(1024).init();

// Accessor functions for singleton bit_array
export fn b(bit_offset: usize) bool { return singleton_bit_array.b(bit_offset); }
export fn r(bit_offset: usize) usize { return singleton_bit_array.r(bit_offset); }
export fn w(bit_offset: usize, val: usize) void { singleton_bit_array.w(bit_offset, val); }

test "singleton_bit_array" {
    const std = @import("std");
    const assert = std.debug.assert;
    const warn = std.debug.warn;

    assert(b(0) == false);
    assert(r(0) == 0);
    w(0, 1);
    assert(b(0) == true);
    assert(r(0) == 1);
    w(0, 0);
    assert(b(0) == false);
    assert(r(0) == 0);
}
