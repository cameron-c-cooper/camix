TARGET_ARCH 	?= aarch64
TARGET_BOARD 	?= rpi3b
TARGET_NAME	?= kernel8

CC 	:= $(TARGET_ARCH)-elf-gcc
LD 	:= $(TARGET_ARCH)-elf-ld
OBJCOPY := $(TARGET_ARCH)-elf-objcopy
AS 	:= $(CC)

ROOT_DIR:= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
BUILD_DIR	:= $(ROOT_DIR)/build
CWARNINGS 	:= -Wall
CFLAGS		:= -ffreestanding -nostdlib -nostdinc -nostartfiles -Iinclude $(CWARNINGS)
LDFLAGS 	:= -T $(ROOT_DIR)/boards/$(TARGET_BOARD)/linker.ld -nostdlib

KERNEL_CFLAGS	:= $(CFLAGS)
KERNEL_SRCDIR	:= $(ROOT_DIR)/kernel
KERNEL_ASMSRC	:= $(shell find $(KERNEL_SRCDIR) -name "*.S")
KERNEL_CSRC	:= $(shell find $(KERNEL_SRCDIR) -name "*.c")
KERNEL_SRCS	:= $(KERNEL_CSRC) $(KERNEL_ASMSRC)
KERNEL_OBJS	:= $(patsubst $(KERNEL_SRCDIR)/%.S,$(BUILD_DIR)/$(TARGET_ARCH)/kernel/%_s.o,$(KERNEL_ASMSRC)) \
		   $(patsubst $(KERNEL_SRCDIR)/%.c,$(BUILD_DIR)/$(TARGET_ARCH)/kernel/%_c.o,$(KERNEL_CSRC))


ARCH_CFLAGS	:= $(CFLAGS)
ARCH_SRCDIR	:= $(ROOT_DIR)/arch/$(TARGET_ARCH)
ARCH_ASMSRC	:= $(shell find $(ARCH_SRCDIR) -name "*.S")
ARCH_CSRC	:= $(shell find $(ARCH_SRCDIR) -name "*.c")
ARCH_OBJS	:= $(patsubst $(ARCH_SRCDIR)/%.S,$(BUILD_DIR)/$(TARGET_ARCH)/$(TARGET_ARCH)/%_s.o,$(ARCH_ASMSRC)) \
		   $(patsubst $(ARCH_SRCDIR)/%.c,$(BUILD_DIR)/$(TARGET_ARCH)/$(TARGET_ARCH)/%_c.o,$(ARCH_CSRC))

BOARD_CFLAGS	:= $(CFLAGS)
BOARD_SRCDIR	:= $(ROOT_DIR)/boards/$(TARGET_BOARD)
BOARD_ASMSRC	:= $(shell find $(BOARD_SRCDIR) -name "*.S")
BOARD_CSRC	:= $(shell find $(BOARD_SRCDIR) -name "*.c")
BOARD_OBJS	:= $(patsubst $(BOARD_SRCDIR)/%.S,$(BUILD_DIR)/$(TARGET_ARCH)/boards/$(TARGET_BOARD)/%_s.o,$(BOARD_ASMSRC)) \
                   $(patsubst $(BOARD_SRCDIR)/%.c,$(BUILD_DIR)/$(TARGET_ARCH)/boards/$(TARGET_BOARD)/%_c.o,$(BOARD_CSRC))

OBJS	:= $(KERNEL_OBJS) $(ARCH_OBJS) $(BOARD_OBJS)

all: init $(BUILD_DIR)/$(TARGET_ARCH)/$(TARGET_NAME).img
	@echo
	@echo
	@echo "Build Completed"

init:
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(BUILD_DIR)/$(TARGET_ARCH)
	@echo "Target ARCH:	$(TARGET_ARCH)"
	@echo "Target Board:	$(TARGET_BOARD)"
	@echo "Target Name:	$(TARGET_NAME)"
	@echo "C Compiler:	$(CC)"
	@echo "Linker:		$(LD)"
	@echo "Build Path:	$(BUILD_DIR)"
	@echo
	@echo

$(BUILD_DIR)/$(TARGET_ARCH)/$(TARGET_NAME).elf: $(OBJS)
	@echo "Generating .elf file..."
	@echo "Linking $<"
	@$(LD) $(LDFLAGS) $^ -o $@

$(BUILD_DIR)/$(TARGET_ARCH)/$(TARGET_NAME).img: $(BUILD_DIR)/$(TARGET_ARCH)/$(TARGET_NAME).elf
	@echo "Copying $< to $@..."
	@$(OBJCOPY) -O binary $< $@

$(BUILD_DIR)/$(TARGET_ARCH)/kernel/%_c.o: $(KERNEL_SRCDIR)/%.c
	@echo "Compiling $@ from $<..."
	@mkdir -p $(dir $@)
	@$(CC) $(KERNEL_CFLAGS) -c $< -o $@

$(BUILD_DIR)/$(TARGET_ARCH)/kernel/%_s.o: $(KERNEL_SRCDIR)/%.S
	@echo "Compiling $@ from $<..."
	@mkdir -p $(dir $@)
	@$(AS) $(KERNEL_CFLAGS) -c $< -o $@

$(BUILD_DIR)/$(TARGET_ARCH)/$(TARGET_ARCH)/%_c.o: $(ARCH_SRCDIR)/%.c
	@echo "Compiling $@ from $<..."
	@mkdir -p $(dir $@)
	@$(CC) $(ARCH_CFLAGS) -c $< -o $@

$(BUILD_DIR)/$(TARGET_ARCH)/$(TARGET_ARCH)/%_s.o: $(ARCH_SRCDIR)/%.S
	@echo "Compiling $@ from $<..."
	@mkdir -p $(dir $@)
	@$(AS) $(ARCH_CFLAGS) -c $< -o $@

$(BUILD_DIR)/$(TARGET_ARCH)/boards/$(TARGET_BOARD)/%_c.o: $(BOARD_SRCDIR)/%.c
	@echo "Compiling $@ from $<..."
	@mkdir -p $(dir $@)
	@$(CC) $(BOARD_CFLAGS) -c $< -o $@

$(BUILD_DIR)/$(TARGET_ARCH)/boards/$(TARGET_BOARD)/%_s.o: $(BOARD_SRCDIR)/%.S
	@echo "Compiling $@ from $<..."
	@mkdir -p $(dir $@)
	@$(AS) $(BOARD_CFLAGS) -c $< -o $@

var-display:
	@echo $(ARCH_OBJS)
	@echo $(KERNEL_OBJS)
