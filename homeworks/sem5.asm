.386

arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10
arg5 equ 12
arg6 equ 14

var1 equ -2
var2 equ -4
var3 equ -6
var4 equ -8
var5 equ -10
var6 equ -12

SCR_W equ 320
SCR_H equ 200

CALC_X equ 10
CALC_Y equ 10
CALC_W equ 300
CALC_H equ 180

DISP_X equ 20
DISP_Y equ 25
DISP_W equ 280
DISP_H equ 28

BTN_X equ 25
BTN_Y equ 70
BTN_W equ 50
BTN_H equ 24
BTN_GAP equ 5

FONT_W      equ 3
FONT_H      equ 5
FONT_SCALE  equ 2
FONT_PIX_W  equ (FONT_W * FONT_SCALE)
FONT_PIX_H  equ (FONT_H * FONT_SCALE)
FONT_ADV    equ 8
FONT_REC    equ 6

PAL_GREEN_FIRST equ 32

COLOR_BG      equ 32
COLOR_PANEL   equ 33
COLOR_DISPLAY equ 34
COLOR_BTN     equ 35
COLOR_BTN_HI  equ 36
COLOR_BORDER  equ 37
COLOR_TEXT    equ 38
COLOR_BTN_TXT equ 32
COLOR_CURSOR  equ 39

EXIT_X equ (BTN_X + 4*(BTN_W + BTN_GAP))
EXIT_Y equ (BTN_Y + 2*(BTN_H + BTN_GAP))
EXIT_W equ (BTN_W)
EXIT_H equ (2*BTN_H + BTN_GAP)

CURSOR_SIZE equ 4

stack segment para stack 'stack'
    db 1024 dup(?)
stack ends

data segment para public 'data'
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

    input_len       dw 0
    quit_flag       db 0
    mouse_prev_btn  dw 0
    mouse_ok        db 0

    after_eval db 0

    last_mx dw 0
    last_my dw 0
    cursor_drawn db 0
    cursor_bg db 16 dup(0)

    btn_chars db '7','8','9','/','C'
              db '4','5','6','*',8
              db '1','2','3','%',27
              db '+','0','-',13,0

    btn_labels db '7','8','9','/','C'
               db '4','5','6','*','<'
               db '1','2','3','%','X'
               db '+','0','-','=',' '

    btn_count dw 20

    gui_err_fmt      db "INVALID FORMAT", 0
    gui_err_range    db "OUT OF RANGE", 0
    gui_err_overflow db "OVERFLOW", 0
    gui_err_div      db "DIV BY ZERO", 0
    gui_err_op       db "UNKNOWN OPERATION", 0

    green_palette db  0,  4,  0
                  db  0, 14,  0
                  db  0,  2,  0
                  db  0, 25,  0
                  db  0, 46,  0
                  db  0, 60,  0
                  db 22, 63, 22
                  db 45, 63, 45

    green_palette_size equ ($ - green_palette)

    font_table label byte

    db ' ', 0,0,0,0,0
    db '?', 7,1,2,0,2
    db '.', 0,0,0,0,2

    db '+', 0,2,7,2,0
    db '-', 0,0,7,0,0
    db '*', 0,7,7,7,0
    db '/', 1,1,2,4,4
    db '%', 5,1,2,4,5
    db '=', 0,7,0,7,0
    db '<', 1,2,4,2,1

    db '0', 7,5,5,5,7
    db '1', 2,6,2,2,2
    db '2', 7,1,7,4,7
    db '3', 7,1,7,1,7
    db '4', 5,5,7,1,1
    db '5', 7,4,7,1,7
    db '6', 7,4,7,5,7
    db '7', 7,1,2,2,2
    db '8', 7,5,7,5,7
    db '9', 7,5,7,1,7

    db 'A', 2,5,7,5,5
    db 'B', 6,5,6,5,6
    db 'C', 7,4,4,4,7
    db 'D', 6,5,5,5,6
    db 'E', 7,4,7,4,7
    db 'F', 7,4,7,4,4
    db 'G', 7,4,5,5,7
    db 'H', 5,5,7,5,5
    db 'I', 7,2,2,2,7
    db 'J', 1,1,1,5,7
    db 'K', 5,5,6,5,5
    db 'L', 4,4,4,4,7
    db 'M', 5,7,7,5,5
    db 'N', 5,7,7,7,5
    db 'O', 7,5,5,5,7
    db 'P', 7,5,7,4,4
    db 'Q', 7,5,5,7,1
    db 'R', 7,5,7,6,5
    db 'S', 7,4,7,1,7
    db 'T', 7,2,2,2,2
    db 'U', 5,5,5,5,7
    db 'V', 5,5,5,5,2
    db 'W', 5,5,7,7,5
    db 'X', 5,5,2,5,5
    db 'Y', 5,5,2,2,2
    db 'Z', 7,1,2,4,7

    font_table_end label byte
    font_glyph_count equ (font_table_end - font_table) / FONT_REC

