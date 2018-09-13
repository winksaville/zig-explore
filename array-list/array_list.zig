const builtin = @import("builtin");
const std = @import("std");
const ArrayList = std.ArrayList;
const AlignedArrayList = std.AlignedArrayList;
const debug = std.debug;
const warn = debug.warn;
const assert = debug.assert;


fn append(comptime T: type, a: *ArrayList(T), value: T) !void {
    var idx: usize = a.len;
    try a.append(T(value));
    warn("item[{}]: len={} items.len={} sizeof(items[idx])={} &items[{}]={*} ",
        idx, a.len, a.items.len, @intCast(usize, @sizeOf(@typeOf(a.items[idx]))), idx, &a.items[idx]);
    if (idx > 0) {
        warn(" addrDiff={}",
            @ptrToInt(&a.items[idx]) - @ptrToInt(&a.items[idx-1]));
    }
    warn("\n");
}

test "ArrayList" {
    warn("\n");
    var da = std.heap.DirectAllocator.init();
    var allocator = &da.allocator;
    // Create a ArrayList aligned on byte boundary
    var al = ArrayList(u8).init(allocator);
    warn("empty:   len={} items.len={} sizeof(items)={}\n",
        al.len, al.items.len, @intCast(usize, @sizeOf(@typeOf(al.items))));

    // Add items and watch items.len and sizeof(items) as wells as adjency of items
    var i: u64 = 0;
    while (i < 10) : (i += 1) {
        try append(u8, &al, u8(1));
    }

    warn("\n");
    const Struct = struct {
        a: []u8, // sizeof(s.a) 16 bytes as its a TypeId.Pointer
        //a: [3]u8 // sizeof(s.a) 3 bytes
        //a: [1024]u8 // sizeof(s.a) takes 1024 bytes
    };
    var s = Struct { .a = try allocator.alloc(u8, 3) };
    s.a[0] = 'c';
    s.a[1] = 'b';
    s.a[2] = 'a';
    //@compileLog(builtin.TypeId(@typeInfo(@typeOf(s.a)))); // TypeId.Pointer
    warn("sizeof(s)={} sizeof(s.a)={} s.a.len={} s.a[0..3]={}\n",
        @intCast(usize, @sizeOf(@typeOf(s))), @intCast(usize, @sizeOf(@typeOf(s.a))), s.a.len, s.a[0..3]);
}
