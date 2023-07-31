nasm -f elf64 -g -F DWARF -o build/tiktaktoe.o tiktaktoe.asm
ld -e _start -o build/tiktaktoe build/tiktaktoe.o
