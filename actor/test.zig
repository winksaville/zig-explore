// Create a Message that supports arbitrary data
// and can be passed between entities via a Queue.

const actor = @import("actor.zig");
const Actor = actor.Actor;
const ActorPtr = actor.ActorPtr;

const Msg = @import("../message/message.zig");
const Message = Msg.Message;
const MessageHeader = Msg.MessageHeader;
const ActorDispatcher = @import("actor_dispatcher.zig").ActorDispatcher;

const std = @import("std");
const bufPrint = std.fmt.bufPrint;
const assert = std.debug.assert;
const warn = std.debug.warn;
const mem = std.mem;
const math = std.math;
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

    fn init(actr: *Actor(MyActorBody)) void {
        var self = &actr.body;
        self.count = 0;
    }

    pub fn processMessage(
            actr: *Actor(MyActorBody),
            msgHeader: *MessageHeader,
    ) void {
        var pMsg = msgHeader.getMessagePtrAs(*Message(MyMsgBody));
        assert(pMsg.header.cmd == msgHeader.cmd);

        actr.body.count += 1;
        warn("MyActorBody: processMessage cmd={} count={}\n",
            msgHeader.cmd, actr.body.count);
    }
};

const ThreadContext = struct {
    const Self = this;

    name_len: usize,
    name: [32]u8,

    pub fn init(self: *Self, name: [] const u8) void {
        // Set name_len and then copy with truncation
        self.name_len = math.min(name.len, self.name.len);
        mem.copy(u8, self.name[0..self.name_len], name[0..self.name_len]);
    }
};

var thread0_context: ThreadContext = undefined;

fn threadDispatcher(context: *ThreadContext) void {
    warn("threadDispatcher: {}\n", context.name[0..context.name_len]);
}

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

    const MyActorDispatcher = ActorDispatcher(5);
    var myActorDispatcher = MyActorDispatcher.init();
    assert(myActorDispatcher.actors_count == 0);
    try myActorDispatcher.add(&myActor);
    assert(myActorDispatcher.actors_count == 1);
    assert(myActorDispatcher.actors[0] == @ptrCast(ActorPtr, &myActor));

    warn("call threadSpawn\n");
    thread0_context.init("thread0");
    warn("thread0_context.name len={} name={}\n", thread0_context.name.len, thread0_context.name[0..thread0_context.name_len]);
    var thread_0 = try std.os.spawnThread(&thread0_context, threadDispatcher);
    warn("call wait\n");
    thread_0.wait();
    warn("call after wait\n");

}
