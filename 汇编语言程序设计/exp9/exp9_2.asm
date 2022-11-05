DATA SEGMENT
    SCORE DB 76, 69, 84, 90, 73, 88, 99, 63, 100, 80
    S6 DB 0
    S7 DB 0
    S8 DB 0
    S9 DB 0
    S10 DB 0
    TMP DB 0
DATA ENDS 

STACK SEGMENT STACK
    DB 128 DUP(0)
STACK ENDS 

CODE SEGMENT
    ASSUME cs:CODE, ds:DATA, ss:STACK
START:
main PROC FAR
    ; 设置段寄存器
    mov ax, DATA
    mov ds, ax
    xor ax, ax
    ; 循环10次
    mov cx, 10
    ; 根据循环次数得到分数数组的偏移量ax
AGAIN:
    mov si, 10
    sub si, cx
    ; 通过变量传参
    mov al, SCORE[si]
    mov TMP, al
    call calcu
    loop AGAIN
    ; 退出代码
    mov ax, 4C00H
    int 21H
main ENDP

calcu PROC NEAR
    ; 保护寄存器
    push ax
    push bx
    push cx
    push dx
    ; 取得参数到ax中
    mov al, TMP
    mov ah, 0
    cmp ax, 100
    jne L1
    inc S10
    jmp DONE
L1: ; 90~99分
    cmp ax, 90
    jb L2
    inc S9
    jmp DONE
L2: ; 80~89分
    cmp ax, 80
    jb L3
    inc S8
    jmp DONE
L3: ; 70~79分
    cmp ax, 70
    jb L4
    inc S7
    jmp DONE
L4: ; 60~69分
    cmp ax, 60
    jb DONE
    inc S6
DONE:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
calcu ENDP

CODE ENDS
    END START