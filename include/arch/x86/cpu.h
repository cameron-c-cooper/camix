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

struct registers_t {
	u64 r15, r14, r13, r12, r11, r10, r9, r8;
	u64 rbp, rdi, rsi, rdx, rcx, rbx, rax;
	u64 int_no;
	u64 err_code;
	u64 rip, cs, rflags, rsp, ss;
};

static inline void io_wait(void) {
	outb(0x80, 0);
}

#endif
