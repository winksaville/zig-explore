const std = @import("std");
const warn = std.debug.warn;

const ArrayU1 = @import("../../zig-array-u1/array-u1.zig").ArrayU1;
var singleton_bit_array = ArrayU1(1024).init();
pub const pSingleton_bit_array = &singleton_bit_array;

pub fn print_pSba() void {
    warn("singleton_bit_array.print_pSba={*} &singleton_bit_array={*}\n", pSingleton_bit_array, &singleton_bit_array);
}

test "singleton_bit_array" {
    const pSba = pSingleton_bit_array;
    const assert = std.debug.assert;

    assert(pSba.b(0) == false);
    assert(pSba.r(0) == 0);
    pSba.w(0, 1);
    assert(pSba.b(0) == true);
    assert(pSba.r(0) == 1);
    pSba.w(0, 0);
    assert(pSba.b(0) == false);
    assert(pSba.r(0) == 0);
}
