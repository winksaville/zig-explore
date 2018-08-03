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

        /// Return a pointer to the Message this MessageHeader is a member of.
        pub fn getMessagePtr(header: *MessageHeader) *Self {
            return @fieldParentPtr(Self, "header", header);
        }

        pub fn format(
            self: *const Self,
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

    pub cmd: u64,

    pub fn init(self: *Self, cmd: u64, message_ptr: var) void {
        self.cmd = cmd;
    }

    pub fn format(
        self: *const Self,
        comptime fmt: []const u8,
        context: var,
        comptime FmtError: type,
        output: fn (@typeOf(context), []const u8) FmtError!void
    ) FmtError!void {
        try std.fmt.format(context, FmtError, output, "cmd={}, ", self.cmd);
    }
};
