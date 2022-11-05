; 一些宏定义
WINWIDTH = 40
WINTOP = 8 
WINLEFT = 20
WINBOTTOM = 17
WINRIGHT= WINLEFT+WINWIDTH-1
COLOR = 74H
PAGEN = 0
CTRL_C = 03H


CODE    SEGMENT
    ASSUME CS:CODE
START:
    ; 置当前显示页为pageN
    MOV AL, PAGEN
    MOV AH, 5
    INT 10H
    ; 初始化窗口
    ; 左上角为wintop行winleft列，左上角为winbottom行winright列
    ; 行属性为color（即设置前景色与背景色）
    MOV CH, WINTOP
    MOV CL, WINLEFT
    MOV DH, WINBOTTOM
    MOV DL, WINRIGHT
    MOV BH, COLOR
    MOV AL, 0
    MOV AH, 6
    INT 10H
    ; 置光标位置于当前页窗口的左下角
    MOV BH, PAGEN
    MOV DH, WINBOTTOM
    MOV DL, WINLEFT
    MOV BH, COLOR
    MOV AH, 2
    INT 10H
NEXT:
    ; 从键盘读入字符，若为ctrl+c，跳转到退出代码
    MOV AH, 0
    INT 16H
    CMP AL, CTRL_C
    JE EXIT
    ; 若输入的字符不为ctrl+c，显示一次输入的字符
    MOV BH, PAGEN
    MOV CX, 1
    MOV AH, 0AH
    INT 10H
    ; 准备向下一列移动光标
    INC DL
    ; 若右侧要超出窗口右边界，向上卷动一行并将光标置于最左侧
    CMP DL, WINRIGHT+1
    JNE SETCUR
    MOV CH, WINTOP
    MOV CL, WINLEFT
    MOV DH, WINBOTTOM
    MOV DL, WINRIGHT
    MOV BH, COLOR
    MOV AL, 1
    MOV AH, 6
    INT 10H
    MOV DL, WINLEFT
SETCUR:  ; 置光标位置到最新位置
    MOV BH, PAGEN
    MOV AH, 02H
    INT 10H
    ; 继续输入
    JMP NEXT
EXIT:  ; 退出代码
    MOV AH, 4CH
    INT 21H
CODE ENDS
    END START
