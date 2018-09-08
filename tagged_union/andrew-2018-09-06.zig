const std = @import("std");
const assert = std.debug.assert;
const mem = std.mem;

// A union has only 1 active field at a time.
const Tag = enum {
    Int,
    Float,
    Bool,
};

const Payload = union(Tag) {
    Int: i64,
    Float: f64,
    Bool: bool,
};
test "simple union" {
    var payload = Payload{ .Int = 1234 };
    const TagType = @TagType(Payload);
    const tag = TagType(payload);

    std.debug.warn("{}\n", tag);
    switch (payload) {
        Payload.Int => {},
        Payload.Float => {},
        Payload.Bool => {},
    }
}
