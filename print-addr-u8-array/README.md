# Zig Message

Use compile time compilation to create a message

## Building
```bash
$ zig build-exe main.zig
```

## Run
```bash
$ ./main ; echo $?
1
```

## Clean
Remove main and `zig-cache/` directory
```bash
$ rm -rf main ./zig-cache/
```
