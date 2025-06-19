ENTRY(_start)
OUTPUT_FORMAT(elf64-littleaarch64)
OUTPUT_ARCH(aarch64)

TEXT_START = 0x40080000;

SECTIONS {
    . = TEXT_START;

    .text.header : {
        KEEP(*(.text.header))
        . = ALIGN(64);
    }

    .text : ALIGN(64) {
        *(.text._start)
        *(.text .text.*)
    }

    .rodata : ALIGN(16) {
        *(.rodata .rodata.*)
    }

    .data : ALIGN(16) {
        *(.data .data.*)
    }
    
    .bss : ALIGN(16) {
        __bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        __bss_end = .;
    }
}