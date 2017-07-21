CC = arm-linux-gnueabi-gcc
CFLAGS = -g -O0 -Wall -static

QEMU = qemu-arm

.PHONY: all clean test
	
all: agra

agra: agra.o agra_main.o framebuffer.o
	$(CC) $(CFLAGS) -o $@ $^

agra.o: agra.s
	$(CC) $(CFLAGS) -c $^
	
agra_main.o: agra_main.c agra.h framebuffer.c
	$(CC) $(CFLAGS) -c $^

clean:
	$(RM) agra agra.o agra_main.o

test: agra
	$(QEMU) agra

debug:
	$(QEMU) -g 24013 agra
