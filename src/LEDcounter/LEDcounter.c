#include <unistd.h>
#include <stdint.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>

#define LED_ADDR 0x41210000

int main(int argc, char* argv[])
{
	if(argc != 2)
	{
		printf("This program an integer arguement as the frequency to set for the LED counter\n The frequency can be between 5MHz and 0.009313 Hz using the 10MHz base clock and a 30 bit divider\n");
		return -1;
	}

	float freq = strtod(argv[1], NULL);
	if(freq < 0.009313 || freq > 50000000)
	{
		printf("Frequency must be between 5MHz and 0.009313 Hz");
		return -1;
	}

	uint32_t div = 10000000/freq;
	printf("divider is %d\n", div);

	int devmem = open("/dev/mem", O_RDWR|O_SYNC);
	int pgsz = getpagesize();
	uint32_t* mem = mmap(NULL, pgsz, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_SHARED, devmem, LED_ADDR);
	*mem = div;

	close(devmem);
	munmap(mem, pgsz);
	return 0;
}
