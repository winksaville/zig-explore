arch:=x86_64
os:=freestanding
environ:=unknown

floattoint.s : floattoint.zig
	zig build-obj --strip --emit asm --release-fast floattoint.zig --target-arch $(arch) --target-os $(os) --target-environ $(environ)

clean:
	rm -rf *.s *.asm *.o
