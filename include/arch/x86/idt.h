#ifndef X86_IDT_H
#define X86_IDT_H

#include <camix/types.h>

#define IDT_MAX_DESCRIPTORS 256

typedef struct idt_entry_t {
	u16 isr_low; // Lower 16 bits of the ISR addr
	u16 kernel_cs;	// GDT selector loaded into CS before calling ISR
	u8 ist;			// IST in TSS that CPU will load into RSP, set to 0 for now
	u8 attrs;
	u16 isr_mid;
	u32 isr_high;
	u32 reserved;
} __attribute__((packed)) idt_entry_t;

struct idtr {
	u16 limit;
	u64 base;
} __attribute__((packed));

void idt_set_descriptor(u8 vec, void *isr, u8 flags);
void init_idt(void);

#endif
