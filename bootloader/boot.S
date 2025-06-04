// Linux Boot Protocol - AArch64
// https://docs.kernel.org/arch/arm64/booting.html

.section ".text._start"
.global _start

.equ KERNEL_SIZE, 360
.equ FLASH_KERNEL_ADDR,  0x000100000
.equ RAM_KERNEL_ADDR,      0x40080000
.equ STACK_TOP, 0x40000000

_start:
    ldr x30, =STACK_TOP
    mov sp, x30

    bl _kernel_copy
    bl _kernel_start
    
_kernel_copy:
    ldr x0, =FLASH_KERNEL_ADDR
    ldr x1, =RAM_KERNEL_ADDR
    ldr x2, =KERNEL_SIZE
1:
    ldr x3, [x0], #8
    str x3, [x1], #8
    subs x2, x2, #8
    b.ne 1b
    ret

_kernel_start:
    ldr x0, #0                      // =DTB_ADDR
    mov x1, #0
    mov x2, #0
    mov x3, #0

    ldr x4, =RAM_KERNEL_ADDR
    br x4

