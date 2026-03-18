stack segment para stack
    db 256 dup(?)
stack ends

data segment para public

    input_buf db 255
              db 0
              db 255 dup(0)

    msg_in  db 'Enter string: $'
    msg16   db 0Dh, 0Ah,'CRC-16: $'
    newline db 0Dh, 0Ah,'$'

data ends

code segment para public
assume cs:code, ds:data, ss:stack

print:
    mov ah, 09h
    int 21h
    ret

print_hex16:
    push ax
    push bx
    push cx
    push dx

    mov cx, 4
    mov bx, ax
next_digit16:
    push cx
    mov cl, 4
    rol bx, cl
    pop cx

    mov dl, bl
    and dl, 0Fh
    cmp dl, 9
    jbe digit
    add dl, 7
digit:
    add dl, '0'
    mov ah, 02h
    int 21h
    loop next_digit16

    pop dx
    pop cx
    pop bx
    pop ax
    ret

calc_crc16:
    push bx
    push cx
    push dx
    push si

    mov ax, 0FFFFh 

    mov cl, [input_buf+1] 
    xor ch, ch             
    lea si, [input_buf+2] 

    cmp byte ptr [input_buf+1], 0
    je done_crc16
crc16_byte:
    xor al, [si]
    mov bx, 8
crc16_bit:
    shr ax, 1
    jnc crc16_no_xor
    xor ax, 0A001h
crc16_no_xor:
    dec bx
    jnz crc16_bit
    inc si
    loop crc16_byte
done_crc16:
    pop si
    pop dx
    pop cx
    pop bx
    ret

start:
    mov ax, data
    mov ds, ax

    mov ax, stack
    mov ss, ax

    lea dx, msg_in
    call print

    lea dx, input_buf
    mov ah, 0Ah
    int 21h

    call calc_crc16
    push ax

    lea dx, msg16
    call print

    pop ax
    call print_hex16

    mov ax, 4C00h
    int 21h

code ends
end start