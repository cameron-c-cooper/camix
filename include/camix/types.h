#ifndef TYPES_H
#define TYPES_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

typedef uint64_t u64;
typedef int64_t s64;
typedef uint32_t u32;
typedef uint32_t s32;
typedef uint16_t u16;
typedef int16_t s16;
typedef uint8_t u8;
typedef int8_t s8;

typedef unsigned long long ullong;


/*
 * Some reasoning for why this is not just using a void*, is because
 * usually a void* points to an object that a compiler may dereference.
 * Additionally, pointer arithmetic semantics will still apply and
 * aliasing/provenance things still apply. By storing them as simple
 * integer addresses, it lets me use them in a better way.
 */
#ifdef CONFIG_BITS_32
typedef u32 phys_addr_t
typedef u32 virt_addr_t
#else
typedef u64 phys_addr_t;
typedef u64 virt_addr_t;
#endif

struct list_head {
	struct list_head *next, *prev;
};

#endif
