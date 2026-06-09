#include <string.h>
#include <stddef.h>

char *strcat(char *restrict dst, const char *restrict src) {
	size_t i, j = 0;
	for (i = 0; dst[i] != '\0'; i++);
	for (j = 0; src[j] != '\0'; j++) {
		dst[i + j] = src[j];
	}
	dst[i + j] = '\0';
	return dst;
}

char *strcpy(char *restrict dst, const char *restrict src) {
	char *ret = dst;
	while (*src != '\0') {
		// var++ occurs after operation
		*dst++ = *src++;
	}
	*dst = 0;
	return ret;
}

char *strchr(const char *s, int c) {
	while (*s != (char) c) {
		if (*s++ == '\0') {
			return NULL;
		}
	}
	return (char *) s;

}


int strcmp(const char *s1, const char *s2) {
	while (*s1++ == *s2++) {
		if (*s1 == '\0') {
			return 0;
		}
	}
	return *s1 - *s2;
}
