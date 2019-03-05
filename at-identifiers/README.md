# Zig at-identifiers

Test if identifiers can start with @.

Answer: No, the following fails to compile
```
const assert = @import("std").debug.assert;

test "@names" {
    const @i = 100;
}
```

## test
```bash
wink@wink-desktop:~/prgs/ziglang/zig-explore/at-identifiers (master)
$ zig test at_ids.zig 
/home/wink/prgs/ziglang/zig-explore/at-identifiers/at_ids.zig:4:11: error: expected token 'Symbol', found '@'
    const @i = 100;
          ^
```
