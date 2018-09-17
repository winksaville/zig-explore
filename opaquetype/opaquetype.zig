const assert = @import("std").debug.assert;

// So a type with just a single variant an opaque pointer
// works fine.
const S = struct {
    const Self = @This();

    value: u32,

    fn getValue(pOpaqueSelf: OpaquePtr()) u32 {
        var pSelf = @ptrCast(*Self, pOpaqueSelf);
        return pSelf.value;
    }

    /// OpaquePtr to S with appropriate alignment
    fn OpaquePtr() type {
        return (*align(@alignOf(S)) @OpaqueType());
    }
};

test "Opaquetype Single Variant" {
    var s = S {
        .value = 1,
    };
    var pS = &s;
    assert(pS.value == 1);
    assert(S.getValue(@ptrCast(S.OpaquePtr(), pS)) == 1);
}

fn V(comptime T: type) type {
    return struct {
        const Self = @This();

        value: T,

        fn getValue(pOpaqueSelf: OpaquePtr()) u32 {
            var pSelf = @ptrCast(*Self, pOpaqueSelf);
            return pSelf.value;
        }

        /// OpaquePtr to V with appropriate alignment
        fn OpaquePtr() type {
            return *align(@alignOf(Self)) @OpaqueType();
        }
    };
}

test "Opaquetype Multi-Variant" {
    var v = V(u32) {
        .value = 1,
    };
    var pV = &v;
    assert(pV.value == 1);

    var pOpaqueV = @ptrCast(V(u32).OpaquePtr(), pV);
    assert(V(u32).getValue(pOpaqueV) == 1);
}
