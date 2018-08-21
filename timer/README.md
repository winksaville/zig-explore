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
duration_cc:77  = cc_end:6275814313601470 - cc_start:6275814313601393
duration_rdtsc:66  = tsc_end:6275814313661288 - tsc_start:6275814313661222
duration_rdtscp:77 = tsc_end:6275814313718180 - tsc_start:6275814313718103 aux_start=1 aux_end=1
Warm up CPU
Running loops
test timer.read(): time=3.031345 ns/op=15.1567 ops/sec=6.597730771530142e+07
test rdstc(): time=1.363489 ns/op=6.8174 ops/sec=1.466824862065639e+08
test rdstcp(): time=1.366454 ns/op=6.8323 ops/sec=1.463642376186104e+08
test readCc(): time=1.365634 ns/op=6.8282 ops/sec=1.4645208749916753e+08
OK
All tests passed.
```

## Clean
Remove `zig-cache/` directory
```bash
$ rm -rf ./zig-cache/
```
