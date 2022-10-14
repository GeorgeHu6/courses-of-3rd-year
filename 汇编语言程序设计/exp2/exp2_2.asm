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
    xor ax, ax
; 完成X+Y+Z计算，最终结果保持存在ax中
    mov ax, X
    add ax, Y
    add ax, Z
; 将计算结果存入W中
    mov W, ax
; 设置21H的带返回值退出的功能码 
    mov ax, 4C00H
    int 21H
CODE ENDS

END START
