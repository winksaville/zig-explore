# Zig timer

Explore performance of zig timer and rdtsc. Looks like
rdtsc is about 2x faster 7ns vs 15ns than zig timer. I was expecting
a greater diff so may not be worth it. There are other things you
can do when using rdtsc for benchmarking.
See [Intel](https://www.intel.com/content/dam/www/public/us/en/documents/white-papers/ia-32-ia-64-benchmark-code-execution-paper.pdf).

Also, added struct CycleCounter as a possible protable tsc like interface.

## Test on my desktop
```bash
$ zig test --release-fast timer.zig
Test 1/1 Timer...
aux1=3 aux2=3
freq=3600000000
duration_cc:66  = cc_end:6139006324558943 - cc_start:6139006324558877
duration_rdtsc:66  = tsc_end:6139006324631554 - tsc_start:6139006324631488
duration_rdtscp:66 = tsc_end:6139006324689326 - tsc_start:6139006324689260 aux_start=1 aux_end=1
test timer.read(): time=3.101288 ns/op=15.5064 ops/sec=6.448934261409179e+07
test rdstc(): time=1.359746 ns/op=6.7987 ops/sec=1.4708628269981328e+08
test rdstcp(): time=1.370580 ns/op=6.8529 ops/sec=1.4592365051196104e+08
test readCc(): time=1.370852 ns/op=6.8543 ops/sec=1.4589470553694078e+08
OK
All tests passed.
```

## Clean
Remove `zig-cache/` directory
```bash
$ rm -rf ./zig-cache/
```
