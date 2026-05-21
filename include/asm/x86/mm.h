#ifndef ASM_MM_H
#define ASM_MM_H

.equ PML4T_ADDR,0x1000
.equ PDPT_ADDR, 0x2000
.equ PDT_ADDR, 	0x3000
.equ PT_ADDR, 	0x4000

.equ PT_ADDR_MASK, 	0xffffffffff000
.equ PT_PRESENT,	0x01
.equ PT_READABLE, 	0x02

.equ SIZEOF_PT, 		0x1000
.equ ENTRIES_PER_PT, 	0x0200
.equ SIZEOF_PT_ENTRY, 	0x08
.equ PAGE_SIZE, 		0x1000

#endif
