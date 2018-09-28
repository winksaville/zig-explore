# Explore i0 and i1

Typical range of a signed binary integer of N bits
can be defined as -(2e(n-1)) .. (2e(n-1))-1. Thus
```
i8 is -(2e7) .. (2e7)-1 or -128 .. 127
...
i2 is -(2e1) .. (2e1)-1 or -2 .. 1
i1 is -(2e0) .. (2e0)-1 or -1 .. 0
i0 is -(2e-1) .. (2e-1)-1 or -0.5 .. -0.5
                  if  @floatToInt(i32, -0.5) == 0
                  then the range is 0 .. 0
```

Determined that i0 always has a value of 0 and
if it was to be formally defined to be -(2e-1) .. (2e-1)-1
the range of values is a single value -0.5. And if
you use zig's floatToInt(f32, -0.5) it converts the value to 0
a plausable value.

Determined that i1 has the values -1 and 0 and
if defined as -(2e0) .. (2e0)-1 the range is -1 .. 0 so
that makes sense.
