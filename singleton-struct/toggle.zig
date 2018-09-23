const sba_ns = @import("singleton_bit_array.zig");
const pSba = sba_ns.pSingleton_bit_array;

pub fn print_pSba() void {
    @import("std").debug.warn("toggle.print_pSba={*}\n", pSba);
}

// Toggle a bit and return new value
pub fn toggle(bit_offset: usize) usize {
    pSba.w(bit_offset, pSba.r(bit_offset) ^ 1);
    return pSba.r(bit_offset);
}

test "toggle" {
    const assert = @import("std").debug.assert;
    var original = pSba.r(0);
    var new = toggle(0);
    assert(new == (original ^ 1));
    new = toggle(0);
    assert(new == original);
}
