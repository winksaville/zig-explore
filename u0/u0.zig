const std = @import("std");
const assert = std.debug.assert;
const warn = std.debug.warn;
const builtin = @import("builtin");
const TypeId = builtin.TypeId;

test "u0" {
    //warn("\n");

    var usize1: usize = undefined;
    var usize2: usize = undefined;

    // Test with u1
    var one: u1 = 1;
    assert(one == 1);
    assert(@sizeOf(@typeOf(one)) == 1);
    assert(@sizeOf(u1) == 1);
    assert(@intCast(u8, one) == 1);

    var pOne: *u1 = &one;
    var pOne2: *u1 = &one;
    assert(pOne.* == pOne2.*);
    assert(pOne == &one);
    assert(pOne2 == &one);
    assert(pOne == pOne2);
    assert(&pOne != &pOne2);

    usize1 = @ptrToInt(pOne);
    usize2 = @ptrToInt(pOne2);
    assert(usize1 == usize2);
    usize1 = @ptrToInt(&pOne);
    usize2 = @ptrToInt(&pOne2);
    assert(usize1 != usize2);

    var pOneOptional: ?*u1 = &one;
    var pOneOptional2: ?*u1 = &one;
    assert(pOneOptional == pOneOptional2);
    assert(&pOneOptional != &pOneOptional2);
    assert(pOneOptional != null);
    assert(pOneOptional == &one);
    if (pOneOptional != null) {
        assert(pOneOptional.?.* == 1);
    } else {
        unreachable; // assert(pOneOptional == null);
    }

    // "Same" tests with u0:

    // These are expected results
    var zero: u0 = 0;
    assert(zero == 0);
    assert(@sizeOf(@typeOf(zero)) == 0);
    assert(@sizeOf(u0) == 0);
    assert(@intCast(u8, zero) == 0);

    // These are expected results expect the last one assert(&pZero == &pZero2)
    var pZero = &zero;
    var pZero2 = &zero;
    assert(pZero.* == pZero2.*);
    assert(pZero == &zero);
    assert(pZero2 == &zero);
    assert(pZero == pZero2);
    assert(&pZero == &pZero2); // This seems odd??

    // Below when trying to convert pZero to int it says:
    //   "pointer to size 0 type has no address"
    // These is unexpected especially above I can "take an address"
    //usize1 = @ptrToInt(pZero); // compile error: pointer to size 0 type has no address
    //usize2 = @ptrToInt(pZero2); // compile error: pointer to size 0 type has no address
    //assert(usize1 == usize2);
    //usize1 = @ptrToInt(&pZero); // compile error: pointer to size 0 type has no address
    //usize2 = @ptrToInt(&pZero2); // compile error: pointer to size 0 type has no address
    //assert(usize1 != usize2);

    // These are expected results
    var pZeroOptional: ?*u0 = &zero;
    var pZeroOptional2: ?*u0 = &zero;
    assert(pZeroOptional == pZeroOptional2);
    assert(&pZeroOptional != &pZeroOptional2);
    assert(pZeroOptional != null);
    assert(pZeroOptional == &zero);
    if (pZeroOptional != null) {
        assert(pZeroOptional.?.* == 0);
    } else {
        unreachable; //assert(pZeroOptional == null);
    }

    // Using "packed" cause compiler error
    // zig: ../src/analyze.cpp:499: ZigType* get_pointer_to_type_extra(CodeGen*, ZigType*, bool, bool, PtrLen, uint32_t, uint32_t, uint32_t): Assertion `byte_alignment == 0' failed.
    // Aborted (core dumped)
    //const Su0 = packed struct {
    const Su0 = struct {
        f0: u8,
        z1: u0,
        z2: u0,
    };

    // These are expected
    var su0 = Su0 { .f0 = 0, .z1 = 0, .z2 = 0 };
    assert(@sizeOf(Su0) == 1);
    assert(su0.z1 == 0);
    assert(su0.z2 == 0);
    assert(su0.z1 == su0.z2);
    assert(&su0.z1 == &su0.z2);
    var pZ1 = &su0.z1;
    var pZ2 = &su0.z2;
    assert(pZ1 == pZ2);

    var pSu0 = &su0;
    var pSu0_u8 = @ptrCast(*align(1) u8, pSu0);
    var pSu0_f0_u8 = @ptrCast(*align(1) u8, &pSu0.f0);
    assert(pSu0_u8 == pSu0_f0_u8);
    var f0_offset: usize = @offsetOf(Su0, "f0");
    assert(f0_offset == 0);

    // If I can take an address of su0.z1 and su0.z1 and assert(pZ1 == pZ2)
    // then I should be able to get its offset and su0.z2 offset and assert(z1_offset == z2_offset).
    //var z1_offset: usize @offsetOf(Su0, "z1"); // compile error: zero-bit field 'z1' in struct 'Su0' has no offset
    //var z2_offset: usize @offsetOf(Su0, "z2"); // compile error: zero-bit field 'z1' in struct 'Su0' has no offset
    //assert(z1_offset == z2_offset); // My expectation?

    //usize1 = @ptrToInt(pZ1); // compile error: pointer to size 0 type has no address
    //usize2 = @ptrToInt(pZ2); // compile error: pointer to size 0 type has no address
    //assert(usize1 == usize2);
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
