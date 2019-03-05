const std = @import("std");
const assert = std.debug.assert;

fn abc(v: u64) bool {
    var ret_val: bool = v >= 0x8000000000000000;
    std.debug.warn("v={x} ret_val={}\n", v, ret_val);
    return ret_val;
}

pub fn main() void {
    var prng = std.rand.DefaultPrng.init(12345678);
    assert(!abc(prng.random.scalar(u64)));
    assert(!abc(prng.random.scalar(u64)));
    assert(abc(prng.random.scalar(u64)));
    assert(abc(prng.random.scalar(u64)));
    assert(!abc(prng.random.scalar(u64)));
    assert(!abc(prng.random.scalar(u64)));

    // This should fail in debug and --release-safe builds
    // and succeed in --release-fast and --release-small builds
    assert(!abc(prng.random.scalar(u64)));
}
