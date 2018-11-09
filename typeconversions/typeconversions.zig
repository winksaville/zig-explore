const builtin = @import("builtin");
const TypeId = builtin.TypeId;

pub fn UintToFloatType(comptime T: type) type {
    return switch (T) {
        u64 => f64,
        u32 => f32,
        u16 => f16,
        else => @compileError("UintFloatType only supports f64, f32 or f16"),
    };
}

pub fn IntToFloatType(comptime T: type) type {
    return switch (T) {
        i64 => f64,
        i32 => f32,
        i16 => f16,
        else => @compileError("IntFloatType only supports f64, f32 or f16"),
    };
}

pub fn FloatToUintType(comptime T: type) type {
    return switch (T) {
        f64 => u64,
        f32 => u32,
        f16 => u16,
        else => @compileError("FloatUintType only supports f64, f32 or f16"),
    };
}

pub fn FloatToIntType(comptime T: type) type {
    return switch (T) {
        f64 => i64,
        f32 => i32,
        f16 => i16,
        else => @compileError("FloatUintType only supports f64, f32 or f16"),
    };
}

pub fn FloatType(comptime T: type) type {
    switch (@typeId(T)) {
        TypeId.Float => return T,
        TypeId.Int => return IntToFloatType(T),
        else => @compileError("FloatType T only supports TypeId.Float or TypeId.Int"),
    }
}

pub fn UintType(comptime T: type) type {
    switch (@typeId(T)) {
        TypeId.Float => return FloatToUintType(T),
        TypeId.Int => return T,
        else => @compileError("UintType T only supports TypeId.Float or TypeId.Int"),
    }
}

pub fn IntType(comptime T: type) type {
    switch (@typeId(T)) {
        TypeId.Float => return FloatToIntType(T),
        TypeId.Int => return T,
        else => @compileError("IntType T only supports TypeId.Float or TypeId.Int"),
    }
}
