DATA SEGMENT
    X DW 8
    ; 系数数组
    COF DW 02H,03H,05H,08H,06H
DATA ENDS

STACK SEGMENT STACK
    DW 128 DUP(0)
STACK ENDS

CODE SEGMENT
    ASSUME cs:CODE, DS:DATA, SS:STACK
START:  ; 初始化代码段       
    ; 设置段寄存器
    mov ax, DATA
    mov ds, ax
    ; ax清零，后面始终保持内容在ax
    mov ax, 0
    ; si用作循环变量
    mov si, 0
CALCU:  ; 进行主体计算
    ; 循环体共执行5次
    cmp si, 0AH
    jz exit
    ; 在每次计算中都进行乘X再加上COF[SI]的操作
    mov dx, X
    imul dx  
    add ax, COF[si]
    ; si += 2
    inc si
    inc si
    ; 继续循环
    jmp CALCU
exit:  ; 退出段代码
    MOV AX, 4C00H
    INT 21H
CODE ENDS

END START
