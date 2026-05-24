#include <arch/x86/mm.h>
#include <camix/init.h>

void kmain(void);

void kmain(void) {
	init();
	volatile unsigned short *vga = (unsigned short *) P2V(0xb8000);
	vga[0] = 0x0f41;
	for (;;) __asm__ volatile ("hlt");
}
