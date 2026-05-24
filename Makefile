PROJ_ROOT	:= $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

include config.mk

DEBUG := y

ifeq ($(DEBUG), y)
	CFLAGS = -g
	LDFLAGS = -g
endif

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

ifeq ($(TARGET_ARCH), i686)
	TARGET_NICKNAME := x86
	CONFIG_FILE := $(PROJ_ROOT)/configs/x86.config
else ifeq ($(TARGET_ARCH), x86_64)
	TARGET_NICKNAME := x86
	CONFIG_FILE := $(PROJ_ROOT)/configs/x86_64.config
	ARCH_FLAGS := -mno-red-zone -mno-mmx -mno-sse -mno-sse2
else
	TARGET_NICKNAME := $(TARGET_ARCH)
	CONFIG_FILE := $(PROJ_ROOT)/configs/$(TARGET_ARCH).config
endif

BUILD_DIR			:= $(PROJ_ROOT)/build
SYSROOT				:= $(PROJ_ROOT)/sysroot
KERNEL_DIR			:= $(PROJ_ROOT)/kernel
KERNEL_BUILD_DIR	:= $(BUILD_DIR)/kernel
DRIVERS_DIR			:= $(PROJ_ROOT)/drivers
DRIVERS_BUILD_DIR	:= $(BUILD_DIR)/drivers
ARCH_DIR			:= $(PROJ_ROOT)/arch/$(TARGET_NICKNAME)
ARCH_BUILD_DIR		:= $(BUILD_DIR)/arch/$(TARGET_NICKNAME)

# The Poor Man's Static Analyzer
CWARNINGS		:= -Wall -Wextra -Wpedantic -pedantic-errors -Werror \
				   -Waggregate-return -Wbad-function-cast -Wcast-align \
				   -Wcast-qual -Wfloat-equal -Wformat=2 -Wlogical-op \
				   -Wmissing-declarations -Wmissing-include-dirs \
				   -Wnested-externs -Wredundant-decls -Wno-cast-qual\
				   -Wsequence-point -Wshadow -Wstrict-prototypes -Wswitch \
				   -Wundef -Wunreachable-code -Wunused-but-set-parameter \
				   -Wwrite-strings -Wno-unused-function -Wno-pointer-arith \
				   -Wno-pointer-to-int-cast -Wno-discarded-qualifiers



KERNEL_C_SRC 	:= $(shell find $(KERNEL_DIR) -type f \( -name '*.c' \))
KERNEL_S_SRC 	:= $(shell find $(KERNEL_DIR) -type f \( -name '*.S' \))
KERNEL_OBJS 	:= $(patsubst $(KERNEL_DIR)/%.c,$(KERNEL_BUILD_DIR)/%_c.o,$(KERNEL_C_SRC)) \
				   $(patsubst $(KERNEL_DIR)/%.S,$(KERNEL_BUILD_DIR)/%_s.o,$(KERNEL_S_SRC))

DRIVERS_C_SRC 	:= $(shell find $(DRIVERS_DIR) -type f \( -name '*.c' \))
DRIVERS_S_SRC 	:= $(shell find $(DRIVERS_DIR) -type f \( -name '*.S' \))
DRIVERS_OBJS 	:= $(patsubst $(DRIVERS_DIR)/%.c,$(DRIVERS_BUILD_DIR)/%_c.o,$(DRIVERS_C_SRC)) \
				   $(patsubst $(DRIVERS_DIR)/%.S,$(DRIVERS_BUILD_DIR)/%_s.o,$(DRIVERS_S_SRC))

include $(ARCH_DIR)/config.mk

ARCH_OBJS := $(patsubst %.o, $(ARCH_BUILD_DIR)/%.o, $(obj-y))
ARCH_SRCS := $(foreach obj, $(obj-y), $(if $(\
			 	wildcard $(ARCH_DIR)/$(obj:.o=.c))\
				$(ARCH_DIR)/$(obj:.o=.c), \
				$(ARCH_DIR)/$(obj:.o=.S)))

OBJS 	:= $(KERNEL_OBJS) $(ARCH_OBJS) $(DRIVERS_OBJS)
#
# Technically because the CPP runs over it, it should live in the build dir
LINKER_FULL_PATH	:= $(ARCH_DIR)/$(LINKER_SCRIPT_SRC)
LINKER_SCRIPT		:= $(patsubst $(ARCH_DIR)/%.lds.S, \
					   $(ARCH_BUILD_DIR)/%.lds, \
					   $(LINKER_FULL_PATH))

