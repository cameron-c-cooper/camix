.global _start

.extern main

section .text
_start:
#ifdef CONFIG_BITS_32
#else
	mov $main, %rdi
	pop %rsi
	mov %rsp, %rdx
#endif
	call main
	
