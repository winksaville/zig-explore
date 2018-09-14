const std = @import("std");
const warn = std.debug.warn;
const assert = std.debug.assert;

fn Buffer(comptime buffer_size: usize) type {
    return struct {
        const Self = @This();

        pub buffer: [buffer_size]u8,

        // Initialize if allocated in the stack
        pub fn init() Self {
            var self: Self = undefined;
            self.fill();
            return self;
        }

        fn fill(self: *Self) void {
            for (self.buffer) |*ptr, i| {
                ptr.* = @truncate(u8, i);
            }
        }
    };
}

test "Buffer" {
    warn("\n");

    const Buffer4k = Buffer(0x1000);
    var bufStack = Buffer4k.init();
    warn("bufStack.buffer[254]={}\n", bufStack.buffer[254]);

    // It would be nice if you could defer allocator so:
    //   var allocator = &std.heap.DirectAlloctor.init().allocator;
    //   defer allocator.deinit();
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();
    var allocator = &direct_allocator.allocator;

    var bufHeap = try allocator.create(Buffer4k.init());
    defer allocator.destroy(bufHeap);
    var r1 = bufHeap.buffer[254];
    warn("bufHeap.buffer[254]={}\n", r1);

    assert(bufStack.buffer[254] == 254);
}
