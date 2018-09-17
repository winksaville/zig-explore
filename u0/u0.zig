const std = @import("std");
const assert = std.debug.assert;
const warn = std.debug.warn;
const builtin = @import("builtin");
const TypeId = builtin.TypeId;

test "u0" {
    assert(@typeId(u0) == TypeId.Int);
    assert(@typeId(u0) != TypeId.Void);

    var zero: u0 = 0;
    assert(zero == 0);
    assert(@sizeOf(@typeOf(zero)) == 0);
    var z: u0 = 0;
    zero = z;
    assert(zero == z);
    //var z1 = @intCast(u1, zero); // Causes compiler seg fault
}
