const std = @import("std");
const warn = std.debug.warn;

fn Buffer(comptime buffer_size: usize) type {
    return struct {
        const Self = this;

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

pub fn main() u8 {
    const Buffer4k = Buffer(0x1000);
    var bufStack = Buffer4k.init();
    warn("bufStack.buffer[254]={}\n", bufStack.buffer[254]);

    // It would be nice if you could defer allocator so:
    //   var allocator = &std.heap.DirectAlloctor.init().allocator;
    //   defer allocator.deinit();
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();
    var allocator = &direct_allocator.allocator;

    var bufHeap = allocator.create(Buffer4k.init()) catch { std.debug.warn("OOM\n"); return 0xFF; };
    defer allocator.destroy(bufHeap);
    var r1 = bufHeap.buffer[254];
    warn("bufHeap.buffer[254]={}\n", r1);

    return bufStack.buffer[254];
}
