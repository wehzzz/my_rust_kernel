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
    uart::print(b"ARM64 Linux-compatible kernel starting...\n");

    if dtb_addr != 0 {
        if (dtb_addr & 0x7) != 0 {
            uart::print(b"ERROR: DTB not 8-byte aligned\n");
        } else {
            uart::print(b"DTB found at: 0x");
            uart::print_hex(dtb_addr);
            uart::print(b"\n");

            let dtb_ptr = dtb_addr as *const u32;
            let magic = unsafe { core::ptr::read_volatile(dtb_ptr) };
            let magic_be = u32::from_be(magic);

            if magic_be == 0xd00dfeed {
                uart::print(b"DTB magic valid\n");
            } else {
                uart::print(b"WARNING: Invalid DTB magic: 0x");
                uart::print_hex(magic as u64);
                uart::print(b"\n");
            }
        }
    } else {
        uart::print(b"WARNING: No DTB provided (x0 = 0)\n");
    }

    let kernel_start = &ARM64_HEADER as *const _ as u64;
    uart::print(b"Kernel loaded at: 0x");
    uart::print_hex(kernel_start);
    uart::print(b" (text_offset: 0x");
    uart::print_hex(ARM64_HEADER.text_offset);
    uart::print(b")\n");

    // Verify we're at correct offset from 2MB boundary
    let base_2mb = kernel_start & !0x1fffff; // Mask to 2MB boundary
    let actual_offset = kernel_start - base_2mb;

    if actual_offset == ARM64_HEADER.text_offset {
        uart::print(b"Kernel correctly positioned at text_offset\n");
    } else {
        uart::print(b"WARNING: Kernel at wrong offset. Expected: 0x");
        uart::print_hex(ARM64_HEADER.text_offset);
        uart::print(b", Got: 0x");
        uart::print_hex(actual_offset);
        uart::print(b"\n");
    }

    uart::print(b"Kernel initialization complete - Boot protocol compliant\n");

    loop {
        unsafe {
            core::arch::asm!("wfe");
        }
    }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    uart::print(b"Panic!\n");
    loop {
    }
}
