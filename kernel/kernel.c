void kmain(void);

void kmain(void) {
	volatile unsigned short *vga = (unsigned short *) 0xb8000;
	vga[0] = 0x0f41;
	for (;;) __asm__ volatile ("hlt");
}
