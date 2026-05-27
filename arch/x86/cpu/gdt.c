#include <arch/x86/gdt.h>
#include <stdint.h>

// 
static gdt_entry_t GDT[5];

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
	// This would be used, but no task
	// __asm__ volatile("mov $0x28, %%ax\nltr %%ax" : : : "eax");
}

void init_gdt(void) {
	gdt_entry_t nd = 0;
	gdt_entry_t kcs = create_gdt_entry(0, 0xfffff, 0x9a, 0xa);
	gdt_entry_t kds = create_gdt_entry(0, 0xfffff, 0x92, 0xc);
	gdt_entry_t uds = create_gdt_entry(0, 0xfffff, 0xf2, 0xc);
	gdt_entry_t ucs = create_gdt_entry(0, 0xfffff, 0xfa, 0xa);
	GDT[0] = nd;
	GDT[1] = kcs;
	GDT[2] = kds;
	GDT[3] = uds;
	GDT[4] = ucs;

	// in the future, there will also be a TSS entry
	struct gdtr gdtr = {
		.size = (sizeof(gdt_entry_t) * 7) - 1,
		.offset = (uint64_t) &GDT[0]
	};

	load_gdt(&gdtr);
}
