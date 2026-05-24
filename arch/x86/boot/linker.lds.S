#ifdef CONFIG_BITS_32
	OUTPUT_FORMAT("elf32-i386")
	OUTPUT_ARCH(i386)
#define KERNEL_VMA 0xc0000000
#else
	OUTPUT_FORMAT("elf64-x86-64")
	OUTPUT_ARCH(i386:x86-64)
#define KERNEL_VMA 0xffffffff80000000
#endif
#define KERNEL_LMA 0x00100000
ENTRY(_start)

SECTIONS {
	. = KERNEL_LMA;
	_kernel_start = .;
	.multiboot.header : {
		KEEP(*(.multiboot.header))
	}
	.multiboot.text : {
		*(.multiboot.text)
	}
	.lm_entry : {
		*(.lm_entry)
	}
	.boot_stack : { 
		*(.boot_stack) 
	}
	.boot_gdt : {
		*(.boot_gdt) 
	}

	. += KERNEL_VMA;

	.text ALIGN(4K) : AT(ADDR(.text) - KERNEL_VMA) {
		*(.text)
	}
	.rodata ALIGN(4K) : AT(ADDR(.rodata) - KERNEL_VMA) {
		*(.rodata)
	}
	.data ALIGN(4K) : AT(ADDR(.data) - KERNEL_VMA) {
		*(.data .data.*)
	}
	.bss ALIGN(4K) : AT(ADDR(.bss) - KERNEL_VMA) {
		*(COMMON)
		*(.bss)
	}
	_kernel_end = .;
}
