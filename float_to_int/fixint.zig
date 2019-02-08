const is_test = @import("builtin").is_test;
const std = @import("std");
const math = std.math;
const Log2Int = std.math.Log2Int;
const maxInt = std.math.maxInt;
const minInt = std.math.minInt;
const warn = std.debug.warn;

const DBG = false;

pub fn fixint(comptime fp_t: type, comptime fixint_t: type, a: fp_t) fixint_t {
    @setRuntimeSafety(is_test);
    const D = switch (fixint_t) {
        i1 => false, // We can't print i1
        else => DBG,
    };

    const fixuint_t = @IntType(false, fixint_t.bit_count);

    const rep_t = switch (fp_t) {
        f32 => u32,
        f64 => u64,
        f128 => u128,
        else => unreachable,
    };
    const srep_t = @IntType(true, rep_t.bit_count);
    const significandBits = switch (fp_t) {
        f32 => 23,
        f64 => 52,
        f128 => 112,
        else => unreachable,
    };

    const typeWidth = rep_t.bit_count;
    const exponentBits = (typeWidth - significandBits - 1);
    const signBit = (rep_t(1) << (significandBits + exponentBits));
    const maxExponent = ((1 << exponentBits) - 1);
    const exponentBias = (maxExponent >> 1);

    const implicitBit = (rep_t(1) << significandBits);
    const significandMask = (implicitBit - 1);

    // Break a into negative, exponent, significand
    const aRep: rep_t = @bitCast(rep_t, a);
    const absMask = signBit - 1;
    const aAbs: rep_t = aRep & absMask;

    const negative = (aRep & signBit) != 0;
    const exponent = @intCast(i32, aAbs >> significandBits) - exponentBias;
    const significand: rep_t = (aAbs & significandMask) | implicitBit;

    if (DBG) warn("negative={x} exponent={}:{x} significand={}:{x}\n", negative, exponent, exponent, significand, significand);

    // If exponent is negative, the result is zero.
    if (exponent < 0) {
        if (DBG) warn("neg exponent result=0:0\n");
        return 0;
    }

    var result: fixint_t = undefined;

    const ShiftedResultType = if (fixint_t.bit_count > rep_t.bit_count) fixuint_t else rep_t;
    var shifted_result: ShiftedResultType = undefined;

    // If the value is too large for the integer type, saturate.
    if (@intCast(usize, exponent) >= fixint_t.bit_count) {
        result = if (negative) fixint_t(minInt(fixint_t)) else fixint_t(maxInt(fixint_t));
        if (D) warn("too large result={}:{x}\n", result, result);
        return result;
    }

    // If 0 <= exponent < significandBits, right shift to get the result.
    // Otherwise, shift left.
    if (exponent < significandBits) {
        if (DBG) warn("exponent:{} < significandBits:{})\n", exponent, usize(significandBits));
        var diff = @intCast(ShiftedResultType, significandBits - exponent);
        if (DBG) warn("diff={}:{x}\n", diff, diff);
        var shift = @intCast(Log2Int(ShiftedResultType), diff);
        if (DBG) warn("significand={}:{x} right shift={}:{x}\n", significand, significand, shift, shift);
        shifted_result = @intCast(ShiftedResultType, significand) >> shift;
    } else {
        if (DBG) warn("exponent:{} >= significandBits:{})\n", exponent, usize(significandBits));
        var diff = @intCast(ShiftedResultType, exponent - significandBits);
        if (DBG) warn("diff={}:{x}\n", diff, diff);
        var shift = @intCast(Log2Int(ShiftedResultType), diff);
        if (D) warn("significand={}:{x} left shift={}:{x}\n", significand, significand, shift, shift);
        shifted_result = @intCast(ShiftedResultType, significand) << shift;
    }
    if (DBG) warn("shifted_result={}\n", shifted_result);
    if (negative) {
        // The result will be negative, but shifted_result is unsigned so compare >= -maxInt
        if (shifted_result >= -math.minInt(fixint_t)) {
            // Saturate
            result = math.minInt(fixint_t);
        } else {
            // Cast shifted_result to result
            result = -1 * @intCast(fixint_t, shifted_result);
        }
    } else {
        // The result will be positive
        if (shifted_result >= math.maxInt(fixint_t)) {
            // Saturate
            result = math.maxInt(fixint_t);
        } else {
            // Cast shifted_result to result
            result = @intCast(fixint_t, shifted_result);
        }
    }
    if (D) warn("result={}:{x}\n", result, result);
    return result;
}

fn test__fixint(comptime fp_t: type, comptime fixint_t: type, a: fp_t, expected: fixint_t) void {
    const x = fixint(fp_t, fixint_t, a);
    std.debug.assert(x == expected);
}