CFLAGS			+= -Iinclude -mcmodel=kernel -ffreestanding -std=c99 -nostdlib -Wa,-64 \
				   $(ARCH_FLAGS) $(CWARNINGS)
LDFLAGS			+= -T $(LINKER_SCRIPT) -nostdlib -ffreestanding -static \
				   -no-pie $(ARCH_FLAGS) -lgcc

MIN_GRUB_FILE	:= $(PROJ_ROOT)/utils/boot/minimal-mb2-grub.cfg
# just in case I want somethign different
DEBUG_GRUB_FILE := $(PROJ_ROOT)/utils/boot/debug-mb2-grub.cfg
GRUB_FILE		:= $(SYSROOT)/boot/grub/grub.cfg

# TODO: Instead of using grub-mkrescue use grub-mkstandalone
kernel: info clean-sysroot $(GRUB_FILE)-min $(SYSROOT)/boot/kernel.elf
	@echo "Generating ISO..."
	@mkdir -p $(SYSROOT)
	@grub-mkrescue -o $(BUILD_DIR)/$@.iso $(SYSROOT)

# kernel.elf never removed so it should actually work in base for. 
kernel-debug: info clean-sysroot $(GRUB_FILE)-debug $(SYSROOT)/boot/kernel.elf
	@echo "Generating ISO..."
	@mkdir -p $(SYSROOT) 
	@grub-mkrescue -o $(BUILD_DIR)/$@.iso $(SYSROOT)

clean-sysroot:
	@echo "Cleaning sysroot..."
	@rm -rf $(SYSROOT)/*

info:
	@echo "Target Architecture:	$(TARGET_NICKNAME)"
	@echo "C Compiler:			$(CC)"
	@echo "Project Root:		$(PROJ_ROOT)"	
	@echo "Build Directory:		$(BUILD_DIR)"
	@echo "Grub Cfg:			$(MIN_GRUB_FILE)"
	@echo

$(GRUB_FILE)-min: $(MIN_GRUB_FILE)
	@echo "Copying over grub config..."
	@mkdir -p $(dir $@)
	@touch $(MIN_GRUB_FILE)
	@cp $< $(GRUB_FILE)

$(GRUB_FILE)-debug: $(DEBUG_GRUB_FILE)
	@echo "Copying over debug grub config..."
	@mkdir -p $(dir $@)
	@touch $(GRUB_FILE)
	@cp $< $(GRUB_FILE)

# $(SYSROOT)/boot/camix.bin: $(BUILD_DIR)/kernel.elf
# 	@mkdir -p $(dir $@)
# 	@$(OBJCOPY) -O binary $< $@ 

$(SYSROOT)/boot/kernel.elf: $(BUILD_DIR)/kernel.elf
	@cp $< $@

$(BUILD_DIR)/kernel.elf: $(OBJS) $(LINKER_SCRIPT)
	@echo "Linking object files..."
	@mkdir -p $(dir $@)
	@$(CC) $(OBJS) $(LDFLAGS) -o $@ 

$(ARCH_BUILD_DIR)/%.o: $(ARCH_DIR)/%.c
	@echo "Compiling $@..."
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@

$(ARCH_BUILD_DIR)/%.o: $(ARCH_DIR)/%.S
	@echo "Compiling $@..."
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@

$(KERNEL_BUILD_DIR)/%_c.o: $(KERNEL_DIR)/%.c
	@echo "Compiling $@..."
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@

$(KERNEL_BUILD_DIR)/%_s.o: $(KERNEL_DIR)/%.S
	@echo "Compiling $@..."
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@

$(DRIVERS_BUILD_DIR)/%_c.o: $(DRIVERS_DIR)/%.c
	@echo "Compiling $@..."
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@

$(DRIVERS_BUILD_DIR)/%_s.o: $(DRIVERS_DIR)/%.S
	@echo "Compiling $@..."
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@

$(LINKER_SCRIPT): $(LINKER_FULL_PATH)
	@echo "Preprocessing linker script..."
	@mkdir -p $(dir $@)
	@$(CC) -E -P -x c -I$(PROJ_ROOT)/include $< -o $@
