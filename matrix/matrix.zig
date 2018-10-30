const builtin = @import("builtin");
const TypeInfo = builtin.TypeInfo;
const TypeId = builtin.TypeId;

const std = @import("std");
const math = std.math;
const meta = std.meta;
const assert = std.debug.assert;
const warn = std.debug.warn;

pub fn Matrix(comptime T: type, comptime m: usize, comptime n: usize) type {
    return struct.{
        const Self = @This();
        const row_cnt = m;
        const col_cnt = n;

        pub data: [m][n]T,

        /// Initialize Matrix to a value
        pub fn init() Self {
            return Self.{ .data = undefined };
        }

        /// Initialize Matrix to a value
        pub fn initVal(val: T) Self {
            var self = Self.init();
            for (self.data) |row, i| {
                for (row) |_, j| {
                    self.data[i][j] = val;
                }
            }
            return self;
        }

        /// Return true of pSelf.data == pOther.data
        pub fn eql(pSelf: *const Self, pOther: *const Self) bool {
            for (pSelf.data) |row, i| {
                for (row) |val, j| {
                    if (val != pOther.data[i][j]) return false;
                }
            }
            return true;
        }

        /// Print the Matrix
        pub fn print(pSelf: *const Self, s: []const u8) void {
            warn("{}", s);
            for (pSelf.data) |row, i| {
                warn("{}: []{}.{{ ", i, @typeName(T));
                for (row) |val, j| {
                    warn("{.7}{}", val, if (j < (row.len - 1)) ", " else " ");
                }
                warn("}},\n");
            }
        }
    };
}

/// Multiply Matrixes m1 by m2
pub fn MatrixMultiplier(comptime m1: type, comptime m2: type) type {
    const m1_DataType = @typeInfo(@typeInfo(meta.fieldInfo(m1, "data").field_type).Array.child).Array.child;
    const m2_DataType = @typeInfo(@typeInfo(meta.fieldInfo(m2, "data").field_type).Array.child).Array.child;

    // What other validations should I check
    if (m1_DataType != m2_DataType) {
        @compileError("m1:" ++ @typeName(m1_DataType) ++ " != m2:" ++ @typeName(m2_DataType));
    }

    if (m1.col_cnt != m2.row_cnt) {
        @compileError("m1.col_cnt:" ++ m1.col_cnt ++ " != m2.row_cnt:" ++ m2.row_cnt);
    }
    const DataType = m1_DataType;
    const row_cnt = m1.row_cnt;
    const col_cnt = m2.col_cnt;
    return struct.{
        pub fn mul(mt1: *const m1, mt2: *const m2) Matrix(DataType, row_cnt, col_cnt) {
            var r = Matrix(DataType, row_cnt, col_cnt).init();
            comptime var i: usize = 0;
            inline while (i < row_cnt) : (i += 1) {
                //warn("mul {}:\n", i);
                comptime var j: usize = 0;
                inline while (j < col_cnt) : (j += 1) {
                    //warn(" ({}:", j);
                    comptime var k: usize = 0;
                    // The inner loop is m1.col_cnt or m2.row_cnt, which are equal
                    inline while (k < m1.col_cnt) : (k += 1) {
                        var val = mt1.data[i][k] * mt2.data[k][j];
                        if (k == 0) {
                            r.data[i][j] = val;
                            //warn(" {}:{}={} * {}", k, val, mt1.data[i][k], mt2.data[k][j]);
                        } else {
                            r.data[i][j] += val;
                            //warn(" {}:{}={} * {}", k, val, mt1.data[i][k], mt2.data[k][j]);
                        }
                    }
                    //warn(" {})\n", r.data[i][j]);
                }
            }
            return r;
        }
    };
}

test "matrix.init" {
    warn("\n");

    var m1 = Matrix(f32, 1, 1).init();
    m1.data = [][1]f32.{
        []f32.{ 2 },
    };
    m1.print("matrix.1x1*1x1 m1:\n");
    assert(m1.data[0][0] == 2);

    const mf32 = Matrix(f32, 4, 4).initVal(1);
    mf32.print("mf32: init(1)\n");

    for (mf32.data) |row| {
        for (row) |val| {
            assert(val == 1);
        }
    }
}

