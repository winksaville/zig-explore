const assert = @import("std").debug.assert;

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

test "opaquetype" {
    var s = S {
        .value = 1,
    };
    var pS = &s;
    assert(pS.value == 1);
    assert(S.getValue(@ptrCast(S.OpaquePtr(), pS)) == 1);
}
