#include <arch/x86/gdt.h>
#include <stdint.h>

gdt_entry_t create_gdt_entry(
		uint32_t base,
		uint32_t limit,
		uint64_t access, 
		uint64_t flags
) {
	uint64_t base_lo = base & 0xffff;
	uint64_t base_mid = (base >> 16) & 0xff;
	uint64_t base_hi = (base >> 24) & 0xff;
	uint64_t limit_lo = limit & 0xffff;
	uint64_t limit_hi = (limit >> 16) & 0x0f;
	gdt_entry_t entry = 0;
	entry |= limit_lo;
	entry |= limit_hi << 48;
	entry |= base_lo << 16;
	entry |= base_mid << 32;
	entry |= base_hi << 56;
	entry |= access << 40;
	entry |= flags << 52;
	return entry;
}

void load_gdt(struct gdtr *gdtr) {
	__asm__ volatile("lgdt (%0)" : : "r"(gdtr));
	reload_gdt();
	__asm__ volatile("mov $0x28, %%ax\nltr %%ax" : : : "eax");
}

void init_gdt(uintptr_t kernel_rsp) {
	
