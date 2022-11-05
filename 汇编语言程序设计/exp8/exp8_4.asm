DATA    SEGMENT
    ROW DW  0 
    COL DW  0 
    COLOR   DB  1
DATA    ENDS
CODE    SEGMENT
    ASSUME  CS:CODE,DS:DATA
START:
    ; 设置段寄存器
    MOV AX, DATA
    MOV DS, AX
    ; 取当前页号、字符列数、显示方式
    MOV AH, 15
    INT 10H
    ; 将原显示方式信息保护
    PUSH AX
    ; 设置显示模式为4色图形（分辨率为320x200）
    MOV AX, 0004H
    INT 10H
    ; 设置调色板ID
    MOV AH, 0BH
    MOV BH, 01H
    MOV BL, 00H
    INT 10H
    ; 总共要画三种颜色
    MOV CX, 3
@1:
    ; 保护寄存器
    PUSH    AX
    PUSH    CX
    PUSH    DX
    PUSH    SI
    PUSH    DI
    ; 准备写像素，AL为颜色值
    ; 写的位置在DX行、CX列
    MOV AH, 0CH
    MOV AL, COLOR
    MOV DI, 100
    MOV DX, ROW
@@1:
    MOV SI, 20
    MOV CX, COL
@@2:
    INT 10H
    ; 写一行宽为20的像素
    INC CX
    DEC SI
    JNZ @@2
    ; 反复写100行
    INC DX
    DEC DI
    JNZ @@1
    ; 恢复寄存器
    POP DI
    POP SI
    POP DX
    POP CX
    POP AX
    ; 等待用户输入
    mov ah, 01h
    int 21h
    ; 用户有输入后，隔40列，画下一种颜色，总共三种
    INC COLOR
    ADD COL, 40
    LOOP @1
    ; 恢复出原来的显示方式并将显示方式还原
    POP AX
    MOV AH, 0H
    INT 10H
    ; 退出代码
    MOV AH, 4CH
    INT 21H
CODE    ENDS
    END START
