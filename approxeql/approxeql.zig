const builtin = @import("builtin");
const TypeId = builtin.TypeId;

const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const warn = std.debug.warn;

const epsilon = @import("epsilon.zig").epsilon;

// Set to true for debug output
const DBG = false;

/// Return true if x is approximately equal to y.
///   Based on `AlmostEqlRelativeAndAbs` at
///   https://randomascii.wordpress.com/2012/02/25/comparing-floating-point-numbers-2012-edition/
///
/// Note: It's possible to calculate max_diff at compile time by adding
/// comptime attribute to digits parameter.
pub fn approxEql(x: var, y: var, digits: usize) bool {
    assert(@typeOf(x) == @typeOf(y));
    assert(@typeId(@typeOf(x)) == TypeId.Float);
    assert(@typeId(@typeOf(x)) == TypeId.Float);
    const T = @typeOf(x);

    if (!DBG) {
        if (digits == 0) return true;

        if (x == y) return true;

        var abs_diff = math.fabs(x - y);
        if (math.isNan(abs_diff) or math.isInf(abs_diff)) return false;

        var max_diff: T = math.pow(T, 10, -@intToFloat(T, digits - 1));
        if (abs_diff <= max_diff) return true;

        var largest = math.max(math.fabs(x), math.fabs(y));
        var scaled_max_diff = max_diff * largest;
        return abs_diff <= scaled_max_diff;
    } else {
        var result: bool = undefined;
        warn("approxEql: x={} y={} digits={}", T(x), T(y), digits);
        defer { warn(" result={}\n", result); }

        if (digits == 0) {
            warn(" digits == 0");
            result = true;
            return result;
        }

        // Performance optimization if x and y are equal
        if (x == y) {
            warn(" x == y");
            result = true;
            return result;
        }

        // Determine the difference and check if diff is a nan or inf
        var abs_diff = math.fabs(x - y);
        warn(" abs_diff={}", abs_diff);
        if (math.isNan(abs_diff) or math.isInf(abs_diff)) {
            warn(" nan or inf");
            result = false;
            return result;
        }

        // Determine our basic max_diff based on digits
        var max_diff: T = math.pow(T, 10, -@intToFloat(T, digits - 1));
        warn(" max_diff={}", max_diff);

        // Use max_diff unscalled to check for results close to zero.
        if (abs_diff <= max_diff) {
            warn(" close to 0");
            result = true;
            return result;
        }

        // Scale max_diff by largest of |x| and |y| for others
        var largest = math.max(math.fabs(x), math.fabs(y));
        var scaled_max_diff = max_diff * largest;
        warn(" scaled_max_diff={}", scaled_max_diff);

        // Compare and return result
        result = (abs_diff <= scaled_max_diff);
        return result;
    }
}

test "approxEql.nan.inf" {
    if (DBG) warn("\n");

    assert(!approxEql(math.nan(f64), math.nan(f64), 17));
    //assert(approxEql(-math.nan(f64), -math.nan(f64), 17));
    //assert(approxEql(math.inf(f64), math.inf(f64), 17));
    //assert(approxEql(-math.inf(f64), -math.inf(f64), 17));

    //assert(!approxEql(math.inf(f64), math.nan(f64), 17));
}

test "approxEql.same" {
    if (DBG) warn("\n");
    const T = f64;
    var x: T = 0;
    var y: T = 0;

    assert(approxEql(x, y, 0));
    assert(approxEql(x, y, 1));
    assert(approxEql(x, y, 2));
    assert(approxEql(x, y, 3));
    assert(approxEql(x, y, 4));
    assert(approxEql(x, y, 5));
    assert(approxEql(x, y, 6));
    assert(approxEql(x, y, 7));
    assert(approxEql(x, y, 8));
    assert(approxEql(x, y, 9));
    assert(approxEql(x, y, 10));
    assert(approxEql(x, y, 11));
    assert(approxEql(x, y, 12));
    assert(approxEql(x, y, 13));
    assert(approxEql(x, y, 14));
    assert(approxEql(x, y, 15));
    assert(approxEql(x, y, 16));
    assert(approxEql(x, y, 17));

    assert(approxEql(T(123e-123), T(123e-123), 17));
    assert(approxEql(T(-123e-123), T(-123e-123), 17));
    assert(approxEql(T(-123e123), T(-123e123), 17));
    assert(approxEql(T(123e123), T(123e123), 17));
}

