// Linux Boot Protocol - AArch64
// https://docs.kernel.org/arch/arm64/booting.html

.section ".text._start"
.global _start

.equ FLASH_KERNEL_ADDR,  0x000100000
.equ RAM_ADDR,           0x40000000
.equ DTB_ADDR,           0x40000000
.equ SPSR_EL2_MODE,      0x9  // EL2h, interrupts disabled (DAIF)

_start:
    msr DAIFSet, 0xF
    isb

    mrs x0, CurrentEL
    lsr x0, x0, #2            // Extract EL number

    cmp x0, #3                // EL3 ?
    b.eq el3_to_el2

    cmp x0, #2                // EL2 ?
    b.ne _kernel_init         // If not EL2 or EL3, skip EL2 setup

    b el2_setup               // If EL2, do EL2 setup directly

el3_to_el2:
    ldr x1, =SPSR_EL2_MODE
    msr spsr_el3, x1

    adr x1, _kernel_init
    msr elr_el3, x1

    eret

el2_setup:
    // ------------------------------------------------------------------------------
    // Clear HCR_EL2 to disable virtualization
    // ------------------------------------------------------------------------------
    mov x1, #0
    msr hcr_el2, x1
    isb

    // ------------------------------------------------------------------------------
    // Disable MMU and cache at EL2
    // ------------------------------------------------------------------------------
    mrs x1, SCTLR_EL2
    bic x1, x1, #1             // MMU off
    bic x1, x1, #(1 << 2)      // D-cache off
    bic x1, x1, #(1 << 12)     // I-cache off
    msr SCTLR_EL2, x1
    isb

_kernel_init:
    ldr x30, =stack_top
    mov sp, x30

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
    ldr x0, =DTB_ADDR
    mov x1, #0
    mov x2, #0
    mov x3, #0

    ldr x4, =RAM_ADDR
    ldr x5, =FLASH_KERNEL_ADDR
    ldr x5, [x5, #8]
    add x4, x4, x5
    br x4

    // ------------------------------------------------------------------------------
    // Stack area
    // ------------------------------------------------------------------------------
    .section ".bss"
    .align 16
stack_base:
    .space 4096
stack_top:
