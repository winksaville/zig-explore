const std = @import("std");
const bufPrint = std.fmt.bufPrint;
const assert = std.debug.assert;
const warn = std.debug.warn;
const mem = std.mem;
const Queue = std.atomic.Queue;

// From std/fmt/index.zig
fn testExpectedActual(expected: []const u8, actual: []const u8) !void {
    if (mem.eql(u8, expected, actual)) return;

    warn("\n====== expected this output: =========\n");
    warn("{}", expected);
    warn("\n======== instead found this: =========\n");
    warn("{}", actual);
    warn("\n======================================\n");
    return error.TestFailed;
}

fn Message(comptime BodyType: type) type {
    return struct {
        const Self = this;

        cmd: u64,
        body: BodyType,

        fn init(cmd: u64) Self {
            var self: Self = undefined;
            self.cmd = cmd;
            BodyType.bodyInit(&self);
            return self;
        }

        pub fn format(self: *const Self,
            comptime fmt: []const u8,
            context: var,
            comptime FmtError: type,
            output: fn (@typeOf(context), []const u8) FmtError!void
        ) FmtError!void {
            if (mem.eql(u8, fmt[0..], "p")) { return std.fmt.formatAddress(self, fmt, context, FmtError, output); }
            else {
                try std.fmt.format(context, FmtError, output, "{{");
                try std.fmt.format(context, FmtError, output, "cmd={},", self.cmd);
                try BodyType.bodyFormat(self, fmt, context, FmtError, output);
                try std.fmt.format(context, FmtError, output, "}}");
            }
        }
    };
}

const MyMessage = Message(struct {
    data: [3]u8,

    fn bodyInit(m: *MyMessage) void {
        mem.set(u8, m.body.data[0..m.body.data.len], 'Z');
    }

    pub fn bodyFormat(m: *const MyMessage,
        comptime fmt: []const u8,
        context: var,
        comptime FmtError: type,
        output: fn (@typeOf(context), []const u8) FmtError!void
    ) FmtError!void {
        try std.fmt.format(context, FmtError, output, "data={{");
        for (m.body.data) |v| {
            try std.fmt.format(context, FmtError, output, "{x},", v);
        }
        try std.fmt.format(context, FmtError, output, "}},");
    }
});

test "Message" {
    var buf1: [256]u8 = undefined;
    var buf2: [256]u8 = undefined;

    var msg = MyMessage.init(123);
    assert(msg.cmd == 123);
    assert(mem.eql(u8, msg.body.data[0..], "ZZZ"));

    try testExpectedActual(
        try bufPrint(buf1[0..], "msg=Message(MyMessage)@{x}", @ptrToInt(&msg)),
        try bufPrint(buf2[0..], "msg={p}", &msg));

    try testExpectedActual(
        "msg={cmd=123,data={5a,5a,5a,},}",
        try bufPrint(buf2[0..], "msg={}", &msg));

    msg.body.data[0] = 'a';
    try testExpectedActual(
        "msg={cmd=123,data={61,5a,5a,},}",
        try bufPrint(buf2[0..], "msg={}", &msg));

    // Create a queue
    const MyQueue = Queue(MyMessage);
    var q = MyQueue.init();

    // Create a node
    var node_0 = MyQueue.Node {
        .data = msg,
        .next = undefined,
    };

    // Add and remove it from the queue
    q.put(&node_0);
    var n = q.get() orelse { return; };
    assert(n.data.cmd == 123);
}
