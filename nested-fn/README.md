# Zig pass-fn

You can't directly nest functions, but you can put them
in a struct and then invoke them.

## Building
```bash
$ zig build-exe main.zig
```

## Run
```bash
$ ./main
v=257
toU8=1
```

## Clean
Remove main and `zig-cache/` directory
```bash
$ rm -rf main ./zig-cache/
```
