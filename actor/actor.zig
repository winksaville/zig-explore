// Create an Actor that process messages

const MessageHeader = @import("../message/message.zig").MessageHeader;

const std = @import("std");
const warn = std.debug.warn;

pub fn Actor(comptime BodyType: type) type {
    return packed struct {
        const Self = this;

        pub body: BodyType,

        pub fn init() Self {
            var self: Self = undefined;
            BodyType.init(&self);
            return self;
        }

        pub fn handleMessage(
            self: *Self,
            msgHeader: *MessageHeader,
        ) void {
            BodyType.processMessage(self, msgHeader);
        }
    };
}
