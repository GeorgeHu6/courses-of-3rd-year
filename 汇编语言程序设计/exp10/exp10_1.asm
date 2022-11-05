DATA    SEGMENT
    DATA1   DB  'INPUT NUMBER1-8 (QUIT: Ctrl-C)--$'
DATA    ENDS

STACK   SEGMENT PARA    STACK   'STACK'
    STA DW 32 DUP(?)
STACK   ENDS

CODE    SEGMENT
    ASSUME  CS:CODE, DS:DATA, SS:STACK, ES:DATA
START:
    ; 设置段寄存器
    MOV AX, DATA
    MOV DS, AX      
    MOV ES, AX      
KKK:
    ; 输出换行回车
    MOV AH, 02H     
    MOV DL, 0DH
    INT 21H
    MOV AH, 02H     
    MOV DL, 0AH
    INT 21H
    ; 输出提示字符串
    MOV AH, 09H     
    MOV DX, OFFSET DATA1
    INT 21H
    ; 读取输入
    MOV AH, 01H
    INT 21H
    ; 输入Ctrl-C
    CMP AL, 03H
    JZ  PPP
    ; 输入不在1~9内就跳转TTT
    CMP AL, 30H
    JBE TTT
    CMP AL, 39H
    JA  TTT
    ; 将数字的ASCII转为值
    SUB AL, 30H     
    XOR AH, AH      
    MOV BP, AX      
GGG:
    ; 输出响铃符
    MOV AH, 02H     
    MOV DL, 07H
    INT 21H
    ; BX为等待循环的次数控制
    mov bx, 100
back:
    ; CX控制每一次的等待循环中等待的时钟刷新次数
    ;（事实上只是个大概，并不绝对精确）
    mov cx,663
    PUSH AX
WAITF1:
    ; 取得61H端口第5个比特的信息，是随时钟刷新而变化的
    IN  AL,61H
    AND AL,10H
    ; 检查时钟是否反转
    CMP AL,AH
    JE WAITF1
    ; 时钟反转则将此时的状态记录在AH中
    MOV AH,AL
    ; 一次时钟刷新结束，跳转，开始检测下一次
    LOOP WAITF1
    ; CX次时钟刷新完成，即一次等待循环完成
    ; 此时将BX-1，开始下一次等待循环
    POP ax
    dec bx
    jnz back
    ; BX次等待循环完成
    DEC BP      
    JNZ GGG
TTT: ; 输入不合法就要求重新输入
    JMP KKK     
PPP:  ; 退出代码
    MOV AX, 4C00H   
    INT 21H
CODE    ENDS
    END START
