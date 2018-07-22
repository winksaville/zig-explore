const std = @import("std");
const assert = std.debug.assert;

fn abc (v: u64) bool {
    std.debug.warn("v={}\n", v);
    return v >= 0x8000000000000000;
}

pub fn main() void {
    var prng = std.rand.DefaultPrng.init(12345678);
    var v: u64 = undefined;
    assert(abc(prng.random.scalar(u64)));
    assert(abc(prng.random.scalar(u64)));
    assert(abc(prng.random.scalar(u64)));
    assert(abc(prng.random.scalar(u64)));
    assert(abc(prng.random.scalar(u64)));
    assert(abc(prng.random.scalar(u64)));
    assert(abc(prng.random.scalar(u64)));
    _ = abc(prng.random.scalar(u64));
}
