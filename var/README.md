# Zig var "types"

In zig a parameter of type "var" isn't a type but is
actually asking the compilter to infer the type at
comptime. Not as I'd initially guessed an "any" type
a runtime.

## Building/testing
```bash
$ zig test message.zig
```

## Clean
Remove `zig-cache/` directory
```bash
$ rm -rf ./zig-cache/
```
