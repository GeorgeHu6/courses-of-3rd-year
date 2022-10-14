DATA SEGMENT

DATA ENDS

; 按惯例清出一片区域作为堆栈段
STACK SEGMENT STACK
    DW 128 DUP(0)
STACK ENDS

CODE SEGMENT
    ASSUME cs:CODE, DS:DATA, SS:STACK
START:           
    ; 设置段寄存器
    mov ax, DATA
    mov ds, ax
    ; 以1234H为例，便于观察
    ; 计划将01H、02H、03H、04H最终分别放在AL、BL、CL、DL中
    MOV AX, 1234H
    ; 每次操作完需要右移4位，预先存入CL中
    MOV CL, 4
    ; 将AX低八位放入DX低八位中
    MOV DL, AL
    ; 只取DX低四位04H
    AND DL, 00001111b
    ; 逻辑右移4位（即1位十六进制）
    SHR AX, CL
    ; 由于进行大于1的移位只能使用CL
    ; 原本应该给CL的结果先放在CH中
    MOV CH, AL
    ; 同样只取低四位得到03H
    AND CH, 00001111b
    ; 逻辑右移1位十六进制
    SHR AX, CL
    ; 同样的操作
    MOV BL, AL
    ; 取得低四位02H
    AND BL, 00001111b
    ; 这次移位完之后AL中剩下的就是01H
    SHR AX, CL
    ; 赋值回来就可以
    MOV CL, CH
    ; 为了看起来更直观，将CH清零
    XOR CH, CH
    
    ; 带返回值退出的功能号
    MOV AX, 4C00H
    INT 21H
CODE ENDS

END START
