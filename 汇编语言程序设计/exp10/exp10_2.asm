DATA    SEGMENT
    COUNT DW 1
    MESS DB 'The bell is ring!', 0DH, 0AH, '$'
DATA    ENDS
CODE    SEGMENT
    ASSUME   CS: CODE, DS: DATA, ES: DATA
MAIN    PROC    FAR
START:
    ; 设置段寄存器
    MOV AX, DATA
    MOV DS, AX
    ; 获得1CH中断向量的地址存在ES:BX
    MOV AL, 1CH
    MOV AH, 35H
    INT 21H
    ; 保护获得的地址
    PUSH ES
    PUSH BX
    PUSH DS
    ; 获得标签RING代码处的段地址和偏移地址存于AX:DX
    MOV DX, OFFSET RING
    MOV AX, SEG RING
    ; 设置中断向量1CH为DS:DX，即标签RING处
    MOV DS, AX
    MOV AL, 1CH
    MOV AH, 25H
    INT 21H
    ; 恢复DS
    POP DS
    ; 获取中断开关情况，若定时器中断关，则将其开启
    IN  AL, 21H
    AND AL, 11111110B
    OUT 21H, AL
    ; 开中断
    STI

; 使用SI、DI做两层循环，通过单纯循环完成延时
; 在这个延时中，定时器不断触发1CH的软中断，反复响铃
    MOV DI, 60000
DELAY:
    MOV SI, 60000
DELAY1:
    DEC SI
    JNZ DELAY1
    DEC DI
    JNZ DELAY
    ; 恢复寄存器内容，并将1CH中断向量原先指向的地址恢复
    POP DX
    POP DS
    MOV AL, 1CH
    MOV AH, 25H
    INT 21H
    ; 程序结束
    MOV AH, 4Ch
    INT 21H
MAIN    ENDP

RING:
    ; 保护寄存器
    PUSH DS
    PUSH AX
    PUSH CX
    PUSH DX
    ; 切换到正常的数据段上
    MOV AX, DATA
    MOV DS, AX
    STI
    DEC COUNT
    JNZ EXIT
    ; 显示字符串
    MOV DX, OFFSET MESS
    MOV AH, 09H
    INT 21H
    ; 响铃次数
    MOV DX, 50
    IN AL, 61H
    ; 清零低2位
    AND AL, 0FCH
SOUND:
    ; 翻转第二位，开启或关闭声音
    XOR AL, 02
    OUT 61H, AL
    ; 等待循环
    MOV CX, 0F400H
WAIT1:
    LOOP WAIT1
    DEC DX
    JNE SOUND
    ; 每COUNT个1CH中断响铃一次
    MOV COUNT, 18
EXIT:
    ; 关中断
    CLI 
    POP DX
    POP CX
    POP AX
    POP DS
    ; 开中断
    sti
    ; 从栈中弹出IP、CS和标志位寄存器
    IRET
CODE  ENDS
    END START
