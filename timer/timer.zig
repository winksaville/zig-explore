// Create a Message that supports arbitrary data
// and can be passed between entities via a Queue.

const std = @import("std");
const Timer = std.os.time.Timer;
const warn = std.debug.warn;
const assert = std.debug.assert;

/// Tests


test "Timer" {
    var timer = try Timer.start();

    const loop_count: usize = 2000000;
    const inner_loop_count = 100;

    var start_time = timer.read();
    var i: usize = 0;
    while (i < loop_count) : (i += 1) {
        comptime var j = 0;
        var cur_time: u64 = undefined;
        inline while(j < inner_loop_count) : (j += 1) {
          cur_time = timer.read();
        }
    }
    var end_time = timer.read();
    var duration = end_time - start_time;
    var seconds = @intToFloat(f64, end_time - start_time) / @intToFloat(f64, std.os.time.ns_per_s);
    var ops_per_sec = @intToFloat(f64, (loop_count * inner_loop_count)) / seconds;
    var ns_per_op = (seconds / @intToFloat(f64, (loop_count * inner_loop_count))) * 1000000000;
    warn("test timer: time={.6} ns/op={.4} ops/sec={}\n", seconds, ns_per_op, ops_per_sec);
}
