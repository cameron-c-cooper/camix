#include "camix/types.h"
#include <camix/pmm.h>
#include <camix/vmm.h>
#include <camix/mm.h>
// TODO: fix this hack
#include <arch/x86/vmm.h>
#include <ds/list.h>

static virt_addr_t heap_top = KERNEL_HEAP_START;
static LIST_HEAD(heap_list);

static struct block_t *heap_grow(size_t size) {
	size_t bytes = sizeof(struct block_t) + size;
	size_t pages = (bytes + PAGE_SIZE - 1) / PAGE_SIZE;

	uintptr_t base = heap_top;
	for (size_t i = 0; i < pages; i++) {
		phys_addr_t phys = pmm_alloc_page();
		if (!phys) {
			return NULL;
		}
		vmm_map_page(heap_top, phys, PTE_PRESENT | PTE_WRITE);
		heap_top += PAGE_SIZE;
	}
	struct block_t *b = (struct block_t *) base;
	b -> size = (pages * PAGE_SIZE) - sizeof(struct block_t);
	b -> free = 0;
	INIT_LIST_HEAD(&b -> list);
	return b;
}


void *kmalloc(size_t size) {
	size = (size + 15) & ~15ULL;
	struct block_t *b;
	list_for_each_entry(b, &heap_list, list) {
		if (b -> free && b -> size >= size) {
			b -> free = 0;
			return (void *) (b + 1);
		}
	}

	struct block_t *nb = heap_grow(size);
	if (!nb) {
		return NULL;
	}
	list_add_tail(&nb -> list, &heap_list);
	return (void *) (nb + 1);
}

void kfree(void *ptr) {
    if (!ptr) return;

    struct block_t *b = (struct block_t *)ptr - 1;
    b->free = 1;

    // Coalesce with next block if it is also free and contiguous
    if (!list_is_last(&b->list, &heap_list)) {
        struct block_t *next = list_next_entry(b, list);
        // Contiguous means the next block header sits exactly at b's end
        if (next->free &&
            (uintptr_t)(b + 1) + b->size == (uintptr_t)next) {
            b->size += sizeof(struct block_t) + next->size;
            list_del(&next->list);
        }
    }

    // Coalesce with previous block if it is also free and contiguous
    if (!list_is_first(&b->list, &heap_list)) {
        struct block_t *prev = list_prev_entry(b, list);
        if (prev->free &&
            (uintptr_t)(prev + 1) + prev->size == (uintptr_t)b) {
            prev->size += sizeof(struct block_t) + b->size;
            list_del(&b->list);
        }
    }
}
