const std = @import("std");
const warn = std.debug.warn;
const mem = std.mem;
const math = std.math;

fn Message(comptime BodyType: type) type {
    return struct {
        const Self = this;

        cmd: u64,
        body: BodyType,

        fn init(cmd: u64) Self {
            var self: Self = undefined;
            self.cmd = cmd;
            BodyType.bodyInit(&self);
            return self;
        }

        pub fn format(self: *const Self,
            comptime fmt: []const u8,
            context: var,
            comptime FmtError: type,
            output: fn (@typeOf(context), []const u8) FmtError!void
        ) FmtError!void {
            if (mem.eql(u8, fmt[0..], "p")) { return std.fmt.formatAddress(self, fmt, context, FmtError, output); }
            else {
                try std.fmt.format(context, FmtError, output, "{{");
                try std.fmt.format(context, FmtError, output, "cmd={},", self.cmd);
                try BodyType.bodyFormat(self, fmt, context, FmtError, output);
                try std.fmt.format(context, FmtError, output, "}}");
            }
        }
    };
}

const MyMessage = Message(struct {
    data: [3]u8,

    fn bodyInit(m: *MyMessage) void {
        mem.set(u8, m.body.data[0..m.body.data.len], 'Z');
    }

    pub fn bodyFormat(m: *const MyMessage,
        comptime fmt: []const u8,
        context: var,
        comptime FmtError: type,
        output: fn (@typeOf(context), []const u8) FmtError!void
    ) FmtError!void {
        try std.fmt.format(context, FmtError, output, "data={{");
        for (m.body.data) |v| {
            try std.fmt.format(context, FmtError, output, "{x},", v);
        }
        try std.fmt.format(context, FmtError, output, "}},");
    }
});

pub fn main() void {
    var msg = MyMessage.init(123);
    warn("msg={p}\n", &msg);
    warn("msg={}\n", &msg);
    //warn("cmd={} data.len={} data={}\n", msg.cmd, msg.body.data.len, msg.body.data[0..]);

    const some_data = "a";
    var copy_len = math.min(msg.body.data.len, some_data.len);
    mem.copy(u8, msg.body.data[0..], some_data[0..copy_len]);
    warn("msg={}\n", &msg);
    //warn("msg.body.data.len={} msg.body.data={}\n", msg.body.data.len, msg.body.data[0..]);
}
