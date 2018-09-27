# What is an ?i32 (optional i32) memory layout.

Answer a ?i32 is logically 8 byte struct on a x86_64 which looks like:
```
const OptionalI32 = struct {
    val: i32;         // The value
    tag: u1;          // tag == 0 then this is "null" (@sizeOf(tag) == 1).
                      // Actually in Zig there is no gurantee as to the
                      // placement/alignment/value of tag. Or that it even
                      // exists as it can be optimized away!!!!
    padding: [3]u8;   // Ignored;
};
```

See doc comment in optional.i32.zig for more information. But my current
understanding of Zig is that the compiler can do anything it wishes and in
general there is aggressive optimizations. But basically there are two pieces
of information a "tag" representing if its null or not and then a value.

So you can't assume any particular layout between val and tag or the type
of the tag nor its values. The only thing you can assume is that the ?i32
is not null then the it will resolve to an i32 type.
