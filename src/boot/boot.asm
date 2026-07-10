section .multiboot
align 8
mb_header_start:
	dd 0xe85250d6
	dd 0
	dd mb_header_end - mb_header_start
	dd -(0xe85250d6 + 0 + (mb_header_end - mb_header_start)) & 0xffffffff

	align 8
	dw 0
	dw 0
	dd 8
mb_header_end:

section .text.boot
bits 32

global _start
extern start64
_start:
	cli
	mov esp, stack_top_low
	mov ebp, esp
	mov [mb_info_ptr], ebx
	mov [mb_magic], eax
	call check_multiboot
	call check_cpuid
	call check_long_mode
	call set_up_page_tables
	call enable_paging
	lgdt [gdt64.pointer]
	jmp gdt64.code_segment:long_mode_start

	hlt

check_multiboot:
	cmp dword [mb_magic], 0x36d76289
	jne .fail
	ret
.fail:
	mov al, "M"
	jmp error

check_cpuid:
	pushfd
	pop eax
	mov ecx, eax
	xor eax, 1 << 21
	push eax
	popfd
	pushfd
	pop eax
	push ecx
	popfd
	cmp eax, ecx
	je .fail
	ret
.fail:
	mov al, "C"
	jmp error

check_long_mode:
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001
	jb .fail
	mov eax, 0x80000001
	cpuid
	test edx, 1 << 29
	jz .fail
	ret
.fail:
	mov al, "L"
	jmp error

; al = single letter error code
error:
	mov dword [0xb8000], 0x4f524f45 ; "ER"
	mov dword [0xb8004], 0x4f3a4f52 ; "R:"
	mov byte  [0xb8008], al
	mov byte  [0xb8009], 0x4f
	hlt

set_up_page_tables:
	; P4[0] -> p3_table_low
	mov eax, p3_table_low
	or  eax, 0b11 ; present | writable
	mov [p4_table], eax

	; P4[511] -> p3_table_high
	mov eax, p3_table_high
	or  eax, 0b11
	mov [p4_table + 511 * 8], eax

	; p3_table_low[0] -> p2_table
	mov eax, p2_table
	or eax, 0b11
	mov [p3_table_low], eax

	; p3_table_high[510] -> p2_table
	mov eax, p2_table
	or eax, 0b11
	mov [p3_table_high + 510 * 8], eax

	; fill p2_table with 512 x 2 MiB huge pages covering phys 0..1GiB
	mov ecx, 0
.map_p2_table:
	mov eax, 0x200000
	mul ecx
	or eax, 0b10000011 ; present | writable | huge (2 MiB)
	mov [p2_table + ecx * 8], eax
	
	inc ecx
	cmp ecx, 512
	jne .map_p2_table
	ret

enable_paging:
	mov eax, p4_table
	mov cr3, eax

	mov eax, cr4
	or eax, 1 << 5
	mov cr4, eax

	mov ecx, 0xc0000080
	rdmsr
	or eax, 1 << 8
	wrmsr

	mov eax, cr0
	or eax, 1 << 31
	mov cr0, eax
	ret

bits 64
long_mode_start:
	mov ax, 0
	mov ss, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	mov rax, start64
	jmp rax

section .bss.boot
align 0x1000
p4_table:	resb 0x1000
p3_table_low:	resb 0x1000
p3_table_high:	resb 0x1000
p2_table:	resb 0x1000

align 16
stack_bottom_low:
	resb 0x4000
stack_top_low:

mb_info_ptr: 	resd 1
mb_magic:	resd 1

section .rodata.boot
align 16
gdt64:
	dq 0
.code_segment: equ $ - gdt64
	dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53) ; exec,code/data,p,lm
.pointer:
	dw $ - gdt64 - 1
	dq gdt64

section .text
bits 64
global start64
extern kernel_main
start64:
	mov rsp, stack_top
	mov rbp, rsp
	xor rbp, rbp

	mov edi, [mb_info_ptr]
	call kernel_main

.hang:
	cli
	hlt
	jmp .hang

section .bss
align 16
stack_bottom:
	resb 0x10000
stack_top:
