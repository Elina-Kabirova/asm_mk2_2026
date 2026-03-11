data_seg segment para public
x dw 2
y dw 3

a dw 2
b dw 2

z dw ? ;res (x*y)/(x+y)
c dw ? ;res (a+b)^2
d dw ? ;res (a+b)^3

sum dw ?
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

	; (x*y)/(x+y)
	mov ax, x
	add ax, y
	mov sum, ax
	mov ax, x
	imul y
	idiv sum
	mov z, ax
	
	; (a+b)^2
	mov ax, a
	add ax, b
	mov sum, ax
	imul ax
	mov c, ax
	
	; (a+b)^3
	mov ax, sum
	imul ax
	imul sum
	mov d, ax

	mov ax,4c00h
	int 21h

code_seg ends
end start