test "matrix.eql" {
    warn("\n");
    const m0 = Matrix(f32, 4, 4).initVal(0);
    for (m0.data) |row| {
        for (row) |val| {
            assert(val == 0);
        }
    }
    var o0 = Matrix(f32, 4, 4).initVal(0);
    assert(m0.eql(&o0));

    // Modify last value and verify !eql
    o0.data[3][3] = 1;
    o0.print("data.eql: o0\n");
    assert(!m0.eql(&o0));

    // Modify first value and verify !eql
    o0.data[0][0] = 1;
    o0.print("data.eql: o0\n");
    assert(!m0.eql(&o0));

    // Restore back to 0 and verify eql
    o0.data[3][3] = 0;
    o0.data[0][0] = 0;
    o0.print("data.eql: o0\n");
    assert(m0.eql(&o0));
}

test "matrix.1x1*1x1" {
    warn("\n");

    const m1 = Matrix(f32, 1, 1).initVal(2);
    m1.print("matrix.1x1*1x1 m1:\n");

    const m2 = Matrix(f32, 1, 1).initVal(3);
    m2.print("matrix.1x1*1x1 m2:\n");

    const m3 = MatrixMultiplier(@typeOf(m1), @typeOf(m2)).mul(&m1, &m2);
    m3.print("matrix.1x1*1x1 m3:\n");

    var expected = Matrix(f32, 1, 1).init();
    expected.data = [][1]f32.{
        []f32.{
            (m1.data[0][0] * m2.data[0][0]),
        },
    };
    expected.print("matrix.1x1*1x1 expected:\n");
    assert(m3.eql(&expected));
}

test "matrix.2x2*2x2" {
    warn("\n");

    var m1 = Matrix(f32, 2, 2).init();
    m1.data = [][2]f32.{
        []f32.{ 1, 2 },
        []f32.{ 3, 4 },
    };
    m1.print("matrix.2x2*2x2 m1:\n");

    var m2 = Matrix(f32, 2, 2).init();
    m2.data = [][2]f32.{
        []f32.{ 5, 6 },
        []f32.{ 7, 8 },
    };
    m2.print("matrix.2x2*2x2 m2:\n");

    const m3 = MatrixMultiplier(@typeOf(m1), @typeOf(m2)).mul(&m1, &m2);
    m3.print("matrix.2x2*2x2 m3:\n");

    var expected = Matrix(f32, 2, 2).init();
    expected.data = [][2]f32.{
        []f32.{
            (m1.data[0][0] * m2.data[0][0]) + (m1.data[0][1] * m2.data[1][0]),
            (m1.data[0][0] * m2.data[0][1]) + (m1.data[0][1] * m2.data[1][1]),
        },
        []f32.{
            (m1.data[1][0] * m2.data[0][0]) + (m1.data[1][1] * m2.data[1][0]),
            (m1.data[1][0] * m2.data[0][1]) + (m1.data[1][1] * m2.data[1][1]),
        },
    };
    expected.print("matrix.2x2*2x2 expected:\n");
    assert(m3.eql(&expected));
}

test "matrix.1x2*2x1" {
    warn("\n");

    var m1 = Matrix(f32, 1, 2).init();
    m1.data = [][2]f32.{
        []f32.{ 3, 4 },
    };
    m1.print("matrix.1x2*2x1 m1:\n");

    var m2 = Matrix(f32, 2, 1).init();
    m2.data = [][1]f32.{
        []f32.{ 5 },
        []f32.{ 7 },
    };
    m2.print("matrix.1x2*2x1 m2:\n");

    const m3 = MatrixMultiplier(@typeOf(m1), @typeOf(m2)).mul(&m1, &m2);
    m3.print("matrix.1x2*2x1 m3:\n");

    var expected = Matrix(f32, 1, 1).init();
    expected.data = [][1]f32.{
        []f32.{
            (m1.data[0][0] * m2.data[0][0]) + (m1.data[0][1] * m2.data[1][0]),
        },
    };
    expected.print("matrix.1x2*2x1 expected:\n");
    assert(m3.eql(&expected));
}
