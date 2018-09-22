# Singleton bit array

It appears that Zig does not provide a mechanism for creating
"global" singleton structs with methods. You can only export C
API compatible functions and variables.

So to be able to create a singleton ArraryU1 you need to provide
accessor functions. See singleton_bit_array.zig.

# Test
```
$ zig build
Test 1/1 test.singleton_bit_array...OK
All tests passed.
```

# xx.zig

Attempt to use a struct method directly, won't compile, maybe someday.
