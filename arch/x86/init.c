#include <camix/init.h>
#include <arch/x86/gdt.h>
#include <arch/x86/idt.h>

void init(void) {
	init_gdt();
	init_idt();
}
