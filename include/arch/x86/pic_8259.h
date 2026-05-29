#ifndef PIC_8259_H
#define PIC_8259_H

#include "arch/x86/io.h"
#include <camix/types.h>

#define MPIC_CMD 	0x0020
#define MPIC_DATA 	0x0021
#define SPIC_CMD	0x00a0
#define SPIC_DATA	0x00a1

#define PIC_EOI 0x20

#define ICW1_ICW4	0x01 // ICW4 present
#define ICW1_SINGLE 0x02 // single/cascade mode
#define ICW1_INTERVAL4 0x04 // call address interval 4 (8)
#define ICW1_LEVEL	0x08
#define ICW1_INIT	0x10

#define ICW4_8086	0x01
#define ICW4_AUTO	0x02
#define ICW4_SFNM 	0x10
#define ICW4_BUF_SLAVE	0x08
#define ICW4_BUF_MASTER	0x08

#define CASCADE_IRQ 2

#define PIC_READ_IRR 0x0a
#define PIC_READ_ISR 0x0b

void pic_sendEOI(u8 irq);
void pic_remap(int offset1, int offset2);
void pic_disable(void);

void irq_set_mask(u8 irqline);
void irq_clear_mask(u8 irqline);

u16 pic_get_irr(void);
u16 pic_get_isr(void);

#endif
