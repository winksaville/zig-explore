# Zig Message

Use compile time compilation to create a message.

So this works, I can "extend" a message and include
different "bodyType's". But a Queue can only handle
one Message(BodyType) and to be useful I want a Queue
that can handle all Message(BodyType)'s

## Building/testing
```bash
$ zig test message.zig
```

## Clean
Remove `zig-cache/` directory
```bash
$ rm -rf ./zig-cache/
```
