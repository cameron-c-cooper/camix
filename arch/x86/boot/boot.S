#include <asm/multiboot2.h>

	/* The multiboot header is confirmed to be correct */
	.section .multiboot.header, "aw"
	.align 8
multiboot2_header_start:
	.long 0xe85250d6
	.long 0x0
	.long multiboot2_header_end - multiboot2_header_start
	.long -(0xe85250d6 + 0 + (multiboot2_header_end - multiboot2_header_start))
	/* TODO: Add multiboot tags for extra information/stuff from grub */

	.short 0 
	.short 0
	.long 8
multiboot2_header_end:

	.section .boot_stack, "aw", @nobits
stack_bottom:
	.skip 0x4000
stack_top:

	.section .bss, "aw", @nobits
	.align 0x1000
boot_page_directory:
	.skip 0x1000
boot_page_table1:
	.skip 0x1000
// TODO: Add more page tables if kernel grows beyong 3 MiB

	.section .multiboot.text, "a"
	.global _start
	.type _start, @function
_start:
	movl $(boot_page_table1 - KERNEL_VMA), %edi
	movl $0, %esi
	movl $1023, %ecx

1:
	cmpl $_kernel_start, %esi
	jl 2f
	cmpl $(_kernel_end - KERNEL_VMA), %esi
	jge 3f

	movl %esi, %edx
	orl $0x003, %edx
	movl %edx, (%edi)

2:
	addl $0x1000, %esi
	addl $4, %edi
	loop 1b

3:
	/* Map VGA mem to 0xc03ff000 as PRESENT | WRITE */
	movl $(0x000b8000 | 0x003), boot_page_table1 - KERNEL_VMA + 1023 * 4

	movl $(boot_page_table1 - KERNEL_VMA + 0x003), boot_page_directory - KERNEL_VMA + 0
	movl $(boot_page_table1 - KERNEL_VMA + 0x003), boot_page_directory - KERNEL_VMA + 768 * 4

	movl $(boot_page_directory - KERNEL_VMA), %ecx
	movl %ecx, %cr3

	movl %cr0, %ecx
	orl $0x80010000, %ecx
	movl %ecx, %cr0

	lea 4f, %ecx
	jmp *%ecx

	.section .text
4:
	// unmap the identitiy mapping
	movl $0x00, boot_page_directory + 0
	movl %cr3, %ecx
	movl %ecx, %cr3
	mov $stack_top, %esp
	call kernel_main

	cli
1:	hlt
	jmp 1b
