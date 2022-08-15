AS = nspire-as
LD = $(shell nspire-tools _toolchainpath)/arm-none-eabi-ld
GENZEHN = genzehn

OBJS = $(patsubst %.S, %.o, $(shell find . -name \*.S))
EXE = nespire

all: $(EXE).tns

$(EXE).tns: $(EXE).elf
	$(GENZEHN) --input $^ --output $@ --compress

$(EXE).elf: $(OBJS)
	$(LD) --pic-veneer --emit-relocs -T $(shell nspire-tools path)/system/ldscript -e main $^ -o $@

%.o: %.S
	$(AS) -c $<

.PHONY: clean
clean:
	-rm -f *.o $(EXE).elf $(EXE).tns
