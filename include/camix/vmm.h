#ifndef VMM_H
#define VMM_H

#include <camix/types.h>

int vmm_map_page(virt_addr_t virt, phys_addr_t phys, u64 flags);

#endif
