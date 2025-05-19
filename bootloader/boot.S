// we define the symbol _start as the entry point of the program
.section ".text._start"
.global _start

// kernel size in byte to copy into the RAM
.equ KERNEL_SIZE, 360
// address containing the kernel in the flash
.equ FLASH_KERNEL_OFFSET,  0x000100000
// address of the RAM in QEMU where the kernel will be copied
.equ RAM_KERNEL_ADDR,      0x40080000

_start:
    // stack initialization
    ldr x30, =STACK_TOP
    mov sp, x30

    // loading kernel in RAM
    ldr x0, =FLASH_KERNEL_OFFSET    // source
    ldr x1, =RAM_KERNEL_ADDR        // destination
    ldr x2, =KERNEL_SIZE            // size

1:
    ldrb w3, [x0], #1
    strb w3, [x1], #1
    subs x2, x2, #1
    b.ne 1b

    // Sauter à l’entrée du kernel
    ldr x1, =RAM_KERNEL_ADDR
    br x1

