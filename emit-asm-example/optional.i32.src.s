
optional.i32.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <entry>:
/// A function or any other code you'd like to see the its asm.
fn aFunc() i32 {
    var pResult: *volatile ?i32 = &gResult;
    var value: i32 = undefined;

    pResult.* = 4;
   0:	48 8b 05 00 00 00 00 	mov    rax,QWORD PTR [rip+0x0]        # 7 <entry+0x7>
   7:	48 89 05 00 00 00 00 	mov    QWORD PTR [rip+0x0],rax        # e <entry+0xe>
    value = if (pResult.* == null) math.minInt(i32) else pResult.*.?;
   e:	80 3d 00 00 00 00 01 	cmp    BYTE PTR [rip+0x0],0x1        # 15 <entry+0x15>
  15:	75 06                	jne    1d <entry+0x1d>
  17:	8b 05 00 00 00 00    	mov    eax,DWORD PTR [rip+0x0]        # 1d <entry+0x1d>
    assert(value == 4);
    pResult.* = null;
  1d:	48 8b 05 00 00 00 00 	mov    rax,QWORD PTR [rip+0x0]        # 24 <entry+0x24>
  24:	48 89 05 00 00 00 00 	mov    QWORD PTR [rip+0x0],rax        # 2b <entry+0x2b>
  2b:	b8 00 00 00 80       	mov    eax,0x80000000
    value = if (pResult.* == null) math.minInt(i32) else pResult.*.?;
  30:	80 3d 00 00 00 00 01 	cmp    BYTE PTR [rip+0x0],0x1        # 37 <entry+0x37>
  37:	75 06                	jne    3f <entry+0x3f>
  39:	8b 05 00 00 00 00    	mov    eax,DWORD PTR [rip+0x0]        # 3f <entry+0x3f>
    return value;
}

/// An exported function otherwise no code is generated when build-obj
export fn entry() i32 {
    return aFunc();
  3f:	c3                   	ret    
