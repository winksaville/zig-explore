const std = @import("std");
const warn = std.debug.warn;
const Allocator = std.mem.Allocator;
const mem = std.mem;
const formatIntBuf = std.fmt.formatIntBuf;

var g: usize = 0;

pub fn nextStr(out_buf: []u8) ?[]const u8 {
    g += 1;

    if (g > 10) { g = 10; return null; }
    var len = formatIntBuf(out_buf[0..], g, 10, false, 0);

    return out_buf[0..len];
}

pub fn next(pAllocator: *Allocator) ?(error![]u8) {
    var buf: [100]u8 = undefined;

    var s = nextStr(buf[0..]);
    if (s == null) {
        warn("s is null\n");
        return (?(error![]u8))(null); // Also, return null; works
    }

    // This works:
    //return mem.dupe(pAllocator, u8, s.?);

    // To make this work you need to cast the return value
    var n = mem.dupe(pAllocator, u8, s.?) catch |err| return (error![]u8)(err);
    warn("n={}\n", n);
    return (error![]u8)(n);
}

test "fancy_error_type" {
    warn("\n");

    var pAllocator = std.debug.global_allocator;

    g = 0;
    var i: usize = 0;
    while (true) : (i += 1) {
        var null_error_str = next(pAllocator);
        if (null_error_str == null) break;
        var s = null_error_str.? catch break;
        warn("s[{}]={}\n", i, s);
        pAllocator.free(s);
    }
}
