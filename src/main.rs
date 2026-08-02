#![no_std]
#![no_main]

use core::panic::PanicInfo;
use crate::x86::gdt;
use crate::io::outb;

mod io;
mod uart;
mod x86;
mod logging;

#[unsafe(no_mangle)]
pub extern "C" fn kernel_main(_multiboot_info_addr: usize) -> ! {
    uart::init();
    info!("KERNEL INIT");
    gdt::init();
    debug!("GDT INIT");
    debug!("GDT LOCATION: {:?}", &raw const gdt::GDT);

    unsafe { outb(0xf4, 0x00) };
    loop { unsafe { core::arch::asm!("hlt") } }
}

#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    println!("PANIC: {}", info);
    unsafe { outb(0xf4, 0x00) }; // qemu shutdown
    loop { unsafe { core::arch::asm!("hlt") } }
}
