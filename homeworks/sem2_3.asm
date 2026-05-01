.386

arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10

var1 equ -2
var2 equ -4
var3 equ -6
var4 equ -8

stack segment para stack
    db 1024 dup(?)
stack ends

data segment para public
    str_input    db 128 dup(0)
    str_val1     db 64 dup(0)
    str_val2     db 64 dup(0)
    str_res      db 64 dup(0)
    
    char_op      db 0
    num_a        dw 0
    num_b        dw 0
    res_low      dw 0
    res_high     dw 0
    current_base dw 10
    atoi_error   db 0
    
    msg_base     db "Select number system (d/h): ", 0
    msg_input    db "Enter expression (e.g. 10 - 5): ", 0
    msg_res_dec  db "Result (Decimal): ", 0
    msg_res_hex  db "Result (Hex): 0x", 0
    
    msg_err      db "Error: ", 0
    err_fmt      db "Invalid format", 0
    err_op       db "Unknown operation", 0
    err_div      db "Division by zero", 0
    err_range_str db "Out of range", 0
    err_overflow  db "Overflow", 0
data ends


code segment para public use16
assume cs:code, ds:data, ss:stack

_putchar:
    push bp
    mov bp, sp
    mov dx, word ptr [bp + arg1]
    mov ah, 02h
    int 21h
    mov sp, bp
    pop bp
    ret

_getchar:
    push bp
    mov bp, sp
    mov ah, 01h
    int 21h
    mov sp, bp
    pop bp
    ret

_strlen: 
    push bp
    mov bp, sp
    mov bx, word ptr [bp + arg1] 
    xor ax, ax
lencyc:    
    cmp byte ptr [bx], 0
    je lenret
    inc ax
    inc bx
    jmp lencyc
lenret:    
    mov sp, bp
    pop bp
    ret

_putstr: 
    push bp
    mov bp, sp
    push word ptr [bp + arg1] 
    call _strlen
    add sp, 2
    mov cx, ax
    mov dx, word ptr [bp + arg1]
    mov ah, 40h
    mov bx, 1
    int 21h
    mov sp, bp
    pop bp
    ret

_getstr:
    push bp
    mov bp, sp
    mov cx, word ptr [bp + arg2]
    mov dx, word ptr [bp + arg1]
    mov ah, 3fh
    mov bx, 0
    int 21h
    
    mov bx, word ptr [bp + arg1]
    add bx, ax
    
    cmp ax, 2
    jb getstr_small
    sub bx, 2
    jmp getstr_zero
    
getstr_small:
    test ax, ax
    jz getstr_zero
    sub bx, 1
    
getstr_zero:
    mov byte ptr [bx], 0
    
    mov sp, bp
    pop bp
    ret

_putnewline:
    push bp
    mov bp, sp
    mov dx, 10
    push dx
    call _putchar
    add sp, 2
    mov dx, 13
    push dx
    call _putchar
    add sp, 2
    mov sp, bp
    pop bp
    ret

_exit:
    push bp
    mov bp, sp
    mov ax, word ptr [bp + arg1]
    mov ah, 4ch
    int 21h
    mov sp, bp
    pop bp
    ret

_exit0:
    push bp
    mov bp, sp
    mov dx, 0
    push dx
    call _exit
    add sp, 2
    mov sp, bp
    pop bp
    ret

_atoi: 
    push bp
    mov bp, sp
    push si
    push di
    push bx
    push cx

    mov atoi_error, 0

    mov si, word ptr [bp + arg1]
    mov bx, current_base
    xor ax, ax
    xor cx, cx

    cmp byte ptr [si], '-'
    jne atoi_loop
    mov cx, 1
    inc si

atoi_loop:
    xor dx, dx
    mov dl, [si]
    test dl, dl
    jz atoi_end

    cmp dl, '0'
    jb atoi_err
    cmp dl, '9'
    jbe atoi_digit

    cmp bx, 16
    jne atoi_err
    and dl, 0DFh
    cmp dl, 'A'
    jb atoi_err
    cmp dl, 'F'
    ja atoi_err
    sub dl, 7

