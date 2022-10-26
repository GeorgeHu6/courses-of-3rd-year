DATA SEGMENT
    ; 待排序序列
    ARRAY DW 5, 10, 2, 3, 4, 6, 8, 7, -9, 1
    ; 两个循环变量
    I DW 0
    J DW 9
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
    ; 设置循环变量i的初值
    ; for i=0
    mov I, 0
Iloop:
    ; 外层循环
    ; for i<10
    cmp I, 10
    jae EXIT
    ; 设置循环变量j的初值
    ; for j=9
    mov J, 9
Jloop:
    ; 内层循环
    ; for j>i
    mov bx, I
    cmp J, bx
    jbe Iinc
    ; ax = array[j-1]
    mov si, J
    shl si, 1
    mov ax, ARRAY[si-2]
    ; 判断是否要交换相邻元素
    ; if (ax < array[j])
    cmp ax, ARRAY[si]
    jae Jdec
    ; 交换array[j-1]和array[j]
    mov bx, ARRAY[si]
    mov ARRAY[si-2], bx
    mov ARRAY[si], ax
Jdec:
    ; j循环一遍后自减1
    ; for j--
    dec J
    jmp Jloop
Iinc:
    ; i循环一遍后自增1
    ; for i++
    inc I
    jmp Iloop
EXIT:  ; 退出代码
    mov ax, 4C00H
    int 21H
CODE ENDS
END START