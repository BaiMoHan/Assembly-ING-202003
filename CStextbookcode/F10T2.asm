;10进制转二进制子模块F10T2
;子模块F10T2
;功能：将10进制ASCII码转换为有符号二进制数->AX/EAX
;如果该数溢出或者为非法数，则-1->SI
;其中，可转换的16位有符号数范围-32767-+32767
;32位有符号数的范围位-2147483647-+2147483647
;详细功能见习题四4.10题
;入口参数：
;SI——指向待转换的十进制ASCII码存储区首址
;CX——存放该10进制ASCII码串的长度
;DX——存放16位或者32位标志
;出口参数：
;转换后的二进制数->AX/EAX
;如果该数溢出或者为非法数，则-1->SI
;所使用的寄存器和变量为
;EBX——中间寄存器
;SIGN——正负数标记
		NAME F10T2
		PUBLIC F10T2
.386
DATA SEGMENT USE16 PARA PUBLIC 'DATA'
SIGN DB ?
DATA ENDS
CODE SENGMENT USE16 PARA PUBLIC 'CODE'
		ASSUME CS:CODE,DS:DATA
F10T2 PROC;P156
		PUSH EBX;保护现场
		MOV EAX,0;EAX清0
		MOV SIGN,0;初始化标志位为0
		MOV BL,[SI];取字符->BL
		CMP BL,'+';判断是否开头为+号
		JE F10;是+号就直接转为F10,先存+号 
		CMP BL,'-';看看是否为-号 
		JNE NEXT2;不是符号说明就是一般十进制数，跳转到NEXT2
		MOV SIGN,1;如果有负号，就将-1->SIGN
F10:
		DEC CX;数字串长度-1
		JZ ERR;除开前面的+号后，如果长度为0就转错误处理
NEXT1:
		INC SI;移到下一个字符处
		MOV BL,[SI];读取下一个字符
NEXT2:
		CMP BL,'0';比较是不是比0的ASCII码还小
		JB ERR;比‘0’小就跳转到错误
		SUB BL,30H;ASCII码转数值
		MOVZX EBX,BL;BL进行0拓展放置EBX中
		IMUL EAX,10;（EAX）乘以10再放到EAX
		JO ERR;溢出了就跳转错误
		ADD EAX,EBX;就是(EAX)乘以10+(EBX)->EAX
		JO ERR;溢出了就跳转错误
		JS ERR;超出范围了就跳转错误
		JC ERR;进位就跳转错误
		DEC CX;数字串长度-1
		JNZ NEXT1;数字串长度未变成0就继续恢复十进制
		CMP DX,16;判断是否为16位标志
		JNE PP0;不是16位标志就跳转PP0,前面的溢出判断都是针对32位的
		CMP EAX,7FFFH;是16位标志就看最后转换的数是否超过16位有符号数的范围
		JA ERR;超过了就转错误
PP0:
		CMP SIGN,1;判断是否为正数
		JNE QQ;正数就跳转QQ
		NEG EAX;是负数就求补才是负数的补码表示
QQ:
		POP EBX;恢复现场
		RET	;返回
ERR:
		MOV SI,-1;遇到错误将-1赋值给SI
		JMP QQ
F10T2 ENDP
CODE ENDS
	END