atoi_digit:
    sub dl, '0'
    mov di, dx

    mul bx
    test dx, dx
    jnz atoi_range_err

    add ax, di
    jc atoi_range_err

    inc si
    jmp atoi_loop

atoi_err:
    mov atoi_error, 1
    xor ax, ax
    jmp atoi_ret

atoi_range_err:
    mov atoi_error, 2
    xor ax, ax
    jmp atoi_ret

atoi_end:
    test cx, cx
    jz atoi_pos_check

    cmp ax, 8000h
    ja atoi_range_err
    neg ax
    jmp atoi_ok

atoi_pos_check:
    cmp ax, 7FFFh
    ja atoi_range_err

atoi_ok:

atoi_ret:
    pop cx
    pop bx
    pop di
    pop si
    mov sp, bp
    pop bp
    ret

_itoa32_dec:
    push bp
    mov bp, sp
    sub sp, 2
    push di
    push si
    push bx

    mov dx, word ptr [bp + arg1]
    mov ax, word ptr [bp + arg2]
    mov di, word ptr [bp + arg3]

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

i32_loop:
    mov bx, ax
    mov ax, dx
    xor dx, dx
    div si
    mov [bp - 2], ax

    mov ax, bx
    div si
    add dl, '0'
    push dx
    inc cx

    mov dx, [bp - 2]
    mov bx, dx
    or bx, ax
    jnz i32_loop

i32_pop:
    pop ax
    mov [di], al
    inc di
    loop i32_pop

    mov byte ptr [di], 0

    pop bx
    pop si
    pop di
    mov sp, bp
    pop bp
    ret

_itoa32_hex:
    push bp
    mov bp, sp
    push di
    push bx
    push cx

    mov di, word ptr [bp + arg3]
    
    mov bx, word ptr [bp + arg1]
    call hex_word
    mov bx, word ptr [bp + arg2]
    call hex_word
    
    mov byte ptr [di], 0

    pop cx
    pop bx
    pop di
    mov sp, bp
    pop bp
    ret

hex_word:
    mov cx, 4
hw_loop:
    rol bx, 4
    mov al, bl
    and al, 0Fh
    cmp al, 9
    jbe hw_digit
    add al, 7
hw_digit:
    add al, '0'
    mov [di], al
    inc di
    loop hw_loop
    ret

_check:
    push bp
    mov bp, sp
    push si
    push di
    push cx

    mov si, word ptr [bp + arg1]

chk_skip1:
    mov al, [si]
    cmp al, ' '
    jne chk_read_v1
    inc si
    jmp chk_skip1

chk_read_v1:
    mov di, offset str_val1
    xor cx, cx

chk_v1_loop:
    mov al, [si]
    test al, al
    jz chk_err

    cmp al, '-'
    jne chk_v1_not_minus
    test cx, cx
    jz chk_v1_copy
    jmp chk_v1_check_op

chk_v1_not_minus:
    cmp al, '+'
    je chk_v1_check_op
    cmp al, '*'
    je chk_v1_check_op
    cmp al, '/'
    je chk_v1_check_op
    cmp al, '%'
    je chk_v1_check_op

    cmp al, ' '
    je chk_v1_space_end

chk_v1_copy:
    mov [di], al
    inc di
    inc si
    inc cx
    jmp chk_v1_loop

chk_v1_check_op:
    test cx, cx
    jz chk_err
    mov byte ptr [di], 0
    jmp chk_read_op

chk_v1_space_end:
    mov byte ptr [di], 0
    test cx, cx
    jz chk_err

chk_skip2:
    inc si
    mov al, [si]
    cmp al, ' '
    je chk_skip2

