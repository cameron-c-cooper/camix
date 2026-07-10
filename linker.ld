ENTRY(_start)

KERNEL_LMA = 1M;
KERNEL_VMA = 0xffffffff80000000;

SECTIONS
{
    . = KERNEL_LMA;

    .boot ALIGN(4K) :
    {
        KEEP(*(.multiboot))
        *(.text.boot)
        *(.rodata.boot)
    }

    .boot.bss ALIGN(4K) (NOLOAD) :
    {
        *(.bss.boot)
    }

    . += KERNEL_VMA;

    .text ALIGN(4K) : AT(ADDR(.text) - KERNEL_VMA)
    {
        *(.text .text.*)
    }

    .rodata ALIGN(4K) : AT(ADDR(.rodata) - KERNEL_VMA)
    {
        *(.rodata .rodata.*)
    }

    .data ALIGN(4K) : AT(ADDR(.data) - KERNEL_VMA)
    {
        *(.data .data.*)
    }

    .bss ALIGN(4K) (NOLOAD) : AT(ADDR(.bss) - KERNEL_VMA)
    {
        *(COMMON)
        *(.bss .bss.*)
    }

    kernel_end_vma = .;
    kernel_end_lma = . - KERNEL_VMA;

    /DISCARD/ :
    {
        *(.eh_frame)
        *(.comment)
        *(.note.*)
    }
}
