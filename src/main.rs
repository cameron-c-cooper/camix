#![no_std]
#![no_main]

use core::panic::PanicInfo;

mod io;
mod uart;

#[unsafe(no_mangle)]
pub extern "C" fn kernel_main(_multiboot_info_addr: usize) -> ! {
    uart::init();
    println!("kernel says hello!");
    loop { unsafe { core::arch::asm!("hlt") } }
}

#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    println!("PANIC: {}", info);
    loop { unsafe { core::arch::asm!("hlt") } }
}
