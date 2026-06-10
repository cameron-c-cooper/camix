#ifndef X86_VMM_H
#define X86_VMM_H

#include <arch/x86/mm.h>

#include <camix/types.h>

#define PHYS_MAP_BASE 0xffff800000000000ULL
#define KERNEL_BASE 0xffffffff80000000ULL
#define KERNEL_HEAP_START 0xffffffff90000000ULL
#define KERNEL_HEAP_END	0xffffffffC0000000ULL

#define  PTE_PRESENT (1ULL << 0)
#define PTE_WRITE (1ULL << 1)
#define PTE_USER (1ULL << 2)
#define PTE_HUGE (1ULL << 7)
#define PTE_NX (1ULL << 63)

#define PAGE_MASK (~0xFFFULL)
#define PTE_ADDR(e) ((e) & 0x000ffffffffff000ULL)

#define PML4_IDX(a) (((a) >> 39) & 0x1ff)
#define PDPT_IDX(a) (((a) >> 30) & 0x1ff)
#define PDT_IDX(a) (((a) >> 21) & 0x1ff)
#define PT_IDX(a) (((a) >> 12) & 0x1ff)

#define PAGE_SIZE ((size_t) 0x1000)

static inline void *phys_to_virt(phys_addr_t phys) {
	return (void *) ((uintptr_t) phys + PHYS_MAP_BASE);
}

static inline phys_addr_t virt_to_phys(virt_addr_t virt) {
	return virt - PHYS_MAP_BASE;
}

static inline void *kphys_to_virt(phys_addr_t phys) {
	return (void *) ((uintptr_t) phys + KERNEL_BASE);
}

static inline phys_addr_t kvirt_to_phys(virt_addr_t virt) {
	return virt - KERNEL_BASE;
}

#endif
