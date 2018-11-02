const builtin = @import("builtin");
const TypeId = builtin.TypeId;
const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const warn = std.debug.warn;

const fit = @import("floatinttypes.zig");
const FloatUintType = fit.FloatUintType;
const FloatIntType = fit.FloatIntType;

pub fn approxEql(x: var, y: var, digits: usize) bool {
    assert(@typeOf(x) == @typeOf(y));
    assert(@typeId(@typeOf(x)) == TypeId.Float);
    assert(@typeId(@typeOf(x)) == TypeId.Float);
    const T = @typeOf(x);

    var a: T = x;
    var b: T = y;

    var result: bool = undefined;
    warn("approxEql: a={} b={} digits={}", T(a), T(b), digits);
    defer { warn(" result={}\n", result); }

    if (digits == 0) {
        warn("digits == 0");
        result = true;
        return result;
    }

    // Equal and +-0.0
    if (a == b) {
        warn("a == b");
        result = true;
        return result;
    }

    // Largest
    var largest = math.max(math.fabs(a), math.fabs(b));

    // Determine the difference and check if we got a nan or inf
    // return false as if they weren't both nan/inf they can't be equal.
    var abs_diff = math.fabs(a - b);
    warn(" abs_diff={}", abs_diff);
    if ((abs_diff == math.nan(T)) or (abs_diff == math.inf(T))) {
        warn(" nan or inf");
        result = false;
        return result;
    }

    // Determine our basic max_diff based on digits
    var max_diff: T = math.pow(T, 10, -@intToFloat(T, digits - 1));
    warn(" max_diff={}", max_diff);

    // Scale max_diff by largest
    var fexp: T = math.log10(largest);
    warn(" fexp={}", fexp);
    var exp_diff: i32 = @floatToInt(i32, math.floor(fexp));
    warn(" exp_diff={}", exp_diff);
    max_diff *= math.pow(T, 10, @intToFloat(T, exp_diff));
    warn(" max_diff scaled={}", max_diff);

    // Compare and return result
    result = (abs_diff <= max_diff);
    return result;
}

/// Sum from start to end with a step of (end - start)/count for count times
/// So if start == 0 and end == 1 and count == 10 then the step is 0.1 and
/// because of the rounding there may be errors introduced.
pub fn sum(comptime T: type, start: T, end: T, count: usize) T {
    var step = (end - start)/@intToFloat(T, count);
    var r: T = start;

    var j: usize = 0;
    while (j < count) : (j += 1) {
        r += step;
    }
    return r;
}

pub fn testSum() void {
    var r = sum(f32, 0, 1, 10);
    warn("r={}\n", r);
    assert(r != f32(1.0));
}

pub fn testApproxEql() void {
    const T = f64;
    var v: T = 4.0;
    //var r = @noInlineCall(sum, T, 0, 4.0, 1000000);
    var r = sum(T, 0, 4.0, 1000000);

    _ = approxEql(r, v, 0);
    assert(approxEql(r, v, 0));
    assert(approxEql(r, v, 1));
    assert(approxEql(r, v, 2));
    assert(approxEql(r, v, 3));
    assert(approxEql(r, v, 4));
    assert(approxEql(r, v, 5));
    assert(approxEql(r, v, 6));
    assert(approxEql(r, v, 7));
    assert(approxEql(r, v, 8));
    assert(approxEql(r, v, 10));
    assert(approxEql(r, v, 11));
    assert(!approxEql(r, v, 12));
    assert(!approxEql(r, v, 13));
    assert(!approxEql(r, v, 14));
    assert(!approxEql(r, v, 15));
    assert(!approxEql(r, v, 16));
    assert(!approxEql(r, v, 17));

    assert(approxEql(f32(1.0), f32(0.9), 1));
    assert(!approxEql(f32(1.0), f32(0.9), 2));

    assert(approxEql(f32(1.0), f32(1.1), 1));
    assert(!approxEql(f32(1.0), f32(1.1), 2));

    assert(approxEql(f32(1.0e10), f32(0.9e10), 1));
    assert(!approxEql(f32(1.0e10), f32(0.9e10), 2));
}

pub fn testFn() void {
    testSum();
    testApproxEql();
}

pub fn main() void {
    testFn();
}

test "sum" {
    warn("\n");
    testFn();
}
