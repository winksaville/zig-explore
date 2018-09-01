//$ zig test make_struct.zig 
// make_struct.zig:20:7: error: no member named 'int64' in struct 'makeStruct((struct []const u8 constant),i64)'
//    v1.int64 = -123;

// Seems the "name" parameter needs to be a "symbol"
// and the return would be something like:
//     return struct { @symbol(name): T, };
fn makeStruct(comptime name: []const u8, comptime T: type) type {
    return struct { name: T, };
}

// Or maybe there is a "symbol" reserved word and then somthing like:
//fn makeStruct(comptime name: symbol, comptime T: type) type {
//    return struct { name: T, };
//}

test "makeStruct" {
    const U1 = comptime makeStruct("int64", i64);
    var v1: U1 = undefined;
    v1.int64 = -123;
}