data ends

code segment para public use16 'code'
assume cs:code, ds:data, ss:stack

_exit:
    push bp
    mov bp, sp
    mov ax, word ptr [bp + arg1]
    mov ah, 4Ch
    int 21h
    mov sp, bp
    pop bp
    ret

_exit0:
    push bp
    mov bp, sp
    push 0
    call _exit
    add sp, 2
    mov sp, bp
    pop bp
    ret

_strlen:
    push bp
    mov bp, sp
    push bx
    mov bx, word ptr [bp + arg1]
    xor ax, ax

strlen_loop:
    cmp byte ptr [bx], 0
    je strlen_done
    inc ax
    inc bx
    jmp strlen_loop

strlen_done:
    pop bx
    mov sp, bp
    pop bp
    ret

_strcpy:
    push bp
    mov bp, sp
    push si
    push di
    push ax

    mov di, word ptr [bp + arg1]
    mov si, word ptr [bp + arg2]

strcpy_loop:
    mov al, byte ptr [si]
    mov byte ptr [di], al
    inc si
    inc di
    cmp al, 0
    jne strcpy_loop

    pop ax
    pop di
    pop si
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

    mov byte ptr atoi_error, 0

    mov si, word ptr [bp + arg1]
    mov bx, word ptr current_base

    xor ax, ax
    xor cx, cx

    cmp byte ptr [si], '-'
    jne atoi_loop

    mov cl, 1
    inc si

atoi_loop:
    xor dx, dx
    mov dl, byte ptr [si]
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

    inc ch
    inc si
    jmp atoi_loop

atoi_err:
    mov byte ptr atoi_error, 1
    xor ax, ax
    jmp atoi_ret

atoi_range_err:
    mov byte ptr atoi_error, 2
    xor ax, ax
    jmp atoi_ret

atoi_end:
    cmp ch, 0
    je atoi_err

    test cl, cl
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

    mov word ptr [bp + var1], ax

    mov ax, bx
    div si

    add dl, '0'
    push dx
    inc cx

    mov dx, word ptr [bp + var1]
    mov bx, dx
    or bx, ax
    jnz i32_loop

i32_pop:
    pop ax
    mov byte ptr [di], al
    inc di
    loop i32_pop

    mov byte ptr [di], 0

    pop bx
    pop si
    pop di
    mov sp, bp
    pop bp
    ret

_check:
    push bp
    mov bp, sp
    push si
    push di
    push cx

    mov si, word ptr [bp + arg1]

chk_skip1:
    mov al, byte ptr [si]
    cmp al, ' '
    jne chk_read_v1
    inc si
    jmp chk_skip1

chk_read_v1:
    mov di, offset str_val1
    xor cx, cx

chk_v1_loop:
    mov al, byte ptr [si]
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
    mov byte ptr [di], al
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
    mov al, byte ptr [si]
    cmp al, ' '
    je chk_skip2

chk_read_op:
    mov al, byte ptr [si]
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
    mov byte ptr char_op, al
    inc si

chk_skip3:
    mov al, byte ptr [si]
    cmp al, ' '
    jne chk_read_v2
    inc si
    jmp chk_skip3

chk_read_v2:
    mov di, offset str_val2

chk_v2_loop:
    mov al, byte ptr [si]
    test al, al
    jz chk_v2_done

    cmp al, ' '
    je chk_v2_done
    cmp al, 13
    je chk_v2_done
    cmp al, 10
    je chk_v2_done

    mov byte ptr [di], al
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

_set_video_mode13:
    push bp
    mov bp, sp
    mov ax, 0013h
    int 10h
    mov sp, bp
    pop bp
    ret

_set_text_mode:
    push bp
    mov bp, sp
    mov ax, 0003h
    int 10h
    mov sp, bp
    pop bp
    ret

