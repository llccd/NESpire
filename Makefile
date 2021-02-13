PREFIX=arm-none-eabi-

nespire.tns : nespire.elf
	$(PREFIX)objcopy -Obinary $< $@

nespire.elf : main.o cpu.o debug.o memory.o ppu.o rom.o menu.o
	$(PREFIX)ld main.o cpu.o debug.o memory.o ppu.o rom.o menu.o -o $@

%.o : %.S
	$(PREFIX)gcc -c $< -o $@
