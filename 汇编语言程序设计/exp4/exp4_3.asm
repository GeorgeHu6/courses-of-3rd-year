DATA SEGMENT
    ERROR_MSG DB 10,'Invalid Input',10,'$'
    INPUT_MSG DB 10,'Input a letter',10,'$'
    LETTERS DB 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    INPUT_CHAR DB 0;
    IS_CHAR DB 0;
DATA ENDS

STACK SEGMENT STACK
    DW 128 DUP(0)
STACK ENDS

CODE SEGMENT

main PROC FAR  ; 主函数
    ASSUME CS:CODE, DS:DATA, SS:STACK

START:
    ; 数据段定义
    mov ax, DATA
    mov ds, ax
    ; 显示输入提示信息
    mov ah, 9
    mov dx, OFFSET INPUT_MSG
    int 21h
    ; 读入一个字符
    mov ah, 1
    int 21h
    mov INPUT_CHAR ,al
    ; 调用judge判断输入字符是否合法
    call judge
    ; 不为大小写字母直接退出
    cmp IS_CHAR, 0
    je OUTPUT_ERROR
    ; 调用calcu进行转换
    call calcu
    ; 换行显示结果并正常退出
    call clrf
    ; 此时INPUT_CHAR中的内容已经转换好了，显示即可
    mov dl, INPUT_CHAR
    mov ah, 6
    int 21h
    jmp EXIT2
OUTPUT_ERROR: ; 显示错误信息
    call outerror
EXIT2:  ; 主函数的退出位置
    mov ax, 4C00H
    int 21h
main ENDP

clrf PROC NEAR  ; 此过程用于显示换行
    ; 保护此过程中要使用的ax与dx
    push ax
    push dx

    ; 输出个换行符（ASCII为10）
    mov dl, 10
    mov ah, 6
    int 21h

    ; 还原现场
    pop dx
    pop ax
    ret
clrf ENDP

calcu PROC NEAR
    ; 保护ax寄存器
    push ax
    ; 使用内存单元进行传参
    mov al, INPUT_CHAR
    cmp al, 'a'
    ; 大于等于a的就是小写，直接-97；大写字母先加32，+32-97=-65，
    jae LOWER
    add al, 32
LOWER:  ; 小写则直接跳转此处
    sub al, 97  ; 此时al中为偏移量
    mov INPUT_CHAR, 'Z'
    sub INPUT_CHAR, al  ; 此时INPUT_CHAR中为转换后的字符

    pop ax
    ret
calcu ENDP


outerror PROC NEAR  ; 用于显示错误信息
    ; 保护子过程中要使用到的寄存器
    push ax
    push dx

    ; 显示输入无效的提示信息
    mov ah, 9
    mov dx, OFFSET ERROR_MSG
    int 21h

    pop dx
    pop ax
    ret
outerror ENDP


judge PROC NEAR  ; 用于判断输入字符是否符合要求
    ; 保护子过程中要用到的寄存器
    push cx
    push si
    mov si, 0
    ; CL作为判断条件
    mov cl, 0
    ; CH存要判断的字符
    mov ch, INPUT_CHAR
REPEAT1:
    ; 最多52次判断循环
    cmp si, 52
    je EXIT1
    ; 与LETTERS中的字符一个个比较看看是否有相同的
    cmp ch, LETTERS[si]
    jne TMP1; 不等则跳过“cl=true”
    mov cl, 1
    jmp EXIT1
TMP1: ; 推进循环
    inc si
    jmp REPEAT1
EXIT1:
    ; 使用内存单元传参，IS_CHAR保存判断的结果
    ; 1表示是字母、0表示不是
    mov IS_CHAR ,cl
    pop si
    pop cx
    ret
judge ENDP

CODE ENDS

END START
