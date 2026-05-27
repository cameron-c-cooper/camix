#ifndef MM_H
#define MM_H
#include <stdint.h>

struct pmm_state {
};

phys_addr_t get_physaddr(virt_addr_t va);
void map_page(phys_addr_t pa, virt_addr_t va, unsigned int flags);

#endif
