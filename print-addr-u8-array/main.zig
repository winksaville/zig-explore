const std = @import("std");
const warn = std.debug.warn;

pub fn main() void {
    var a = "abcdef";
    var as: []u8 = a[0..];
    const S = struct { a: []u8 };
    var s = S { .a=a[0..] };

    //@compileLog(@typeOf(a));     // [6]u8
    //@compileLog(@typeOf(&a));    // *[6]u8
    //@compileLog(@typeOf(&a[0])); // *u8

    // Use {p} requires latest master to work.
    warn("              a = {}\n", a);
    warn("             &a = {}\n", &a);
    warn("             &a = {p}\n", &a);
    warn("  @ptrToInt(&a) = {x}\n", @ptrToInt(&a));
    warn("          &a[0] = {p}\n", &a[0]);

    warn("             as = {}\n", as);
    warn("            &as = {p}\n", &as);
    warn(" @ptrToInt(&as) = {x}\n", @ptrToInt(&as));
    warn("         &as[0] = {p}\n", &as[0]);

    warn("            s.a = {}\n", s.a);
    warn("           &s.a = {p}\n", &s.a);
    warn("@ptrToInt(&s.a) = {x}\n", @ptrToInt(&s.a));
    warn("        &s.a[0] = {p}\n", &s.a[0]);
}
