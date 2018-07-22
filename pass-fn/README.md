# Zig pass-fn

Exploring passing functions as parameter. They
can be passed as "required" parameters or as
"optional" parameter by passing null.

## Building
```bash
$ zig build-exe main.zig
```

## Run
```bash
$ ./main 
F:#
f:+
F:#
f:-
h:+
h: fnParam is nullh:-
h:+
F:#
h:-
i:+
i: fnParam is nulli:-
i:+
F:#
i:-
```

## Clean
Remove main and `zig-cache/` directory
```bash
$ rm -rf main ./zig-cache/
```
