DATA SEGMENT
	A DW 0, 16, 7, 17, 19, 2, 12, 6, 14, -4, 13, -2, -1, 15, 20
	B DW 17, 24, 21, -6, 19, 5, 11, -1, 12, -3, 1, 16, 4, 22, 3, 7, 6, -5, 15, 25
	C DW 15 DUP(0)
	; 记录相同元素的个数
	COUNT DW 0
	; 循环变量
	I DW 0
	J DW 0
DATA ENDS

; 清零栈段空间
STACK SEGMENT STACK
	DW 128 DUP(0)
STACK ENDS

CODE SEGMENT
	; 设置段寄存器
	ASSUME cs:CODE, ds:DATA, ss:STACK
START:
	mov ax, DATA
	mov ds, ax
	; 初始化变量
	; BX记录C数组中当前可以存数的位置，每次要加2
	mov bx, 0
	mov I, 0
	mov J, 0
Iloop: ; 外层i循环
	cmp I, 15
	jae EXIT
	; for (j=0)
	mov J, 0
Jloop: ; 内层j循环
	cmp J, 20
	jae Iinc
	; if (A[i] == B[j])
	mov si, I
	; 注意将下标乘2转为字节位置
	shl si, 1
	mov ax, A[si]
	mov si, J
	shl si, 1
	cmp ax, B[si]
	jne Jinc
	; count++
	add COUNT, 1
	; C[bi] = A[i]
	mov C[bx], ax
	; bx+=2
	add bx, 2
	; break
	jmp Iinc
Jinc: ; 循环变量j自增
	; for(j++)
	inc J
	jmp Jloop
Iinc:	; 循环变量i自增
	; for(i++)
	inc I
	jmp Iloop
EXIT:  ; 退出代码
    mov ax, 4C00H
    int 21H

CODE ENDS
END START
