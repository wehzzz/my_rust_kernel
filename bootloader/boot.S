// Linux Boot Protocol - AArch64
// https://docs.kernel.org/arch/arm64/booting.html

.section ".text._start"
.global _start

.equ FLASH_KERNEL_ADDR,  0x000100000
.equ RAM_ADDR,           0x40000000
.equ STACK_TOP,          0x40010000

_start:
    msr DAIFSet, 0xF
    isb

    ldr x0, =STACK_TOP
    mov sp, x0

    mrs x0, CurrentEL
    lsr x0, x0, #2            // Extract EL number

    cmp x0, #2                // EL2 ?
    b.ne _kernel_init         // If not EL2 or EL3, skip EL2 setup

    b el2_setup               // If EL2, do EL2 setup directly

el2_setup:
    // Disable MMU and cache at EL2
    mrs x1, SCTLR_EL2
    bic x1, x1, #1             // MMU off
    bic x1, x1, #(1 << 2)      // D-cache off
    bic x1, x1, #(1 << 12)     // I-cache off
    msr SCTLR_EL2, x1
    isb

    // Reset virtual timer offset
    msr CNTVOFF_EL2, xzr

    // Configure CNTHCTL_EL2 for EL1 access
    mrs x1, CNTHCTL_EL2
    orr x1, x1, #0x3           // Set EL1PCEN (bit 1) and EL1PCTEN (bit 0)
    msr CNTHCTL_EL2, x1

    // Disable virtual timer
    msr CNTV_CTL_EL0, xzr

    // Configure interrupt controller
    msr ICC_SRE_EL2, xzr       // Disable system register access
    msr ICH_HCR_EL2, xzr       // Disable interrupt virtualization
    isb

_kernel_init:
    bl _kernel_copy
    bl _kernel_start
    
_kernel_copy:
    ldr x0, =FLASH_KERNEL_ADDR

    ldr x5, [x0, #8]           // =TEXT_OFFSET
    ldr x1, =RAM_ADDR
    add x1, x1, x5

    ldr x2, [x0, #16]          // =KERNEL_SIZE from kernel header
1:
    ldr x3, [x0], #8
    str x3, [x1], #8
    subs x2, x2, #8
    b.ne 1b
    ret

_kernel_start:
    ldr x0, =RAM_ADDR
    mov x1, #0
    mov x2, #0
    mov x3, #0

    ldr x4, =RAM_ADDR
    ldr x5, =FLASH_KERNEL_ADDR
    ldr x5, [x5, #8]
    add x4, x4, x5
    br x4