# Zig hello world from zig/example/hello_world

# A hello world using libc
```
$ zig build-exe --library c hello_libc.zig
$ ./hello_libc
Hello, world!
```

# A hello world not using libc
```
$ zig build-exe hello.zig
$ ./hello
Hello, world!
```
