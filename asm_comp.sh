#!/bin/bash

if [[ ${1##*.} != "asm" ]]; then
    echo "Файл должен иметь расширение .asm"
    exit 1
fi

FILE=${1%.*}

nasm -f elf64 $FILE.asm -o $FILE.o
ld $FILE.o -o $FILE
rm $FILE.o