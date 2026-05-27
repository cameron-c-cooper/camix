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
	_bootstrap_start = .;
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
	_bootstrap_end = .;

	. += KERNEL_VMA;

	.text ALIGN(4K) : AT(ADDR(.text) - KERNEL_VMA) {
		_text_start = .;
		*(.text)
		_text_end = .;
	}
	.rodata ALIGN(4K) : AT(ADDR(.rodata) - KERNEL_VMA) {
		_rodata_start = .;
		*(.rodata)
		_rodata_end = .;
	}
	.bss ALIGN(4K) : AT(ADDR(.bss) - KERNEL_VMA) {
		_bss_start = .;
		*(COMMON)
		*(.bss)
		_bss_end = .;
	}
	.data ALIGN(4K) : AT(ADDR(.data) - KERNEL_VMA) {
		_data_start = .;
		*(.data .data.*)
		_data_end = .;
	}
	_kernel_end = .;
}
