; 宏定义绘制的行列起点和终点，以及颜色
COL_START = 155
COL_END = 165
ROW_START = 0
ROW_END = 200
COLOR = 1110b

DATA SEGMENT
    ROW DW 0 
    COL DW 0 
DATA ENDS

STACK SEGMENT STACK
    DW 128 DUP(0)
STACK ENDS


CODE SEGMENT
    ASSUME  CS:CODE,DS:DATA
START:
    ; 设置段寄存器
    MOV AX, DATA
    MOV DS, AX
    ; 获取当前显示模式并进行保护
    mov ah, 0FH
    int 10H
    push ax
    push bx
    ; 设置显示模式256色图形（分辨率320x200）
    mov ax, 0013H
    INT 10H
    ; 初始化变量
    mov ROW, ROW_START
    mov COL, COL_START
    mov cx, ROW_END-ROW_START
DRAW_ROW:
    mov COL, COL_START
    push ax
    push bx
    push cx
    push dx
DRAW_LINE:
    cmp COL, COL_END
    jae NEXT
    ; 绘制点
    mov dx, ROW
    mov cx, COL
    mov al, COLOR
    mov ah, 0CH
    mov bh, 0
    int 10H
    inc COL
    jmp DRAW_LINE
NEXT:
    pop dx
    pop cx
    pop bx
    pop ax
    inc ROW
    loop DRAW_ROW
    ; 等待用户输入
    mov ah, 01h
    int 21h
EXIT:  ; 退出代码
    ; 还原最初的显示模式
    pop bx
    pop ax
    mov ah, 0
    int 10H
    mov ah, 4CH
    int 21H
CODE ENDS
    END START
