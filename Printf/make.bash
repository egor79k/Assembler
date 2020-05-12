#!/bin/bash
nasm -f elf64 printf.asm
nasm -f elf64 main.asm
ld main.o printf.o -o main