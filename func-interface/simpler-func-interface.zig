const std = @import("std");
const debug = std.debug;
const assert = debug.assert;
const mem = std.mem;
const Allocator = mem.Allocator;

pub fn SimplerFuncInterface(comptime FuncType: type) type {
    return struct {
        const Self = @This();

        func: FuncType,

        fn init(func: FuncType) Self {
            return Self {
                .func = func,
            };
        }
    };
}

pub fn theStr(str: []const u8) ![]const u8 {
    if (str.len == 0) return error.WTF;
    return str;
}

test "SimplerFuncInterface.theStr" {
    var sfi = SimplerFuncInterface(@typeOf(theStr)).init(theStr);
    var s = try sfi.func("bye");
    assert(mem.eql(u8, s, "bye"));
}

pub fn dupStr(pAllocator: *Allocator, str: []const u8) ![]const u8 {
    if (str.len == 0) return error.WTF;
    return try mem.dupe(pAllocator, u8, str);
}

test "SimplerFuncInterface.dupStr" {
    const Sfi = SimplerFuncInterface(@typeOf(dupStr));
    var sfi: Sfi = undefined;
    sfi.func = dupStr;
    var s = try sfi.func(debug.global_allocator, "hi");
    defer debug.global_allocator.free(s);
    assert(mem.eql(u8, s, "hi"));
}
