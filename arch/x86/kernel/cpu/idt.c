#include <arch/x86/idt.h>
#include <stdbool.h>

static bool vectors[IDT_MAX_DESCRIPTORS];

__attribute__((aligned(0x10)))
static idt_entry_t idt[256];

static struct idtr idtr;

extern void* isr_stub_table[];


__attribute__((noreturn))
void exception_handler(void);
void exception_handler() {
	__asm__ volatile ("cli; hlt");
	for (;;);
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

extern void printf(const char *fmt, ...);

void init_idt() {
	idtr.base = (uintptr_t) &idt[0];
	idtr.limit = (u16) sizeof(idt_entry_t) * IDT_MAX_DESCRIPTORS - 1;
	for (u8 vec = 0; vec < 32; vec++) {
		idt_set_descriptor(vec, isr_stub_table[vec], 0x8e);
		vectors[vec] = true;
	}

	__asm__ volatile ("lidt %0" : : "m"(idtr));
	__asm__ volatile ("sti");

	printf("IDT Initialized\n");
}
