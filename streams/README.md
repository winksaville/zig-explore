# Zig streams

These are buffered streams for performance.

## Building
```bash
$ zig build-exe main.zig
```

## Run
```bash
$ time ./main <data >data.out
count=4096000

real	0m0.319s
user	0m0.312s
sys	0m0.007s
$ ./main <data >data.out
$ diff data data.out
```

## Clean
Remove main and `zig-cache/` directory
```bash
$ rm -rf main ./zig-cache/
```
