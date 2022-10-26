DATA SEGMENT
    ARRAY DW 5, 10, 2, 3, 4, 6, 8, 7, -9, 1
    ; 两个循环变量
    I DW 0
    J DW 9
    ; 用于二分查找时的左右标记
    LEFT DW 0
    RIGHT DW 9
    ; 若找到了目标数，将其数组下标存在index中
    INDEX DW -1
    ; 待查找的目标数
    TARGET DW -1
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
; 和程序1一样的代码，对序列进行排序
    ; for i=0
    mov I, 0
Iloop:
    ; for i<10
    cmp I, 10
    jae FIND
    ; for j=9
    mov J, 9
Jloop:
    ; for j>i
    mov bx, I
    cmp J, bx
    jbe Iinc
    ; ax = array[j-1]
    mov si, J
    shl si, 1
    mov ax, ARRAY[si-2]
    ; if (ax < array[j])
    cmp ax, ARRAY[si]
    jae Jdec
    ; 交换array[j-1]和array[j]
    mov bx, ARRAY[si]
    mov ARRAY[si-2], bx
    mov ARRAY[si], ax
Jdec:
    ; for j--
    dec J
    jmp Jloop
Iinc:
    ; for i++
    inc I
    jmp Iloop

; 二分查找从这里开始
FIND:
    ; 初始化左右标志（下标）
    mov LEFT, 0
    mov RIGHT, 9
    ; cx中存放中间位置值
    mov cx, 0
AGAIN:
    ; while循环体
    ; while (left <= right)
    mov bx, LEFT
    cmp bx, RIGHT
    jg END
    ; 计算中间位置（下标）
    ; bx=(left+right)/2
    mov bx, LEFT
    add bx, RIGHT
    shr bx, 1
    ; 乘2得到字节位置
    mov si, bx
    shl si, 1
    ; 得到中间位置的值
    ; cx=array[bx]
    mov cx, ARRAY[si]
EQ: ; 找到了目标值
    ; if (target==cx)
    cmp TARGET, cx
    jne LT
    ; 把下标记录在INDEX中
    mov INDEX, bx
    ; break
    jmp END
LT: ; 目标值比中间值小，向右找
    ; else if (target<cx)
    cmp TARGET, cx
    jae GT
    ; left=bx+1
    inc bx
    mov LEFT, bx
    jmp AGAIN
GT: ; 目标值比中间值大，向左找
    ; else
    ; right=bx-1
    dec bx
    mov RIGHT, bx
    jmp AGAIN

END: ; 判断是否找到了，即查看INDEX是否为负
    mov ax, INDEX
    AND ax, ax
    js NO
YES: ; 找到了
    mov dl, 'Y'
    mov ah, 2
    int 21H
    jmp EXIT
NO: ; 没找到
    mov dl, 'N'
    mov ah, 2
    int 21H
EXIT: ; 退出代码
    mov ax, 4C00H
    int 21H
CODE ENDS
END START