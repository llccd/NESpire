CC = arm-none-eabi-gcc
LD = arm-none-eabi-ld
OBJCOPY = arm-none-eabi-objcopy

nespire.tns : nespire.elf
	$(OBJCOPY) -O binary $< $@

nespire.elf : main.o cpu.o debug.o memory.o ppu.o rom.o menu.o
	$(LD) -e main main.o cpu.o debug.o memory.o ppu.o rom.o menu.o -o $@

%.o : %.s
	$(CC) -mcpu=arm926ej-s -c $< -o $@

.PHONY : clean
clean :
	-rm -f *.o *.elf nespire.tns
