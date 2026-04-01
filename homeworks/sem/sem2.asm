.386

arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10

stack segment para stack
    db 1024 dup(0)
stack ends

data segment para public
    ; Буферы для ввода и обработки
    str_input    db 128 dup(0)
    str_val1     db 64 dup(0)
    str_val2     db 64 dup(0)
    char_op      db 0
    
    num_a        dw 0
    num_b        dw 0
    res_low      dw 0
    res_high     dw 0
    current_base dw 10

    ; Сообщения
    msg_base     db "Select number system (d/h): ", 0
    msg_input    db "Enter expression (e.g. 10 + 5): ", 0
    msg_res_dec  db "Result (Decimal): ", 0
    msg_res_hex  db "Result (Hex): 0x", 0

    ; Ошибки
    err_fmt      db "Error: Invalid format", 0
    err_op       db "Error: Unknown operation", 0
    err_div      db "Error: Division by zero", 0
    err_base     db "Error: Invalid base", 0
data ends

code segment para public use16
assume cs:code, ds:data, ss:stack

_putchar:
    push bp
    mov bp, sp
    mov dx, [bp+arg1]
    mov ah, 02h
    int 21h
    pop bp
    ret

_putstr:
    push bp
    mov bp, sp
    mov si, [bp+arg1]
put_loop:
    lodsb
    cmp al, 0
    je put_done
    mov dl, al
    mov ah, 02h
    int 21h
    jmp put_loop
put_done:
    pop bp
    ret

_putnewline:
    push 10
    call _putchar
    push 13
    call _putchar
    add sp, 4
    ret

_atoi:
    push bp
    mov bp, sp
    push si
    push bx
    
    mov si, [bp+arg1]
    mov bx, [bp+arg2]
    xor eax, eax
    xor cx, cx

    cmp byte ptr [si], '-'
    jne atoi_c
    mov cx, 1
    inc si
atoi_c:
    movzx edx, byte ptr [si]
    test dl, dl
    je atoi_e
    cmp dl, '0'
    jb atoi_err
    cmp dl, '9'
    jbe is_d
    and dl, 0DFh
    sub dl, 7
is_d:
    sub dl, '0'
    movzx ebx, word ptr [bp+arg2]
    imul eax, ebx
    movzx edx, dl
    add eax, edx
    inc si
    jmp atoi_c
atoi_e:
    test cx, cx
    jz atoi_check
    neg eax
atoi_check:
    cmp eax, 32767
    jg atoi_err
    cmp eax, -32768
    jl atoi_err
    clc
    jmp atoi_r
atoi_err:
    stc
atoi_r:
    pop bx
    pop si
    pop bp
    ret

_itoa32_dec:
    push bp
    mov bp, sp
    push di
    push si
    push bx

    mov dx, [bp+arg1]
    mov ax, [bp+arg2]
    mov di, [bp+arg3]

    test dx, 8000h
    jz i32_pos
    mov byte ptr [di], '-'
    inc di
    not dx
    not ax
    add ax, 1
    adc dx, 0
i32_pos:
    xor cx, cx
    mov si, 10
i32_lp:
    mov bx, ax
    mov ax, dx
    xor dx, dx
    div si
    mov bp, ax 
    mov ax, bx
    div si
    add dl, '0'
    push dx
    inc cx
    mov dx, bp
    mov bx, dx
    or bx, ax
    jnz i32_lp
i32_pop:
    pop ax
    stosb
    loop i32_pop
    mov byte ptr [di], 0
    pop bx
    pop si
    pop di
    pop bp
    ret

_itoa16:
    push bp
    mov bp, sp
    push di
    push si
    push bx
    
    mov di, [bp+arg3]
    
    mov bx, [bp+arg1] 
    call hex_word_to_str
    
    mov bx, [bp+arg2]
    call hex_word_to_str
    
    mov byte ptr [di], 0
    
    pop bx
    pop si
    pop di
    pop bp
    ret
	
hex_word_to_str:
    mov cx, 4
hex_word_loop:
    rol bx, 4 
    mov al, bl
    and al, 0Fh
    cmp al, 9
    jbe hex_digit_ok
    add al, 7
hex_digit_ok:
    add al, '0'
    mov [di], al
    inc di
    loop hex_word_loop
    ret
	
_calc:
    push bp
    mov bp, sp

    ;Выбор системы счисления
    push offset msg_base
    call _putstr
    add sp, 2
    
    mov ah, 01h
    int 21h
    mov bl, al
    call _putnewline

    cmp bl, 'd'
    je set_dec
    cmp bl, 'h'
    je set_hex
    push offset err_base
    call _putstr
    jmp calc_exit
set_dec:
    mov current_base, 10
    jmp get_input
set_hex:
    mov current_base, 16

get_input:
    push offset msg_input
    call _putstr
    add sp, 2
    
    mov dx, offset str_input
    mov ah, 3Fh
    mov bx, 0
    mov cx, 120
    int 21h
    
    mov si, offset str_input
    add si, ax
    sub si, 2
    mov byte ptr [si], 0

    mov si, offset str_input
    mov di, offset str_val1
    cld
    
scan_val1:
    lodsb
    cmp al, ' '
    je end_val1
    cmp al, 0
    je error_fmt
    stosb
    jmp scan_val1
end_val1:
    mov byte ptr [di], 0

    lodsb
    mov char_op, al
    
    lodsb
    cmp al, ' '
    jne error_fmt

    mov di, offset str_val2
scan_val2:
    lodsb
    stosb
    cmp al, 0
    jne scan_val2

    ; Превращаем строки в числа
    push current_base
    push offset str_val1
    call _atoi
    add sp, 4
    jc error_fmt
    mov num_a, ax

    push current_base
    push offset str_val2
    call _atoi
    add sp, 4
    jc error_fmt
    mov num_b, ax

    ; Вычисления
    mov ax, num_a
    mov bx, num_b
    mov cl, char_op

    cmp cl, '+'
    je do_add
    cmp cl, '-'
    je do_sub
    cmp cl, '*'
    je do_mul
    cmp cl, '/'
    je do_div
    cmp cl, '%'
    je do_mod
    
    push offset err_op
    call _putstr
    jmp calc_exit

do_add:
    add ax, bx
    cwd
    jmp print_res
do_sub:
    sub ax, bx
    cwd
    jmp print_res
do_mul:
    imul bx
    jmp print_res
do_div:
    test bx, bx
    jz error_div
    cwd
    idiv bx  
    cwd
    jmp print_res
do_mod:
    test bx, bx
    jz error_div
    cwd
    idiv bx
    mov ax, dx 
    cwd
    jmp print_res

error_fmt:
    push offset err_fmt
    call _putstr
    jmp calc_exit
error_div:
    push offset err_div
    call _putstr
    jmp calc_exit

print_res:
    mov res_low, ax
    mov res_high, dx

    call _putnewline
    
    ; Decimal Output
    push offset msg_res_dec
    call _putstr
    add sp, 2
    
    push offset str_input 
    push res_low          
    push res_high       
    call _itoa32_dec
    add sp, 6
    
    push offset str_input
    call _putstr
    add sp, 2
    call _putnewline

    ; Hexadecimal Output
    push offset msg_res_hex
    call _putstr
    add sp, 2
    
    push offset str_input
    push res_low         
    push res_high 
    call _itoa16
    add sp, 6
    
    push offset str_input
    call _putstr
    add sp, 2
    call _putnewline

calc_exit:
    pop bp
    ret

start:
    mov ax, data
    mov ds, ax
    mov es, ax
    
    call _calc
    
    mov ax, 4C00h
    int 21h
code ends
end start