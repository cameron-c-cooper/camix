#ifndef ASM_BOOT_H
#define ASM_BOOT_H

// #ifdef CONFIG_BITS_64
.equ KERNEL_VMA, 0xffffffff80000000
// #else
// .equ KERNEL_VMA 0xc0000000
// #endif
.equ KERNEL_LMA, 0x00100000

.equ EFLAGS_ID, (1 << 21)
.equ CR0_PAGING, (1 << 31)
.equ CR0_PM_ENABLE, (1 << 0)
.equ CR0_PG_ENABLE, (1 << 31)
.equ CR4_PAE_ENABLE, (1 << 5)
.equ EFER_MSR, 0xc0000080
.equ EFER_LM_ENABLE, (1<<8)

#endif
