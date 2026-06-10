.altmacro

#define __isr_err_stub(x) \
isr_stub_##x: \
	pushq $##x;\
	jmp isr_common;\

#define __isr_no_err_stub(x) \
isr_stub_##x: \
	pushq $0;\
	pushq $##x;\
	jmp isr_common

#define __irq_stub(x) \
irq_stub_##x: \
	pushq $0; \
	pushq $##x;\
	jmp isr_common

.extern exception_handler

isr_common:
    pushq %rax
    pushq %rbx
    pushq %rcx
    pushq %rdx
    pushq %rsi
    pushq %rdi
    pushq %rbp
    pushq %r8
    pushq %r9
    pushq %r10
    pushq %r11
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15

	movq %rsp, %rdi # pass pointer to stack frame as first arg
	call exception_handler

    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %r11
    popq %r10
    popq %r9
    popq %r8
    popq %rbp
    popq %rdi
    popq %rsi
    popq %rdx
    popq %rcx
    popq %rbx
    popq %rax
	addq $16, %rsp

	iretq

__isr_no_err_stub(0)
__isr_no_err_stub(1)
__isr_no_err_stub(2)
__isr_no_err_stub(3)
__isr_no_err_stub(4)
__isr_no_err_stub(5)
__isr_no_err_stub(6)
__isr_no_err_stub(7)
__isr_err_stub(8)
__isr_no_err_stub(9)
__isr_err_stub(10)
__isr_err_stub(11)
__isr_err_stub(12)
__isr_err_stub(13)
__isr_err_stub(14)
__isr_no_err_stub(15)
__isr_no_err_stub(16)
__isr_err_stub(17)
__isr_no_err_stub(18)
__isr_no_err_stub(19)
__isr_no_err_stub(20)
__isr_no_err_stub(21)
__isr_no_err_stub(22)
__isr_no_err_stub(23)
__isr_no_err_stub(24)
__isr_no_err_stub(25)
__isr_no_err_stub(26)
__isr_no_err_stub(27)
__isr_no_err_stub(28)
__isr_no_err_stub(29)
__isr_err_stub(30)
__isr_no_err_stub(31)
__irq_stub(32)

.section .rodata
.global isr_stub_table
isr_stub_table:
	.quad isr_stub_0
	.quad isr_stub_1
	.quad isr_stub_2
	.quad isr_stub_3
	.quad isr_stub_4
	.quad isr_stub_5
	.quad isr_stub_6
	.quad isr_stub_7
	.quad isr_stub_8
	.quad isr_stub_9
	.quad isr_stub_10
	.quad isr_stub_11
	.quad isr_stub_12
	.quad isr_stub_13
	.quad isr_stub_14
	.quad isr_stub_15
	.quad isr_stub_16
	.quad isr_stub_17
	.quad isr_stub_18
	.quad isr_stub_19
	.quad isr_stub_20
	.quad isr_stub_21
	.quad isr_stub_22
	.quad isr_stub_23
	.quad isr_stub_24
	.quad isr_stub_25
	.quad isr_stub_26
	.quad isr_stub_27
	.quad isr_stub_28
	.quad isr_stub_29
	.quad isr_stub_30
	.quad isr_stub_31
	.quad irq_stub_32
