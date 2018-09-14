const std = @import("std");
const assert = std.debug.assert;
const mem = std.mem;

const Message = struct {
    const Self = @This();
    const BodyPtr = *@OpaqueType();

    pub body_ptr: BodyPtr,

    pub fn init(body_ptr: var) Self {
        var self = Self {
            .body_ptr = @ptrCast(Message.BodyPtr, body_ptr),
        };
        return self;
    }

    pub fn getBodyPtrAs(self: *const Self, comptime T: type) T {
        return @ptrCast(T, self.body_ptr);
    }
};

const MyMsgBody = struct {
    const Self = @This();
    pub data: [3]u8,

    pub fn init() Self {
        var self: Self = undefined;
        mem.set(u8, self.data[0..], 'Z');
        return self;
    }
};

test "Message" {
    var myMsgBody = MyMsgBody.init();
    assert(mem.eql(u8, myMsgBody.data[0..], "ZZZ"));

    var myMsg1 = Message.init(&myMsgBody);
    assert(@ptrToInt(myMsg1.body_ptr) == @ptrToInt(&myMsgBody));

    var myMsgBody2 = myMsg1.getBodyPtrAs(*MyMsgBody);
    assert(mem.eql(u8, myMsgBody2.data[0..], "ZZZ"));
}
