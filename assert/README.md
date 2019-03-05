# Zig assert

Using assert in various builds

## Building/run "debug" the default
```bash
wink@wink-desktop:~/prgs/ziglang/zig-explore/assert (master)
$ zig build-exe main.zig && ./main ; echo $?
v=7501d44a6a0d7333 ret_val=false
v=7d22e08922b1eaf5 ret_val=false
v=cab6b0b652f6e4cf ret_val=true
v=fe54f57d71f29f35 ret_val=true
v=3203d31d5ab411b0 ret_val=false
v=268221808f1c5a71 ret_val=false
v=83c80b041672979e ret_val=true
reached unreachable code
/home/wink/opt/lib/zig/std/debug.zig:169:14: 0x203029 in ??? (main)
    if (!ok) unreachable; // assertion failure
             ^
/home/wink/prgs/ziglang/zig-explore/assert/main.zig:21:11: 0x223ada in ??? (main)
    assert(!abc(prng.random.scalar(u64)));
          ^
/home/wink/opt/lib/zig/std/special/bootstrap.zig:112:22: 0x22359b in ??? (main)
            root.main();
                     ^
/home/wink/opt/lib/zig/std/special/bootstrap.zig:43:5: 0x2233a0 in ??? (main)
    @noInlineCall(posixCallMainAndExit);
    ^
Aborted (core dumped)
134
```

## Building/run "--release-safe" FAILS but no stack frame
```bash
wink@wink-desktop:~/prgs/ziglang/zig-explore/assert (master)
$ zig --release-safe build-exe main.zig && ./main ; echo $?
v=7501d44a6a0d7333 ret_val=false
v=7d22e08922b1eaf5 ret_val=false
v=cab6b0b652f6e4cf ret_val=true
v=fe54f57d71f29f35 ret_val=true
v=3203d31d5ab411b0 ret_val=false
v=268221808f1c5a71 ret_val=false
v=83c80b041672979e ret_val=true
reached unreachable code
Segmentation fault (core dumped)
139
```

## Building/run "--release-fast" succeeds
```bash
$ zig --release-fast build-exe main.zig && ./main ; echo $?
v=7501d44a6a0d7333 ret_val=false
v=7d22e08922b1eaf5 ret_val=false
v=cab6b0b652f6e4cf ret_val=true
v=fe54f57d71f29f35 ret_val=true
v=3203d31d5ab411b0 ret_val=false
v=268221808f1c5a71 ret_val=false
v=83c80b041672979e ret_val=true
0
```

## Building/run "--release-small" succeeds
```bash
$ zig --release-small build-exe main.zig && ./main ; echo $?
v=7501d44a6a0d7333 ret_val=false
v=7d22e08922b1eaf5 ret_val=false
v=cab6b0b652f6e4cf ret_val=true
v=fe54f57d71f29f35 ret_val=true
v=3203d31d5ab411b0 ret_val=false
v=268221808f1c5a71 ret_val=false
v=83c80b041672979e ret_val=true
0
```

## Clean
Remove main and `zig-cache/` directory
```bash
$ rm -rf main ./zig-cache/
```
