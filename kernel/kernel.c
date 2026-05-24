#include <arch/x86/mm.h>

void kmain(void);

void kmain(void) {
	// make sure there is no page fault
	volatile unsigned short *vga = (unsigned short *) P2V(0xb8000);
	vga[0] = 0x0f41;
	for (;;) __asm__ volatile ("hlt");
}
