const std = @import("std");
const warn = std.debug.warn;

pub fn F() void {
    warn("F:#\n");
}

// Required function parameter
pub fn f(fnParam: fn() void) void {
    warn("f:+\n");
    fnParam();
    warn("f:-\n");
}

// Function with optional function parameter using orelse
pub fn h(fnParam: ?fn() void) void {
    warn("h:+\n");
    defer warn("h:-\n");
    var func = fnParam orelse { warn("h: fnParam is null"); return; };
    func();
}

// Function with optional function parameter using if
pub fn i(fnParam: ?fn() void) void {
    warn("i:+\n");
    if (fnParam) |func| {
        func();
    } else {
        warn("i: fnParam is null");
    }
    warn("i:-\n");
}

pub fn main() void {
    F();
    //f(null); // compile error
    f(F);
    h(null);
    h(F);
    i(null);
    i(F);
}