test "approxEql.epsilon*1" {
    if (DBG) warn("\n");
    const T = f64;
    const et = epsilon(T);
    var x: T = 0;
    var y: T = et * 1;
    assert(y == et);

    assert(approxEql(x, y, 0));
    assert(approxEql(x, y, 1));
    assert(approxEql(x, y, 2));
    assert(approxEql(x, y, 3));
    assert(approxEql(x, y, 4));
    assert(approxEql(x, y, 5));
    assert(approxEql(x, y, 6));
    assert(approxEql(x, y, 7));
    assert(approxEql(x, y, 8));
    assert(approxEql(x, y, 9));
    assert(approxEql(x, y, 10));
    assert(approxEql(x, y, 11));
    assert(approxEql(x, y, 12));
    assert(approxEql(x, y, 13));
    assert(approxEql(x, y, 14));
    assert(approxEql(x, y, 15));
    assert(approxEql(x, y, 16));
    assert(!approxEql(x, y, 17));
}

test "approxEql.epsilon*4" {
    if (DBG) warn("\n");
    const T = f64;
    const et = epsilon(T);
    var x: T = 0;
    var y: T = et * T(4);

    assert(approxEql(x, y, 0));
    assert(approxEql(x, y, 1));
    assert(approxEql(x, y, 2));
    assert(approxEql(x, y, 3));
    assert(approxEql(x, y, 4));
    assert(approxEql(x, y, 5));
    assert(approxEql(x, y, 6));
    assert(approxEql(x, y, 7));
    assert(approxEql(x, y, 8));
    assert(approxEql(x, y, 9));
    assert(approxEql(x, y, 10));
    assert(approxEql(x, y, 11));
    assert(approxEql(x, y, 12));
    assert(approxEql(x, y, 13));
    assert(approxEql(x, y, 14));
    assert(approxEql(x, y, 15));
    assert(approxEql(x, y, 16));
    assert(!approxEql(x, y, 17));
}

test "approxEql.epsilon*5" {
    if (DBG) warn("\n");
    const T = f64;
    const et = epsilon(T);
    var x: T = 0;
    var y: T = et * T(5);

    assert(approxEql(x, y, 0));
    assert(approxEql(x, y, 1));
    assert(approxEql(x, y, 2));
    assert(approxEql(x, y, 3));
    assert(approxEql(x, y, 4));
    assert(approxEql(x, y, 5));
    assert(approxEql(x, y, 6));
    assert(approxEql(x, y, 7));
    assert(approxEql(x, y, 8));
    assert(approxEql(x, y, 9));
    assert(approxEql(x, y, 10));
    assert(approxEql(x, y, 11));
    assert(approxEql(x, y, 12));
    assert(approxEql(x, y, 13));
    assert(approxEql(x, y, 14));
    assert(approxEql(x, y, 15));
    assert(!approxEql(x, y, 16));
    assert(!approxEql(x, y, 17));
}

test "approxEql.epsilon*45" {
    if (DBG) warn("\n");
    const T = f64;
    const et = epsilon(T);
    var x: T = 0;
    var y: T = et * T(45);

    assert(approxEql(x, y, 0));
    assert(approxEql(x, y, 1));
    assert(approxEql(x, y, 2));
    assert(approxEql(x, y, 3));
    assert(approxEql(x, y, 4));
    assert(approxEql(x, y, 5));
    assert(approxEql(x, y, 6));
    assert(approxEql(x, y, 7));
    assert(approxEql(x, y, 8));
    assert(approxEql(x, y, 9));
    assert(approxEql(x, y, 10));
    assert(approxEql(x, y, 11));
    assert(approxEql(x, y, 12));
    assert(approxEql(x, y, 13));
    assert(approxEql(x, y, 14));
    assert(approxEql(x, y, 15));
    assert(!approxEql(x, y, 16));
    assert(!approxEql(x, y, 17));
}

test "approxEql.epsilon*46" {
    if (DBG) warn("\n");
    const T = f64;
    const et = epsilon(T);
    var x: T = 0;
    var y: T = et * T(46);

    assert(approxEql(x, y, 0));
    assert(approxEql(x, y, 1));
    assert(approxEql(x, y, 2));
    assert(approxEql(x, y, 3));
    assert(approxEql(x, y, 4));
    assert(approxEql(x, y, 5));
    assert(approxEql(x, y, 6));
    assert(approxEql(x, y, 7));
    assert(approxEql(x, y, 8));
    assert(approxEql(x, y, 9));
    assert(approxEql(x, y, 10));
    assert(approxEql(x, y, 11));
    assert(approxEql(x, y, 12));
    assert(approxEql(x, y, 13));
    assert(approxEql(x, y, 14));
    assert(!approxEql(x, y, 15));
    assert(!approxEql(x, y, 16));
    assert(!approxEql(x, y, 17));
}

