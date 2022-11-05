STACK   SEGMENT PARA    STACK   'STACK'
    DB 64 DUP(0)
STACK   ENDS

DSEG    SEGMENT
; 两只老虎
    MUS_FREQ    DW 2 DUP(262,294,330,262)
                DW 2 DUP(330,349,391)
                DW 2 DUP(391,440,391,349,330,262)
                DW 330,196,262
                DW 294,196,262,-1
    ; 一拍设为12
    MUS_TIME    DW 2 DUP(12, 12, 12, 12)
                DW 2 DUP(12,12,24)
                DW 2 DUP(6,6,6,6,12,12)
                DW 2 DUP(12,12,24)
DSEG    ENDS

CSEG    SEGMENT
    ASSUME  CS:CSEG,SS:STACK,DS:DSEG
MUSIC   PROC
    ; 设置段寄存器
    MOV AX,DSEG
    MOV DS,AX
    ; 取得频率及时间的偏移地址
    LEA SI,MUS_FREQ
    LEA BP,DS:MUS_TIME
FREQ:
    ; 判断是否到最后一个音
    ; DI存音调，BX存音长
    MOV DI,[SI]
    CMP DI,-1
    JE END_MUS
    MOV BX,DS:[BP]
    ; 保护寄存器
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI
    ; 向43H端口输出182，初始化扬声器的设置
    MOV AL,0B6H
    OUT 43H,AL
    ; 计算音调号=12348H/频率，得到的结果在AX中
    MOV DX,12H
    MOV AX,348CH
    DIV DI
    ; 42H端口宽度为8位，AX需要分两次传入，先低字节再高字节
    OUT 42H,AL
    MOV AL,AH
    OUT 42H,AL
    ; 读取61H端口内容，并把低两位置为1，使得扬声器发声
    IN  AL,61H
    MOV AH,AL
    OR AL,3
    OUT 61H,AL
    ; bx=bx*4
    add bx,bx
    add bx,bx
back:
    ; 等待663个时钟刷新为一个等待循环
    mov cx, 300
    ; 此时AH为61H端口原状态，AL为发声状态
    PUSH AX
WAITF1:  ; 等待一个时钟刷新时间（非精确）
    ; 取时钟刷新切换位
    IN AL,61H
    AND AL,10H
    CMP AL,AH
    JE  WAITF1
    MOV AH,AL
    LOOP WAITF1
    POP ax
    ; 按照音长进行等待，等待期间一直发声
    dec bx
    jnz back
    ; 向61H端口输出其原来未发声的状态
    MOV AL,AH
    OUT 61H,AL
    ; 恢复寄存器
    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    ; 播放下一个音
    ADD SI,2
    ADD BP,2
    JMP FREQ
END_MUS:  ; 退出代码
    MOV AX,4C00H
    INT 21H
MUSIC   ENDP
CSEG    ENDS
    END MUSIC
