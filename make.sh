nasm -fbin main.asm -o Rotozoomer.img

qemu-system-i386 -drive format=raw,file="Rotozoomer.img"
