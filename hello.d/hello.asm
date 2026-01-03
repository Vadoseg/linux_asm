section .data
    msg db "Hello, World!", 0xA ; db - define bytes (Reserves place for symbols, 0xA = \n)
    msg_len equ $ - msg         ; Count string len ($ - current position and msg as start of the msg string)

section .text
    global _start

_start:
    ; Step 1. Calling system call 'write' (sys_write)
    mov rax, 1 ; 1 - Number of syscall of write on x64
    mov rdi, 1 ; File descriptor (1 = stdout)
    mov rsi, msg ; Pointer to string
    mov rdx, msg_len
    syscall ; Call for Kernel

    ; Step 2. Call for system call 'exit'
    mov rax, 60 ; 60 - Number of syscall of exit
    mov rdi, 0  ; Return code (0)
    syscall     ; Kernel call