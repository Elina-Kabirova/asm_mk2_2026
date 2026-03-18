stack segment para stack
    db 256 dup(?)
stack ends

data segment para public
    input_buf db 255
              db 0
              db 255 dup(0)

    msg_in  db 'Enter string: $'
    msg16   db 0Dh, 0Ah,'CRC-16: $'
	crc16_table	dw 00000h, 01021h, 02042h, 03063h, 04084h, 050A5h, 060C6h, 070E7h
				dw 08108h, 09129h, 0A14Ah, 0B16Bh, 0C18Ch, 0D1ADh, 0E1CEh, 0F1EFh
				dw 01231h, 00210h, 03273h, 02252h, 052B5h, 04294h, 072F7h, 062D6h
				dw 09339h, 08318h, 0B37Bh, 0A35Ah, 0D3BDh, 0C39Ch, 0F3FFh, 0E3DEh
				dw 02462h, 03443h, 00420h, 01401h, 064E6h, 074C7h, 044A4h, 05485h
				dw 0A56Ah, 0B54Bh, 08528h, 09509h, 0E5EEh, 0F5CFh, 0C5ACh, 0D58Dh
				dw 03653h, 02672h, 01611h, 00630h, 076D7h, 066F6h, 05695h, 046B4h
				dw 0B75Bh, 0A77Ah, 09719h, 08738h, 0F7DFh, 0E7FEh, 0D79Dh, 0C7BCh
				dw 048C4h, 058E5h, 06886h, 078A7h, 00840h, 01861h, 02802h, 03823h
				dw 0C9CCh, 0D9EDh, 0E98Eh, 0F9AFh, 08948h, 09969h, 0A90Ah, 0B92Bh
				dw 05AF5h, 04AD4h, 07AB7h, 06A96h, 01A71h, 00A50h, 03A33h, 02A12h
				dw 0DBFDh, 0CBDCh, 0FBBFh, 0EB9Eh, 09B79h, 08B58h, 0BB3Bh, 0AB1Ah
				dw 06CA6h, 07C87h, 04CE4h, 05CC5h, 02C22h, 03C03h, 00C60h, 01C41h
				dw 0EDAEh, 0FD8Fh, 0CDECh, 0DDCDh, 0AD2Ah, 0BD0Bh, 08D68h, 09D49h
				dw 07E97h, 06EB6h, 05ED5h, 04EF4h, 03E13h, 02E32h, 01E51h, 00E70h
				dw 0FF9Fh, 0EFBEh, 0DFDDh, 0CFFCh, 0BF1Bh, 0AF3Ah, 09F59h, 08F78h
				dw 09188h, 081A9h, 0B1CAh, 0A1EBh, 0D10Ch, 0C12Dh, 0F14Eh, 0E16Fh
				dw 01080h, 000A1h, 030C2h, 020E3h, 05004h, 04025h, 07046h, 06067h
				dw 083B9h, 09398h, 0A3FBh, 0B3DAh, 0C33Dh, 0D31Ch, 0E37Fh, 0F35Eh
				dw 002B1h, 01290h, 022F3h, 032D2h, 04235h, 05214h, 06277h, 07256h
				dw 0B5EAh, 0A5CBh, 095A8h, 08589h, 0F56Eh, 0E54Fh, 0D52Ch, 0C50Dh
				dw 034E2h, 024C3h, 014A0h, 00481h, 07466h, 06447h, 05424h, 04405h
				dw 0A7DBh, 0B7FAh, 08799h, 097B8h, 0E75Fh, 0F77Eh, 0C71Dh, 0D73Ch
				dw 026D3h, 036F2h, 00691h, 016B0h, 06657h, 07676h, 04615h, 05634h
				dw 0D94Ch, 0C96Dh, 0F90Eh, 0E92Fh, 099C8h, 089E9h, 0B98Ah, 0A9ABh
				dw 05844h, 04865h, 07806h, 06827h, 018C0h, 008E1h, 03882h, 028A3h
				dw 0CB7Dh, 0DB5Ch, 0EB3Fh, 0FB1Eh, 08BF9h, 09BD8h, 0ABBBh, 0BB9Ah
				dw 04A75h, 05A54h, 06A37h, 07A16h, 00AF1h, 01AD0h, 02AB3h, 03A92h
				dw 0FD2Eh, 0ED0Fh, 0DD6Ch, 0CD4Dh, 0BDAAh, 0AD8Bh, 09DE8h, 08DC9h
				dw 07C26h, 06C07h, 05C64h, 04C45h, 03CA2h, 02C83h, 01CE0h, 00CC1h
				dw 0EF1Fh, 0FF3Eh, 0CF5Dh, 0DF7Ch, 0AF9Bh, 0BFBAh, 08FD9h, 09FF8h
				dw 06E17h, 07E36h, 04E55h, 05E74h, 02E93h, 03EB2h, 00ED1h, 01EF0h
		
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

calc_crc16_table:
    push bx
    push cx
    push dx
    push si
    push di

    mov ax, 0FFFFh

    mov cl, [input_buf+1]
    xor ch, ch
    lea si, [input_buf+2]

    cmp cx, 0
    je done_crc
next_byte:
    mov bl, ah
    xor bl, [si]

    ; AX «= 8
    mov ah, al
    mov al, 0

    ; DI = index * 2
    xor bh, bh
    mov di, bx
    shl di, 1

    xor ax, crc16_table[di]

    inc si
    loop next_byte
done_crc:
    pop di
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

    call calc_crc16_table
    push ax

    lea dx, msg16
    call print

    pop ax
    call print_hex16

    mov ax, 4C00h
    int 21h

code ends
end start