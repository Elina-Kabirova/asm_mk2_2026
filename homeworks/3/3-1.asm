
data_seg segment para public
	str1_max db 240
	str1_len db ?
	str1_str db 256 dup(?)
	
	str2_max db 240
	str2_len db ?
	str2_str db 256 dup(?)
	
	str3_max db 240
	str3_len db ?
	str3_str db 256 dup(?)
	
	new_line db 0Dh, 0Ah, '$'
data_seg ends

stack_seg segment para stack
	db 256 dup(?)
stack_seg ends

code_seg segment para

assume cs:code_seg,ds:data_seg,ss:stack_seg

start:

	mov ax, data_seg
	mov ds, ax
	mov ax, stack_seg
	mov ss, ax
	
	mov ah, 0Ah
	mov dx, offset str1_max
	int 21h
	
	mov ah, 09h
	mov dx, offset new_line
	int 21h
	
	mov ah, 0Ah
	mov dx, offset str2_max
	int 21h
	
	mov ah, 09h
	mov dx, offset new_line
	int 21h
	
	mov ah, 0Ah
	mov dx, offset str3_max
	int 21h
	
	mov ah, 09h
	mov dx, offset new_line
	int 21h
	
	mov bl, byte ptr[str1_len]
	mov bh, 0
	mov si, offset str1_str
	mov byte ptr [si+bx], '$'
	mov ah, 09h
	mov dx, offset str1_str
	int 21h
	
	mov ah, 09h
	mov dx, offset new_line
	int 21h
	
	mov bl, byte ptr[str2_len]
	mov bh, 0
	mov si, offset str2_str
	mov byte ptr [si+bx], '$'
	mov ah, 09h
	mov dx, offset str2_str
	int 21h
	
	mov ah, 09h
	mov dx, offset new_line
	int 21h
	
	mov bl, byte ptr[str3_len]
	mov bh, 0
	mov si, offset str3_str
	mov byte ptr [si+bx], '$'
	mov ah, 09h
	mov dx, offset str3_str
	int 21h
	
	mov ah, 09h
	mov dx, offset new_line
	int 21h
	
	mov ax, 4c00h
	int 21h
	
code_seg ends
end start
	