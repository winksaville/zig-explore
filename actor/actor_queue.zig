// Actor Queue
//
// In the future this will probably turn into
// a specialized queue that only supports
// Multiple Procuder Single Consuer (MPSC) lock
// free queues.

const std = @import("std");
const Queue = std.atomic.Queue;
const MessageHeader = @import("../message/message.zig").MessageHeader;

pub const ActorQueue = Queue(*MessageHeader);