_set_green_palette:
    push bp
    mov bp, sp
    push ax
    push cx
    push dx
    push si

    cld

    mov dx, 03C8h 			; порт VGA "DAC Write Index"
    mov al, PAL_GREEN_FIRST
    out dx, al

    inc dx 					; dx = 03C9h — порт "DAC Data"
    mov si, offset green_palette
    mov cx, green_palette_size

sgp_loop:
    lodsb
    out dx, al
    loop sgp_loop

    pop si
    pop dx
    pop cx
    pop ax
    mov sp, bp
    pop bp
    ret

_fill_rect:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    cld

    mov ax, 0A000h
    mov es, ax

    mov ax, word ptr [bp + arg2]
    mov bx, 320
    mul bx
    add ax, word ptr [bp + arg1]
    mov di, ax

    mov dx, word ptr [bp + arg4]
    mov al, byte ptr [bp + arg5]

fr_y_loop:
    cmp dx, 0
    je fr_done

    push di
    mov cx, word ptr [bp + arg3]
    rep stosb
    pop di

    add di, 320
    dec dx
    jmp fr_y_loop

fr_done:
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret

_draw_rect:
    push bp
    mov bp, sp

    push word ptr [bp + arg5]
    push 1
    push word ptr [bp + arg3]
    push word ptr [bp + arg2]
    push word ptr [bp + arg1]
    call _fill_rect
    add sp, 10

    mov ax, word ptr [bp + arg2]
    add ax, word ptr [bp + arg4]
    dec ax

    push word ptr [bp + arg5]
    push 1
    push word ptr [bp + arg3]
    push ax
    push word ptr [bp + arg1]
    call _fill_rect
    add sp, 10

    push word ptr [bp + arg5]
    push word ptr [bp + arg4]
    push 1
    push word ptr [bp + arg2]
    push word ptr [bp + arg1]
    call _fill_rect
    add sp, 10

    mov ax, word ptr [bp + arg1]
    add ax, word ptr [bp + arg3]
    dec ax

    push word ptr [bp + arg5]
    push word ptr [bp + arg4]
    push 1
    push word ptr [bp + arg2]
    push ax
    call _fill_rect
    add sp, 10

    mov sp, bp
    pop bp
    ret

_draw_char:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax, word ptr [bp + arg2]
    cmp ax, (SCR_W - FONT_PIX_W)
    ja dc_done

    mov ax, word ptr [bp + arg3]
    cmp ax, (SCR_H - FONT_PIX_H)
    ja dc_done

    mov al, byte ptr [bp + arg1]
    mov si, offset font_table
    mov cx, font_glyph_count

dc_find_loop:
    cmp al, byte ptr [si]
    je dc_found
    add si, FONT_REC
    loop dc_find_loop

    mov al, '?'
    mov si, offset font_table
    mov cx, font_glyph_count

dc_find_question:
    cmp al, byte ptr [si]
    je dc_found
    add si, FONT_REC
    loop dc_find_question

    jmp dc_done

dc_found:
    inc si

    mov ax, 0A000h
    mov es, ax

    mov ax, word ptr [bp + arg3]
    mov bx, 320
    mul bx
    add ax, word ptr [bp + arg2]
    mov di, ax

    mov dl, byte ptr [bp + arg4]
    mov dh, FONT_H

dc_row_loop:
    mov bl, byte ptr [si]
    inc si

    push di

    mov bh, 4
    mov cl, FONT_W

dc_col_loop:
    test bl, bh
    jz dc_skip_pixel

    mov byte ptr es:[di], dl
    mov byte ptr es:[di + 1], dl
    mov byte ptr es:[di + 320], dl
    mov byte ptr es:[di + 321], dl

dc_skip_pixel:
    add di, FONT_SCALE
    shr bh, 1
    dec cl
    jnz dc_col_loop

    pop di
    add di, (320 * FONT_SCALE)

    dec dh
    jnz dc_row_loop

dc_done:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret

_draw_string:
    push bp
    mov bp, sp
    push ax
    push bx
    push si

    mov si, word ptr [bp + arg1]
    mov bx, word ptr [bp + arg2]

draw_string_loop:
    mov al, byte ptr [si]
    cmp al, 0
    je draw_string_done

    xor ah, ah

    push word ptr [bp + arg4]
    push word ptr [bp + arg3]
    push bx
    push ax
    call _draw_char
    add sp, 8

    add bx, FONT_ADV
    inc si
    jmp draw_string_loop

