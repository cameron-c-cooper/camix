#ifndef ASM_GDT_H
#define ASM_GDT_H

/* Access bits */
.equ PRESENT, 	(1 << 7)
.equ NOT_SYS, 	(1 << 4)
.equ EXEC, 		(1 << 3)
.equ DC, 		(1 << 2)
.equ RW, 		(1 << 1)
.equ ACCESSED,	(1 << 0)

/* Flag bits */
.equ GRAN_4K, 	(1 << 7)
.equ SZ_32,		(1 << 6)
.equ LONG_MODE, (1 << 5)

#endif
