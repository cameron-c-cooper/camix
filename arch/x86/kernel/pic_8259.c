#include <arch/x86/pic_8259.h>

void pic_sendEOI(u8 irq) {
	if (irq >= 8) outb(SPIC_CMD,PIC_EOI);
	outb(MPIC_CMD,PIC_EOI);
}

void pic_remap(int offset1, int offset2) {
	outb(MPIC_CMD, ICW1_INIT | ICW1_ICW4); // starts init seq in cascade mode
	// using io_wait because slow hardware may effect PIC setup
	io_wait();
	outb(SPIC_CMD, ICW1_INIT | ICW1_ICW4);
	io_wait();
	outb(MPIC_DATA, offset1);
	io_wait();
	outb(SPIC_DATA, offset2);
	io_wait();
	outb(MPIC_DATA, 1 << CASCADE_IRQ);
	io_wait();
	outb(SPIC_DATA, 2);
	io_wait();
	outb(MPIC_DATA, ICW4_8086);
	io_wait();
	outb(SPIC_DATA, ICW4_8086);
	io_wait();

	// unmask pics
	outb(MPIC_DATA, 0);
	outb(SPIC_DATA, 0);
}

// basically just masks all interrupts
void pic_disable(void) {
	outb(MPIC_DATA, 0xff);
	outb(SPIC_DATA, 0xff);
}

/*
 * IMR is a 8 bit wide bitmap of request lines going into the PIC. When a bit
 * is set, PIC ignores request and continues normal op. Setting the mask on a 
 * higher req line will not affect a lower line. Masking IRQ2 will cause the
 * SPIC to stop raising IRQs
 */
void irq_set_mask(u8 irqline) {
	u16 port;
	u8 value;
	if (irqline < 8) port = MPIC_DATA;
	else {
		port = SPIC_DATA;
		irqline -= 8;
	}
	value = inb(port) | (1 << irqline);
	outb(port, value);
}

void irq_clear_mask(u8 irqline) {
	u16 port;
	u8 value;
	if (irqline < 8) port = MPIC_DATA;
	else {
		port = SPIC_DATA;
		irqline -= 8;
	}
	value = inb(port) & ~(1 << irqline);
	outb(port, value);
}

static u16 __pic_get_irq_reg(int ocw3) {
	outb(MPIC_CMD, ocw3);
	outb(SPIC_CMD, ocw3);
	return (inb(SPIC_CMD) << 8) | inb(MPIC_CMD);
}

/*
 * These functions will show bit 2 as on wheneever any PIC2 bits are set.
 * Additionally, resetting OCW3 cmd is not necessary (according to spec).
 */
u16 pic_get_irr(void) {
	return __pic_get_irq_reg(PIC_READ_IRR);
}

u16 pic_get_isr(void) {
	return __pic_get_irq_reg(PIC_READ_ISR);
}
