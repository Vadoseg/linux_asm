%define BUF_SIZE 256

section .bss ; Reserve buf = BUF_SIZE
    buf resb BUF_SIZE

section .text
    global _start

_start:
    call read_f ; Calling my read function
    call write_f
    call exit
    syscall

read_f:
    mov rax, 0      ; syscall for sys_read
    mov rdi, 0      ; fd for stdin
    mov rsi, buf    ; buf addr
    mov rdx, BUF_SIZE
    syscall         ; rax returns number of readed bytes

write_f:
    mov rdx, rax ; Save in rdx number of bytes returned by rax
    mov rax, 1   ; syscall for sys_write
    mov rdi, 1   ; fd for stdout
    mov rsi, buf ; buf addr
    syscall

exit:
    mov rax, 60     ; syscall for exit
    xor rdi, rdi    ; xor instead of "mov rdi, 0", bcs "xor rdi, rdi" = 3 bytes, "mov rdi, 0" = 7 bytes
    syscall