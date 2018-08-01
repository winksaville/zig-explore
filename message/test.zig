// Create a Message that supports arbitrary data
// and can be passed between entities via a Queue.

const Message = @import("message.zig").Message;
const MessageHeader = @import("message.zig").MessageHeader;

const std = @import("std");
const Allocator = std.mem.Allocator;
const bufPrint = std.fmt.bufPrint;
const assert = std.debug.assert;
const warn = std.debug.warn;
const mem = std.mem;
const Queue = std.atomic.Queue;

const MyMsgBody = packed struct {
    const Self = this;
    data: [3]u8,

    fn init(self: *Self) void {
        mem.set(u8, self.data[0..], 'Z');
    }

    pub fn format(m: *const MyMsgBody,
        comptime fmt: []const u8,
        context: var,
        comptime FmtError: type,
        output: fn (@typeOf(context), []const u8) FmtError!void
    ) FmtError!void {
        try std.fmt.format(context, FmtError, output, "data={{");
        for (m.data) |v| {
            if ((v >= ' ') and (v <= 0x7f)) {
                try std.fmt.format(context, FmtError, output, "{c}," , v);
            } else {
                try std.fmt.format(context, FmtError, output, "{x},", v);
            }
        }
        try std.fmt.format(context, FmtError, output, "}},");
    }
};

test "Message" {
    // Create a message
    const MyMsg = Message(MyMsgBody);
    var myMsg = MyMsg.init(123);
    warn("\nmyMsg={}\n", &myMsg);

    assert(myMsg.header.cmd == 123);
    assert(myMsg.header.message_offset == @ptrToInt(&myMsg.header.message_offset) - @ptrToInt(&myMsg)); 
    assert(mem.eql(u8, myMsg.body.data[0..], "ZZZ"));

    // Get the MessagePtr as *MyMsg
    var pMsg = myMsg.header.getMessagePtrAs(*MyMsg);
    assert(@ptrToInt(pMsg) == @ptrToInt(&myMsg));
    assert(mem.eql(u8, pMsg.body.data[0..], "ZZZ"));

    var buf1: [256]u8 = undefined;
    var buf2: [256]u8 = undefined;

    try testExpectedActual(
        "pMsg={cmd=123, message_offset=0, body={data={Z,Z,Z,},},}",
        try bufPrint(buf2[0..], "pMsg={}", pMsg));

    pMsg.body.data[0] = 'a';
    try testExpectedActual(
        "pMsg={cmd=123, message_offset=0, body={data={a,Z,Z,},},}",
        try bufPrint(buf2[0..], "pMsg={}", pMsg));

    // Create a queue of MessageHeader pointers
    const MyQueue = Queue(*MessageHeader);
    var q = MyQueue.init();

    // Create a node with a pointer to a message header
    var node_0 = MyQueue.Node {
        .data = &myMsg.header,
        .next = undefined,
    };

    // Add and remove it from the queue and verify
    q.put(&node_0);
    var n = q.get() orelse { return error.QGetFailed; };
    pMsg = n.data.getMessagePtrAs(*MyMsg);
    assert(pMsg.header.cmd == 123);
    assert(mem.eql(u8, pMsg.body.data[0..], "aZZ"));

    warn(" pMsg={}\n", pMsg);
    try testExpectedActual(
        "pMsg={cmd=123, message_offset=0, body={data={a,Z,Z,},},}",
        try bufPrint(buf2[0..], "pMsg={}", pMsg));
}

fn testExpectedActual(expected: []const u8, actual: []const u8) !void {
    if (mem.eql(u8, expected, actual)) return;

    warn("\n====== expected this output: =========\n");
    warn("{}", expected);
    warn("\n======== instead found this: =========\n");
    warn("{}", actual);
    warn("\n======================================\n");
    return error.TestFailed;
}
