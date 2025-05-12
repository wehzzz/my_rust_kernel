.section ".text._start"
.global _start
_start:
    ldr x0, =STACK_TOP
    mov sp, x0
    bl kmain
.hang:
    b .hang
