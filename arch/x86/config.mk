obj-$(CONFIG_BITS_64) += boot/head64.o
obj-$(CONFIG_BITS_32) += boot/head32.o
obj-$(CONFIG_BITS_64) += cpu/gdt.o
obj-$(CONFIG_BITS_64) += cpu/reload_gdt.o
obj-y += init.o
# obj-$(CONFIG_BITS_64) += mm/paging64.o

LINKER_SCRIPT_SRC	:= boot/linker.lds.S
