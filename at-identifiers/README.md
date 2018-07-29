# Zig at-identifiers

Test if programs can use identifiers that start with @.

Answer: no the following fails to compile
```
const assert = @import("std").debug.assert;

test "varFn" {
    const @i = 100
    var @j = 23;
    assert((@i + @j) == 123);
}
```

## test
```bash
$ zig test at_ids.zig
/home/wink/prgs/ziglang/zig-explore/at-identifiers/at_ids.zig:3:4: error: expected token '(', found '@'
fn @fn123() u64 {
   ^
```

## Clean
Remove `zig-cache/` directory
```bash
$ rm -rf ./zig-cache/
```
