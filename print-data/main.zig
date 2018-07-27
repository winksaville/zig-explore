const std = @import("std");
const Queue = std.atomic.Queue;
const warn = std.debug.warn;


pub fn main() void {
    const S = struct {
        const Self = this;

        b1: u1,
        i: u8,
        ai: []u8,

        /// Custom format routine for S
        pub fn format(self: *Self,
            comptime fmt: []const u8,
            context: var,
            comptime FmtError: type,
            output: fn (@typeOf(context), []const u8) FmtError!void
        ) FmtError!void {
            if (std.mem.eql(u8, fmt[0..], "p")) { return std.fmt.formatAddress(self, fmt, context, FmtError, output); }
            else {
                try std.fmt.format(context, FmtError, output, "{{");
                try std.fmt.format(context, FmtError, output, ".b1={} .i={} .ai={{", self.b1, self.i);
                for (self.ai) |v| {
                    try std.fmt.format(context, FmtError, output, "{x},", v);
                }
                try std.fmt.format(context, FmtError, output, "}}");
                try std.fmt.format(context, FmtError, output, "}}");
            }
        }
    };
    var a = "abcdef";
    warn("&a={p} a={}\n", &a, a);

    var s = S {.b1=1, .i=123, .ai=a[0..2]};
    warn("s = S {p}\n", &s);
    warn("s = S {}\n", &s);
    warn("s.b1={}\n", s.b1);
    warn("s.i={}\n", s.i);
    warn("s.ai={}\n", s.ai);
    warn("&s.ai={p} &a={p}\n", &s.ai, &a);
    warn("&s.ai[0]={p}\n", &s.ai[0]);
    warn("s.ai[0]={c}\n", s.ai[0]);
    warn("s.ai[1]={x}\n", s.ai[1]);

    const Q = Queue(u32);
    var q = Q.init();
    q.dump();
    
    var da = std.heap.DirectAllocator.init();
    defer da.deinit();
    var allocator = &da.allocator;
    var node: *Q.Node = allocator.create(Q.Node {.data=1, .next=undefined}) catch { warn("OOM\n"); return; };
    q.put(node);
    q.dump();

    var node0 = Q.Node {
        .data = 123,
        .next = undefined,
    };
    q.put(&node0);
    q.dump();
    var node1 = Q.Node {
        .data = 456,
        .next = undefined,
    };
    q.put(&node1);
    q.dump();

    
    var b = []Q.Node {
        Q.Node { .data = 789, .next = undefined },
        Q.Node { .data = 012, .next = undefined },
    };
    q.put(&b[0]);
    q.dump();
    q.put(&b[1]);
    q.dump();
}
