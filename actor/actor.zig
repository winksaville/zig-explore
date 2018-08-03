// Create an Actor that process messages

const std = @import("std");
const MessageHeader = @import("../message/message.zig").MessageHeader;

pub const ActorPtr = *@OpaqueType();

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
