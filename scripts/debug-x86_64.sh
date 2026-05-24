#!/bin/sh
qemu-system-x86_64 -M pc -cpu qemu64 -m 256 -cdrom ./build/kernel.iso -boot d -serial stdio -d int,cpu_reset -no-reboot -no-shutdown -S -s
