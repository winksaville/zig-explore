const warn = @import("std").debug.warn;

test "print i1" {
    var v1: u1 = 1;
    warn("v1={}\n", v1);
}
