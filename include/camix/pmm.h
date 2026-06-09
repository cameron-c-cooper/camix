#ifndef PMM_H
#define PMM_H

#include <camix/types.h>
#include <camix/multiboot2.h>

#define PAGE_SIZE 0x1000
#define ALIGN_DOWN(x) 	((x) & ~(PAGE_SIZE - 1))
#define ALIGN_UP(x)		(((x) + PAGE_SIZE - 1) & ~(PAGE_SIZE - 1))

struct save_modules {
	u64 start;
	u64 end;
};

void init_pmm(phys_addr_t max_phys_addr);
void pmm_add_region(u64 base, u64 len);
void pmm_finalize(
		u64 mb2_addr, u32 mb2_size,
		struct save_modules *modules,
		int module_count
);
void pmm_mark_used(u64 base, u64 len);
virt_addr_t pmm_alloc_page(void);
void pmm_free_page(phys_addr_t phys_addr);

#endif
