const builtin = @import("builtin");
const TypeId = builtin.TypeId;
const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const warn = std.debug.warn;

const fit = @import("floatinttypes.zig");
const FloatUintType = fit.FloatUintType;
const FloatIntType = fit.FloatIntType;

pub fn ulpsDiff(comptime T: type, a: T, b: T) FloatUintType(T) {
    if ((a == math.nan(T)) or (b == math.nan(T))) return math.maxInt(FloatUintType(T));
    if ((a == math.inf(T)) or (b == math.inf(T))) return math.maxInt(FloatUintType(T));
    if ((a == 0.0) or (b == 0.0)) return FloatUintType(T)(0);
    var diff = @bitCast(FloatIntType(T), a) - @bitCast(FloatIntType(T), b);
    return if (diff < 0) @bitCast(FloatUintType(T), -diff) else @bitCast(FloatUintType(T), diff);
}

pub fn approxEqlUlps(comptime T: type, a: T, b: T, maxUlpsDiff: FloatUintType(T)) bool {
    if (math.signbit(a) != math.signbit(b)) {
        if (a == b) {
            return true; // handle +0.0 == -0.0
        }
        return false;
    }

    return ulpsDiff(T, a, b) < maxUlpsDiff;
}

test "no tests" {
}
