DATA SEGMENT
    ERROR_MSG DB 10,'Invalid Input',10,'$'
    INPUT_MSG DB 10,'Input a char between a and z',10,'$' 
DATA ENDS

STACK SEGMENT STACK
    DW 128 DUP(0)
STACK ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STACK
START:
    mov ax, DATA
    mov ds, ax
    
INPUT: ; 输入读取段代码
    ; 显示输入提示信息
    mov ah, 9
    mov dx, OFFSET INPUT_MSG
    int 21h
    ; 从键盘读取一个字符作为输入
    mov ah, 1
    int 21h
    
    ; 由于AL中存了用户输入的字符，入栈进行保护
    push ax
    
    ; 检查输入是否在a-z范围内
    cmp al, 'a'
    jb ERROR_OUTPUT
    cmp al, 'z'
    ja ERROR_OUTPUT
    
    ; 输出个换行符
    mov dl, 10
    mov ah, 6
    int 21h

CALCU:  ; 计算转换字母代码
    ; 将AX弹出，重新得到用户输入的字符
    pop ax
    ; 计算结果保持在DL中
    mov dl, 'z'
    ; 偏移量存在AL
    sub al, 'a'
    ; 倒着从z减回来
    sub dl, al
    ; 输出（DL）
    mov ah, 6
    int 21H
EXIT:  ; 退出代码  
    MOV AX, 4C00H
    INT 21H

ERROR_OUTPUT: ; 输入非法提示信息输出代码
    ; 显示错误提示信息
    mov ah, 9
    mov dx, OFFSET ERROR_MSG
    int 21h
    ; 输入非法，要求用户重新输入
    jmp INPUT

CODE ENDS

END START
