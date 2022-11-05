DATA SEGMENT
	N DW 2
	SUM DW 1
DATA ENDS

STACK SEGMENT STACK
	DW 128 DUP(0)
STACK ENDS

CODE SEGMENT
	ASSUME cs:CODE, ds:DATA, ss:STACK
START:
	mov ax, DATA
	mov ds, ax
	; 初始化变量
	mov SUM, 1
	mov N, 2
	mov ax, 0
AGAIN:
	; while(sum <= 200)
	cmp sum, 200
	jg EXIT
	; 减少指令，将n*(n+1)转换为n^2+n
	; n^2+n存在ax中
	; ax = n*n+n
	mov ax, N
	imul ax
	add ax, N
	; 往sum上加
	; sum += ax
	add SUM, ax
	; n++
	inc N
	jmp AGAIN
EXIT:  ; 退出代码
    mov ax, 4C00H
    int 21H

CODE ENDS
END START
