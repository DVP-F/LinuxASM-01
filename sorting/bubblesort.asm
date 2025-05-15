section .data
    newline db 0x0A    ; newline character

section .text 
    global _start 

rseed: 
    mov [0x00ff], r10d ; seeding 
    RET 

rgen: ; xorshift32 implementation (randint gen) 
    mov r10d, [0x00ff] 
    mov r11d, r10d 
    shr r11d, 12 
    xor r10d, r11d 
    mov r11d, r10d 
    shl r11d, 25 
    xor r10d, r11d 
    mov r11d, r10d 
    shr r11d, 27 
    xor r10d, r11d 
    mov r8d, 2685821657736338717 
    mul r10d 
    mov [0x00ff], r10d 
    RET 

_start: 
    call rseed 
    call rgen 

post:
    mov rcx, 20              ; 20 numbers to print
    mov rsi, 0x0aff          ; Starting address of numbers
    mov rdi, 1               ; File descriptor (stdout)

L3:
    mov rax, [rsi]           ; Load the number
    call print_number        ; Convert and print it
    add rsi, 4               ; Move to next number (dword)
    loop L3

    mov rax, 1               ; Write syscall (exit) 
    mov rdi, 0
    syscall

; Subroutine to print an integer as a string 
print_number:
    mov rbx, 10              ; Divisor for decimal
    mov rdx, 0               ; Clear remainder
    mov rdi, rsp             ; Use stack for the string buffer
    add rdi, 40              ; Go to top of stack (safe zone)
    mov byte [rdi], 0        ; Null-terminate string

convert_digit:
    xor rdx, rdx             ; Clear remainder
    div rbx                  ; Divide rax by 10
    add dl, '0'              ; Convert remainder to ASCII
    dec rdi                  ; Move backwards in buffer
    mov [rdi], dl            ; Store character
    test rax, rax            ; If rax is zero, we're done
    jnz convert_digit

    mov rax, 1               ; Syscall: write
    mov rsi, rdi             ; Point to the number string
    mov rdx, 40              ; Maximum possible digits (safe)
    syscall

    mov rax, 1               ; Print newline
    mov rsi, newline
    mov rdx, 1
    syscall

    ret

    mov CL, 640 ; counter :3 
L1: 
    call rgen 
    mov [0x0aff+CL], [0x00ff] ; set a whole buncha addresses to random ints 
    call rgen 
    sub CL, 32 
    jnz L1 

    mov CL, 20 
L2: 
    mov r12d, 0 
    mov edx, 32 
    dec CL 
    mul edx, CL 
    inc CL 

    mov eax, edx ; prep counters 
    mov ebx, edx 
    add ebx, 32 

R1: ; ebx is smaller
    mov r13d, [0x0aff+ebx] 
    mov [0x0aff+ebx], [0x0aff+eax] 
    mov [0x0aff+eax], [0x0aff+ebx] 
    inc r12d 
    ret 

    cmp [0x0aff+ebx], [0x0aff+eax] 
    jb R1 

    dec CL 
    jnz L2 
    cmp r12d, 0 
    je post 