draw_string_done:
    pop si
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret

_draw_display:
    push bp
    mov bp, sp

    push COLOR_DISPLAY
    push DISP_H
    push DISP_W
    push DISP_Y
    push DISP_X
    call _fill_rect
    add sp, 10

    push COLOR_BORDER
    push DISP_H
    push DISP_W
    push DISP_Y
    push DISP_X
    call _draw_rect
    add sp, 10

    push COLOR_TEXT
    push (DISP_Y + 9)
    push (DISP_X + 6)
    push offset str_input
    call _draw_string
    add sp, 8

    mov sp, bp
    pop bp
    ret

_draw_button:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si

    mov ax, word ptr [bp + arg1]
    xor dx, dx
    mov bx, 5
    div bx
    mov cx, dx

    mov bx, BTN_W + BTN_GAP
    mov ax, cx
    mul bx
    add ax, BTN_X
    mov si, ax

    mov ax, word ptr [bp + arg1]
    xor dx, dx
    mov bx, 5
    div bx

    mov bx, BTN_H + BTN_GAP
    mul bx
    add ax, BTN_Y
    mov dx, ax

    cmp word ptr [bp + arg2], 0
    je dbtn_normal

    mov bx, COLOR_BTN_HI
    jmp dbtn_color_ready

dbtn_normal:
    mov bx, COLOR_BTN

dbtn_color_ready:
    push bx
    push BTN_H
    push BTN_W
    push dx
    push si
    call _fill_rect
    add sp, 10

    push COLOR_BORDER
    push BTN_H
    push BTN_W
    push dx
    push si
    call _draw_rect
    add sp, 10

    mov bx, word ptr [bp + arg1]
    mov al, byte ptr [btn_labels + bx]
    xor ah, ah

    push COLOR_BTN_TXT

    mov bx, dx
    add bx, 7
    push bx

    mov bx, si
    add bx, 22
    push bx

    push ax
    call _draw_char
    add sp, 8

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret

_draw_exit_button:
    push bp
    mov bp, sp
    push ax
    push bx

    cmp word ptr [bp + arg1], 0
    je ex_normal

    mov bx, COLOR_BTN_HI
    jmp ex_color_ok

ex_normal:
    mov bx, COLOR_BTN

ex_color_ok:
    push bx
    push EXIT_H
    push EXIT_W
    push EXIT_Y
    push EXIT_X
    call _fill_rect
    add sp, 10

    push COLOR_BORDER
    push EXIT_H
    push EXIT_W
    push EXIT_Y
    push EXIT_X
    call _draw_rect
    add sp, 10

    push COLOR_BTN_TXT
    push (EXIT_Y + 21)
    push (EXIT_X + 22)
    push 'X'
    call _draw_char
    add sp, 8

    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret

_draw_buttons:
    push bp
    mov bp, sp
    push cx

    xor cx, cx

draw_buttons_loop:
    cmp cx, word ptr btn_count
    jae draw_buttons_done

    cmp cx, 14
    je draw_exit_here

    cmp cx, 19
    je draw_skip

    push 0
    push cx
    call _draw_button
    add sp, 4

    jmp draw_next

draw_exit_here:
    push 0
    call _draw_exit_button
    add sp, 2
    jmp draw_next

draw_skip:

draw_next:
    inc cx
    jmp draw_buttons_loop

draw_buttons_done:
    pop cx
    mov sp, bp
    pop bp
    ret

_draw_gui:
    push bp
    mov bp, sp

    push COLOR_BG
    push SCR_H
    push SCR_W
    push 0
    push 0
    call _fill_rect
    add sp, 10

    push COLOR_PANEL
    push CALC_H
    push CALC_W
    push CALC_Y
    push CALC_X
    call _fill_rect
    add sp, 10

    push COLOR_BORDER
    push CALC_H
    push CALC_W
    push CALC_Y
    push CALC_X
    call _draw_rect
    add sp, 10

    call _draw_display
    call _draw_buttons

    mov sp, bp
    pop bp
    ret

_save_bg:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax, 0A000h
    mov es, ax

    mov ax, word ptr last_my
    mov bx, 320
    mul bx
    add ax, word ptr last_mx
    mov si, ax

    mov di, offset cursor_bg
    mov dx, CURSOR_SIZE

sb_row:
    mov cx, CURSOR_SIZE
    push si

