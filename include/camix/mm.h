#ifndef MM_H
#define MM_H
#include <stdint.h>

/*
 * Some reasoning for why this is not just using a void*, is because
 * usually a void* points to an object that a compiler may dereference.
 * Additionally, pointer arithmetic semantics will still apply and
 * aliasing/provenance things still apply. By storing them as simple
 * integer addresses, it lets me use them in a better way.
 */
#ifdef CONFIG_BITS_32
typedef uint32_t virt_addr_t;
typedef uint32_t phys_addr_t;
#else
typedef uint64_t virt_addr_t;
typedef uint64_t phys_addr_t;
#endif

phys_addr_t get_physaddr(virt_addr_t va);
void map_page(phys_addr_t pa, virt_addr_t va, unsigned int flags);

#endif
