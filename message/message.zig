// Create a Message that supports arbitrary data
// and can be passed between entities via a Queue.

const std = @import("std");
const warn = std.debug.warn;

pub fn Message(comptime BodyType: type) type {
    return packed struct {
        const Self = this;

        pub header: MessageHeader,
        pub body: BodyType,

        pub fn init(cmd: u64) Self {
            var self: Self = undefined;
            self.header.init(cmd, &self);
            BodyType.init(&self.body);
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

pub const MessageHeader = packed struct {
    const Self = this;

    pub message_offset: usize,
    pub cmd: u64,

    pub fn init(self: *Self, cmd: u64, message_ptr: var) void {
        self.cmd = cmd;
        self.message_offset = @ptrToInt(&self.message_offset) - @ptrToInt(message_ptr);
    }

    pub fn getMessagePtrAs(self: *const Self, comptime T: type) T {
        var message_ptr = @intToPtr(T, @ptrToInt(&self.message_offset) - self.message_offset);
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