sb_pix:
    mov al, byte ptr es:[si]
    mov byte ptr [di], al
    inc si
    inc di
    loop sb_pix

    pop si
    add si, 320
    dec dx
    jnz sb_row

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret

_restore_bg:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax, 0A000h
    mov es, ax

    mov ax, word ptr last_my
    mov bx, 320
    mul bx
    add ax, word ptr last_mx
    mov di, ax

    mov si, offset cursor_bg
    mov dx, CURSOR_SIZE

rb_row:
    mov cx, CURSOR_SIZE
    push di

rb_pix:
    mov al, byte ptr [si]
    mov byte ptr es:[di], al
    inc si
    inc di
    loop rb_pix

    pop di
    add di, 320
    dec dx
    jnz rb_row

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret

_paint_cursor:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    mov ax, 0A000h
    mov es, ax

    mov ax, word ptr last_my
    mov bx, 320
    mul bx
    add ax, word ptr last_mx
    mov di, ax

    mov dx, CURSOR_SIZE
    mov al, COLOR_CURSOR

pc_row:
    mov cx, CURSOR_SIZE
    push di

pc_pix:
    mov byte ptr es:[di], al
    inc di
    loop pc_pix

    pop di
    add di, 320
    dec dx
    jnz pc_row

    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret

_hide_cursor:
    push bp
    mov bp, sp

    cmp byte ptr cursor_drawn, 0
    je hc_done

    call _restore_bg
    mov byte ptr cursor_drawn, 0

hc_done:
    mov sp, bp
    pop bp
    ret

_show_cursor:
    push bp
    mov bp, sp

    cmp byte ptr cursor_drawn, 1
    je sc_done

    call _save_bg
    call _paint_cursor
    mov byte ptr cursor_drawn, 1

sc_done:
    mov sp, bp
    pop bp
    ret

_mouse_init:
    push bp
    mov bp, sp

    mov byte ptr mouse_ok, 0

    mov ax, 0
    int 33h

    cmp ax, 0
    je mouse_init_done

    mov byte ptr mouse_ok, 1

    mov ax, 7
    mov cx, 0
    mov dx, 319
    int 33h

    mov ax, 8
    mov cx, 0
    mov dx, 199
    int 33h

mouse_init_done:
    mov sp, bp
    pop bp
    ret

_init_font:
    push bp
    mov bp, sp
    mov sp, bp
    pop bp
    ret

_button_by_pos:
    push bp
    mov bp, sp
    push bx
    push cx
    push dx
    push si
    push di

    mov si, word ptr [bp + arg1]
    mov di, word ptr [bp + arg2]

    cmp si, BTN_X
    jb bbp_none

    cmp di, BTN_Y
    jb bbp_none

    mov ax, si
    sub ax, BTN_X
    mov bx, BTN_W + BTN_GAP
    xor dx, dx
    div bx

    cmp ax, 5
    jae bbp_none

    cmp dx, BTN_W
    jae bbp_none

    mov cx, ax

    mov ax, di
    sub ax, BTN_Y
    mov bx, BTN_H + BTN_GAP
    xor dx, dx
    div bx

    cmp ax, 4
    jae bbp_none

    cmp dx, BTN_H
    jae bbp_none

    mov bx, 5
    mul bx
    add ax, cx

    cmp ax, word ptr btn_count
    jae bbp_none

    cmp ax, 19
    jne bbp_ret

    mov ax, 14
    jmp bbp_ret

bbp_none:
    mov ax, 0FFFFh

bbp_ret:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    mov sp, bp
    pop bp
    ret

_eval_gui:
    push bp
    mov bp, sp

    mov word ptr current_base, 10

    push offset str_input
    call _check
    pop ax
    jc eg_err_format

    push offset str_val1
    call _atoi
    add sp, 2

    cmp byte ptr atoi_error, 1
    je eg_err_format

    cmp byte ptr atoi_error, 2
    je eg_err_range

    mov word ptr num_a, ax

    push offset str_val2
    call _atoi
    add sp, 2

    cmp byte ptr atoi_error, 1
    je eg_err_format

    cmp byte ptr atoi_error, 2
    je eg_err_range

    mov word ptr num_b, ax

    mov ax, word ptr num_a
    mov bx, word ptr num_b
    mov cl, byte ptr char_op

    cmp cl, '+'
    je eg_add

    cmp cl, '-'
    je eg_sub

    cmp cl, '*'
    je eg_mul

    cmp cl, '/'
    je eg_div

    cmp cl, '%'
    je eg_mod

    jmp eg_err_op

