# Explore returning null error or string

The "string" could potentially be any type.

I initially had a compiler error when I wanted to print the contents for what next
would return:
```
    18	pub fn next(pAllocator: *Allocator) ?(error![]u8) {
    19	    var buf: [100]u8 = undefined;
    20	
    21	    var s = nextStr(buf[0..]);
    22	    if (s == null) {
    23	        warn("s is null\n");
    24	        return null;
    25	    }
    26	
    27	    // This works:
    28	    //return mem.dupe(pAllocator, u8, s.?);
    29	
    30	    // Using var n causes compile error:
    31	    //   $ zig test return_null_error_str.zig 
    32	    //   return_null_error_str.zig:35:13: error: expected type '?error![]u8', found '@typeOf(dupe).ReturnType.ErrorSet'
    33	    //       var n = try mem.dupe(pAllocator, u8, s.?);
    34	    //               ^
    35	    var n = try mem.dupe(pAllocator, u8, s.?);
    36	    warn("n={}\n");
    37	    return n;
    38	
    39	}
```

The solution from andrew, https://irclog.whitequark.org/zig/2018-09-11#23039575,
is to cast to the necessary return type:
```
    18	pub fn next(pAllocator: *Allocator) ?(error![]u8) {
    19	    var buf: [100]u8 = undefined;
    20	
    21	    var s = nextStr(buf[0..]);
    22	    if (s == null) {
    23	        warn("s is null\n");
    24	        return (?(error![]u8))(null); // Also, return null; works
    25	    }
    26	
    27	    // This works:
    28	    //return mem.dupe(pAllocator, u8, s.?);
    29	
    30	    // To make this work you need to cast the return value
    31	    var n = mem.dupe(pAllocator, u8, s.?) catch |err| return (error![]u8)(err);
    32	    warn("n={}\n", n);
    33	    return (error![]u8)(n);
    34	}
```

I got this technique from std/os/index.txt for the implementation
of ArgIteratorWindows:
```
  1861	    /// You must free the returned memory when done.
  1862	    pub fn next(self: *ArgIteratorWindows, allocator: *Allocator) ?(NextError![]u8) {
  1863	        // march forward over whitespace
  1864	        while (true) : (self.index += 1) {
  1865	            const byte = self.cmd_line[self.index];
  1866	            switch (byte) {
  1867	                0 => return null,
  1868	                ' ', '\t' => continue,
  1869	                else => break,
  1870	            }
  1871	        }
  1872	
  1873	        return self.internalNext(allocator);
  1874	    }
```

And ArgIterator:
```
  1998	    /// You must free the returned memory when done.
  1999	    pub fn next(self: *ArgIterator, allocator: *Allocator) ?(NextError![]u8) {
  2000	        if (builtin.os == Os.windows) {
  2001	            return self.inner.next(allocator);
  2002	        } else {
  2003	            return mem.dupe(allocator, u8, self.inner.next() orelse return null);
  2004	        }
  2005	    }
```
