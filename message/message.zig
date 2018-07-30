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

const Message = struct {
    const Self = this;
    const BodyPtr = *@OpaqueType();

    pub cmd: u64,
    pub body_ptr: BodyPtr,

    pub fn createOne(cmd: u64, body_ptr: BodyPtr) Self {
        var self = Self {
            .cmd = cmd,
            .body_ptr = body_ptr,
        };
        return self;
    }

    //fn createOneAligned(allocator: *Allocator, cmd: u64, comptime alignment: u29, size: usize) !Self {
    //    var self: Self = undefined;
    //    self.cmd = cmd;
    //    try self.body_ptr = self.allocator.allignedAlloc(u8, alignment, self.body_size);
    //    return self;
    //}

    //pub fn format(self: *const Self,
    //    comptime fmt: []const u8,
    //    context: var,
    //    comptime FmtError: type,
    //    output: fn (@typeOf(context), []const u8) FmtError!void
    //) FmtError!void {
    //    try std.fmt.format(context, FmtError, output, "cmd={},", self.cmd);
    //}
};

fn MessageBody(comptime BodyType: type) type {
    return struct {
        const Self = this;

        pub body: BodyType,

        pub fn init() Self {
            var self: Self = undefined;
            BodyType.init(&self.body);
            warn("MessageBody.init: &self={x} &self.body={x}\n", @ptrToInt(&self), @ptrToInt(&self.body));
            return self;
        }

        pub fn format(msg: *const Message,
            comptime fmt: []const u8,
            context: var,
            comptime FmtError: type,
            output: fn (@typeOf(context), []const u8) FmtError!void
        ) FmtError!void {
            if (mem.eql(u8, fmt[0..], "p")) { return std.fmt.formatAddress(msg, fmt, context, FmtError, output); }
            else {
                try std.fmt.format(context, FmtError, output, "{{");
                try msg.format("", context, FmtError, output);
                if (msg.body_ptr == &self.body) {
                    try BodyType.bodyFormat(self, fmt, context, FmtError, output);
                }
                try std.fmt.format(context, FmtError, output, "}}");
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

    pub fn bodyFormat(m: *const MyMsgBody,
        comptime fmt: []const u8,
        context: var,
        comptime FmtError: type,
        output: fn (@typeOf(context), []const u8) FmtError!void
    ) FmtError!void {
        try std.fmt.format(context, FmtError, output, "data={{");
        for (m.data) |v| {
            try std.fmt.format(context, FmtError, output, "{x},", v);
        }
        try std.fmt.format(context, FmtError, output, "}},");
    }
};

test "Message" {
    //const MyMsg = Message();
    var myMsg1 = Message.createOne(123, @intToPtr(Message.BodyPtr, 0));

    //var da = std.heap.DirectAllocator.init();
    //defer da.deinit();
    //var allocator = &da.allocator;

    const MyMessageBody = MessageBody(MyMsgBody);
    var myMsgBody = &MyMessageBody.init();
    warn("&myMsgBody={x}\n", @ptrToInt(&myMsgBody));
    warn("&myMsgBody={p}\n", &myMsgBody);

    var myMsg2 = Message.createOne(456, @ptrCast(Message.BodyPtr, myMsgBody));

    var buf1: [256]u8 = undefined;
    var buf2: [256]u8 = undefined;

    assert(myMsg2.cmd == 456);
    assert(@ptrToInt(myMsg2.body_ptr) == @ptrToInt(&myMsgBody.body.data[0]));
    warn("&data={p}\n", &myMsgBody.body.data);
    warn("data={p}\n", myMsgBody.body.data);
    warn("data={}\n", myMsgBody.body.data);
    assert(mem.eql(u8, myMsgBody.body.data[0..], "ZZZ"));

    //warn(myMsg2.body_ptr.format("{}", &myMsg2));
    //try testExpectedActual(
    //    try bufPrint(buf1[0..], "msg=Message(MyMessage)@{x}", @ptrToInt(&msg)),
    //    try bufPrint(buf2[0..], "msg={p}", &msg));

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
