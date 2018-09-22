const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const toggle_obj = b.addObject("toggle", "toggle.zig");
    const singleton_bit_array_obj =
        b.addObject("singleton_bit_array", "singleton_bit_array.zig");

    const tst = b.addTest("test.singleton_bit_array.zig");
    tst.addObject(toggle_obj);
    tst.addObject(singleton_bit_array_obj);
    tst.setOutputPath("./test");

    b.default_step.dependOn(&tst.step);    
}
