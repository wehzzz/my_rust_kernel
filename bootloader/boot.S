.section .text._start
.global _start
.type _start, %function

.global kmain

_start:
    // Init stack
    ldr x0, =STACK_TOP
    mov sp, x0

    // Appel à __start (Rust entry point)
    bl kmain

    // Si __start retourne, boucle infinie
hang:
    wfe
    b hang