eg_add:
    add ax, bx
    jo eg_err_overflow
    cwd
    jmp eg_print_res

eg_sub:
    sub ax, bx
    jo eg_err_overflow
    cwd
    jmp eg_print_res

eg_mul:
    imul bx

    test ax, 8000h
    jz eg_mul_positive

    cmp dx, 0FFFFh
    jne eg_err_overflow
    jmp eg_print_res

eg_mul_positive:
    cmp dx, 0
    jne eg_err_overflow
    jmp eg_print_res

eg_div:
    test bx, bx
    jz eg_err_div

    cmp ax, 8000h
    jne eg_div_normal

    cmp bx, 0FFFFh
    je eg_err_overflow

eg_div_normal:
    cwd
    idiv bx
    cwd
    jmp eg_print_res

eg_mod:
    test bx, bx
    jz eg_err_div

    cmp ax, 8000h
    jne eg_mod_normal

    cmp bx, 0FFFFh
    je eg_err_overflow

eg_mod_normal:
    cwd
    idiv bx
    mov ax, dx
    cwd
    jmp eg_print_res

eg_print_res:
    mov word ptr res_low, ax
    mov word ptr res_high, dx

    push offset str_res
    push word ptr res_low
    push word ptr res_high
    call _itoa32_dec
    add sp, 6

    push offset str_res
    push offset str_input
    call _strcpy
    add sp, 4

    push offset str_input
    call _strlen
    add sp, 2

    mov word ptr input_len, ax
    jmp eg_done

eg_err_format:
    push offset gui_err_fmt
    push offset str_input
    call _strcpy
    add sp, 4
    jmp eg_update_len

eg_err_range:
    push offset gui_err_range
    push offset str_input
    call _strcpy
    add sp, 4
    jmp eg_update_len

eg_err_overflow:
    push offset gui_err_overflow
    push offset str_input
    call _strcpy
    add sp, 4
    jmp eg_update_len

eg_err_div:
    push offset gui_err_div
    push offset str_input
    call _strcpy
    add sp, 4
    jmp eg_update_len

eg_err_op:
    push offset gui_err_op
    push offset str_input
    call _strcpy
    add sp, 4

eg_update_len:
    push offset str_input
    call _strlen
    add sp, 2
    mov word ptr input_len, ax

eg_done:
    mov sp, bp
    pop bp
    ret

_handle_input_char:
    push bp
    mov bp, sp
    push ax
    push bx

    mov al, byte ptr [bp + arg1]

    cmp al, 27
    jne hic_not_esc

    mov byte ptr quit_flag, 1
    jmp hic_done

hic_not_esc:
    cmp al, 13
    jne hic_not_enter

    call _eval_gui
    call _draw_display
    jmp hic_done

hic_not_enter:
    cmp al, 8
    jne hic_not_back

    cmp word ptr input_len, 0
    je hic_redraw

    dec word ptr input_len
    mov bx, word ptr input_len
    mov byte ptr [str_input + bx], 0
    jmp hic_redraw

hic_not_back:
    cmp al, 'C'
    je hic_clear

    cmp al, 'c'
    jne hic_not_clear

hic_clear:
    mov word ptr input_len, 0
    mov byte ptr str_input, 0
    jmp hic_redraw

hic_not_clear:
    cmp al, '0'
    jb hic_check_ops

    cmp al, '9'
    jbe hic_append

hic_check_ops:
    cmp al, '+'
    je hic_append

    cmp al, '-'
    je hic_append

    cmp al, '*'
    je hic_append

    cmp al, '/'
    je hic_append

    cmp al, '%'
    je hic_append

    cmp al, ' '
    je hic_append

    jmp hic_done

hic_append:
    cmp word ptr input_len, 120
    jae hic_done

    mov bx, word ptr input_len
    mov byte ptr [str_input + bx], al

    inc word ptr input_len

    mov bx, word ptr input_len
    mov byte ptr [str_input + bx], 0

hic_redraw:
    call _draw_display

hic_done:
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret

_delay:
    push bp
    mov bp, sp
    push cx
    push dx

    mov cx, word ptr [bp + arg1]

delay_outer:
    push cx
    mov cx, 0FFFFh

