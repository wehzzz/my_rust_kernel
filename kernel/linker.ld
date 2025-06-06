ENTRY(kmain)
OUTPUT_FORMAT(elf64-littleaarch64)
OUTPUT_ARCH(aarch64)

FLASH_START = 0x000100000;
RAM_START = 0x40000000;
TEXT_START = 0x40080000;

SECTIONS {
    . = FLASH_START;
    . = RAM_START;
    . = TEXT_START;

    .text.header : {
        KEEP(*(.text.header))
        . = ALIGN(64);
    }

    .text : {
        *(.text)
        *(.text.*)
        *(.rodata)
        *(.rodata.*)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(.bss COMMON)
    }

    . = ALIGN(0x1000);
    TTBR0_SPACE = .;
    . += 8192*8;
    TTBR0_SPACE_END = .;
    . = ALIGN(0x1000);
    TTBR1_SPACE = .;
    . += 8192*8;
    TTBR1_SPACE_END = .;

    . = ALIGN(8);
    . = 0x7fff0000;
}
