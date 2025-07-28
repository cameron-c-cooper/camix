#include <camix/drivers/uart.h>

void kmain() {
    uart_init();
    uart_puts("Hello, World!\n");
    while(1) {
	uart_send(uart_getc());
    }
}
