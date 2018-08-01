// Create a Message that supports arbitrary data
// and can be passed between entities via a Queue.

const Actor = @import("actor.zig").Actor;

const Msg = @import("../message/message.zig");
const Message = Msg.Message;
const MessageHeader = Msg.MessageHeader;

const std = @import("std");
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

    pub fn format(
        m: *const MyMsgBody,
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

const MyActorBody = packed struct {
    const Self = this;

    count: u64,

    fn init(actor: *Actor(MyActorBody)) void {
        var self = &actor.body;
        self.count = 0;
    }

    pub fn processMessage(
            actor: *Actor(MyActorBody),
            msgHeader: *MessageHeader,
    ) void {
        var pMsg = msgHeader.getMessagePtrAs(*Message(MyMsgBody));
        assert(pMsg.header.cmd == msgHeader.cmd);

        actor.body.count += 1;
        warn("MyActorBody: processMessage cmd={} count={}\n",
            msgHeader.cmd, actor.body.count);
    }
};

test "Actor" {
    // Create a message
    const MyMsg = Message(MyMsgBody);
    var myMsg = MyMsg.init(123);

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
    var pMsg = n.data.getMessagePtrAs(*MyMsg);

    // Create an Actor
    const MyActor = Actor(MyActorBody);
    var myActor = MyActor.init();

    myActor.handleMessage(n.data);
    assert(myActor.body.count == 1);
    myActor.handleMessage(n.data);
    assert(myActor.body.count == 2);
}
