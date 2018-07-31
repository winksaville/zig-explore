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
    const BodyPtr = *@OpaqueType();
    const NullBodyPtr = @intToPtr(MessageHeader.BodyPtr, 0);

    pub cmd: u64,
    pub body_ptr: BodyPtr,

    //pub fn init(cmd: u64, body_ptr: BodyPtr) Self {
    pub fn init(cmd: u64, body_ptr: var) Self {
        var self = Self {
            .cmd = cmd,
            .body_ptr = @ptrCast(MessageHeader.BodyPtr, body_ptr),
        };
        return self;
    }

    pub fn getBodyPtrAs(self: *const Self, comptime T: type) T {
        return @ptrCast(T, self.body_ptr);
    }

    pub fn format(self: *const Self,
        comptime fmt: []const u8,
        context: var,
        comptime FmtError: type,
        output: fn (@typeOf(context), []const u8) FmtError!void
    ) FmtError!void {
        try std.fmt.format(context, FmtError, output, "cmd={},", self.cmd);
    }
};

fn MessageBody(comptime BodyType: type) type {
    return struct {
        const Self = this;

        pub body: BodyType,
        pub msg: ?*MessageHeader,

        pub fn init() Self {
            var self: Self = undefined;
            BodyType.init(&self.body);
            warn("MessageBody.init: &self={x} &self.body={x}\n", @ptrToInt(&self), @ptrToInt(&self.body));
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
                if (self.msg) |msg| {
                    try std.fmt.format(context, FmtError, output, "{{");
                    try msg.format("", context, FmtError, output);
                }
                try std.fmt.format(context, FmtError, output, "{{");
                try BodyType.format(&self.body, fmt, context, FmtError, output);
                try std.fmt.format(context, FmtError, output, "}}");
                if (self.msg) |msg| {
                    try std.fmt.format(context, FmtError, output, "}}");
                }
            }
        }
    };
}

const MyMsgBody = struct {
    const Self = this;
    data: [3]u8,

    fn init(self: *Self) void {
        mem.set(u8, self.data[0..], 'Z');
        warn("MyMsgBody.init: set data to 'Z' &self={p} &self.data[0]={p} self.data[0]={}\n", &self, &self.data[0], self.data[0]);
    }

    pub fn format(m: *const MyMsgBody,
        comptime fmt: []const u8,
        context: var,
        comptime FmtError: type,
        output: fn (@typeOf(context), []const u8) FmtError!void
    ) FmtError!void {
        for (m.data) |v| {
            try std.fmt.format(context, FmtError, output, "{x},", v);
        }
    }
};

test "Message" {
    // Test NullBodyPtr works
    var msg_with_no_body_ptr = MessageHeader.init(123, MessageHeader.NullBodyPtr);
    assert(msg_with_no_body_ptr.cmd == 123);
    assert(msg_with_no_body_ptr.body_ptr == MessageHeader.NullBodyPtr);

    // Create a message body
    const MyMessageBody = MessageBody(MyMsgBody);
    var myMsgBody = MyMessageBody.init();
    warn("&myMsgBody={x}\n", @ptrToInt(&myMsgBody));
    warn("&myMsgBody={p}\n", &myMsgBody);
    warn("&myMsgBody={}\n", &myMsgBody);

    // Create a message using myMsgBody
    var myMsg1 = MessageHeader.init(456, &myMsgBody);
    myMsgBody.msg = &myMsg1;
    warn("&myMsgBody={}\n", &myMsgBody);
    assert(myMsg1.cmd == 456);
    assert(@ptrToInt(myMsg1.body_ptr) == @ptrToInt(&myMsgBody));
    assert(mem.eql(u8, myMsgBody.body.data[0..], "ZZZ"));

    // Get the BodyPtr as *MyMessageBody
    var myMsgBody2 = myMsg1.getBodyPtrAs(*MyMessageBody);
    assert(mem.eql(u8, myMsgBody2.body.data[0..], "ZZZ"));

    ////var buf1: [256]u8 = undefined;
    ////var buf2: [256]u8 = undefined;
    ////warn(myMsg2.body_ptr.format("{}", &myMsg2));
    ////try testExpectedActual(
    ////    try bufPrint(buf1[0..], "msg=Message(MyMessage)@{x}", @ptrToInt(&msg)),
    ////    try bufPrint(buf2[0..], "msg={p}", &msg));

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
