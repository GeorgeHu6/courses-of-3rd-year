DATA SEGMENT
	I DW 1
	SUM DW 0
DATA ENDS

STACK SEGMENT STACK
	DW 128 DUP(0)
STACK ENDS

CODE SEGMENT
	ASSUME cs:CODE, ds:DATA, ss:STACK
START:
	; 设置段寄存器
	mov ax, DATA
	mov ds, ax
	; 初始化变量
	; for (i=1)
	mov I, 1
	mov SUM, 0
Iloop: ; i循环
	; for(i<=100)
	cmp I, 100
	ja EXIT
	; sum+=i
	mov ax, I
	add SUM, ax
Iinc: ; 循环变量i自增 
	inc I
	jmp Iloop
EXIT:  ; 退出代码
    mov ax, 4C00H
    int 21H
CODE ENDS
END START

