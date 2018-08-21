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
Test 1/2 fences...OK
Test 2/2 Timer...
aux1=3 aux2=3
freq=3600000000
    duration_cc:77 =  cc_end:6303880268225749 -  cc_start:6303880268225672
 duration_rdtsc:77 = tsc_end:6303880268325365 - tsc_start:6303880268325288
duration_rdtscp:77 = tsc_end:6303880268421945 - tsc_start:6303880268421868 aux_start=1 aux_end=1
Warm up CPU
Running loops
test timer.read(): cpu_id=0 time=3.1079s time/op=15.5394ns ops/sec=64352674
test     readCc(): cpu_id=24 time=1.3606s time/op=6.8032ns ops/sec=146989476
test      rdtsc(): cpu_id=24 time=1.3625s time/op=6.8126ns ops/sec=146787117
test     rdstcp(): cpu_id=24 time=1.3621s time/op=6.8106ns ops/sec=146829179
OK
All tests passed.
```

## Clean
Remove `zig-cache/` directory
```bash
$ rm -rf ./zig-cache/
```
