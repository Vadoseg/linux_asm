; Usage: Input numbers like "123" or "1 2 3" without "+" (Anyway it will be ignored)
%define IN_BUF_S 256
%define SUM_BUF_S 20

section .bss ; Reserve buf = IN_BUF_S
    input resb IN_BUF_S
    sum_buf resb SUM_BUF_S
    sum_buf_end equ $

section .data
    res_msg db "End sum: ", 0
    res_msg_len equ $ - res_msg
    newln db 0xA

section .text
    global _start

_start:
    mov rdi, input
    call read_f

    ; RAX contains number of input bytes
    mov rcx, rax    ; rcx is counter for loop (While rcx contains bytes, continue)
    mov rsi, input  ; rsi points on start of input string
    xor rbx, rbx

    call sum_loop
    call exit

read_f:
    push r12     ; Save old R12 in stack (By rules)
    mov r12, rdi ; save rdi in r12

    mov rax, 0      ; syscall for sys_read
    mov rdi, 0      ; fd for stdin
    
    mov rsi, r12        ; Use r12 string in sys_read (As read buffer)
    mov rdx, IN_BUF_S
    syscall             ; rax returns number of readed bytes

    pop r12 ; Return old r12 before return
    ret

sum_loop:
    cmp rcx, 0 ; Check if symbols ended of not
    je print_res

    movzx rdx, byte [rsi] ; Take current symbol

    ; Check if symbol is a number (0-9 in ASCII 48-57)
    cmp dl, 10 ; Skip \n
    je next_char
    cmp dl, '0' ; If < 0 then skip
    jb next_char
    cmp dl, '9' ; If > 9 then skip
    ja next_char

    sub dl, '0'     ; Convert ASCII in number
    add rbx, rdx    ; Add in sum

next_char:
    inc rsi ; Next symbol
    dec rcx ; Decrease symbol counter
    jmp sum_loop

write_f:
    push r12     ; Save old R12 in stack (By rules)
    mov r12, rdi

    mov rax, 1   ; syscall for sys_write
    mov rdi, 1   ; fd for stdout
    mov rsi, r12 ; Use r12 string in sys_write
    syscall

    pop r12 ; Return old r12 before return
    ret

print_res:
    push r13
    mov rax, rbx ; Save sum in RAX for division
    mov rcx, 10  ; Delimiter
    mov r13, sum_buf_end ; End of sum buffer

convert_loop:
    xor rdx, rdx ; Clear rdx before division
    div rcx      ; RAX / 10. Result in RAX, remainder in RDX

    add dl, '0'     ; Convert remainder back to ASCII
    dec r13         ; Move pointer of sum buf backwards
    mov [r13], dl   ; Write number in buf

    test rax, rax    ; Check if RAX have something inside
    jnz convert_loop ; If RAX != 0, continue

    mov rdi, res_msg
    mov rdx, res_msg_len ; save length of the string in rdx
    call write_f

    ; Now RSI points on start of string with number in buffer
    ; Count string len for write_f
    mov rdx, sum_buf_end
    sub rdx, r13          ; Len = End of buf - current ptr 

    mov rdi, r13
    call write_f

    mov rdi, newln
    mov rdx, 1
    call write_f

    pop r13
    call exit

exit:
    mov rax, 60     ; syscall for exit
    xor rdi, rdi    ; xor instead of "mov rdi, 0", bcs "xor rdi, rdi" = 3 bytes, "mov rdi, 0" = 7 bytes
    syscall