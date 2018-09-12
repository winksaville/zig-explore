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
Test 1/4 FuncInterface.regular...OK
Test 2/4 FuncInterface.alloc...OK
Test 3/4 Rec.undefined...OK
Test 4/4 Rec...OK
All tests passed.
```
