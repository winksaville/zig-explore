# Zig print data

Print data including adding format to a struct so
it can "automatically" print its own data. As a note
you must pass the struct with a format method by
address.



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
