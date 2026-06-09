LIB_ROOT	:= $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

include $(LIB_ROOT)/../config.mk

ifeq ($(TARGET_ARCH), i686)
	TARGET_NICKNAME := x86
	CONFIG_X86 = y
else ifeq ($(TARGET_ARCH), x86_64)
	TARGET_NICKNAME := x86
	CONFIG_X86_64 = y
else
	TARGET_NICKNAME := $(TARGET_ARCH)
endif

PREFIX?=/usr/local

CC	:= $(TARGET_ARCH)-elf-gcc
AS	:= $(TARGET_ARCH)-elf-as
AR	:= $(TARGET_ARCH)-elf-ar
LD	:= $(TARGET_ARCH)-elf-ld
NM	:= $(TARGET_ARCH)-elf-nm
SIZE	:= $(TARGET_ARCH)-elf-size
GCOV	:= $(TARGET_ARCH)-elf-gcov
GPROF	:= $(TARGET_ARCH)-elf-gprof
STRIP	:= $(TARGET_ARCH)-elf-strip
OBJCOPY := $(TARGET_ARCH)-elf-objcopy
OBJDUMP := $(TARGET_ARCH)-elf-objdump
READELF := $(TARGET_ARCH)-elf-readelf

LIB_BUILD_DIR	:= $(LIB_ROOT)/build
LIB_SRC_DIR		:= $(LIB_ROOT)/src

CWARNINGS		:= -Wall -Wextra -Wpedantic -pedantic-errors -Werror \
				   -Waggregate-return -Wbad-function-cast -Wcast-align \
				   -Wcast-qual -Wfloat-equal -Wformat=2 -Wlogical-op \
				   -Wmissing-declarations -Wmissing-include-dirs \
				   -Wnested-externs -Wredundant-decls -Wno-cast-qual\
				   -Wsequence-point -Wshadow -Wstrict-prototypes -Wswitch \
				   -Wundef -Wunreachable-code -Wunused-but-set-parameter \
				   -Wwrite-strings -Wno-unused-function -Wno-pointer-arith \
				   -Wno-pointer-to-int-cast -Wno-discarded-qualifiers

CFLAGS	:= $(CFLAGS) $(CWARNINGS) -I$(LIB_ROOT)/../include \
		   -I$(LIB_ROOT)/../include/libc -ffreestanding -nostdlib

LIBK_CFLAGS := $(CFLAGS)

LIB_C_SRC 	:= $(shell find $(LIB_SRC_DIR) -type f \( -name '*.c' \))
LIB_S_SRC	:= $(shell find $(LIB_SRC_DIR)/asm/arch/$(TARGET_NICKNAME) -type f \( -name '*.S' \))
LIB_OBJS	:= $(patsubst $(LIB_SRC_DIR)/%.c,$(LIB_BUILD_DIR)/%.c.libk.o,$(LIB_C_SRC)) \
			   $(patsubst $(LIB_SRC_DIR)/%.S,$(LIB_BUILD_DIR)/%.S.libk.o,$(LIB_S_SRC))

FREE_OBJS := $(LIB_OBJS)
BINARIES := $(LIB_BUILD_DIR)/libk.a

.SUFFIXES: .o .link.o .c .S
.PHONY: all clean

all: $(BINARIES)

$(LIB_BUILD_DIR)/libk.a: $(FREE_OBJS)
	@$(AR) rcs $@ $^

$(LIB_BUILD_DIR)/%.c.o:
	@mkdir -p $(dir $@)
	@$(CC) -MD -c $< -o $@ std=gnu11 $(CFLAGS)

$(LIB_BUILD_DIR)/%.S.o:
	@mkdir -p $(dir $@)
	@$(CC) -MD -c $< -o $@ $(CFLAGS)

$(LIB_BUILD_DIR)/%.c.libk.o: $(LIB_SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	@$(CC) -MD -c $< -o $@ -std=gnu11 $(LIBK_CFLAGS)

$(LIB_BUILD_DIR)/%.S.libk.o: $(LIB_SRC_DIR)/%.S
	@mkdir -p $(dir $@)
	@$(CC) -MD -c $< -o $@ $(LIBK_CFLAGS)

clean:
	@rm -rf $(LIB_BUILD_DIR)
