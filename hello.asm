section .data
    message db 'Hello, world!', 13, 10

section .text
    global _start

_start:
    ; Print the message to stdout
    mov eax, 4          ; system call number for sys_write
    mov ebx, 1          ; file descriptor for stdout
    mov ecx, message    ; address of the message
    mov edx, 15         ; length of the message
    int 0x80            ; call kernel

    ; Exit the program
    mov eax, 1          ; system call number for sys_exit
    xor ebx, ebx        ; return code 0
    int 0x80            ; call kernel