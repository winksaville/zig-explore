
main:     file format elf64-x86-64


Disassembly of section .text:

0000000000201000 <_start>:
  201000:	48 8d 04 24          	lea    rax,[rsp]
  201004:	48 89 05 05 10 00 00 	mov    QWORD PTR [rip+0x1005],rax        # 202010 <argc_ptr>
  20100b:	e8 00 00 00 00       	call   201010 <posixCallMainAndExit>

0000000000201010 <posixCallMainAndExit>:
  201010:	48 8b 0d f9 0f 00 00 	mov    rcx,QWORD PTR [rip+0xff9]        # 202010 <argc_ptr>
  201017:	48 8b 01             	mov    rax,QWORD PTR [rcx]
  20101a:	48 8d 14 c1          	lea    rdx,[rcx+rax*8]
  20101e:	48 83 c2 10          	add    rdx,0x10
  201022:	48 83 c1 08          	add    rcx,0x8
  201026:	48 c7 c6 ff ff ff ff 	mov    rsi,0xffffffffffffffff
  20102d:	48 89 d7             	mov    rdi,rdx
  201030:	48 83 c6 01          	add    rsi,0x1
  201034:	48 83 3f 00          	cmp    QWORD PTR [rdi],0x0
  201038:	48 8d 7f 08          	lea    rdi,[rdi+0x8]
  20103c:	75 f2                	jne    201030 <posixCallMainAndExit+0x20>
  20103e:	48 89 3d d3 0f 00 00 	mov    QWORD PTR [rip+0xfd3],rdi        # 202018 <linux_elf_aux_maybe>
  201045:	48 89 0d d4 0f 00 00 	mov    QWORD PTR [rip+0xfd4],rcx        # 202020 <raw>
  20104c:	48 89 05 d5 0f 00 00 	mov    QWORD PTR [rip+0xfd5],rax        # 202028 <raw+0x8>
  201053:	48 89 15 a6 0f 00 00 	mov    QWORD PTR [rip+0xfa6],rdx        # 202000 <posix_environ_raw>
  20105a:	48 89 35 a7 0f 00 00 	mov    QWORD PTR [rip+0xfa7],rsi        # 202008 <posix_environ_raw+0x8>
  201061:	b8 3c 00 00 00       	mov    eax,0x3c
  201066:	bf 7b 00 00 00       	mov    edi,0x7b
  20106b:	0f 05                	syscall 
