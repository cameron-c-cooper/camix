#ifndef X86_CPU_H
#define X86_CPU_H

#include <camix/types.h>
#include <stdbool.h>

static inline void outb(u16 port, u8 byte) {
	__asm__ volatile ("outb %0, %1" : : "a"(byte), "Nd"(port));
}

static inline u8 inb(u16 port) {
	u8 ret;
	__asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
	return ret;
}

// wait 1-4 microseconds.
static inline void io_wait(void) {
	outb(0x80, 0);
}

#endif
