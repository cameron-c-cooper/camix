#ifndef __CAMIX_DRIVER_UART_H
#define __CAMIX_DRIVER_UART_H
#include <stdint.h>
#include <stddef.h>

int serial_init(void);
void serial_write_byte(uint8_t byte);
void serial_write(const char *s);
void serial_write_len(const char *s, size_t n);
void serial_printf(const char *fmt, ...);

#endif
