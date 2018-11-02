const std = @import("std");
const assert = std.debug.assert;
const warn = std.debug.warn;
const math = std.math;

// Set to true for debug output
const DBG = false;

pub fn epsilon(comptime T: type) T {
    return switch (T) {
        f64 => math.f64_epsilon,
        f32 => math.f32_epsilon,
        f16 => math.f16_epsilon,
        else => @compileError("epsilon only supports f64, f32 or f16"),
    };
}

fn testEpsilon(comptime T: type) void {
    assert(epsilon(T) != T(0));
    assert(epsilon(T) == epsilon(T));
    assert((epsilon(T) * T(2)) == (epsilon(T) + epsilon(T)));

    var e1_cnt = T(1) / epsilon(T);
    var e2_cnt = T(2) / epsilon(T);
    var e3_cnt = T(3) / epsilon(T);
    var e4_cnt = T(4) / epsilon(T);

    if (DBG) {
        warn("epsilon.{}={}\n", @typeName(T), epsilon(T));
        warn("epsilon.{} e2_cnt:{}-e1_cnt:{}={}\n", @typeName(T), e2_cnt, e1_cnt, e2_cnt - e1_cnt);
        warn("epsilon.{} e4_cnt:{}-e3_cnt:{}={}\n", @typeName(T), e4_cnt, e3_cnt, e4_cnt - e3_cnt);
    }
    assert(e2_cnt - e1_cnt == e4_cnt - e3_cnt);
}

test "epsilon.f64" {
    if (DBG) warn("\n");
    testEpsilon(f64);
}

test "epsilon.f32" {
    if (DBG) warn("\n");
    testEpsilon(f32);
}

test "epsilon.f16" {
    if (DBG) warn("\n");
    testEpsilon(f16);
}
