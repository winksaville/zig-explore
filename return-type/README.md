# Explore how to determine a methods return type at comptime

One thing I don't like is that when using this @typeof(xx).ReturnType
you must always use a "full" spec, `error!void` instead of the short
cut `!void`.

See return-type.zig for details:
```
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

// Examples calling handleReturnType
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
```
