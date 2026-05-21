obj-$(CONFIG_BITS_64) += boot/head64.o
obj-$(CONFIG_BITS_32) += boot/head32.o

LINKER_SCRIPT_SRC	:= boot/linker.lds.S
