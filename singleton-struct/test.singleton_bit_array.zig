const std = @import("std");
const assert = std.debug.assert;
const warn = std.debug.warn;

const sba_ns = @import("singleton_bit_array.zig");
const pSba = &sba_ns.singleton_bit_array;

const toggle_ns = @import("toggle.zig");
const toggle = toggle_ns.toggle;

test "test.singleton_bit_array" {
    warn("\ntest.singleton_bit_array: pSba={*}\n", pSba);
    toggle_ns.print_pSba();
    sba_ns.print_pSba();
    assert(pSba.b(0) == false);
    assert(pSba.r(0) == 0);
    assert(toggle(0) == 1);
    assert(pSba.b(0) == true);
    assert(pSba.r(0) == 1);
    assert(toggle(0) == 0);
    assert(pSba.b(0) == false);
    assert(pSba.r(0) == 0);
    pSba.w(0, 1);
    assert(pSba.b(0) == true);
    assert(pSba.r(0) == 1);
    assert(toggle(0) == 0);
    assert(pSba.b(0) == false);
    assert(pSba.r(0) == 0);
}
