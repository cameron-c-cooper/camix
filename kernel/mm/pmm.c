#include <camix/types.h>

extern u64 _data_end;
virt_addr_t bitmap = (virt_addr_t) (&_data_end);
phys_addr_t mem_start;
u64 total_blocks;
u64 bitmap_size;

void init_pmm(void) {
}
