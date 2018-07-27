const std = @import("std");
const warn = std.debug.warn;
const mem = std.mem;
const math = std.math;

fn Message(comptime T: type) type {
    return struct {
        const Self = this;

        cmd: u64,
        body: T,

        fn init(cmd: u64) Self {
        //fn init(cmd: u64, bodyInit: fn(t: *T) void) Self {
            var self: Self = undefined;
            self.cmd = cmd;
            //bodyInit(&self.body);
            return self;
        }
    };
}
const MyMessage = Message(struct {data: [3]u8});

fn MyMessageBodyInit(m: *MyMessage) void {
    mem.set(u8, m.body.data[0..m.body.data.len], 'Z');
}

pub fn main() void {
    //var msg = MyMessage.init(123, MyMessageBodyInit);
    var msg = MyMessage.init(123);
    MyMessageBodyInit(&msg);
    warn("cmd={} data.len={} data={}\n", msg.cmd, msg.body.data.len, msg.body.data[0..]);

    warn("msg.cmd={}\n", msg.cmd);
    const some_data = "a";
    //var copy_len = math.min(msg.body.data.len, some_data.len);
    //mem.copy(u8, msg.body.data[0..], some_data[0..copy_len]);
    for (some_data) |v,i| {
        if (i >= msg.body.data.len) {
            //warn("overflowed msg.body.data at index {}\n", i);
            break;
        }
        msg.body.data[i] = v;
    }
    warn("msg.body.data.len={} msg.body.data={}\n", msg.body.data.len, msg.body.data[0..]);
}
