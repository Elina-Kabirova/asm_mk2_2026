data_seg segment para public
buf db 241(?)
data_seg ends

stack_seg segment para stack
db 256 dup("?")
stack_seg ends

code_seg segment para 

assume 	cs:code_seg,ds:data_seg,ss:stack_seg

start:

	mov ax,data_seg
	mov ds,ax
	mov ax,stack_seg
	mov ss,ax

	mov ah, 3fh
    mov bx, 0
    mov cx, 240
    mov dx, offset buf
    int 21h
	
	mov cx, ax
    mov ah, 40h
    mov bx, 1    
	mov dx, offset buf
    int 21h

	mov ax,4c00h
	int 21h

code_seg ends
end start
