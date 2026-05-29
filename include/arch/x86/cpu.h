#ifndef X86_CPU_H
#define X86_CPU_H

#include <camix/types.h>

static inline void outb(u16 port, u8 byte) {
	__asm__ __volatile__("outb %0, %1" : : "a"(byte), "Nd"(port));
}

static inline u8 inb(u16 port) {
	u8 ret;
	__asm__ __volatile__("inb %1, %0" : "=a"(ret) : "Nd"(port));
	return ret;
}

static inline void io_wait(void

#endif
