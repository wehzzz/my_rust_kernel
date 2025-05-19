// disable the standard lib
#![no_std]
#![no_main]
// use the panic handler
use core::panic::PanicInfo;
// we need this in the case we write the same char twice and because of compiler opti
use core::ptr::write_volatile;

const UART: *mut u8 = 0x0900_0000 as *mut u8;

#[unsafe(no_mangle)]
pub extern "C" fn kmain() -> ! {
    print(b"Hello, from Rust!\n");
    loop {
        
    }
}

fn putchar(c: u8) {
    unsafe {
        let uart_fr = (UART as usize + 0x18) as *const u32; // UART Flag Register
        while (*uart_fr & (1 << 5)) != 0 {} // Attendre que le FIFO de transmission soit vide
        write_volatile(UART, c);
    }
}

fn print(s: &[u8]) {
    for &c in s {
        putchar(c);
    }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    print(b"Panic!\n");
    loop {}
}