delay_inner:
    loop delay_inner

    pop cx
    loop delay_outer

    pop dx
    pop cx
    mov sp, bp
    pop bp
    ret

_highlight_char:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx

    xor cx, cx
    mov al, byte ptr [bp + arg1]

highlight_loop:
    cmp cx, word ptr btn_count
    jae highlight_done

    mov bx, cx
    cmp byte ptr [btn_chars + bx], al
    jne highlight_next

    cmp cx, 14
    jne hi_normal_btn

    push 1
    call _draw_exit_button
    add sp, 2

    push 2
    call _delay
    add sp, 2

    push 0
    call _draw_exit_button
    add sp, 2

    jmp highlight_done

hi_normal_btn:
    push 1
    push cx
    call _draw_button
    add sp, 4

    push 2
    call _delay
    add sp, 2

    push 0
    push cx
    call _draw_button
    add sp, 4

    jmp highlight_done

highlight_next:
    inc cx
    jmp highlight_loop

highlight_done:
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret

_gui_main:
    push bp
    mov bp, sp

    call _set_video_mode13
    call _set_green_palette
    call _init_font
    call _draw_gui
    call _mouse_init

    mov word ptr last_mx, 0
    mov word ptr last_my, 0
    mov byte ptr cursor_drawn, 0

gui_loop:
    cmp byte ptr quit_flag, 1
    je gui_exit

    mov ah, 01h
    int 16h
    jz gui_mouse_check

    mov ah, 00h
    int 16h
    xor ah, ah

    call _hide_cursor

    push ax
    call _highlight_char
    add sp, 2

    push ax
    call _handle_input_char
    add sp, 2

gui_mouse_check:
    cmp byte ptr mouse_ok, 1
    jne gui_redraw_cursor

    mov ax, 3
    int 33h

    cmp cx, 316
    jbe mouse_x_ok

    mov cx, 316

mouse_x_ok:
    cmp dx, 196
    jbe mouse_y_ok

    mov dx, 196

mouse_y_ok:
    cmp cx, word ptr last_mx
    jne mouse_moved

    cmp dx, word ptr last_my
    je mouse_check_btn

mouse_moved:
    push bx
    push cx
    push dx

    call _hide_cursor

    pop dx
    pop cx
    pop bx

    mov word ptr last_mx, cx
    mov word ptr last_my, dx

mouse_check_btn:
    test bx, 1
    jz gui_mouse_released

    cmp word ptr mouse_prev_btn, 0
    jne gui_redraw_cursor

    mov word ptr mouse_prev_btn, bx

    push dx
    push cx
    call _button_by_pos
    add sp, 4

    cmp ax, 0FFFFh
    je gui_redraw_cursor

    cmp ax, 14
    jne mouse_normal_btn

    call _hide_cursor

    push 1
    call _draw_exit_button
    add sp, 2

    push 2
    call _delay
    add sp, 2

    push 0
    call _draw_exit_button
    add sp, 2

    mov ax, 27
    push ax
    call _handle_input_char
    add sp, 2

    jmp gui_redraw_cursor

mouse_normal_btn:
    push ax
    call _hide_cursor
    pop ax

    push ax

    push 1
    push ax
    call _draw_button
    add sp, 4

    push 2
    call _delay
    add sp, 2

    pop ax

    push ax

    push 0
    push ax
    call _draw_button
    add sp, 4

    pop ax

    mov bx, ax
    mov al, byte ptr [btn_chars + bx]
    xor ah, ah

    push ax
    call _handle_input_char
    add sp, 2

    jmp gui_redraw_cursor

gui_mouse_released:
    mov word ptr mouse_prev_btn, 0

gui_redraw_cursor:
    call _show_cursor
    jmp gui_loop

gui_exit:
    call _set_text_mode

    mov sp, bp
    pop bp
    ret

start:
    mov ax, data
    mov ds, ax

    mov ax, stack
    mov ss, ax
    mov sp, 1024

    mov byte ptr str_input, 0
    mov word ptr input_len, 0
    mov byte ptr quit_flag, 0
    mov word ptr current_base, 10
    mov word ptr mouse_prev_btn, 0
    mov byte ptr mouse_ok, 0
    mov byte ptr after_eval, 0
    mov byte ptr cursor_drawn, 0
    mov word ptr last_mx, 0
    mov word ptr last_my, 0

    call _gui_main
    call _exit0

code ends
end start