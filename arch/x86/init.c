#include <camix/init.h>
#include <arch/x86/gdt.h>

void init(void) {
	init_gdt();
}