test "approxEql.epsilon*450" {
    if (DBG) warn("\n");
    const T = f64;
    const et = epsilon(T);
    var x: T = 0;
    var y: T = et * T(450);

    assert(approxEql(x, y, 0));
    assert(approxEql(x, y, 1));
    assert(approxEql(x, y, 2));
    assert(approxEql(x, y, 3));
    assert(approxEql(x, y, 4));
    assert(approxEql(x, y, 5));
    assert(approxEql(x, y, 6));
    assert(approxEql(x, y, 7));
    assert(approxEql(x, y, 8));
    assert(approxEql(x, y, 9));
    assert(approxEql(x, y, 10));
    assert(approxEql(x, y, 11));
    assert(approxEql(x, y, 12));
    assert(approxEql(x, y, 13));
    assert(approxEql(x, y, 14));
    assert(!approxEql(x, y, 15));
    assert(!approxEql(x, y, 16));
    assert(!approxEql(x, y, 17));
}

test "approxEql.epsilon*451" {
    if (DBG) warn("\n");
    const T = f64;
    const et = epsilon(T);
    var x: T = 0;
    var y: T = et * T(451);

    assert(approxEql(x, y, 0));
    assert(approxEql(x, y, 1));
    assert(approxEql(x, y, 2));
    assert(approxEql(x, y, 3));
    assert(approxEql(x, y, 4));
    assert(approxEql(x, y, 5));
    assert(approxEql(x, y, 6));
    assert(approxEql(x, y, 7));
    assert(approxEql(x, y, 8));
    assert(approxEql(x, y, 9));
    assert(approxEql(x, y, 10));
    assert(approxEql(x, y, 11));
    assert(approxEql(x, y, 12));
    assert(approxEql(x, y, 13));
    assert(!approxEql(x, y, 14));
    assert(!approxEql(x, y, 15));
    assert(!approxEql(x, y, 16));
    assert(!approxEql(x, y, 17));
}

/// Sum from start to end with a step of (end - start)/count for
/// count times.  So if start == 0 and end == 1 and count == 10 then
/// the step is 0.1 and because of the imprecision of floating point
/// errors are introduced.
fn sum(comptime T: type, start: T, end: T, count: usize) T {
    var step = (end - start)/@intToFloat(T, count);
    var r: T = start;

    var j: usize = 0;
    while (j < count) : (j += 1) {
        r += step;
    }
    return r;
}

test "approxEql.sum.f64" {
    if (DBG) warn("\n");
    const T = f64;
    var x: T = 1;
    var end: T = sum(T, 0, x, 10);
    if (DBG) warn("x={} end={}\n", x, end);
    assert(x != end);

    assert(approxEql(x, end, 0));
    assert(approxEql(x, end, 1));
    assert(approxEql(x, end, 2));
    assert(approxEql(x, end, 3));
    assert(approxEql(x, end, 4));
    assert(approxEql(x, end, 5));
    assert(approxEql(x, end, 6));
    assert(approxEql(x, end, 7));
    assert(approxEql(x, end, 8));
    assert(approxEql(x, end, 9));
    assert(approxEql(x, end, 10));
    assert(approxEql(x, end, 11));
    assert(approxEql(x, end, 12));
    assert(approxEql(x, end, 13));
    assert(approxEql(x, end, 14));
    assert(approxEql(x, end, 15));
    assert(approxEql(x, end, 16));
    assert(!approxEql(x, end, 17));
}

test "approxEql.sum.f32" {
    if (DBG) warn("\n");
    const T = f32;
    var x: T = 1;
    var end: T = sum(T, 0, x, 10);
    if (DBG) warn("x={} end={}\n", x, end);
    assert(x != end);

    assert(approxEql(x, end, 0));
    assert(approxEql(x, end, 1));
    assert(approxEql(x, end, 2));
    assert(approxEql(x, end, 3));
    assert(approxEql(x, end, 4));
    assert(approxEql(x, end, 5));
    assert(approxEql(x, end, 6));
    assert(approxEql(x, end, 7));
    assert(!approxEql(x, end, 8));
    assert(!approxEql(x, end, 9));
    assert(!approxEql(x, end, 10));
    assert(!approxEql(x, end, 11));
    assert(!approxEql(x, end, 12));
    assert(!approxEql(x, end, 13));
    assert(!approxEql(x, end, 14));
    assert(!approxEql(x, end, 15));
    assert(!approxEql(x, end, 16));
    assert(!approxEql(x, end, 17));
}

