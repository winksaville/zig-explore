# Zig timer

Explore performance of zig timer.

## Test on my desktop
```bash
$ zig test --release-fast timer.zig 
Test 1/1 Timer...test timer: time=3.020657 ns/op=15.1033 ops/sec=6.621076757109957e+07
OK
All tests passed.
```

## Clean
Remove `zig-cache/` directory
```bash
$ rm -rf ./zig-cache/
```
