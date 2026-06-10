#include <arch/x86/vmm.h>
#include <camix/pmm.h>
#include <camix/vmm.h>
#include <arch/x86/pmm.h>
#include <string.h>

static phys_addr_t kernel_pml4;

static phys_addr_t alloc_table(void) {
	phys_addr_t phys = pmm_alloc_page();
	if (!phys) return 0;
	memset(phys_to_virt(phys), 0, PAGE_SIZE);
	return phys;
}

int vmm_map_page(virt_addr_t virt, phys_addr_t phys, u64 flags) {
	u64 *pml4 = phys_to_virt(kernel_pml4);

	u64 *pml4e = &pml4[PML4_IDX(virt)];
	if (!(*pml4e & PTE_PRESENT)) {
		phys_addr_t t = alloc_table();
		if (!t) {
			return -1;
		}
		*pml4e = t | PTE_PRESENT | PTE_WRITE | (flags & PTE_USER);
	}
	u64 *pdpt = phys_to_virt(PTE_ADDR(*pml4e));

	u64 *pdpte = &pdpt[PDPT_IDX(virt)];
	if (!(*pdpte & PTE_PRESENT)) {
		phys_addr_t t = alloc_table();
		if (!t) {
			return -1;
		}
		*pdpte = t | PTE_PRESENT | PTE_WRITE | (flags & PTE_USER);
	}
	u64 *pd = phys_to_virt(PTE_ADDR(*pdpte));
	u64 *pde = &pd[PDT_IDX(virt)];
	if (!(*pde & PTE_PRESENT)) {
		phys_addr_t t = alloc_table();
		if (!t) {
			return -1;
		}
		*pde = t | PTE_PRESENT | PTE_WRITE | (flags & PTE_USER);
	}
	u64 *pt = phys_to_virt(PTE_ADDR(*pde));
	pt[PT_IDX(virt)] = (phys & PAGE_MASK) | flags | PTE_PRESENT;
	__asm__ volatile ("invlpg (%0)" :: "r"(virt) : "memory");
	return 0;
}