chk_read_op:
    mov al, [si]
    
    cmp al, '+'
    je chk_op_ok
    cmp al, '-'
    je chk_op_ok
    cmp al, '*'
    je chk_op_ok
    cmp al, '/'
    je chk_op_ok
    cmp al, '%'
    je chk_op_ok
    jmp chk_err

chk_op_ok:
    mov char_op, al
    inc si

chk_skip3:
    mov al, [si]
    cmp al, ' '
    jne chk_read_v2
    inc si
    jmp chk_skip3

chk_read_v2:
    mov di, offset str_val2

chk_v2_loop:
    mov al, [si]
    test al, al
    jz chk_v2_done
    cmp al, ' '
    je chk_v2_done
    cmp al, 13
    je chk_v2_done
    cmp al, 10
    je chk_v2_done
    
    mov [di], al
    inc di
    inc si
    jmp chk_v2_loop

chk_v2_done:
    mov byte ptr [di], 0
    
    cmp di, offset str_val2
    je chk_err
    
    clc
    jmp chk_ret

chk_err:
    stc

chk_ret:
    pop cx
    pop di
    pop si
    mov sp, bp
    pop bp
    ret


_calc: 
    push bp
    mov bp, sp

    push offset msg_base
    call _putstr
    add sp, 2

    call _getchar
    mov cl, al              
    
    call _putnewline

    mov current_base, 10
    cmp cl, 'h'
    jne ask_expr
    mov current_base, 16

ask_expr:
    push offset msg_input
    call _putstr
    add sp, 2

    push 120
    push offset str_input
    call _getstr
    add sp, 4

    push offset str_input
    call _check
    add sp, 2
    jc err_format

    push offset str_val1
    call _atoi
    add sp, 2
    cmp atoi_error, 1
    je  err_format
    cmp atoi_error, 2
    je  err_out_range
    mov num_a, ax

    push offset str_val2
    call _atoi
    add sp, 2
    cmp atoi_error, 1
    je  err_format
    cmp atoi_error, 2
    je  err_out_range
    mov num_b, ax

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
    add sp, 2
    jmp calc_done

do_add:
    add ax, bx
    jo err_overflow_handler
    cwd
    jmp print_res

do_sub:
    sub ax, bx
    jo err_overflow_handler
    cwd
    jmp print_res

do_mul:
    imul bx
    jmp print_res

do_div:
    test bx, bx
    jz err_divide
    cwd
    idiv bx
    cwd
    jmp print_res

do_mod:
    test bx, bx
    jz err_divide
    cwd
    idiv bx
    mov ax, dx
    cwd
    jmp print_res


print_res:
    mov res_low, ax
    mov res_high, dx

    call _putnewline

    push offset msg_res_dec
    call _putstr
    add sp, 2

    push offset str_res
    push res_low
    push res_high
    call _itoa32_dec
    add sp, 6

    push offset str_res
    call _putstr
    add sp, 2
    call _putnewline

    push offset msg_res_hex
    call _putstr
    add sp, 2

    push offset str_res
    push res_low
    push res_high
    call _itoa32_hex
    add sp, 6

    push offset str_res
    call _putstr
    add sp, 2
    call _putnewline
    jmp calc_done

err_format:
    push offset msg_err
    call _putstr
    add sp, 2
    push offset err_fmt
    call _putstr
    add sp, 2
    call _putnewline
    jmp calc_done

err_out_range:
    push offset msg_err
    call _putstr
    add sp, 2
    push offset err_range_str
    call _putstr
    add sp, 2
    call _putnewline
    jmp calc_done

err_overflow_handler:
    push offset msg_err
    call _putstr
    add sp, 2
    push offset err_overflow
    call _putstr
    add sp, 2
    call _putnewline
    jmp calc_done

err_divide:
    push offset msg_err
    call _putstr
    add sp, 2
    push offset err_div
    call _putstr
    add sp, 2
    call _putnewline

calc_done:
    mov sp, bp
    pop bp
    ret

start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
    
    call _calc

    call _exit0
code ends

end start