# Explore @OpaqueType

Explore how @OpaqueType works. One possible use might be as a technique
to create polymorphism. But as far as I can tell it doesn't really
help because you need to know the type anyway before making a call
to a routine.

For example below in the multi-variant type V the caller
needs to know the type prior to invoking getValue
`assert(V(u32).getValue(pOpaqueV) == 1);`.

To work around that something needs to be stored in the object itself, i.e.
use a typed union or some such. The problem with that is in
zig its not easily extensible at compile time without modifying
the tagged union.

```
fn V(comptime T: type) type {
    return struct {
        const Self = @This();

        value: T,

        fn getValue(pOpaqueSelf: OpaquePtr()) u32 {
            var pSelf = @ptrCast(*Self, pOpaqueSelf);
            return pSelf.value;
        }

        /// OpaquePtr to V with appropriate alignment
        fn OpaquePtr() type {
            return *align(@alignOf(Self)) @OpaqueType();
        }
    };
}

test "Opaquetype Multi-Variant" {
    var v = V(u32) {
        .value = 1,
    };
    var pV = &v;
    assert(pV.value == 1);

    var pOpaqueV = @ptrCast(V(u32).OpaquePtr(), pV);
    assert(V(u32).getValue(pOpaqueV) == 1);
}
```

Below is something I got working with [help](https://irclog.whitequark.org/zig/2018-09-16#23076041) from Andrew and MajorLag.
[Here](https://gist.github.com/winksaville/62169f69d8b7f38d505aa2cc866ba6f2) is the gist I shared with on Zig IRC.
```
$ zig test opaquetype.zig 
Test 1/1 opaquetype...OK
All tests passed.
```
My first mistake was getValue parameter `pOpaqueSelf` needed to be a
pointer; `pOpaqueSelf: *@OpaqueType`. But that still
didn't work, there was still an error as the types didn't match
because the call site of getValue had it's own `@OpaqueType` and apparently
the location is part of the type. So I had to have a single defintion
for the type, but that also didn't work because @ptrCast forces
an alignment. So I finally created `fn OpaquePtr` which returns a
pointer with proper alignment and is an `@OpaqueType`. And then
use that when defining ` fn getValue(pOpaqueSelf: OpaquePtr()) u32` and
also when calling getValue; `assert(S.getValue(@ptrCast(S.OpaquePtr(), pS)) == 1);`

An interesting note: when an `@OpaqueType()` is used with extern C code
`@ptrCast` at the call site isn't needed. And example is that
`pthread_t = @OpaqueType()` and `Thread.Handle = c.pthread_t`. There are
then two call sites which pass thread_ptr.data.handle, a call to
c.pthread_create and posix.close in std/os/index.zig. Neither of
these need @ptrCasts.

But when using @OpaqueType with zig it seems to require @ptrCast as
can be seen below:
```zig
    assert(S.getValue(@ptrCast(S.OpaquePtr(), pS)) == 1);
```

Here is the full code that "works":
```zig
const assert = @import("std").debug.assert;

const S = struct {
    const Self = @This();

    value: u32,

    fn getValue(pOpaqueSelf: OpaquePtr()) u32 {
        var pSelf = @ptrCast(*Self, pOpaqueSelf);
        return pSelf.value;
    }

    /// OpaquePtr to S with appropriate alignment
    fn OpaquePtr() type {
        return (*align(@alignOf(S)) @OpaqueType());
    }
};

test "opaquetype" {
    var s = S {
        .value = 1,
    };
    var pS = &s;
    assert(pS.value == 1);
    assert(S.getValue(@ptrCast(S.OpaquePtr(), pS)) == 1);
}
```
