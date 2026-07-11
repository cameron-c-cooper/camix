kernel:
	cargo build --target x86_64-camix.json

iso: kernel
	mkdir -p isodir/boot/grub
	cp target/x86_64-camix/debug/camix isodir/boot/kernel.bin
	cp grub/grub.cfg isodir/boot/grub/
	grub-mkrescue -o camix.iso isodir

run: iso
	qemu-system-x86_64 -cdrom camix.iso -d int,cpu_reset -no-reboot -nographic -device isa-debug-exit,iobase=0xf4,iosize=0x04
	# qemu-system-x86_64 -cdrom camix.iso -serial stdio -d int,cpu_reset -no-reboot
