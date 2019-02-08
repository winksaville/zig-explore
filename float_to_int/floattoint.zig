const std = @import("std");
const assert = std.debug.assert;

var result: bool = undefined;
var vF32: f32 = 1;

export fn floatToInt() bool {
    const pResult: *volatile bool = &result;
    const pvF32: *volatile f32 = &vF32;

    pResult.* = @floatToInt(u0, pvF32.*) == 0;
    pResult.* = @floatToInt(u1, pvF32.*) == 1;
    pResult.* = @floatToInt(u2, pvF32.*) == 1;
    pResult.* = @floatToInt(u64, pvF32.*) == 1;
    pResult.* = @floatToInt(u65, pvF32.*) == 1;
    pResult.* = @floatToInt(u128, pvF32.*) == 1;

    return pResult.*;
} 

test "floattoint" {
    @import("std").debug.assert(floatToInt());
}

// Trying to use fixuint with a u1 causes compiler to segfault.
const notbroken = @import("fixuint_u1_broken.zig").fixuint;
test "notbroken"  {
    if (false) { // Previously setting to false causes complier to segfault, now OK with 
                 // https://github.com/ziglang/zig/commit/f330eebe4bc6a036846cf05706f72855627c705a
        return error.SkipZigTest;
    }
    assert(notbroken(f32, u1, 1.0) == 1);
}

// Special casing u1 is a workaround
const workaround = @import("fixuint_u1_workaround.zig").fixuint;
test "workaround"  {
    assert(workaround(f32, u1, 1.0) == 1);
}
