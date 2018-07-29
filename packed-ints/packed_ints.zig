const std = @import("std");
const assert = std.debug.assert;
const warn = std.debug.warn;

test "packed.structs" {
    {
        const s_u1 = struct {
            f1_u1: u1,
            f2_u7: u7,
        };

        assert(@sizeOf(s_u1) == 2);
        assert(@offsetOf(s_u1, "f1_u1") == 0);
        assert(@offsetOf(s_u1, "f2_u7") == 1);
    }
    {
        const ps_u1 = packed struct {
            f1_u1: u1,
            f2_u7: u7,
        };
        assert(@sizeOf(ps_u1) == 1);
        assert(@offsetOf(ps_u1, "f1_u1") == 0);
        assert(@offsetOf(ps_u1, "f2_u7") == 0);
    }
    {
        const s_u8 = struct {
            f1_u8: u8,
            f2_u8: u8,
        };

        assert(@sizeOf(s_u8) == 2);
        assert(@offsetOf(s_u8, "f1_u8") == 0);
        assert(@offsetOf(s_u8, "f2_u8") == 1);
    }
    {
        const ps_u8 = packed struct {
            f1_u8: u8,
            f2_u8: u8,
        };

        assert(@sizeOf(ps_u8) == 2);
        assert(@offsetOf(ps_u8, "f1_u8") == 0);
        assert(@offsetOf(ps_u8, "f2_u8") == 1);
    }
    {
        const s_u127_u1 = struct {
            f1_u127: u127,
            f2_u1: u1,
        };

        assert(@sizeOf(s_u127_u1) == (16 + @sizeOf(usize)));
        assert(@offsetOf(s_u127_u1, "f1_u127") == 0);
        assert(@offsetOf(s_u127_u1, "f2_u1") == 16);
    }
    {
        const ps_u127_u1 = packed struct {
            f1_u127: u127,
            f2_u1: u1,
        };

        assert(@sizeOf(ps_u127_u1) == 16);
        assert(@offsetOf(ps_u127_u1, "f1_u127") == 0);
        assert(@offsetOf(ps_u127_u1, "f2_u1") == 0);
    }
}

test "packed.arrays" {
    {
        var a_u1 = []u1 {1, 0, 1, 0, 1, 0};
        assert(usize(@sizeOf(@typeOf(a_u1))) == 6);
    }
    {
        // Packed arrays aren't supported :(
        //var pa_u1 = packed []u1 {1, 0, 1, 0, 1, 0};
        //warn("@sizeOf(pa_u1)={}\n", u32(@sizeOf(@typeOf(pa_u1))));
        //assert(usize(@sizeOf(@typeOf(pa_u1))) == 1);
    }
}
