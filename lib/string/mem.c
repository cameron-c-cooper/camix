#include <string.h>
#include <stddef.h>
#include <camix/types.h>

void *memset(void *str, int c, size_t bytes) {
	for (size_t i = 0; i < bytes; i++) {
		((unsigned char *) str)[i] = (unsigned char) c;
	}
	return str;
}

void *memcpy(void *dst, const void *src, size_t bytes) {
	const char* s = (char *) src;
	char *d = (char *) dst;
	for (size_t i = 0; i < bytes; i++) {
		d[i] = s[i];
	}

	return dst;
}

void *memmove(void *dst, const void *src, size_t len) {
	unsigned char cpy[len];
	memcpy(cpy, src, len);
	return memcpy(dst, cpy, len);
}

void *memchr(const void *str, int c, size_t n) {
	u8 *ptr = (u8 *) str;
	u8 c_char = (u8) c;
	for (size_t i = 0; i < n; i++, ptr++) {
		if (*ptr == c_char) {
			return ptr;
		}
	}
	return NULL;
}

