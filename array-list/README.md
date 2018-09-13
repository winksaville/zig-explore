# Play with ArrayList

The size of Arrays:
sizeof [1]u8 == 1
sizeof [10]u8 == 10
sizeof [1023]u8 = 1023

The size of Slice:
sizeof []u8 == 16

Note: []u8 is a TypeId.Pointer which looks to be a usize pointer and length, as a guess.

Bottom line ArrayList.items is an Array of the passed T as can be seen in array_list.zig:
```
    items: []align(A) T
```

I am surprised how "inefficient" realloc was when using DirectAllocator. It appears
DirectAllocator allocates at least a os.page of memory yet we only use 8 bytes of the
first allocation! You can see that in the addresses of &item[8] which about 0xfffh
bytes below items[7], and items[0] is now at 0xc9000 instead of 0xca000. It definitely
means DirectAllocator isn't the best allocator to use for small arrays of small elements.

Also, do not use self-referential pointers in a Type passed to ArrayList as memory is
copied when realloc'd.
```
$ zig test array_list.zig 
Test 1/1 ArrayList...
empty:   len=0 items.len=0 sizeof(items)=16
item[0]: len=1 items.len=8 sizeof(items[idx])=1 &items[0]=u8@7efee0bca000 
item[1]: len=2 items.len=8 sizeof(items[idx])=1 &items[1]=u8@7efee0bca001  addrDiff=1
item[2]: len=3 items.len=8 sizeof(items[idx])=1 &items[2]=u8@7efee0bca002  addrDiff=1
item[3]: len=4 items.len=8 sizeof(items[idx])=1 &items[3]=u8@7efee0bca003  addrDiff=1
item[4]: len=5 items.len=8 sizeof(items[idx])=1 &items[4]=u8@7efee0bca004  addrDiff=1
item[5]: len=6 items.len=8 sizeof(items[idx])=1 &items[5]=u8@7efee0bca005  addrDiff=1
item[6]: len=7 items.len=8 sizeof(items[idx])=1 &items[6]=u8@7efee0bca006  addrDiff=1
item[7]: len=8 items.len=8 sizeof(items[idx])=1 &items[7]=u8@7efee0bca007  addrDiff=1
item[8]: len=9 items.len=20 sizeof(items[idx])=1 &items[8]=u8@7efee0bc9008  addrDiff=1
item[9]: len=10 items.len=20 sizeof(items[idx])=1 &items[9]=u8@7efee0bc9009  addrDiff=1

sizeof(s)=16 sizeof(s.a)=16 s.a.len=3 s.a[0..3]=cba
OK
All tests passed.
```
