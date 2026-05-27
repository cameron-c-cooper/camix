#include <asm/x86/boot.h>
#include <asm/x86/cpuid.h>
#include <asm/x86/mm.h>
#include <asm/x86/gdt.h>
#include <asm/x86/vga.h>

/* For now, this will only target 64 bit. */

	/* The multiboot header is confirmed to be correct */
	.section .multiboot.header, "aw"
	.align 8
multiboot2_header_start:
	.long 0xe85250d6
	.long 0x0
	.long multiboot2_header_end - multiboot2_header_start
	.long -(0xe85250d6 + 0 + (multiboot2_header_end - multiboot2_header_start))
	/* TODO: Add multiboot tags for extra information/stuff from grub */
	/*
	.align 8

	.short 5
	.short 0
	.long 20
	.long 0
	.long 0
	.long 0

	.align 8
	*/
	.short 0 
	.short 0
	.long 8
multiboot2_header_end:

	.section .boot_stack, "aw", @nobits
stack_bottom:
	.skip 0x4000
stack_top:

.section .boot_gdt, "a"
GDT:
	.quad 0
	.word 0xffff
	.word 0
	.byte 0
	.byte PRESENT | NOT_SYS | EXEC | RW
	.byte GRAN_4K | LONG_MODE | 0xf
	.byte 0
	.word 0xffff
	.word 0
	.byte 0
	.byte PRESENT | NOT_SYS | RW
	.byte GRAN_4K | SZ_32 | 0xf
	.byte 0

GDT_Pointer:
        .word . - GDT - 1
        .long GDT

indirect_target:
	.long LM_Entrance
	.word 0x08
	
	.code32
	.section .multiboot.text, "a"
	.global _start
	.type _start, @function
	/* TODO: Macro out the 32 bit and 64 bit from each other */
_start:
	cli

	mov %eax, %esi
	mov %ebx, %ebp

	mov $stack_top, %esp
	call check_cpuid

	pushl %eax
	pushl %ebx

	mov $CPUID_EXTENSIONS, %eax
	cpuid
	cmp $CPUID_EXT_FEATURES, %eax
	# jb .no_lm

	mov $CPUID_EXT_FEATURES, %eax
	cpuid
	test $CPUID_EDX_EXT_FEAT_LM, %eax
	# jz .no_lm

	/* Have to setup gdt before paging due to compaitibility mode bs */
	movl $GDT_Pointer, %eax
	lgdt (%eax) 

	/* 64 bit paging uses PAE with an extra level, so
		PML4T	(Page Map Level 4 Table)
		PDPT 	(Page Directory Pointer Table)
		PDT		(Page Directory Table)
		PT		(Page Table)
	   Each entry in a 64 bit page table is double the size of an equivalent 
	   32 bit entry. Thus, each table can only hold 512 entries instead of
	   1024. One entry in the PT can address 4 KiB, each table is 4 KiB long.
	   Thus, the maximum address space is 256 TiB. Each level of page tables
	   simply contains pointers to the ones below, so each level refers to a
	   more granular range of virtual addresses that the MMU uses to map each
	   page to a physical address. For now, we will simply use 0x1000 as the
	   beginning of the PML4T and each level below is contigous with 4 KiB inc.
	*/
	mov $PML4T_ADDR, %edi
	mov %edi, %cr3
	xor %eax, %eax
	/* 0x1c00 word is equivalent to 0x700 bytes */
	mov $0x1c00, %ecx
	rep stosl
	movl %cr3, %edi

	/* 
	  Linking the first entries of each table, 2 MB doesnt go over 1 PDT entry
	*/
	movl $(LO_PDPT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE), (%edi)
	mov $LO_PDPT_ADDR, %edi
	movl $(LO_PDT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE), (%edi)
	mov $LO_PDT_ADDR, %edi
	movl $(LO_PT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE), (%edi)

	mov $LO_PT_ADDR, %edi
	mov $(PT_PRESENT | PT_READABLE), %ebx
	mov $ENTRIES_PER_PT, %ecx

.set_entry_low:
	mov %ebx, (%edi) 
	add $PAGE_SIZE, %ebx
	add $SIZEOF_PT_ENTRY, %edi
	loop .set_entry_low
	/* Low memory paging done */

	/* kmain placed at approx 0xffffffff80105000 */
	mov $PML4T_ADDR, %edi
	add $(PML4_HIGH_IDX * SIZEOF_PT_ENTRY), %edi
	/* establish new PDPT table at higher address */
	movl $(HI_PDPT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE), (%edi)

	mov $HI_PDPT_ADDR, %edi
	add $(PDPT_HIGH_IDX * SIZEOF_PT_ENTRY), %edi
	movl $(HI_PDT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE), (%edi)

	mov $HI_PDT_ADDR, %edi
	movl $(HI_PT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE), (%edi)

	mov $HI_PT_ADDR, %edi
	mov $(PT_PRESENT | PT_READABLE), %ebx
	mov $ENTRIES_PER_PT, %ecx
.set_entry_high:
	mov %ebx, (%edi)
	add $PAGE_SIZE, %ebx
	add $SIZEOF_PT_ENTRY, %edi
	loop .set_entry_high
	
	mov %cr4, %eax
	or $CR4_PAE_ENABLE, %eax
	mov %eax, %cr4

	/* TODO: Thinik about PML5 */

	mov $EFER_MSR, %ecx
	rdmsr
	or $EFER_LM_ENABLE, %eax
	wrmsr
	
	mov %cr0, %eax
	or $(CR0_PG_ENABLE | CR0_PM_ENABLE), %eax
	mov %eax, %cr0
	
	ljmp *indirect_target

check_cpuid:
	pushfl
	popl %eax
	movl %eax, %ecx
	xor $EFLAGS_ID, %eax

	push %eax
	popfl
	pushfl
	popl %eax

	pushl %ecx
	popfl

	xor %ecx, %eax
	jnz .supported
	/* TODO: Add further support for more in depth error messages */
	.not_supported:
		mov $0, %ax
		ret
	.supported:
		mov $1, %ax
		ret

/* Still in the low section of memory */
.section .lm_entry, "ax"
.code64
LM_Entrance:
	mov $0x10, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	mov %ax, %ss

	mov $VGA_TEXT_BUFFER_ADDR, %rdi
	mov $0, %rax
	mov $(VGA_TEXT_BUFFER_SIZE >> 3), %rcx
	rep stosq

	mov %rsi, %rdi
	mov %rbp, %rsi
	
	/* x86_64 System V ABI defines rdi and rsi for first two params */
	/*
	mov %rax, %rdi
	mov %rbx, %rsi
	*/

	/* 
		For now, do not zero out the frame pointer. It can help carry
	   	the multiboot2 information inside of it.
	*/
	mov $stack_top, %rsp
	/* zero out the frame pointer, we need new call stack root */
	xor %rbp, %rbp

.extern kmain
	call kmain

/* just in case kernel_main magically returns */
.hang:
	cli
	hlt
	jmp .hang
