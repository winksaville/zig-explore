# Zig Message

Use compile time compilation to create a message

## Building
```bash
$ zig build-exe main.zig
```

## Run
```bash
$ ./main
msg=Message(MyMessage)@7ffd612335e0
msg={cmd=123,data={5a,5a,5a,},}
msg={cmd=123,data={61,5a,5a,},}
```

## Clean
Remove main and `zig-cache/` directory
```bash
$ rm -rf main ./zig-cache/
```
