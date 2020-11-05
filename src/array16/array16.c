#include <unistd.h>
#include <stdint.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdio.h>

#define INP_ADDR 0x41200000
#define READ_INDEX 2

uint32_t* baseAddr;

void write16(uint8_t pos, uint16_t val)
{
    *baseAddr = 0x00100000 + (pos << 16) + val;
}

int read16(uint8_t pos)
{
    *baseAddr = 0x00000000 + (pos << 16);
    uint32_t val = baseAddr[READ_INDEX];
    return val;
}

int main(int argc, char* argv[])
{
    int devmem = open("/dev/mem", O_RDWR|O_SYNC);
	int pgsz = getpagesize();
	baseAddr = mmap(NULL, pgsz, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_SHARED, devmem, INP_ADDR);
    char msg[] = "this is a test!";
    char readMsg[16] = "\0";

    for(int i = 0; i <= 0xf; i++)
    {
        printf("Value at index %d is 0x%x\n", i, read16(i));
    }

    printf("Writing message into array\n");
    for(int i = 0; i <= 0xf; i++)
    {
        write16(i, msg[i]);
    }

    for(int i = 0; i <= 0xf; i++)
    {
        readMsg[i] = read16(i);
    }

    printf("Mesasge read from array: %s\n", readMsg);
    close(devmem);
    munmap(baseAddr, pgsz);
}
