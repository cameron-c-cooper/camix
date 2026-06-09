#include <camix/types.h>
#include <camix/pmm.h>
#include <arch/x86/pmm.h>
#include <string.h>

/*
 * General process for memory allocation:
 * 	1. Is there enough free VMEM
 * 	2. if so, use some structure to record mem alloc status
 * 	3. if no, ask the vmm to enlarge available address space (mmap, sbrk, etc)
 * 	4. VMM then calls the PMM to allocate the RAM
 * 	5. newly allocate RAM is recorded in the appropriate paging tables by 
 * 		the vmm
 * 	6. go to step 2
 *
 *
 */

static u64 *pmm_bitmap;
static u64 pmm_bitmap_size;
static u64 pmm_total_pages;

static void pmm_mark_free(u64 base, u64 len);

extern u8 _kernel_end[];
extern u8 _kernel_start[];

void init_pmm(phys_addr_t max_phys_addr) {
	pmm_total_pages = max_phys_addr / PAGE_SIZE;
	pmm_bitmap_size = (pmm_total_pages + 63) / 64;
	pmm_bitmap = (u64 *) ALIGN_UP((u64) _kernel_end);
	memset(pmm_bitmap, 0xff, pmm_bitmap_size * 8);
}

static void pmm_mark_free(u64 base, u64 len) {
	u64 page = ALIGN_UP(base) / PAGE_SIZE;
	u64 page_end = ALIGN_DOWN(base + len) / PAGE_SIZE;
	for (u64 p = page; p < page_end; p++) {
		pmm_bitmap[p >> 6] &= ~(1 << (p % 64));
	}
}

void pmm_mark_used(u64 base, u64 len) {
	u64 page = ALIGN_DOWN(base) / PAGE_SIZE;
	u64 page_end = ALIGN_UP(base + len) / PAGE_SIZE;
	for (u64 p = page; p < page_end; p++) {
		pmm_bitmap[p >> 6] |= (1 << (p % 64));
	}
}

void pmm_add_region(u64 base, u64 len) {
	pmm_mark_free(base, len);
}

void pmm_finalize(
		u64 mb2_addr, u32 mb2_size,
		struct save_modules *modules,
		int module_count
) {
	pmm_mark_used(
			(u64) _kernel_start,
			(u64) _kernel_end - (u64) _kernel_start);

	pmm_mark_used(mb2_addr, mb2_size);

	pmm_mark_used(
			(u64) pmm_bitmap,
			pmm_bitmap_size * 8);

	for (int i = 0; i < module_count; i++) {
		pmm_mark_used(modules[i].start,
				modules[i].end - modules[i].start);
	}
			
	pmm_mark_used(0, PAGE_SIZE);
}
virt_addr_t pmm_alloc_page(void) {
	for (u64 i = 0; i < pmm_bitmap_size; i++) {
		if (pmm_bitmap[i] == ~0ULL) continue; // skip word
		int bit = __builtin_ctzll(~pmm_bitmap[i]);
		u64 page = (i << 6) + bit;
		if (page >= pmm_total_pages) return 0;
		pmm_bitmap[i] |= (1 << bit);
		return page * PAGE_SIZE;
	}
	return 0;
}

void pmm_free_page(phys_addr_t phys_addr) {
	u64 page = phys_addr / PAGE_SIZE;
	pmm_bitmap[page >> 6] &= ~(1 << (page % 64));
}
