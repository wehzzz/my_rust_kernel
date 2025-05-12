.section ".text._start"

.global _start
_start:
    mov x0, #0x09000000
    mov x1, #'A'
    strb w1, [x0]
    b .
    ldr x30, =STACK_TOP
    mov sp, x30
    bl _start
.hang:
    b .hang
