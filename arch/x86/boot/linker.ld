ENTRY(_start)

SECTIONS {
	. = 0x00100000;

	_kernel_start = .;
	.multiboot.header : {
		KEEP(*(.multiboot.header))
	}

	.multiboot.text : {
		*(.multiboot.text)
	}

	. += 0xc0000000;
	.text ALIGN(4K) : AT(ADDR(.text) - 0xc0000000) {
		*(.text)
	}
	.rodata ALIGN(4K) : AT(ADDR(.rodata) - 0xc0000000) {
		*(.rodata)
	}
	.data ALIGN(4K) : AT(ADDR(.data) - 0xc0000000) {
		*(.data .data.*)
	}
	.bss ALIGN(4K) : AT(ADDR(.bss) - 0xc0000000) {
		*(COMMON)
		*(.bss)
		*(.boot_stack)
	}
	_kernel_end = .;
}
