DATA SEGMENT
    X DB -5
    Y DB 0
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
    mov bl, X
L1:  ; if X>0
    test bl, bl
    jle L2
    mov Y, 1
    jmp EXIT
L2:  ; else if (X == 0)
    test bl, bl
    jnz L3
    mov Y, 0
    jmp EXIT
L3:  ; else
    mov Y, -1
EXIT:  ; 退出段
    mov ax, 4C00H
    int 21H
CODE ENDS
END START