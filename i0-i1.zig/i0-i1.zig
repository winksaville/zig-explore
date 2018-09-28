const std = @import("std");
const assert = std.debug.assert;
const warn = std.debug.warn;

test "test.i0" {
    warn("\n");
    warn("     -pow(2, -1)={}\n", -std.math.pow(f32, 2, -1));
    warn("    pow(2, -1)-1={}\n", std.math.pow(f32, 2, -1)-1);
    warn("floatToInt(-0.5)={}\n", @floatToInt(i32, -0.5));
    var x0: i0 = 0;
    assert(x0 == 0);
}

test "test.i1" {
    warn("\n");
    warn("     -pow(2, 0)={}\n", -std.math.pow(f32, 2, 0));
    warn("    pow(2, 0)-1={}\n", std.math.pow(f32, 2, 0)-1);
    var v0: i1 = 0;
    assert(v0 == 0);
    var v1: i1 = -1;
    assert(v1 == -1);
    assert(v0 != v1);
}
