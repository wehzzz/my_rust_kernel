[bits 16] ;ensure 16-bit mode
[org 0x7C00] ;assembly code starts at 0x7C00

KERNEL_OFFSET equ 0x1000 ;kernel start address

jump 0x0000:start

start:
    cli ;disable interrupt
    xor ax, ax ;clear ax
    mov ds, ax ;set data segment to 0
    mov es, ax ;set extra segment to 0
    mov ss, ax ;set stack segment to 0
    mov fs, ax ;set fs segment to 0
    mov gs, ax ;set gs segment to 0
    mov sp, 0x7C00 ;set stack pointer to 0x7C00