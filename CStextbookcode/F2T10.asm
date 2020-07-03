;二进制转十进制子模块F2T10
;子模块：F2T10
;功能：将AX/EAX中的有符号二进制数转为十进制ASCII码输出，
;其中，子程序RADIX的功能为将EAX中的无符号二进制数按（EBX）
;所规定的基制转换为ASCII码送入SI所指示的缓存区中
;调用F2T10的入口参数：
;AX/EAX——存放待转换的二进制数
;DX——存放16位或32位标志
;调用F2T10的出口参数：
;F2T10子程序无出口参数
;所使用的变量：
;BUF——存放转换后的十进制ASCII码数字串的字节缓冲区首址
;调用RADIX的出口参数
;所求P进制ASCII码数字串按高位在前、低位在后的顺序放在以
;SI为指针的字节缓冲区中
;SI——指向字节缓冲区中最后一个ASCII码的下一个字节处
;所使用的寄存器：
;CX——P进制数字入栈出栈时的计数器
;EDX——按除法指令和系统功能调用的规定使用
;;
		NAME F2T10
		PUBLIC F2T10
.386
DATA SEGMENT USE16 PARA PUBLIC 'DATA'
F2T10BUF DB 12 DUP(?)
DATA ENDS
CODE SEGMENT USE16 PARA PUBLIC 'CODE'
		ASSUME CS:CODE,DS:DATA
F2T10 PROC FAR
		PUSH EBX;保护现场
		PUSH SI;保护现场
		LEA SI,F2T10BUF
		CMP DX,32;判断是32位的还是16位的，从而选择对EAX还是AX操作
		JNE B;若是32位的数，对EAX操作就转B
		MOVSX EAX,AX;16位操作就将（AX）符号位拓展32位->EAX
B:
		OR EAX,EAX;为了得到标志位
		JNS PLUS;不为负就跳转到PLUS
		NEG EAX;为负就变正
		MOV BYTE PTR [SI],'-';将负号先送到SI指向的字节缓冲区
		INC SI;字节缓冲区指针移到下一位
PLUS:
		MOV EBX,10;RADIX的入口参数，EBX存放待转换的进制基数
		CALL RADIX ;调用RADIX子程序将(EAX)转为10进制ASCII吗
		MOV BYTE PTR [SI],'$';在SI末尾补上'$'
		LEA DX,F2T10BUF;显示转换后的十进制数
		MOV AH,9
		INT 21H
		POP SI;恢复现场
		POP EBX;恢复现场
		RET ;返回
F2T10 ENDP