const std = @import("std");
const assert = std.debug.assert;
const warn = std.debug.warn;

// Define three structs each with a method named `returnSomething` then
// in handleReturnType we pass a Type and then use a switch statement
// on @typeOf(s.returnSomething).ReturnType. Then in each arm of the switch
// we match on the actual return type and provide what going to happen at
// runtime.
//
// So when handleReturnType is executed at compile it generates code a routine
// which when executed contains just the code in the selected switch arm.

const S1 = struct {
    fn returnSomething(a: bool) u64 {
        warn("a={}\n", a);
        return @intCast(u64, 1);
    }
};

const S2 = struct {
    fn returnSomething(a: bool) void {
        warn("a={}\n", a);
    }
};

const S3 = struct {
    fn returnSomething(a: bool) error!u64 {
        warn("a={}\n", a);
        if (a) {
            return error.aIsTrue;
        } else {
            return @intCast(u64, 1);
        }
    }
};

fn handleReturnType(comptime s: var) error!void {
    switch(@typeOf(s.returnSomething).ReturnType) {
        u64 => {
            var c = s.returnSomething(true);
            warn("s.returnSomething c={}\n", c);
            return;
        },
        void => {
            s.returnSomething(true);
            warn("s.returnSomething void\n");
            return;
        },
        error!u64 => {
            var c = try s.returnSomething(false);
            warn("s.returnSomething error!u64 c={}\n", c);
            return;
        },
        else => return error.BadNews,
    }
}

test "return-type" {
    warn("\n");
    assert((try S3.returnSomething(false)) == 1);
    try handleReturnType(S1);
    // Above generates:
    //  var c = s.returnSomething(true);
    //  warn("s.returnSomething c={}\n", c);

    try handleReturnType(S2);
    // Above generates:
    //   s.returnSomething(true);
    //   warn("s.returnSomething void\n");

    try handleReturnType(S3);
    // Above generates:
    //var c = try s.returnSomething(false);
    //warn("s.returnSomething error!u64 c={}\n", c);
}
