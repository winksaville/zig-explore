# Explore u0

A proposal was filed to [remove u0](https://github.com/ziglang/zig/issues/1530) and
then a [discussion on IRC](https://irclog.whitequark.org/zig/2018-09-17#23085429).

I did some "tests" and it seems to me a u0 is reasonable, but it needs to have
properties that are "intutative" right now things are messed up and Andrew is
trying to fix them. When he's done I'll try some of the tests in u0.zig and
see if I think they are "intutative".

This is weird:
```
var zero: u0 = 0;
var pZero = &zero;
assert(pZero == null); // This is weird there is no address but could be "by definition"
assert(pZero.* == 0);  // But this implies needs to be an error, you can't defeference if
                       // pZero == null.
```

And this is weird too:
```
var pZeroOptional: ?*u0 = &zero;
//warn("pZeroOptional={*}\n", pZeroOptional); // LLVM ERROR: Borken module found, compilation aborted!
assert(&zero == null);         // This is true
assert(pZeroOptional != null); // And this is true
assert(pZeroOptional == &zero);// And this is true
if (pZeroOptional != null) {
    assert(pZeroOptional.?.* == 0);
} else {
    unreachable; // Currently unreachable
    //assert(pZeroOptional == null);
}
```

Can't do a @noInlineCall(x()):
```
fn x() u0 {
    var zero: u0 = 0;
    return zero;
}

test "fn x() u0" {
    assert(x() == 0);
    var result = x();
    //var result = @noInlineCall(x()); // Compiler error: type 'u0' not a function
    assert(result == 0);
}
```
