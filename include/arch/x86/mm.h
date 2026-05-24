#ifndef X86_MM_H
#define X86_MM_H

#define PML4T_ADDR 0x1000
#define PT_ADDR_MASK 0xffffffffff000
#define PT_PRESENT 0x01
#define PT_READABLE 0x02

#ifdef CONFIG_BITS_32
#define KERNEL_VMA 0xc0000000
#else
#define KERNEL_VMA 0xffffffff80000000
#endif

#define P2V(x) ((x) + KERNEL_VMA)
#define V2P(x) ((x) - KERNEL_VMA)

#endif
