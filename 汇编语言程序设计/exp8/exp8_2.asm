CODE    SEGMENT
    ASSUME  CS:CODE
START:
    ; 切换显示模式到16色文本（分辨率80*25）
    MOV AX, 0002H
    INT 10H
    ; 置光标位置到第0页、第5行第024H列
    MOV AH, 02H
    MOV BH, 00H
    MOV DX, 0524H
    INT 10H
    ; 在第0页光标处以2C属性显示字符‘G’，显示8次
    MOV AH, 09H
    MOV BH, 00H
    MOV BL, 2CH
    MOV AL, 'G'
    MOV CX, 8
    INT 10H
    ; 置光标位置到第0页、第0AH行第024H列
    MOV AH, 02H
    MOV BH, 00H
    MOV DX, 0A24H
    INT 10H
    ; 在第0页光标处以1E属性显示字符‘O’，显示8次
    MOV AH, 09H
    MOV BH, 00H
    MOV BL, 1EH
    MOV AL, 'O'
    MOV CX, 8
    INT 10H
    ; 置光标位置到第0页、第0FH行第024H列
    MOV AH, 02H
    MOV BH, 00H
    MOV DX, 0F24H
    INT 10H
    ; 在第0页光标处以04FH属性显示字符‘O’，显示8次
    MOV AH, 09H
    MOV BH, 00H
    MOV BL, 4FH
    MOV AL, 'O'
    MOV CX, 8
    INT 10H
    ; 置光标位置到第0页、第014H行第024H列
    MOV AH, 02H
    MOV BH, 00H
    MOV DX, 1424H
    INT 10H
    ; 在第0页光标处以02H属性显示字符‘D’，显示8次
    MOV AH, 09H
    MOV BH, 00H
    MOV BL, 02H
    MOV AL, 'D'
    MOV CX, 8
    INT 10H
    ; 退出代码
    MOV AH, 4CH
    INT 21H
CODE    ENDS
    END START
