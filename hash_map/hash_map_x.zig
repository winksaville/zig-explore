const std = @import("std");
const assert = std.debug.assert;
const warn = std.debug.warn;

const Allocator = std.mem.Allocator;
const mem = std.mem;

const HashMap = std.HashMap;
const AutoHashMap = std.AutoHashMap;

test "HashMap.struct" {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();
    var pAllocator = &direct_allocator.allocator;

    const NameValue = struct {
        name: []const u8,
        value: []const u8,
    };

    const NameValueMap = HashMap([]const u8, NameValue, mem.hash_slice_u8, mem.eql_slice_u8);

    var map = NameValueMap.init(pAllocator);

    // Add a new NameValue to an empty list.
    //   - error if memory failure
    //   - r != null r is the previous value
    //   - r == null then new NameValue was added to the map
    var r = try map.put("wink saville", NameValue { .name="wink saville", .value="hello from wink", });
    if (r != null) {
        warn("wink saville, already inserted but this is impossible, failing\n");
        return error.NameAlreadyInserted;
    }
    // Get the value we just inserted
    var pR: ?*NameValueMap.KV = map.get("wink saville");
    assert(pR != null);
    assert(mem.eql(u8, pR.?.value.name, "wink saville"));
    assert(mem.eql(u8, pR.?.value.value, "hello from wink"));


    // Replace previous NameValue with a new value
    r = try map.put("wink saville", NameValue { .name="wink saville", .value="bye from wink", });
    if (r == null) {
        warn("wink saville, was already inserted and this is impossible, failing\n");
        return error.NameWasntInserted;
    }
    // Old value is returned
    assert(mem.eql(u8, r.?.value.name, "wink saville"));
    assert(mem.eql(u8, r.?.value.value, "hello from wink"));

    // Get the "new" NameValue we inserted
    pR = map.get("wink saville"); // orelse return error.ExpectingSuccess;
    assert(pR != null);
    assert(mem.eql(u8, pR.?.value.name, "wink saville"));
    assert(mem.eql(u8, pR.?.value.value, "bye from wink"));

    // Expecting failure, got == null
    pR = map.get("wink");
    assert(pR == null);
}

// From std/hash_map.zig
test "HashMap.basic" {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    var map = AutoHashMap(i32, i32).init(&direct_allocator.allocator);
    defer map.deinit();

    assert((try map.put(1, 11)) == null);
    assert((try map.put(2, 22)) == null);
    assert((try map.put(3, 33)) == null);
    assert((try map.put(4, 44)) == null);
    assert((try map.put(5, 55)) == null);

    assert((try map.put(5, 66)).?.value == 55);
    assert((try map.put(5, 55)).?.value == 66);

    const gop1 = try map.getOrPut(5);
    assert(gop1.found_existing == true);
    assert(gop1.kv.value == 55);
    gop1.kv.value = 77;
    assert(map.get(5).?.value == 77);

    const gop2 = try map.getOrPut(99);
    assert(gop2.found_existing == false);
    gop2.kv.value = 42;
    assert(map.get(99).?.value == 42);

    assert(map.contains(2));
    assert(map.get(2).?.value == 22);
    _ = map.remove(2);
    assert(map.remove(2) == null);
    assert(map.get(2) == null);
}

// From std/hash_map.zig
test "HashMap.iterator" {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    var reset_map = AutoHashMap(i32, i32).init(&direct_allocator.allocator);
    defer reset_map.deinit();

    assert((try reset_map.put(1, 11)) == null);
    assert((try reset_map.put(2, 22)) == null);
    assert((try reset_map.put(3, 33)) == null);

    var keys = []i32{
        3,
        2,
        1,
    };
    var values = []i32{
        33,
        22,
        11,
    };

    var it = reset_map.iterator();
    var count: usize = 0;
    while (it.next()) |next| {
        assert(next.key == keys[count]);
        assert(next.value == values[count]);
        count += 1;
    }

    assert(count == 3);
    assert(it.next() == null);
    it.reset();
    count = 0;
    while (it.next()) |next| {
        assert(next.key == keys[count]);
        assert(next.value == values[count]);
        count += 1;
        if (count == 2) break;
    }

    it.reset();
    var entry = it.next().?;
    assert(entry.key == keys[0]);
    assert(entry.value == values[0]);
}


