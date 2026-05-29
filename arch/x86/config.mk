obj-$(CONFIG_BITS_64) += boot/head64.o
obj-$(CONFIG_BITS_32) += boot/head32.o
obj-y += kernel/cpu/isr.o
obj-y += kernel/cpu/idt.o
obj-y += kernel/cpu/gdt.o
obj-y += kernel/cpu/reload_gdt.o
obj-y += kernel/cpu/cpuid.o
obj-y += kernel/setup.o
# obj-y += kernel/interrupts.o
# obj-$(CONFIG_BITS_64) += mm/paging64.o

LINKER_SCRIPT_SRC	:= boot/linker.lds.S