test "approxEql.sum.f64" {
    if (DBG) warn("\n");
    const T = f64;
    var x: T = 124e123;
    var end: T = sum(T, 123e123, x, 10000000);
    if (DBG) warn("x={} end={}\n", x, end);
    assert(x != end);

    assert(approxEql(x, end, 0));
    assert(approxEql(x, end, 1));
    assert(approxEql(x, end, 2));
    assert(approxEql(x, end, 3));
    assert(approxEql(x, end, 4));
    assert(approxEql(x, end, 5));
    assert(approxEql(x, end, 6));
    assert(approxEql(x, end, 7));
    assert(approxEql(x, end, 8));
    assert(approxEql(x, end, 9));
    assert(approxEql(x, end, 10));
    assert(!approxEql(x, end, 11));
    assert(!approxEql(x, end, 12));
    assert(!approxEql(x, end, 13));
    assert(!approxEql(x, end, 14));
    assert(!approxEql(x, end, 15));
    assert(!approxEql(x, end, 16));
    assert(!approxEql(x, end, 17));
}

test "approxEql.sum.f32" {
    if (DBG) warn("\n");
    const T = f32;
    var x: T = 124e21;
    var end: T = sum(T, 123e21, x, 10000);
    if (DBG) warn("x={} end={}\n", x, end);
    assert(x != end);

    assert(approxEql(x, end, 0));
    assert(approxEql(x, end, 1));
    assert(approxEql(x, end, 2));
    assert(approxEql(x, end, 3));
    assert(approxEql(x, end, 4));
    assert(approxEql(x, end, 5));
    assert(!approxEql(x, end, 6));
    assert(!approxEql(x, end, 7));
    assert(!approxEql(x, end, 8));
    assert(!approxEql(x, end, 9));
    assert(!approxEql(x, end, 10));
    assert(!approxEql(x, end, 11));
    assert(!approxEql(x, end, 12));
    assert(!approxEql(x, end, 13));
    assert(!approxEql(x, end, 14));
    assert(!approxEql(x, end, 15));
    assert(!approxEql(x, end, 16));
    assert(!approxEql(x, end, 17));
}

/// Subtract from start down to end with a step of (start - end)/count
/// for count times. So if start == 1 and end == 0 and count == 10 then
/// the step is 0.1 and because of the imprecision of floating point
/// errors are introduced.
fn sub(comptime T: type, start: T, end: T, count: usize) T {
    var step = (start - end)/@intToFloat(T, count);
    var r: T = start;

    var j: usize = 0;
    while (j < count) : (j += 1) {
        r -= step;
    }
    return r;
}

test "approxEql.sub.f64" {
    if (DBG) warn("\n");
    const T = f64;
    var x: T = 0;
    var end: T = sub(T, 1, x, 10);
    if (DBG) warn("x={} end={}\n", x, end);
    assert(x != end);

    assert(approxEql(x, end, 0));
    assert(approxEql(x, end, 1));
    assert(approxEql(x, end, 2));
    assert(approxEql(x, end, 3));
    assert(approxEql(x, end, 4));
    assert(approxEql(x, end, 5));
    assert(approxEql(x, end, 6));
    assert(approxEql(x, end, 7));
    assert(approxEql(x, end, 8));
    assert(approxEql(x, end, 9));
    assert(approxEql(x, end, 10));
    assert(approxEql(x, end, 11));
    assert(approxEql(x, end, 12));
    assert(approxEql(x, end, 13));
    assert(approxEql(x, end, 14));
    assert(approxEql(x, end, 15));
    assert(approxEql(x, end, 16));
    assert(!approxEql(x, end, 17));
}

test "approxEql.sub.f32" {
    if (DBG) warn("\n");
    const T = f32;
    var x: T = 0;
    var end: T = sub(T, 1, x, 10);
    if (DBG) warn("x={} end={}\n", x, end);
    assert(x != end);

    assert(approxEql(x, end, 0));
    assert(approxEql(x, end, 1));
    assert(approxEql(x, end, 2));
    assert(approxEql(x, end, 3));
    assert(approxEql(x, end, 4));
    assert(approxEql(x, end, 5));
    assert(approxEql(x, end, 6));
    assert(approxEql(x, end, 7));
    assert(approxEql(x, end, 8));
    assert(!approxEql(x, end, 9));
    assert(!approxEql(x, end, 10));
    assert(!approxEql(x, end, 11));
    assert(!approxEql(x, end, 12));
    assert(!approxEql(x, end, 13));
    assert(!approxEql(x, end, 14));
    assert(!approxEql(x, end, 15));
    assert(!approxEql(x, end, 16));
    assert(!approxEql(x, end, 17));
}
