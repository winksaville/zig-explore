extern fn r(bit_offset: usize) usize;
extern fn w(bit_offset: usize, val: usize) void;

// Toggle a bit and return new value
export fn toggle(bit_offset: usize) usize {
    w(bit_offset, r(bit_offset) ^ 1);
    return r(bit_offset);
}

test "toggle" {
    const assert = @import("std").debug.assert;
    var original = r(0);
    assert(original == 0);
    var new = toggle(0);
    assert(new == (original ^ 1));
    new = toggle(0);
    assert(new == original);
}
