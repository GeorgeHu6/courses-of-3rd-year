DATA SEGMENT
    X DW 5
    Y DW 6
    Z DW 18
    W DW 0
DATA ENDS

STACK SEGMENT STACK
    DW 128 DUP(0)
STACK ENDS

CODE SEGMENT
    ASSUME cs:CODE, DS:DATA, SS:STACK
START:
; 设置段寄存器
    mov ax, DATA
    mov ds, ax
; 将ax清零
    xor bx, bx
; 始终保持计算结果存在bx中
; X
    mov bx, X
; X+2Y
    mov ax, Y
    mov dx, 2
    imul dx
    add bx, ax
; X+2Y+5Z
    mov ax, Z
    mov dx, 5
    imul dx
    add bx, ax
; 结果存于W
    mov W, bx
    
    mov ax, 4C00H
    int 21H
CODE ENDS

END START
