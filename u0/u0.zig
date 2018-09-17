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
    assert(@sizeOf(u0) == 0);

    var z: u0 = 0;
    zero = z;
    assert(zero == z);
    assert(&zero == null);
    //warn("zero={}\n", zero); // Can't print yet bug #557
    //var z1 = @intCast(u1, zero); // Causes compiler seg fault

    var pZero: *u0 = &zero;
    //warn("pZero={}\n", pZero); // Can't print yet bug #557

    assert(pZero == null);
    //assert(@ptrCast(?*u0, pZero) == null); // Crashes compiler with seg fault

    var one: u1 = 1;
    var pOneOptional: ?*u1 = &one;
    warn("pOneOptional={*}\n", pOneOptional);
    if (pOneOptional != null) {
        assert(pOneOptional.?.* == 1);
    } else {
        unreachable; // assert(pOneOptional == null);
    }

    var pZeroOptional: ?*u0 = &zero;
    //warn("pZeroOptional={*}\n", pZeroOptional); // LLVM ERROR: Borken module found, compilation aborted!
    assert(&zero == null);         // This is true
    assert(pZeroOptional != null); // And this is true
    assert(pZeroOptional == &zero);// And this is true
    if (pZeroOptional != null) {
        assert(pZeroOptional.?.* == 0);
    } else {
        unreachable; // Currently unreachable
        //assert(pZeroOptional == null);
    }

    const Su0 = struct {
        z: u0,
    };
    var su0 = Su0 { .z = 0, };
    assert(@sizeOf(Su0) == 0);
    assert(&su0 == null);
    assert(su0.z == 0);

    // Empty structs are similar to u0
    const Empty = struct {};
    var empty: Empty = undefined;
    assert(@sizeOf(Empty) == 0);
    assert(&empty == null);

    var v: void = {};
    assert(v == {});
    assert(&v == null);
    assert(@sizeOf(@typeOf(v)) == 0);
    var pV = &v;
    assert(pV == &v);
    assert(pV == null);
    assert(pV.* == {});
}

fn x() u0 {
    var zero: u0 = 0;
    return zero;
}

test "fn x() u0" {
    assert(x() == 0);
    var result = x();
    //var result = @noInlineCall(x()); // Compiler error: type 'u0' not a function
    assert(result == 0);
}
