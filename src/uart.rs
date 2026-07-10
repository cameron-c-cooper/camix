use crate::io::{inb, outb};
use core::fmt;

const COM1: u16 = 0x3f8;

pub struct Serial {
    port: u16
}

impl Serial {
    pub unsafe fn init(port: u16) -> Self {
        unsafe {
            outb(port + 1, 0x00); // disable all interrupts
            outb(port + 3, 0x80); // enable DLAB (set baud rate divisor)
            outb(port + 0, 0x03); // divisor low byte -> 38400 baud
            outb(port + 1, 0x00); // divisor high byte
            outb(port + 3, 0x03); // 8 bits, no parity, one stop bit, DLAB off
            outb(port + 2, 0xc7); // enable FIFO, clear it, 14-byte threshold
            outb(port + 4, 0x0b); // IRQs enabled (unused for now), RTS/DSR set
     
            // Loopback test: make sure there's actually a working UART here
            // before we trust it, rather than silently writing into the void.
            outb(port + 4, 0x1e); // enable loopback mode
            outb(port + 0, 0xae); // send a test byte
            if inb(port + 0) != 0xae {
                // No usable serial port (e.g. weird QEMU config). Halt rather
                // than pretend output is working.
                loop {
                    asm_hlt();
                }
            }
            outb(port + 4, 0x0f);
            Serial { port }
        }
    }

    fn transmit_empty(&self) -> bool {
        unsafe { inb(self.port + 5) & 0x20 != 0 }
    }

    pub fn write_byte(&mut self, byte: u8) {
        while !self.transmit_empty() {}
        unsafe {
            outb(self.port, byte);
        }
    }
}

impl fmt::Write for Serial {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        for byte in s.bytes() {
            if byte == b'\n' {
                self.write_byte(b'\r');
            }
            self.write_byte(byte);
        }
        Ok(())
    }
}

fn asm_hlt() {
    unsafe { core::arch::asm!("hlt") };
}

// interrupts off assumption now. Once int handlers come into play need
// a spinlock or something
static mut SERIAL: Option<Serial> = None;

pub fn init() {
    unsafe {
        SERIAL = Some(Serial::init(COM1));
    }
}

#[allow(static_mut_refs)]
pub fn _print(args: fmt::Arguments) {
    use core::fmt::Write;
    unsafe {
        if let Some(serial) = SERIAL.as_mut() {
            serial.write_fmt(args).unwrap();
        }
    }
}

#[macro_export]
macro_rules! print {
    ($($arg:tt)*) => ($crate::uart::_print(format_args!($($arg)*)));
}

#[macro_export]
macro_rules! println {
    () => ($crate::print!("\n"));
    ($($arg:tt)*) => ($crate::print!("{}\n", format_args!($($arg)*)));
}
