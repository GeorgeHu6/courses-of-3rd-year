DATA SEGMENT
    ; 定义好要检查的字符串
    STRING DB 'aBCEFghi15OXyZ', 0DH
DATA ENDS

STACK SEGMENT STACK
    ; 堆栈段清零
    DW 128 DUP(0)
STACK ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STACK
START:
    ; 定义数据段
    mov ax, DATA
    mov ds, ax
    ; si作为循环变量，先清零
    mov si, 0
EXAM:  ; 循环体，用于查看是否到了字符串末
    ; 一个个字符读入到AL
    mov al, STRING[si]
    ; 检查是否为0DH
    cmp al, 0DH
    ; 若为0DH，直接跳转到退出段的代码
    jz EXIT
    ; si++
    inc si
    ; 进行循环
    jmp EXAM
EXIT:  ; 退出段
    ; 将结果保存到CX中
    mov cx, si
    ; 程序返回的功能码
    MOV AX, 4C00H
    INT 21H

CODE ENDS

END START
