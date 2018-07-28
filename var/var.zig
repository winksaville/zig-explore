const std = @import("std");
const builtin = @import("builtin");
const assert = std.debug.assert;

fn varFn1(x: var) u64 {
    return x * 123;
}

// Note: when you look at the llvm-ir (--verbose-llvm-ir) this
// routine actually turns into two routines, varFn2 and varFn2.10.
// varFn2 return the constant 246 for varFn2(2) which is the
// comptime_int path and varFn2.10 returns x * 123
fn varFn2(x: var) u64 {
    switch (@typeOf(x)) {
        // Handle x being a literal integer, otherwise we get
        // the @compileError below saying "error: varFn2 doesn't handle comptime_int"
        comptime_int => {
            return x * 123;
        },
        else => {
            // Not a literal, get the type and handle it appropriately
            switch (@typeInfo(@typeOf(x))) {
                builtin.TypeId.Int => {
                    return x * 123;
                },
                else => {
                    @compileError("varFn2 doesn't handle " ++ @typeName(@typeOf(x)));
                },
            }
        },
    }
    return 0;
}

test "varFn" {
    var z = varFn1(1);
    assert(z == (1 * 123));
    z = varFn2(2);
    assert(z == (2 * 123));
    z = varFn2(z);
    assert(z == (123 * 2 * 123));
}
