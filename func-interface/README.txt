# Explore function interface

I want to be able to have an interface where a
function might sometimes be passed a allocator
and sometimes not.

```
pub fn FuncInterface(comptime ft: FuncType, comptime T: type) type {
    return struct {
        const Self = this;

        const Type = switch (ft) {
            FuncType.alloc => fn (*Allocator, []const u8) error!T,
            FuncType.regular => fn ([]const u8) error!T,
        };

        func: Type,

        fn init(func: Type) Self {
            return Self {
                .func = func,
            };
        }
    };
}
```

Working fine:
```
$ zig test func-interface.zig 
Test 1/2 FuncInterface.regular...OK
Test 2/2 FuncInterface.alloc...OK
All tests pass
```

Then I figured out a simpler version, just pass the FuncType directly
```
pub fn SimplerFuncInterface(comptime FuncType: type) type {
    return struct {
        const Self = this;

        func: FuncType,

        fn init(func: FuncType) Self {
            return Self {
                .func = func,
            };
        }
    };
}

pub fn dupStr(pAllocator: *Allocator, str: []const u8) ![]const u8 {
    if (str.len == 0) return error.WTF;
    return try mem.dupe(pAllocator, u8, str);
}

pub fn theStr(str: []const u8) ![]const u8 {
    if (str.len == 0) return error.WTF;
    return str;
}

test "SimplerFuncInterface.dupStr" {
    const Sfi = SimplerFuncInterface(@typeOf(dupStr));
    var sfi: Sfi = undefined;
    sfi.func = dupStr;
    var s = try sfi.func(debug.global_allocator, "hi");
    defer debug.global_allocator.free(s);
    assert(mem.eql(u8, s, "hi"));
}

test "SimplerFuncInterface.theStr" {
    var sfi = SimplerFuncInterface(@typeOf(theStr)).init(theStr);
    var s = try sfi.func("bye");
    assert(mem.eql(u8, s, "bye"));
}
```

And that works fine too
```
$ zig test simpler-func-interface.zig
Test 1/2 SimplerFuncInterface.dupStr...OK
Test 2/2 SimplerFuncInterface.theStr...OK
All tests passed.
```
