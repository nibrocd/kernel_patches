#include <unistd.h>
#include <stdint.h>
#include <sys/mman.h>
#include <fcntl.h>

#define LED_ADDR 0x41200000

int main(int argc, char* argv[])
{
	int devmem = open("/dev/mem", O_RDWR|O_SYNC);
	int pgsz = getpagesize();
	uint32_t* mem = mmap(NULL, pgsz, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_SHARED, devmem, LED_ADDR);
	*mem = 0x1;
	sleep(1);

	int sec = 0;
	while(sec < 30)
	{
		if(*mem == 0x8)
			*mem = 0x1;

		else
			*mem = *mem << 1;

		sleep(1);
		sec++;
	}

	*mem = 0x0;
	sleep(1);
	*mem = 0xf;
	close(devmem);
	munmap(mem, pgsz);
	return 0;
}
