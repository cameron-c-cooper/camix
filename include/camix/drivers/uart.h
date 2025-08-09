#ifndef __CAMIX_DRIVER_UART_H
#define __CAMIX_DRIVER_UART_H

void uart_init(void);
void uart_send(unsigned int c);
char uart_getc();
void uart_puts(char *s);
// TODO: Implement uart_printf?

#endif
