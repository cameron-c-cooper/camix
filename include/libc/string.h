#ifndef LIB_STRING_H
#define LIB_STRING_H

#include <stddef.h>
#include <camix/types.h>

#define NULL ((void *) 0)

void *memset(void *str, int c, size_t bytes);
void *memcpy(void *dst, const void *src, size_t bytes);
void *memmove(void *dst, const void *src, size_t len);
void *memchr(const void *str, int c, size_t n);

char *strcat(char *restrict dst, const char * restrict src);
char *strchr(const char *s, int c);
char *strcpy(char *restrict dst, const char * restrict src);
int strcmp(const char *s1, const char *s2);

#endif
