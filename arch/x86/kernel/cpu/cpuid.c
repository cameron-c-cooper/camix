#include "camix/types.h"
#include <arch/x86/cpuid.h>

void cpuid_get_vendor(char vendor[12+1]) {
	u32 ebx = 0, edx = 0, ecx = 0;
	__asm__ volatile (
			"mov $0, %%eax;" 
		 	"cpuid"
			: "=b" (ebx), "=d" (edx), "=c" (ecx)
			:
			:
	);
	*(u32 *)(vendor) = ebx;
	*(u32 *)(vendor + 4) = edx;
	*(u32 *)(vendor + 8) = ecx;
	vendor[12] = '\0';
}

