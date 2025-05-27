section .data
    newline db 0x0A    ; newline character
    seed dw 0          ; Proper seed storage

section .bss
    array resd 20      ; Reserve space for 20 integers

section .text 
    global _start 

rseed: 
    mov [seed], r10d   ; seeding 
    ret 

rgen: ; xorshift32 implementation (randint gen) 
    mov r10d, [seed] 
    mov r11d, r10d 
    shr r11d, 12 
    xor r10d, r11d 
    mov r11d, r10d 
    shl r11d, 25 
    xor r10d, r11d 
    mov r11d, r10d 
    shr r11d, 27 
    xor r10d, r11d 
    mov r8d, 0xD2D64D ; 32 bit relative prime :3 
    imul r10d, r8d 
    mov [seed], r10d 
    ret 

_start: 
    call rseed 

    ; fill array with 20 random integers
    mov rcx, 20
    mov rbx, 0
.fill_array:
    call rgen
    mov [array + rbx*4], r10d
    inc rbx
    loop .fill_array

.sort_outer:
    mov r12d, 0           ; swap counter
    mov ecx, 19           ; 20 elements = 19 comparisons
    xor rbx, rbx

.sort_inner:
    mov eax, [array + rbx*4]
    mov edx, [array + rbx*4 + 4]
    cmp eax, edx
    jbe .no_swap

    ; swap
    mov [array + rbx*4], edx
    mov [array + rbx*4 + 4], eax
    inc r12d

.no_swap:
    inc rbx
    loop .sort_inner

    cmp r12d, 0
    jne .sort_outer

post:
    mov rcx, 20              ; 20 numbers to print
    mov rsi, array 
    mov rdi, 1 

.L3:
    mov eax, [rsi]           ; Load the number, convert and print it
    call print_number 
    add rsi, 4               ; Move to next number (dword)
    loop .L3

    mov rax, 60              ; syscall: exit
    xor rdi, rdi
    syscall

print_number:
    mov rbx, 10
    xor rcx, rcx
    mov rdi, rsp
    add rdi, 40
    mov byte [rdi], 0

.convert_digit:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test rax, rax
    jnz .convert_digit

    mov rax, 1
    mov rsi, rdi
    mov rdx, 40
    syscall

    mov rax, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ret