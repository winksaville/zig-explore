const std = @import("std");
const assert = std.debug.assert;
const warn = std.debug.warn;

extern fn b(bit_offset: usize) bool;
extern fn r(bit_offset: usize) usize;
extern fn w(bit_offset: usize, val: usize) void;
extern fn toggle(bit_offset: usize) usize;

test "test.singleton_bit_array" {
    assert(b(0) == false);
    assert(r(0) == 0);
    assert(toggle(0) == 1);
    assert(b(0) == true);
    assert(r(0) == 1);
    assert(toggle(0) == 0);
    assert(b(0) == false);
    assert(r(0) == 0);
    w(0, 1);
    assert(b(0) == true);
    assert(r(0) == 1);
    assert(toggle(0) == 0);
    assert(b(0) == false);
    assert(r(0) == 0);
}
