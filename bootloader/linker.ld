ENTRY(_start)
OUTPUT_FORMAT(elf64-littleaarch64)
OUTPUT_ARCH(aarch64)

MEMORY
{
    RAM (rwx) : ORIGIN = 0x00080000, LENGTH = 128M
}

SECTIONS
{
    . = ORIGIN(RAM);

    /* Code + rodata */
    .text : ALIGN(4)
    {
        _text_start = .;
        KEEP(*(.text._start))     /* Point d’entrée */
        *(.text)                  /* Code */
        *(.text.*)
        *(.rodata)                /* Constantes */
        *(.rodata.*)
        _text_end = .;
    } > RAM

    /* Données initialisées */
    .data : ALIGN(4)
    {
        _data_start = .;
        *(.data)
        *(.data.*)
        _data_end = .;
    } > RAM

    /* Données non initialisées (zéro) */
    .bss (NOLOAD) : ALIGN(4)
    {
        _bss_start = .;
        *(.bss)
        *(COMMON)
        _bss_end = .;
    } > RAM

    /* Espaces pour la pagination */
    . = ALIGN(0x1000);
    TTBR0_SPACE = .;
    . += 8192 * 8;
    TTBR0_SPACE_END = .;

    . = ALIGN(0x1000);
    TTBR1_SPACE = .;
    . += 8192 * 8;
    TTBR1_SPACE_END = .;

    /* Pile (stack) en haut de la RAM */
    . = ALIGN(8);
    . = ORIGIN(RAM) + LENGTH(RAM) - 0x10000;
    STACK_TOP = .;
}

