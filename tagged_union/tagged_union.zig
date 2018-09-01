const std = @import("std");
const assert = std.debug.assert;
const warn = std.debug.warn;

const Allocator = std.mem.Allocator;
const mem = std.mem;

const HashMap = std.HashMap;
const AutoHashMap = std.AutoHashMap;

test "TaggedUnion.HashMap" {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();
    var pAllocator = &direct_allocator.allocator;

    const Tagged8 = union(enum) {
        int1_8: i8,
        int2_8: i8,
        uint2_8: u8,
        uint1_8: u8,
    };
    var t8 = Tagged8 { .uint2_8=28, };
    warn("sizeof(Tagged8)={} t8={}\n", usize(@sizeOf(Tagged8)), t8);

    // Compile error no packed tagged unions
    //const PackedTagged8 = packed union(enum) {
    //    int8: i8,
    //    uint8: u8,
    //};
    //warn("sizeof(PackedTagged8)={}\n", usize(@sizeOf(PackedTagged8)));

    const TaggedUnionValue = union(enum) {
        int64: i64,
        uint64: u64,
    };

    const NamedTaggedUnionValueMap = HashMap([]const u8, TaggedUnionValue, mem.hash_slice_u8, mem.eql_slice_u8);

    var map = NamedTaggedUnionValueMap.init(pAllocator);

    // Add a new NameValue to an empty list.
    //   - error if memory failure
    //   - r != null r is the previous value
    //   - r == null then new NameValue was added to the map
    var r = try map.put("value1", TaggedUnionValue { .int64=-123, });
    if (r != null) {
        warn("value1, already inserted but this is impossible, failing\n");
        return error.value1AlreadyInserted;
    }
    // Get the value we just inserted
    var pR: ?*NamedTaggedUnionValueMap.KV = map.get("value1");
    assert(pR != null);
    assert(pR.?.value.int64 == -123);



    r = try map.put("value2", TaggedUnionValue { .uint64=123, });
    if (r != null) {
        warn("value2, already inserted but this is impossible, failing\n");
        return error.value2AlreadyInserted;
    }
    // Get the value we just inserted
    pR = map.get("value2");
    assert(pR != null);
    assert(pR.?.value.uint64 == 123);
}
