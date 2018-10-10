# Minimal static main.zig

This is the minimal zig code and we build it
as a stripped static binary.

## Code
```
$ cat main.zig 
pub fn main() u8 {
    return 123;
}
```

## Build, small static main
```
$ zig build-exe main.zig --release-small --strip --static
```
## Generate srouce
```
$ objdump --source -d -M intel main > main.s
$ cat -n main.s
     1	
     2	main:     file format elf64-x86-64
     3	
     4	
     5	Disassembly of section .text:
     6	
     7	0000000000201000 <_start>:
     8	  201000:	48 8d 04 24          	lea    rax,[rsp]
     9	  201004:	48 89 05 05 10 00 00 	mov    QWORD PTR [rip+0x1005],rax        # 202010 <argc_ptr>
    10	  20100b:	e8 00 00 00 00       	call   201010 <posixCallMainAndExit>
    11	
    12	0000000000201010 <posixCallMainAndExit>:
    13	  201010:	48 8b 0d f9 0f 00 00 	mov    rcx,QWORD PTR [rip+0xff9]        # 202010 <argc_ptr>
    14	  201017:	48 8b 01             	mov    rax,QWORD PTR [rcx]
    15	  20101a:	48 8d 14 c1          	lea    rdx,[rcx+rax*8]
    16	  20101e:	48 83 c2 10          	add    rdx,0x10
    17	  201022:	48 83 c1 08          	add    rcx,0x8
    18	  201026:	48 c7 c6 ff ff ff ff 	mov    rsi,0xffffffffffffffff
    19	  20102d:	48 89 d7             	mov    rdi,rdx
    20	  201030:	48 83 c6 01          	add    rsi,0x1
    21	  201034:	48 83 3f 00          	cmp    QWORD PTR [rdi],0x0
    22	  201038:	48 8d 7f 08          	lea    rdi,[rdi+0x8]
    23	  20103c:	75 f2                	jne    201030 <posixCallMainAndExit+0x20>
    24	  20103e:	48 89 3d d3 0f 00 00 	mov    QWORD PTR [rip+0xfd3],rdi        # 202018 <linux_elf_aux_maybe>
    25	  201045:	48 89 0d d4 0f 00 00 	mov    QWORD PTR [rip+0xfd4],rcx        # 202020 <raw>
    26	  20104c:	48 89 05 d5 0f 00 00 	mov    QWORD PTR [rip+0xfd5],rax        # 202028 <raw+0x8>
    27	  201053:	48 89 15 a6 0f 00 00 	mov    QWORD PTR [rip+0xfa6],rdx        # 202000 <posix_environ_raw>
    28	  20105a:	48 89 35 a7 0f 00 00 	mov    QWORD PTR [rip+0xfa7],rsi        # 202008 <posix_environ_raw+0x8>
    29	  201061:	b8 3c 00 00 00       	mov    eax,0x3c
    30	  201066:	bf 7b 00 00 00       	mov    edi,0x7b
    31	  20106b:	0f 05                	syscall 
```
## Run
```
$ ./main
$ echo $?
123
```
