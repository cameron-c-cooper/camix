#include <camix/mm.h>
#include <arch/x86/mm.h>
#include <camix/types.h>
#include <ds/list.h>

struct free_memory {
	uintptr_t beginning;
	size_t size;
	list_head next_mem;
}

static inline uintptr_t __get_first_free_ptr(void) {
}
