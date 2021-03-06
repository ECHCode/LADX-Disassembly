.POSIX:

# If your default python is 3, you may want to change this to python27.
PYTHON = python

.SUFFIXES:
.SUFFIXES: .asm .o .gbc


# For now, we only need to build one rom (game.gbc).
all: game.gbc

clean: ;
	@rm -f $(obj)
	@rm -f game.{gbc,sym,map}

DumpBanks: tools/DumpBanks.c
	gcc -std=c99 -o DumpBanks tools/DumpBanks.c
	chmod a+x DumpBanks

bin/banks:
	mkdir -p bin/banks

bin/banks/bank_00_0.bin: bin/banks DumpBanks
	cd bin/banks && ../../DumpBanks ../../Zelda.gbc

# Objects are assembled from source.
# src/main.o is built from src/main.asm.
obj = src/main.o

src/main.o: src/*.asm src/constants/*.asm src/code/*.asm bin/banks/bank_00_0.bin

.asm.o:
	rgbasm -i src/ -o $@ $<

# Then we link them to create a playable image.
# This also spits out game.sym, which lets you use labels in bgb.
# Generating a mapfile is required thanks to a bug in rgblink.
game.gbc: $(obj)
	rgblink -n $*.sym -m $*.map -o $@ $(obj)
	rgbfix  -c -n 0 -r 0x03 -s -l 0x33 -k "01" -m 0x1B -j -p 0xFF -t "ZELDA" -v $@
	@md5sum -c ladx.md5
