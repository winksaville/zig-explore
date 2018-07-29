const assert = @import("std").debug.assert;

test "varFn" {
    const @i = 100
    var @j = 23;
    assert((@i + @j) == 123);
}
