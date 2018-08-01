const std = @import("std");
const Allocator = std.mem.Allocator;
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

const MessageHeader = struct {
    const Self = this;

    pub cmd: u64,
    pub message_offset: usize,

    pub fn init(self: *Self, cmd: u64, message_ptr: var) void {
        self.cmd = cmd;
        self.message_offset = @ptrToInt(&self.message_offset) - @ptrToInt(message_ptr);
        warn("MessageHeader.init: cmd={} message_ptr={*}, &self.message_offset={*} self.message_offset={}\n", self.cmd, message_ptr, &self.message_offset, self.message_offset);
    }

    pub fn getMessagePtrAs(self: *const Self, comptime T: type) T {
        var message_ptr = @intToPtr(T, @ptrToInt(&self.message_offset) - self.message_offset);
        warn("MessageHeader.getMessagePtrAs: cmd={} message_ptr={*}, &self.message_offset={*} self.message_offset={}\n", self.cmd, message_ptr, &self.message_offset, self.message_offset);
        return @ptrCast(T, message_ptr);
    }

    pub fn format(self: *const Self,
        comptime fmt: []const u8,
        context: var,
        comptime FmtError: type,
        output: fn (@typeOf(context), []const u8) FmtError!void
    ) FmtError!void {
        try std.fmt.format(context, FmtError, output, "cmd={}, message_offset={}, ", self.cmd, self.message_offset);
    }
};

fn Message(comptime BodyType: type) type {
    return struct {
        const Self = this;

        pub header: MessageHeader,
        pub body: BodyType,

        pub fn init(cmd: u64) Self {
            var self: Self = undefined;
            self.header.init(cmd, &self);
            BodyType.init(&self.body);
            warn("Message.init: &self={*} &self.header={*} &self.body={*}\n",
                    &self, &self.header, &self.body);
            return self;
        }

        pub fn format(self: *const Self,
            comptime fmt: []const u8,
            context: var,
            comptime FmtError: type,
            output: fn (@typeOf(context), []const u8) FmtError!void
        ) FmtError!void {
            try std.fmt.format(context, FmtError, output, "{{");
            try self.header.format("", context, FmtError, output);
            try std.fmt.format(context, FmtError, output, "body={{");
            try BodyType.format(&self.body, fmt, context, FmtError, output);
            try std.fmt.format(context, FmtError, output, "}},");
            try std.fmt.format(context, FmtError, output, "}}");
        }
    };
}

const MyMsgBody = struct {
    const Self = this;
    data: [3]u8,

    fn init(self: *Self) void {
        mem.set(u8, self.data[0..], 'Z');
        //warn("MyMsgBody.init: set data to 'Z' &self={*} &self.data[0]={*} self.data[0]={}\n", self, &self.data[0], self.data[0]);
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
    // Create a message with MyMsgBody
    const MyMsg = Message(MyMsgBody);
    var myMsg = MyMsg.init(456);
    warn("myMsg: &myMsg={*} &myMsg.header={*} &myMsg.body={*}\n", &myMsg, &myMsg.header, &myMsg.body);
    warn("myMsg={}\n", &myMsg);

    // Test myMsg
    assert(myMsg.header.cmd == 456);
    assert(myMsg.header.message_offset == @ptrToInt(&myMsg.header.message_offset) - @ptrToInt(&myMsg)); 
    assert(mem.eql(u8, myMsg.body.data[0..], "ZZZ"));

    // Get the MessagePtr as *MyMsg
    var myMsg2 = myMsg.header.getMessagePtrAs(*MyMsg);
    assert(@ptrToInt(myMsg2) == @ptrToInt(&myMsg));
    assert(mem.eql(u8, myMsg2.body.data[0..], "ZZZ"));

    ////var buf1: [256]u8 = undefined;
    ////var buf2: [256]u8 = undefined;
    ////warn(myMsg2.message_ptr.format("{}", &myMsg2));
    ////try testExpectedActual(
    ////    try bufPrint(buf1[0..], "msg=Message(MyMessage)@{x}", @ptrToInt(&msg)),
    ////    try bufPrint(buf2[0..], "msg={*}", &msg));

//    try testExpectedActual(
//        "msg={cmd=123,data={5a,5a,5a,},}",
//        try bufPrint(buf2[0..], "msg={}", &msg));
//
//    msg.body.data[0] = 'a';
//    try testExpectedActual(
//        "msg={cmd=123,data={61,5a,5a,},}",
//        try bufPrint(buf2[0..], "msg={}", &msg));
//
//    // Create a queue
//    const MyQueue = Queue(MyMessage);
//    var q = MyQueue.init();
//
//    // Create a node
//    var node_0 = MyQueue.Node {
//        .data = msg,
//        .next = undefined,
//    };
//
//    // Add and remove it from the queue
//    q.put(&node_0);
//    var n = q.get() orelse { return; };
//    assert(n.data.cmd == 123);
}
