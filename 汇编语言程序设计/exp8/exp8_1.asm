DATA    SEGMENT
    A   DB  'How do you do?',0AH,0DH
        DB  '$'
    ; B作为输入缓冲区，最多输入20个字符
    B   DB  20,?,20 DUP(?)
DATA    ENDS
CODE    SEGMENT
    ASSUME  CS:CODE,DS:DATA
START:
    ; 设置段寄存器
    MOV AX, DATA
    MOV DS, AX
    ; 显示字符串A
    MOV AH, 09H
    LEA DX, A
    INT 21H
    ; 键盘输入到缓冲区，需要输入回车键结束输入
    ; 也就是说实际能够看到的输入只能19个字符
    LEA DX, B
    MOV AH, 0AH
    INT 21H
    ; 输出个换行符将输入和输出分开到两行
    MOV DL, 0AH   
    MOV AH, 02H
    INT 21H
    ; 获得实际输入的字符串长度
    MOV AL, B+1     
    MOV AH, 0
    ; 输入字符串实际长度放在SI中
    MOV SI, AX
    ; 输入字符串的开始位置存在DX中
    MOV DX, OFFSET B+2
    MOV BX, DX
    ; 在输入字符串的末尾加上字符串结束标记‘$’
    MOV BYTE PTR [BX+SI+1], '$'
    ; 调用21H中断显示DS:DX处的字符串
    MOV AH, 09H
    INT 21H
    ; 退出代码
    MOV AH, 4CH
    INT 21H
CODE    ENDS
    END START
