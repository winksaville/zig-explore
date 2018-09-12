const std = @import("std");
const debug = std.debug;
const assert = debug.assert;
const mem = std.mem;
const Allocator = mem.Allocator;

pub const FuncType = enum {
    alloc,
    regular,
};

pub fn FuncInterface(comptime ft: FuncType, comptime T: type) type {
    return struct {
        const Self = this;

        const Type = switch (ft) {
            FuncType.alloc => fn (*Allocator, []const u8) error!T,
            FuncType.regular => fn ([]const u8) error!T,
        };

        func: Type,

        fn init(func: Type) Self {
            return Self {
                .func = func,
            };
        }
    };
}

pub fn dupStr(pAllocator: *Allocator, str: []const u8) ![]const u8 {
    if (str.len == 0) return error.WTF;
    return try mem.dupe(pAllocator, u8, str);
}

pub fn theStr(str: []const u8) ![]const u8 {
    if (str.len == 0) return error.WTF;
    return str;
}

test "FuncInterface.regular" {
    var fi = FuncInterface(FuncType.regular, []const u8).init(theStr);
    var s = try fi.func("hi");
    assert(mem.eql(u8, s, "hi"));
}

test "FuncInterface.alloc" {
    var fi = FuncInterface(FuncType.alloc, []const u8).init(dupStr);
    var s = try fi.func(debug.global_allocator, "bye");
    defer debug.global_allocator.free(s);
    assert(mem.eql(u8, s, "bye"));
}
