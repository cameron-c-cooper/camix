#!/bin/sh
qemu-system-i386 -M pc -cpu qemu32 -m 256 -cdrom ./build/kernel.iso -boot d -serial stdio
gdb
