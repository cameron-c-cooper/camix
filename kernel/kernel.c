#include <arch/x86/mm.h>
#include <camix/multiboot2.h>
#include <stdint.h>

void kmain(unsigned long magic, unsigned long addr);

void kmain(unsigned long magic, unsigned long addr) {
	// make sure there is no page fault
	volatile unsigned short *vga = (unsigned short *) P2V(0xb8000);
	vga[0] = 0x0f41;
	vga[1] = magic;
	vga[2] = addr;
	for (;;) __asm__ volatile ("hlt");
}
