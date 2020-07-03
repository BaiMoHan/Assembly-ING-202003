;子程序名：RADIX
;功能：将EAX中的32位无符号二进制数转为P进制数（16位段）
;入口参数：
;EAX——存放待转换的32位无符号二进制数
;EBX——存放要转换数制的记述
;SI——存放转换后的P进制ASCII码数字串的字节缓冲区首址
;出口参数：
;所求P进制ASCII码数字串按高位在前、低位在后的顺序存放在以SI为指针的字节缓冲区中
;SI——指向字节缓冲区中最后一个ASCII码的下一个字节处
;CX——P进制数字入栈、出栈时的计数器
;EDX——做除法时存放被除数高位或者余数
.386
RADIX PROC
		;保护现场
		PUSH CX
		PUSH EDX
		XOR CX,CX
LOP1:	XOR EDX,EDX
		DIV EBX ;(EAX)除以P，所得商->EAX,余数入栈
		PUSH DX;先得的余数最后是高位的数
		INC CX	;CX记录余数的个数
		OR EAX,EAX
		JNZ LOP1;若(EAX)!=0，则继续求余转换循环
LOP2:	POP AX	;弹出的数就是之前求的余数
		CMP AL,10;看看是不是10以内的
		JB L1;是10以内的就可以直接进行ASCII码转换
		ADD AL,7;不小于10的数字转换要改成A,补充ASCII码缺少的
L1:		ADD AL,30H;数值+30H后就转换成了相应数字的ASCII码
		MOV [SI],AL;将转换后的ASCII码送至SI所代表的缓存区中
		INC SI;SI移到缓存区下一个地址处
		LOOP LOP2;CX-1->CX,CX!=0,则继续循环
		;恢复现场
		POP EDX
		POP CX
		RET
RADIX	ENDP
		