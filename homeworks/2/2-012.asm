
data_seg segment para public
str db "Hello, asm!",0Dh,0Ah,"$"
data_seg ends

stack_seg segment para stack
db 256 dup("?")
stack_seg ends

code_seg segment para

assume cs:code_seg,ds:data_seg,ss:stack_seg

start:
	
	mov ax,data_seg
	mov ds,ax
	mov ax,stack_seg
	mov ss,ax
	
	lea bx, str + 7
	mov byte ptr [bx], '1'
	lea bx, [bx + 1]
	
	mov dl, [bx]
	mov ah, 02h
	int 21h
	
	mov al, 01h
	int 21h
	
	mov dx,offset str
	mov ah,09h
	int 21h
	
	mov ax, 4c00h
	int 21h
	
code_seg ends
end start
