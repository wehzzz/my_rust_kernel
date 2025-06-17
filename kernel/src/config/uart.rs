use core::ptr::write_volatile;

const UART: *mut u8 = 0x0900_0000 as *mut u8;

fn putchar(c: u8) {
    unsafe {
        let uart_fr = ((UART as usize) + 0x18) as *const u32;
        while (*uart_fr & (1 << 5)) != 0 {}
        write_volatile(UART, c);
    }
}

pub fn print(s: &[u8]) {
    for &c in s {
        putchar(c);
    }
}

pub fn print_hex(value: u64) {
    let hex_chars = b"0123456789abcdef";
    for i in (0..16).rev() {
        let digit = ((value >> (i * 4)) & 0xf) as usize;
        print(&[hex_chars[digit]]);
    }
}
