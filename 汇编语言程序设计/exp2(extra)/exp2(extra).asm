data segment
; 按照题意要求，从NUM开始依次存放a、b、c、d
    NUM DW 2, -4, -18, -13              
; 最后要将结果存入RESL，此处先声明一下
    RESL DW 0                           
data ends

; 按照习惯申请一下堆栈
stack segment stack
    DW 128 dup(0)
stack ends

code segment
; 定义段和段寄存器的关系
    assume cs:code, ds:data, ss:stack
start:
; 设置段寄存器        
    mov ax, data
    mov ds, ax
; 清空ax
    xor ax, ax

; 过程中始终保持最终结果存在ax中
    mov ax, NUM
    mov bx, NUM+2
; 乘法不能使用立即数，在cx中存好常数10
    mov cx, 0AH
; 完成a*b
    imul bx
; 完成(a*b)+10
    add ax, 0AH    
; 完成((a*b)+10)*10
    imul cx
; 完成((a*b)+10)*10+c
    mov bx, NUM+4 
    add ax, bx
; 完成(((a*b)+10)*10+c)*10
    imul cx
; 完成(((a*b)+10)*10+c)*10+d
    mov bx, NUM+6
    add ax, bx
; 将最终计算结果存入RESL中
    mov RESL, ax
; 程序带返回码终止
    mov ax, 4c00h
    int 21h    
code ends
end start