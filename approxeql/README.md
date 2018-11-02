# Explore floating point approximately equal

THIS IS PROBABLY WRONG, do NOT use!

With floating point comparing for equality is frought with problems
and typically it can only be done approximately. For instance summing
a series of calculated numbers will likely not produce the exactly
expected results. For instance summing 0.1 10 times should result in
a value of 1.0 but it doesn't the value with an f32 is r=1.00000011e+00:

```
pub fn sum(comptime T: type, start: T, end: T, count: usize) T {
    var step = (end - start)/@intToFloat(T, count);
    var r: T = start;

    var j: usize = 0;
    while (j < count) : (j += 1) {
        r += step;
    }
    return r;
}

pub fn testSum() void {
    var r = sum(f32, 0, 1, 10);
    warn("r={}\n", r);
    assert(r != f32(1.0));
}
```

Therefore a notion of approximately equals is needed. [Here](https://www.google.com/search?q=floating+point+compare)
is a Google search and [here](https://randomascii.wordpress.com/2012/02/25/comparing-floating-point-numbers-2012-edition/)
was the first hit and seems to have good information.

I took what I've learned so I came up with my own approxEql in zig that uses
significant `digits` to calcuate an allowable max difference that can is then
used do determine equality. It "seems" to be working and the code is in
approxeql.zig, but I'm have ZERO EXPERTICE so this is probably wrong!!!

# Building

```
$ zig build-exe approxeql.zig 
wink@wink-desktop:~/prgs/ziglang/zig-explore/approxeql (master)
$ ./approxeql 
r=1.00000011e+00
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=0digits == 0 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=0digits == 0 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=1 abs_diff=3.1672442446506466e-11 max_diff=1.0e+00 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e+00 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=2 abs_diff=3.1672442446506466e-11 max_diff=1.0e-01 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-01 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=3 abs_diff=3.1672442446506466e-11 max_diff=1.0e-02 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-02 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=4 abs_diff=3.1672442446506466e-11 max_diff=1.0e-03 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-03 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=5 abs_diff=3.1672442446506466e-11 max_diff=1.0e-04 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-04 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=6 abs_diff=3.1672442446506466e-11 max_diff=1.0e-05 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-05 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=7 abs_diff=3.1672442446506466e-11 max_diff=1.0e-06 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-06 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=8 abs_diff=3.1672442446506466e-11 max_diff=1.0e-07 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-07 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=10 abs_diff=3.1672442446506466e-11 max_diff=1.0e-09 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-09 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=11 abs_diff=3.1672442446506466e-11 max_diff=1.0e-10 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-10 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=12 abs_diff=3.1672442446506466e-11 max_diff=1.0e-11 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-11 result=false
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=13 abs_diff=3.1672442446506466e-11 max_diff=1.0e-12 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-12 result=false
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=14 abs_diff=3.1672442446506466e-11 max_diff=1.0e-13 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-13 result=false
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=15 abs_diff=3.1672442446506466e-11 max_diff=1.0e-14 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-14 result=false
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=16 abs_diff=3.1672442446506466e-11 max_diff=1.0e-15 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-15 result=false
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=17 abs_diff=3.1672442446506466e-11 max_diff=1.0e-16 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-16 result=false
approxEql: a=1.0e+00 b=8.99999976e-01 digits=1 abs_diff=1.00000023e-01 max_diff=1.0e+00 fexp=0.0e+00 exp_diff=0 max_diff scaled=1.0e+00 result=true
approxEql: a=1.0e+00 b=8.99999976e-01 digits=2 abs_diff=1.00000023e-01 max_diff=1.00000001e-01 fexp=0.0e+00 exp_diff=0 max_diff scaled=1.00000001e-01 result=false
approxEql: a=1.0e+00 b=1.10000002e+00 digits=1 abs_diff=1.00000023e-01 max_diff=1.0e+00 fexp=4.13926951e-02 exp_diff=0 max_diff scaled=1.0e+00 result=true
approxEql: a=1.0e+00 b=1.10000002e+00 digits=2 abs_diff=1.00000023e-01 max_diff=1.00000001e-01 fexp=4.13926951e-02 exp_diff=0 max_diff scaled=1.00000001e-01 result=false
approxEql: a=1.0e+10 b=8.99999948e+09 digits=1 abs_diff=1.00000051e+09 max_diff=1.0e+00 fexp=1.0e+01 exp_diff=10 max_diff scaled=1.0e+10 result=true
approxEql: a=1.0e+10 b=8.99999948e+09 digits=2 abs_diff=1.00000051e+09 max_diff=1.00000001e-01 fexp=1.0e+01 exp_diff=10 max_diff scaled=1.0e+09 result=false
```

# Test

```
$ zig test approxeql.zig 
Test 1/1 sum...
r=1.00000011e+00
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=0digits == 0 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=0digits == 0 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=1 abs_diff=3.1672442446506466e-11 max_diff=1.0e+00 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e+00 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=2 abs_diff=3.1672442446506466e-11 max_diff=1.0e-01 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-01 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=3 abs_diff=3.1672442446506466e-11 max_diff=1.0e-02 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-02 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=4 abs_diff=3.1672442446506466e-11 max_diff=1.0e-03 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-03 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=5 abs_diff=3.1672442446506466e-11 max_diff=1.0e-04 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-04 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=6 abs_diff=3.1672442446506466e-11 max_diff=1.0e-05 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-05 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=7 abs_diff=3.1672442446506466e-11 max_diff=1.0e-06 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-06 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=8 abs_diff=3.1672442446506466e-11 max_diff=1.0e-07 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-07 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=10 abs_diff=3.1672442446506466e-11 max_diff=1.0e-09 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-09 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=11 abs_diff=3.1672442446506466e-11 max_diff=1.0e-10 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-10 result=true
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=12 abs_diff=3.1672442446506466e-11 max_diff=1.0e-11 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-11 result=false
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=13 abs_diff=3.1672442446506466e-11 max_diff=1.0e-12 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-12 result=false
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=14 abs_diff=3.1672442446506466e-11 max_diff=1.0e-13 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-13 result=false
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=15 abs_diff=3.1672442446506466e-11 max_diff=1.0e-14 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-14 result=false
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=16 abs_diff=3.1672442446506466e-11 max_diff=1.0e-15 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-15 result=false
approxEql: a=4.000000000031672e+00 b=4.0e+00 digits=17 abs_diff=3.1672442446506466e-11 max_diff=1.0e-16 fexp=6.020599913314012e-01 exp_diff=0 max_diff scaled=1.0e-16 result=false
approxEql: a=1.0e+00 b=8.99999976e-01 digits=1 abs_diff=1.00000023e-01 max_diff=1.0e+00 fexp=0.0e+00 exp_diff=0 max_diff scaled=1.0e+00 result=true
approxEql: a=1.0e+00 b=8.99999976e-01 digits=2 abs_diff=1.00000023e-01 max_diff=1.00000001e-01 fexp=0.0e+00 exp_diff=0 max_diff scaled=1.00000001e-01 result=false
approxEql: a=1.0e+00 b=1.10000002e+00 digits=1 abs_diff=1.00000023e-01 max_diff=1.0e+00 fexp=4.13926951e-02 exp_diff=0 max_diff scaled=1.0e+00 result=true
approxEql: a=1.0e+00 b=1.10000002e+00 digits=2 abs_diff=1.00000023e-01 max_diff=1.00000001e-01 fexp=4.13926951e-02 exp_diff=0 max_diff scaled=1.00000001e-01 result=false
approxEql: a=1.0e+10 b=8.99999948e+09 digits=1 abs_diff=1.00000051e+09 max_diff=1.0e+00 fexp=1.0e+01 exp_diff=10 max_diff scaled=1.0e+10 result=true
approxEql: a=1.0e+10 b=8.99999948e+09 digits=2 abs_diff=1.00000051e+09 max_diff=1.00000001e-01 fexp=1.0e+01 exp_diff=10 max_diff scaled=1.0e+09 result=false
OK
All tests passed.
```
