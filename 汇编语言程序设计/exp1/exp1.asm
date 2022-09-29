DATA	SEGMENT							;数据段定义开始
	X	DB	0E5H						;此处为标准十六进制表示，定义了一个1字节长的数E5，并命名为X
	Y	DB	34H							;定义了一个1字节长的数34，并命名为Y
	W	DW	?							;定义了一个1字长（2字节）的数，暂时不写入具体值，命名为W
DATA	ENDS							;数据段定义结束
CODE	SEGMENT							;定义代码段开始
		ASSUME	CS:CODE,DS:DATA			;定义段和段寄存器的关系
;代码的真正开始，这段代码完成了一字节长的加法：X+Y，最后把结果放入数据段中定义1的一个字长的W中
START:	MOV	AX,	DATA					;将汇编阶段分配的数据段段首地址存入AX寄存器
		MOV	DS,	AX						;初始化数据段段寄存器
		XOR	AH,	AH						;将AX的高八位清零
		MOV	AL,	X						;将在数据段中定义的X存入AX寄存器的低八位
		ADD	AL,	Y						;将在数据段中定义的Y加入AX寄存器的低八位
		ADC	AH,	0						;使用ADC将进位标志寄存器CF中的值加到AX寄存器高八位中
		MOV	W,	AX						;至此，一字节加法X+Y已经完成，结果在AX中，将其存入数据段
		MOV	AH,	4CH						;将4C存入AX的高八位中，这是程序带返回码终止的功能号
		INT		21H						;进行DOS系统调用中断
CODE	ENDS							;代码段定义结束
		END START						;整个汇编语言源程序结束
