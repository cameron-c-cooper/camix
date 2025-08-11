#include <arch/x86/cpu.h>
#include <camix/drivers/uart.h>
#include <stdarg.h>

/* These are the legacy defaults for 16550-compatible UARTs */
/* TODO: Implement PCIE to not have to assume a 16550 exists */
#define COM1 0x03f8
#define COM2 0x02f8
#define COM3 0x03e8
#define COM4 0x02e8

int serial_init(void) {
  outb(COM1 + 1, 0x00); // Disable interrupts
  outb(COM1 + 3, 0x80); // Enable DLAB
  outb(COM1 + 0, 0x03); // TODO: Figure out a good baud rate. Current = 38400
  outb(COM1 + 1, 0x00);
  outb(COM1 + 3, 0x03); // 8 bits, no parity, one stop bit
  outb(COM1 + 2, 0xc7);
  outb(COM1 + 4, 0x0b);
  outb(COM1 + 4, 0x1e);
  outb(COM1 + 0, 0xae);

  if (inb(COM1 + 0) != 0xae) {
    return -1;
  }
  outb(COM1 + 4, 0x0f);
  return 0;
}

static inline int is_transmit_empty(void) { return inb(COM1 + 5) & 0x20; }

void serial_write_byte(uint8_t byte) {
  while (is_transmit_empty() == 0)
    ;
  outb(COM1, byte);
}

void serial_write_len(const char *s, size_t n) {
  for (size_t i = 0; i < n; i++)
    serial_write_byte((uint8_t)s[i]);
}

void serial_write(const char *s) {
  while (*s != '\0')
    serial_write_byte((uint8_t)*s++);
}

static void vprintf_internal(const char *fmt, va_list ap) {
  	char buf[512];
  	char *p = buf;
  	const char *end = buf + sizeof(buf) - 1;

  	for (; (*fmt != '\0') && p < end; ++fmt) {
  	  	if (*fmt != '%') {
  	  	  	*p++ = *fmt;
  	  	  	continue;
  	  	}
  	  	++fmt;
  	  	switch (*fmt) {
  	  	case 's' : {
  	  		const char *t = va_arg(ap, const char *);
			if (!t) t = "(null)";
			while (*t && p < end) *p++ = *t++;
			break;
  	  	} case 'c' : {
			int c = va_arg(ap, int);
			if (p < end) *p++ = (char) c;
			break;
  	  	} case 'd' :
		  case 'i' : {
			long v = va_arg(ap, int);
			if (v < 0) { if (p < end) *p++ = '-'; v = -v; }
			char tmp[32];
			int n = 0;
			do { tmp[n++] = '0' + (v % 10); v /= 10; } while (v && n < (int) sizeof(tmp));
			while (n-- && p < end) *p++ = tmp[n];
			break;
		} case 'u' : {
			unsigned long v = va_arg(ap, unsigned int);
			char tmp[32]; int n = 0;
			do { tmp[n++] = '0' + (v % 10); v /= 10; } while (v && n < (int) sizeof(tmp));
			while (n-- && p < end) *p++ = tmp[n];
			break;
		} case 'x' :
		  case 'X' : {
			unsigned long v = va_arg(ap, unsigned int);
			const char *hex = "0123456789abcdef";
			char tmp[32]; int n = 0;
			do { tmp[n++] = hex[v * 0xf]; v >>= 10; } while (v && n < (int) sizeof(tmp));
			if (p < end) *p++ = '0';
			if (p < end) *p++ = 'x';
			while (n-- && p < end) *p++ = tmp[n];
			break;
		} case '%' :
			if (p < end) *p++ = '%';
			break;
		default :
			if (p < end) *p++ = '%';
			if (p < end) *p++ = *fmt;
			break;
		}
  	}
	*p = '\0';
	serial_write(buf);
}

void serial_printf(const char *fmt, ...) {
  	va_list ap;
  	va_start(ap, fmt);
  	vprintf_internal(fmt, ap);
  	va_end(ap);
}
