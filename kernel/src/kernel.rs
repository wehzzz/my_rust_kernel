// disable the standard lib
#![no_std]
#![no_main]

mod config;

use config::header;
use config::uart;
// use the panic handler
use core::panic::PanicInfo;

#[unsafe(no_mangle)]
#[unsafe(link_section = ".text.header")]
pub static ARM64_HEADER: header::Arm64Header = header::Arm64Header::new();

#[unsafe(no_mangle)]
pub extern "C" fn _start(dtb_addr: u64, _reserved1: u64, _reserved2: u64, _reserved3: u64) -> ! {
    kmain(dtb_addr);
}

fn kmain(dtb_addr: u64) -> ! {
    if dtb_addr != 0 {
        uart::print(b"DTB found at: 0x");
        uart::print_hex(dtb_addr);
        uart::print(b"\n");
    } else {
        uart::print(b"Warning: No DTB provided\n");
    }
    uart::print(b"Kernel initialization complete\n");
    loop {
    }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    uart::print(b"Panic!\n");
    loop {
    }
}
