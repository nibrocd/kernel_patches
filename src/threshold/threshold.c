#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/mman.h>
#include <fcntl.h>

#define LED_ADDR 0x41200000

int main(int argc, char* argv[])
{
	if (argc != 2)
	{
		printf("requires 1 integer arguement\n");
		return -1;
	}

	int thresh = atoi(argv[1]);

	int devmem = open("/dev/mem", O_RDWR|O_SYNC);
	int pgsz = getpagesize();
	uint32_t* mem = mmap(NULL, pgsz, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_SHARED, devmem, LED_ADDR);
	*mem = thresh;

	close(devmem);
	munmap(mem, pgsz);
	return 0;
}
