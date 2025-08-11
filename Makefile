TARGET_ARCH := i686

ifeq ($(TARGET_ARCH), i686)
	TARGET_NICKNAME := x86
else
	TARGET_NICKNAME := $(TARGET_ARCH)
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

PROJ_ROOT	:= $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

BUILD_DIR			:= $(PROJ_ROOT)/build
KERNEL_DIR			:= $(PROJ_ROOT)/kernel
KERNEL_BUILD_DIR	:= $(BUILD_DIR)/kernel
DRIVERS_DIR			:= $(PROJ_ROOT)/drivers
DRIVERS_BUILD_DIR	:= $(BUILD_DIR)/drivers
ARCH_DIR			:= $(PROJ_ROOT)/arch/$(TARGET_NICKNAME)
ARCH_BUILD_DIR		:= $(BUILD_DIR)/arch/$(TARGET_NICKNAME)

LINKER_SCRIPT	:= $(ARCH_DIR)/boot/linker.ld
# The Poor Man's Static Analyzer
CWARNINGS		:= -Wall -Wextra -Wpedantic -pedantic-errors -Werror -Waggregate-return \
				   -Wbad-function-cast -Wcast-align -Wcast-qual \
				   -Wfloat-equal -Wformat=2 -Wlogical-op \
				   -Wmissing-declarations -Wmissing-include-dirs -Wmissing-prototypes \
				   -Wnested-externs -Wpointer-arith -Wredundant-decls -Wsequence-point \
				   -Wshadow -Wstrict-prototypes -Wswitch -Wundef -Wunreachable-code \
				   -Wunused-but-set-parameter -Wwrite-strings \
				   -Wno-unused-function

CFLAGS			:= -Iinclude -ffreestanding -std=c99 $(CWARNINGS)
LDFLAGS			:= -T $(LINKER_SCRIPT) -lgcc -nostdlib -ffreestanding -static -no-pie

KERNEL_C_SRC 	:= $(shell find $(KERNEL_DIR) -type f \( -name '*.c' \))
KERNEL_S_SRC 	:= $(shell find $(KERNEL_DIR) -type f \( -name '*.S' \))
KERNEL_OBJS 	:= $(patsubst $(KERNEL_DIR)/%.c,$(KERNEL_BUILD_DIR)/%_c.o,$(KERNEL_C_SRC)) \
				   $(patsubst $(KERNEL_DIR)/%.S,$(KERNEL_BUILD_DIR)/%_s.o,$(KERNEL_S_SRC))

DRIVERS_C_SRC 	:= $(shell find $(DRIVERS_DIR) -type f \( -name '*.c' \))
DRIVERS_S_SRC 	:= $(shell find $(DRIVERS_DIR) -type f \( -name '*.S' \))
DRIVERS_OBJS 	:= $(patsubst $(DRIVERS_DIR)/%.c,$(DRIVERS_BUILD_DIR)/%_c.o,$(DRIVERS_C_SRC)) \
				   $(patsubst $(DRIVERS_DIR)/%.S,$(DRIVERS_BUILD_DIR)/%_s.o,$(DRIVERS_S_SRC))

ARCH_C_SRC 	:= $(shell find $(ARCH_DIR) -type f \( -name '*.c' \))
ARCH_S_SRC 	:= $(shell find $(ARCH_DIR) -type f \( -name '*.S' \))
ARCH_OBJS 	:= $(patsubst $(ARCH_DIR)/%.c,$(ARCH_BUILD_DIR)/%_c.o,$(ARCH_C_SRC)) \
			   $(patsubst $(ARCH_DIR)/%.S,$(ARCH_BUILD_DIR)/%_s.o,$(ARCH_S_SRC))

OBJS 	:= $(KERNEL_OBJS) $(ARCH_OBJS) $(DRIVERS_OBJS)

GRUB_FILE	:= $(PROJ_ROOT)/utils/booting/minimal-mb2-grub.cfg

# TODO: Instead of using grub-mkrescue use grub-mkstandalone
kernel: info $(BUILD_DIR)/sysroot/boot/camix.bin $(BUILD_DIR)/sysroot/boot/grub/grub.cfg
	@echo "Generating ISO..."
	@mkdir -p $(dir $@)
	@grub-mkrescue -o $(BUILD_DIR)/$@.iso $(BUILD_DIR)/sysroot

# kernel.elf never removed so it should actually work in base for. 
kernel-debug: info $(BUILD_DIR)/sysroot/boot/camix.bin $(BUILD_DIR)/sysroot/boot/grub/grub.cfg
	@echo "Generating ISO..."
	@mkdir -p $(dir $@)
	@grub-mkrescue -o $(BUILD_DIR)/$@.iso $(BUILD_DIR)/sysroot

info:
	@echo "Target Architecture:	$(TARGET_NICKNAME)"
	@echo "C Compiler:		$(CC)"
	@echo "Project Root:		$(PROJ_ROOT)"	
	@echo "Build Directory:	$(BUILD_DIR)"
	@echo "Grub Cfg:		$(GRUB_FILE)"
	@echo


$(BUILD_DIR)/sysroot/boot/grub/grub.cfg:
	@echo "Copying over grub config..."
	@mkdir -p $(dir $@)
	@touch $@
	@cp $(GRUB_FILE) $(BUILD_DIR)/sysroot/boot/grub/grub.cfg

$(BUILD_DIR)/sysroot/boot/camix.bin: $(BUILD_DIR)/kernel.elf
	@mkdir -p $(dir $@)
	@$(OBJCOPY) -O binary $< $@ 

$(BUILD_DIR)/kernel.elf: $(OBJS)
	@echo "Linking object files..."
	@mkdir -p $(dir $@)
	@$(CC) $(LDFLAGS) $^ -o $@ 

$(ARCH_BUILD_DIR)/%_c.o: $(ARCH_DIR)/%.c
	@echo "Compiling $@..."
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@

$(ARCH_BUILD_DIR)/%_s.o: $(ARCH_DIR)/%.S
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
