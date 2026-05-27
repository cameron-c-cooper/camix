.code64
.global reload_gdt
.section .text

reload_gdt:
	push $0x08
	lea (.reload_CS), %rax
	push %rax
	retfq

.reload_CS:
	mov $0x10, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %ss
	xor %ax, %ax
	mov %ax, %fs
	mov %ax, %gs
	ret
