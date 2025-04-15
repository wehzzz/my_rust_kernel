[bits 16] ;ensure 16-bit mode
[org 0x7C00] ;assembly code starts at 0x7C00

KERNEL_OFFSET equ 0x1000 ;kernel start address

start:
    cli ;disable interrupt