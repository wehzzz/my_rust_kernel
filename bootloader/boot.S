.section ".text._start"
.global _start
_start:
    ldr x30, =STACK_TOP
    mov sp, x30
    bl kmain
.hang:
    b .hang
