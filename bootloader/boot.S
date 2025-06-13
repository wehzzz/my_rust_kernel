// Linux Boot Protocol - AArch64
// https://docs.kernel.org/arch/arm64/booting.html

.section ".text._start"
.global _start

.equ FLASH_KERNEL_ADDR,   0x000100000
.equ RAM_ADDR,     0x40000000

_start:
    ldr x30, =stack_top
    mov sp, x30

    bl _kernel_copy
    bl _kernel_start
    
_kernel_copy:
    ldr x0, =FLASH_KERNEL_ADDR

    ldr x5, [x0, #8]                // =TEXT_OFFSET
    ldr x1, =RAM_ADDR
    add x1, x1, x5

    ldr x2, [x0, #16]               // =KERNEL_SIZE from kernel header
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

    ldr x4, =RAM_ADDR
    ldr x5, =FLASH_KERNEL_ADDR
    ldr x5, [x5, #8]
    add x4, x4, x5
    br x4

