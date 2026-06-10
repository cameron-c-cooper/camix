#include <arch/x86/cpu.h>
#include "arch/x86/pic_8259.h"
#include "camix/types.h"
#include <arch/x86/idt.h>
#include <stdbool.h>
#include <stdint.h>
#include <arch/x86/pmm.h>
#include <arch/x86/vmm.h>
#include <camix/pmm.h>
#include <camix/vmm.h>

static bool vectors[IDT_MAX_DESCRIPTORS];

__attribute__((aligned(0x10)))
static idt_entry_t idt[256];

static struct idtr idtr;

extern void* isr_stub_table[];
extern void printf(const char *fmt, ...);

static inline uintptr_t read_cr2(void);

// TODO: Find proper location for this
void page_fault_handler(struct registers_t *regs);
void page_fault_handler(struct registers_t *regs) {
	printf("Handling page fault");
	uintptr_t fault_addr = read_cr2();
	bool present = regs -> err_code & (1 << 0);
	// bool write = regs -> err_code & (1 << 1);
	// bool user = regs -> err_code & (1 << 2);
	// bool nx_fault = regs -> err_code & (1 << 4);
	if (!present) {
		phys_addr_t phys = pmm_alloc_page();
		if (!phys) {
			printf("PMM: Out of memory\n");
			goto halt;
		}
		u32 flags = PT_PRESENT | PT_READABLE;
		vmm_map_page(fault_addr & ~0xfffULL, phys, flags);
		return;
	}
halt:
	printf("PAGE FAULT | addr=0x%llx err=0x%llx rip=0x%llx\n",
		   fault_addr, regs->err_code, regs->rip);
    __asm__ volatile ("cli; hlt");
    for (;;);
}

void exception_handler(struct registers_t *regs);
void exception_handler(struct registers_t *regs) {
	switch (regs -> int_no) {
	case 14:
		page_fault_handler(regs);
		break;
	case 0xd:
		printf("GP Fault");
		break;
	case 32:
		printf(".\n");
		break;
	default:
		printf("Exception 0x%x at RIP=0x%x\n", regs -> int_no, regs -> rip);
		__asm__ volatile ("cli; hlt");
		for (;;);
	}
}


static inline uintptr_t read_cr2(void) {
	uintptr_t addr;
	__asm__ volatile ("mov %%cr2, %0" : "=r"(addr));
	return addr;
}

void idt_set_descriptor(u8 vec, void *isr, u8 flags) {
	idt_entry_t *desc = &idt[vec];
	desc ->  isr_low 	= (u32) isr & 0xffff;
	desc -> kernel_cs	= 0x08; // kernel offset
	desc -> ist 		= 0;
	desc -> attrs 		= flags;
	desc -> isr_mid 	= ((u64) isr >> 16) & 0xffff;
	desc -> isr_high 	= ((u64) isr >> 32) & 0xffffffff;
	desc -> reserved 	= 0;
}


void init_idt(void) {
	idtr.base = (uintptr_t) &idt[0];
	idtr.limit = (u16) sizeof(idt_entry_t) * IDT_MAX_DESCRIPTORS - 1;
	for (u8 vec = 0; vec < 32; vec++) {
		idt_set_descriptor(vec, isr_stub_table[vec], 0x8e);
		vectors[vec] = true;
	}

	__asm__ volatile ("lidt %0" : : "m"(idtr));

	pic_remap(0x20, 0x28);

	__asm__ volatile ("sti");

	printf("IDT Initialized\n");
}
