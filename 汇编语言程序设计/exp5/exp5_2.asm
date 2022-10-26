DATA    SEGMENT
    ; 数组BUF
    BUF DB  38H,73H,1FH
    ; 字符串常量段
    NEG_STR DB 'Negative', 10, '$'
    POS_STR DB 'Positive', 10, '$'
    ZERO_STR DB 'Zero', 10, '$'
    ; 变量段
    ORG 1000
    I DW 0

DATA	ENDS

STACK SEGMENT STACK
    DW 128 DUP(0)
STACK ENDS

CODE    SEGMENT

main PROC FAR 
    ASSUME  CS:CODE,DS:DATA,SS:STACK
START:
    ; 定义数据段
    MOV AX,DATA
    MOV DS,AX
    ; 循环变量初始化
    MOV I, 0
    jmp LOOP_JUDGE
L1:  ; BUF[i]<0
    mov si, I
    mov al, BUF[si]
    cbw
    test ax, ax
    jns L2
    lea dx, NEG_STR
    call printDx
    jmp LOOP_INC
L2:  ; BUF[i]>0
    mov si, I
    mov al, BUF[si]
    cbw
    test ax, ax
    jle L3
    lea dx, POS_STR
    call printDx
    jmp LOOP_INC
L3:  ; else，即BUF[i]==0
    lea dx, ZERO_STR
    call printDx
    jmp LOOP_INC
LOOP_INC:  ; 循环变量+1
    add I, 1
LOOP_JUDGE:  ; 循环判断
    cmp I, 3
    jb L1
EXIT:  ; 退出段
    mov ax, 4C00H
    int 21H
main ENDP

; 输出DX处的内容
printDx PROC NEAR:
    push ax
    mov ah, 9
    int 21h
    pop ax
    ret
printDx ENDP
    
CODE    ENDS
    END START
