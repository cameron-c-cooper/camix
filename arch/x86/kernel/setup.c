#include <camix/init.h>
#include <arch/x86/gdt.h>
#include <arch/x86/idt.h>
#include <arch/x86/cpuid.h>

extern void printf(const char *fmt, ...);

void early_init(void) {
	init_gdt();
	char vendor[12+1];
	cpuid_get_vendor(vendor);
	printf("%s\n", vendor);
}

void late_init(void) {
	init_idt();
}
