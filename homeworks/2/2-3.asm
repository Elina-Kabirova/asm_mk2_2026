
data_seg segment para public
	max_len db 240
	act_len db ?
	string db 256 dup(?)
data_seg ends

stack_seg segment para stack
db 256 dup("?")
stack_seg ends

code_seg segment para

assume cs:code_seg,ds:data_seg,ss:stack_seg

start:
	
	mov ax, data_seg
	mov ds, ax
	mov ax, stack_seg
	mov ss, ax
	
	mov ah, 0Ah
	mov dx, offset max_len
	int 21h
	
	mov bx, 0
	mov bl, byte ptr[act_len]
	mov si, offset string
	mov byte ptr[si+bx], '$'
	mov ah, 09h
	mov dx, offset string
	int 21h
	
	mov ax, 4c00h
	int 21h
	
code_seg ends
end start
	
	
	