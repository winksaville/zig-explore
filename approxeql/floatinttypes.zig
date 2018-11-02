pub fn FloatUintType(comptime T: type) type {
    return switch (T) {
        f64 => u64,
        f32 => u32,
        f16 => u16,
        else => @compileError("floatUintType only supports f64, f32 or f16"),
    };
}

pub fn FloatIntType(comptime T: type) type {
    return switch (T) {
        f64 => i64,
        f32 => i32,
        f16 => i16,
        else => @compileError("floatUintType only supports f64, f32 or f16"),
    };
}