test "fixint" {
    if (DBG) warn("\n");
    test__fixint(f32, i1, -math.inf_f32, -1);
    test__fixint(f32, i1, -math.f32_max, -1);
    test__fixint(f32, i1, -2.0, -1);
    test__fixint(f32, i1, -1.1, -1);
    test__fixint(f32, i1, -1.0, -1);
    test__fixint(f32, i1, -0.9, 0);
    test__fixint(f32, i1, -0.1, 0);
    test__fixint(f32, i1, -math.f32_min, 0);
    test__fixint(f32, i1, -0.0, 0);
    test__fixint(f32, i1, 0.0, 0);
    test__fixint(f32, i1, math.f32_min, 0);
    test__fixint(f32, i1, 0.1, 0);
    test__fixint(f32, i1, 0.9, 0);
    test__fixint(f32, i1, 1.0, 0);
    test__fixint(f32, i1, 2.0, 0);
    test__fixint(f32, i1, math.f32_max, 0);
    test__fixint(f32, i1, math.inf_f32, 0);

    test__fixint(f32, i2, -math.inf_f32, -2);
    test__fixint(f32, i2, -math.f32_max, -2);
    test__fixint(f32, i2, -2.0, -2);
    test__fixint(f32, i2, -1.9, -1);
    test__fixint(f32, i2, -1.1, -1);
    test__fixint(f32, i2, -1.0, -1);
    test__fixint(f32, i2, -0.9, 0);
    test__fixint(f32, i2, -0.1, 0);
    test__fixint(f32, i2, -math.f32_min, 0);
    test__fixint(f32, i2, -0.0, 0);
    test__fixint(f32, i2, 0.0, 0);
    test__fixint(f32, i2, math.f32_min, 0);
    test__fixint(f32, i2, 0.1, 0);
    test__fixint(f32, i2, 0.9, 0);
    test__fixint(f32, i2, 1.0, 1);
    test__fixint(f32, i2, 2.0, 1);
    test__fixint(f32, i2, math.f32_max, 1);
    test__fixint(f32, i2, math.inf_f32, 1);

    test__fixint(f32, i3, -math.inf_f32, -4);
    test__fixint(f32, i3, -math.f32_max, -4);
    test__fixint(f32, i3, -4.0, -4);
    test__fixint(f32, i3, -3.0, -3);
    test__fixint(f32, i3, -2.0, -2);
    test__fixint(f32, i3, -1.9, -1);
    test__fixint(f32, i3, -1.1, -1);
    test__fixint(f32, i3, -1.0, -1);
    test__fixint(f32, i3, -0.9, 0);
    test__fixint(f32, i3, -0.1, 0);
    test__fixint(f32, i3, -math.f32_min, 0);
    test__fixint(f32, i3, -0.0, 0);
    test__fixint(f32, i3, 0.0, 0);
    test__fixint(f32, i3, math.f32_min, 0);
    test__fixint(f32, i3, 0.1, 0);
    test__fixint(f32, i3, 0.9, 0);
    test__fixint(f32, i3, 1.0, 1);
    test__fixint(f32, i3, 2.0, 2);
    test__fixint(f32, i3, 3.0, 3);
    test__fixint(f32, i3, 4.0, 3);
    test__fixint(f32, i3, math.f32_max, 3);
    test__fixint(f32, i3, math.inf_f32, 3);

    test__fixint(f64, i32, -math.inf_f64, math.minInt(i32));
    test__fixint(f64, i32, -math.f64_max, math.minInt(i32));
    test__fixint(f64, i32, @intToFloat(f64, math.minInt(i32)), math.minInt(i32));
    test__fixint(f64, i32, @intToFloat(f64, math.minInt(i32))+1, math.minInt(i32)+1);
    test__fixint(f64, i32, -2.0, -2);
    test__fixint(f64, i32, -1.9, -1);
    test__fixint(f64, i32, -1.1, -1);
    test__fixint(f64, i32, -1.0, -1);
    test__fixint(f64, i32, -0.9, 0);
    test__fixint(f64, i32, -0.1, 0);
    test__fixint(f64, i32, -math.f32_min, 0);
    test__fixint(f64, i32, -0.0, 0);
    test__fixint(f64, i32, 0.0, 0);
    test__fixint(f64, i32, math.f32_min, 0);
    test__fixint(f64, i32, 0.1, 0);
    test__fixint(f64, i32, 0.9, 0);
    test__fixint(f64, i32, 1.0, 1);
    test__fixint(f64, i32, @intToFloat(f64, math.maxInt(i32))-1, math.maxInt(i32)-1);
    test__fixint(f64, i32, @intToFloat(f64, math.maxInt(i32)), math.maxInt(i32));
    test__fixint(f64, i32, math.f64_max, math.maxInt(i32));
    test__fixint(f64, i32, math.inf_f64, math.maxInt(i32));

    test__fixint(f64, i64, -math.inf_f64, math.minInt(i64));
    test__fixint(f64, i64, -math.f64_max, math.minInt(i64));
    test__fixint(f64, i64, @intToFloat(f64, math.minInt(i64)), math.minInt(i64));
    test__fixint(f64, i64, @intToFloat(f64, math.minInt(i64))+1, math.minInt(i64));
    test__fixint(f64, i64, -2.0, -2);
    test__fixint(f64, i64, -1.9, -1);
    test__fixint(f64, i64, -1.1, -1);
    test__fixint(f64, i64, -1.0, -1);
    test__fixint(f64, i64, -0.9, 0);
    test__fixint(f64, i64, -0.1, 0);
    test__fixint(f64, i64, -math.f32_min, 0);
    test__fixint(f64, i64, -0.0, 0);
    test__fixint(f64, i64, 0.0, 0);
    test__fixint(f64, i64, math.f32_min, 0);
    test__fixint(f64, i64, 0.1, 0);
    test__fixint(f64, i64, 0.9, 0);
    test__fixint(f64, i64, 1.0, 1);
    test__fixint(f64, i64, @intToFloat(f64, math.maxInt(i64))-1, math.maxInt(i64));
    test__fixint(f64, i64, @intToFloat(f64, math.maxInt(i64)), math.maxInt(i64));
    test__fixint(f64, i64, math.f64_max, math.maxInt(i64));
    test__fixint(f64, i64, math.inf_f64, math.maxInt(i64));

    test__fixint(f64, i128, -math.inf_f64, math.minInt(i128));
    test__fixint(f64, i128, -math.f64_max, math.minInt(i128));
    test__fixint(f64, i128, @intToFloat(f64, math.minInt(i128)), math.minInt(i128));
    test__fixint(f64, i128, @intToFloat(f64, math.minInt(i128))+1, math.minInt(i128));
    test__fixint(f64, i128, -2.0, -2);
    test__fixint(f64, i128, -1.9, -1);
    test__fixint(f64, i128, -1.1, -1);
    test__fixint(f64, i128, -1.0, -1);
    test__fixint(f64, i128, -0.9, 0);
    test__fixint(f64, i128, -0.1, 0);
    test__fixint(f64, i128, -math.f32_min, 0);
    test__fixint(f64, i128, -0.0, 0);
    test__fixint(f64, i128, 0.0, 0);
    test__fixint(f64, i128, math.f32_min, 0);
    test__fixint(f64, i128, 0.1, 0);
    test__fixint(f64, i128, 0.9, 0);
    test__fixint(f64, i128, 1.0, 1);
    test__fixint(f64, i128, @intToFloat(f64, math.maxInt(i128))-1, math.maxInt(i128));
    test__fixint(f64, i128, @intToFloat(f64, math.maxInt(i128)), math.maxInt(i128));
    test__fixint(f64, i128, math.f64_max, math.maxInt(i128));
    test__fixint(f64, i128, math.inf_f64, math.maxInt(i128));

    test__fixint(f64, i128, 0x1.0p+0, i128(1) << 0);
    test__fixint(f64, i128, 0x1.0p+1, i128(1) << 1);
    test__fixint(f64, i128, 0x1.0p+2, i128(1) << 2);
    test__fixint(f64, i128, 0x1.0p+50, i128(1) << 50);
    test__fixint(f64, i128, 0x1.0p+51, i128(1) << 51);
    test__fixint(f64, i128, 0x1.0p+52, i128(1) << 52);
    test__fixint(f64, i128, 0x1.0p+53, i128(1) << 53);

    test__fixint(f64, i128, 0x1.0p+125, i128(0x1) << 125-0);
    test__fixint(f64, i128, 0x1.8p+125, i128(0x3) << 125-1);
    test__fixint(f64, i128, 0x1.Cp+125, i128(0x7) << 125-2);
    test__fixint(f64, i128, 0x1.Ep+125, i128(0xF) << 125-3);
    test__fixint(f64, i128, 0x1.Fp+125, i128(0x1F) << 125-4);
    test__fixint(f64, i128, 0x1.F8p+125, i128(0x3F) << 125-5);
    test__fixint(f64, i128, 0x1.FCp+125, i128(0x7F) << 125-6);
    test__fixint(f64, i128, 0x1.FEp+125, i128(0xFF) << 125-7);
    test__fixint(f64, i128, 0x1.FFp+125, i128(0x1FF) << 125-8);
    test__fixint(f64, i128, 0x1.FF8p+125, i128(0x3FF) << 125-9);
    test__fixint(f64, i128, 0x1.FFFp+125, i128(0x1FFF) << 125-12);
    test__fixint(f64, i128, 0x1.FFFFp+125, i128(0x1FFFF) << 125-16);
    test__fixint(f64, i128, 0x1.FFFFFp+125, i128(0x1FFFFF) << 125-20);
    test__fixint(f64, i128, 0x1.FFFFFFFFFp+125, i128(0x1FFFFFFFFF) << 125-36);
    test__fixint(f64, i128, 0x1.FFFFFFFFFFFFEp+125, i128(0xFFFFFFFFFFFFF) << 125-51);
    test__fixint(f64, i128, 0x1.FFFFFFFFFFFFFp+125, i128(0x1FFFFFFFFFFFFF) << 125-52);
}
