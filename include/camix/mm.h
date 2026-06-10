#ifndef MM_H
#define MM_H

#include "camix/types.h"

struct block_t {
	size_t size;
	int free;
	struct list_head list;
};

void *kmalloc(size_t size);
void kfree(void *ptr);

#endif
