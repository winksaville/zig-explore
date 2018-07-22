const std = @import("std");
const warn = std.debug.warn;

pub fn main() u8 {
    const xyz = struct {
        fn toU8 (v: u64) u8 {
            warn("v={}\n", v);
            return @truncate(u8, v);
        }
    };

    var v = xyz.toU8(257);
    warn("toU8={}\n", v);
    return v;
}
