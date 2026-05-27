#ifndef X86_GDT_H
#define X86_GDT_H

#include <stdint.h>

typedef uint64_t gdt_entry_t;

struct gdtr {
	uint16_t size;
	uint64_t offset;
} __attribute__((packed));

gdt_entry_t create_gdt_entry(
		uint32_t base,
		uint32_t limit,
		uint64_t access,
		uint64_t flags
);

extern void reload_gdt(void);
void init_gdt(void);
void load_gdt(struct gdtr *gdtr);

#define GDT_HWSWITCH_FLAG (1 << 52)
#define GDT_LM_FLAG (1 << 53)
#define GDT_MISC_FLAG (1 << 54)
#define GDT_GRAN_FLAG (1 << 55)
#define GDT_PRES_FLAG (1 << 47)

inline uint8_t gdt_get_ring(gdt_entry_t *entry) {
	return ((*entry) >> 45) & 0x03;
}

inline uint8_t gdt_get_selector_type(gdt_entry_t *entry) {
	return ((*entry) >> 40) & 0x0f;
}

inline uint8_t gdt_is_system_selector(gdt_entry_t *entry) {
	return ((*entry) >> 44) & 0x01;
}

inline uint8_t gdt_is_present(gdt_entry_t *entry) {
	return ((*entry) >> 47) & 0x01;
}

inline uint8_t gdt_get_flags(gdt_entry_t *entry) {
	return ((*entry) >> 52) & 0x0f;
}

#endif
