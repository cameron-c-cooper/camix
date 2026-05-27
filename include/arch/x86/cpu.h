#ifndef X86_CPU_H
#define X86_CPU_H

#include <stdint.h>

static inline void outb(uint16_t port, uint8_t byte) {
	__asm__ __volatile__("outb %0, %1" : : "a"(byte), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) {
	uint8_t ret;
	__asm__ __volatile__("inb %1, %0" : "=a"(ret) : "Nd"(port));
	return ret;
}

#endif
