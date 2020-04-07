;F6.ASM
;功能：实现功能六,展示货物信息并修改
;入口参数：
; AUTH——顾客状态还是店主状态标志位
; 寄存器使用：
; DI——指向F6BUF的指针
; DX——中间寄存器
; SI——Good地址的变址寄存器
; CX——输入到F6BUF中的字符个数
; AX——存放输入的字符和F2T10的入口参数传递
;子模块（程序）F10T2
;功能：将10进制ASCII码转换为有符号二进制数->AX/EAX
;如果该数溢出或者为非法数，则-1->SI
;其中，可转换的16位有符号数范围-32767-+32767
;32位有符号数的范围位-2147483647-+2147483647
;详细功能见习题四4.10题
; 入口参数：
; SI——指向待转换的十进制ASCII码存储区首址
; CX——存放该10进制ASCII码串的长度
; DX——存放16位或者32位标志
; 出口参数：
; 转换后的二进制数->AX/EAX
; 如果该数溢出或者为非法数，则-1->SI
; 所使用的寄存器和变量为
; EBX——中间寄存器
; SIGN——正负数标记
;二进制转十进制子模块F2T10
;子模块(程序)：F2T10
;功能：将AX/EAX中的有符号二进制数转为十进制ASCII码输出，
;其中，子程序RADIX的功能为将EAX中的无符号二进制数按（EBX）
;所规定的基制转换为ASCII码送入SI所指示的缓存区中
;调用F2T10的入口参数：
;AX/EAX——存放待转换的二进制数
;DX——存放16位或32位标志
;调用F2T10的出口参数：
;F2T10子程序无出口参数
; 所使用的变量：
; BUF——存放转换后的十进制ASCII码数字串的字节缓冲区首址
; 调用RADIX的出口参数
; 所求P进制ASCII码数字串按高位在前、低位在后的顺序放在以
; SI为指针的字节缓冲区中
; SI——指向字节缓冲区中最后一个ASCII码的下一个字节处
; 所使用的寄存器：
; CX——P进制数字入栈出栈时的计数器
; EDX——按除法指令和系统功能调用的规定使用
		NAME F6
		EXTRN Good:FAR
		PUBLIC F6,RADIX,F2T10,F10T2
	IF1	;将宏库在第一次扫描时加入一起汇编
		INCLUDE PHMACRO.LIB
	ENDIF
.386
DATA SEGMENT USE16 PARA PUBLIC 'DATA'
SIGN DB ?
F6BUF		DB	30 DUP(0);输入的一个10进制数字串存储区
F2T10BUF DB 12 DUP(?)
PROJECT1 DB 'Discount: $';折扣
PROJECT2 DB 'Load price: $';进货价
PROJECT3 DB 'Buy Price: $';销售价
PROJECT4 DB 'Quantity of incoming goods: $';进货总数
F6SUCEND DB 'Change finished!$';更改信息结束
DELE DB '>>$'
DATA ENDS
		STACK0 <200 DUP(0)>;调用宏指令定义堆栈
CODE SEGMENT USE16 PARA PUBLIC 'CODE'
		ASSUME DS:DATA,CS:CODE,SS:STACK
START:
F6 PROC
		PUSHA ;保护现场
		PUSHAD;保护现场
		MOV AX,DATA
		; MOV DS,AX
		MOV ES,AX
		INT 3
		; LEA DI,F6BUF
F6PRO1:
		MOV DI,OFFSET Good;取Good地址
		MOV SI,DS:[DI];取GOOD内容
		LEA DI,F6BUF
		CRLF
		WRITE PROJECT1;输出折扣信息
		MOV AX,0
		MOV AL,[SI+10];折扣->AX作为入口参数
		MOV DX,16;DX标志16位的
		CALL F2T10;调用F2T10输出折扣信息
		WRITE DELE;输出分隔符
		MOV CX,0;10进制数子串长度计数器清0
F6NEXT1:
		IN1	;1号功能调用
		CMP AL,0DH;判断是否是回车
		JNE F6P1;是一般字符就跳转F6P
		OR CX,CX;判断是否未输入
		JZ F6PRO2;直接回车就跳转F6PRO2
		JMP F6DIGIT1;不为0就转F6DIGIT准备调用F10T2模块
F6P1:
		;该指令为单字符输出指令，调用该指令后，
		;可以将累加器AL中的值传递到当前ES段的DI地址处，
		;并且根据DF的值来影响DI的值，如果DF为0，则调用该指令后，
		;DI自增1，DF——用于字符串操作指令程序设计。
		STOSB;将输入一个字符送至BUF区
		INC CX;输入的字符个数+1
		JMP F6NEXT1;转输入下一个字符
F6DIGIT1:
		LEA SI,F6BUF
		MOV DX,16;需要转换为16为二进制数
		CALL F10T2;调用F10T2子模块
		CMP SI,-1
		JE F6PRO1;遇到非法字符就跳转到F6PRO1重新输入
		MOV [SI+10],AX;新折扣放入
		JMP F6PRO2;开始进货价的显示
		
F6PRO2:
		MOV DI,OFFSET Good;取Good地址
		MOV SI,DS:[DI];取GOOD内容
		LEA DI,F6BUF
		WRITE PROJECT2;输出进货价信息
		MOV AX,[SI+11];进货价->AX作为入口参数
		MOV DX,16;DX标志16位的
		CALL F2T10;调用F2T10输出折扣信息
		WRITE DELE;输出分隔符
		MOV CX,0;10进制数子串长度计数器清0
F6NEXT2:
		IN1	;1号功能调用
		CMP AL,0DH;判断是否是回车
		JNE F6P2;是一般字符就跳转F6P
		OR CX,CX;判断是否未输入
		JZ F6PRO3;直接回车就跳转F6PRO3
		JMP F6DIGIT2;不为0就转F6DIGIT准备调用F10T2模块
F6P2:
		;该指令为单字符输出指令，调用该指令后，
		;可以将累加器AL中的值传递到当前ES段的DI地址处，
		;并且根据DF的值来影响DI的值，如果DF为0，则调用该指令后，
		;DI自增1，DF——用于字符串操作指令程序设计。
		STOSB;将输入一个字符送至BUF区
		INC CX;输入的字符个数+1
		JMP F6NEXT2;转输入下一个字符
F6DIGIT2:
		LEA SI,F6BUF
		MOV DX,16;需要转换为16为二进制数
		CALL F10T2;调用F10T2子模块
		CMP SI,-1
		JE F6PRO2;遇到非法字符就跳转到F6PRO2重新输入
		MOV [SI+11],AX;新折扣放入
		JMP F6PRO3;开始销售价的显示
		
F6PRO3:
		MOV DI,OFFSET Good;取Good地址
		MOV SI,DS:[DI];取GOOD内容
		LEA DI,F6BUF
		WRITE PROJECT3;输出销售价信息
		MOV AX,[SI+13];销售价->AX作为入口参数
		MOV DX,16;DX标志16位的
		CALL F2T10;调用F2T10输出折扣信息
		WRITE DELE;输出分隔符
		MOV CX,0;10进制数子串长度计数器清0
F6NEXT3:
		IN1	;1号功能调用
		CMP AL,0DH;判断是否是回车
		JNE F6P3;是一般字符就跳转F6P
		OR CX,CX;判断是否未输入
		JZ F6PRO4;直接回车就跳转F6PRO4
		JMP F6DIGIT3;不为0就转F6DIGIT准备调用F10T2模块
F6P3:
		;该指令为单字符输出指令，调用该指令后，
		;可以将累加器AL中的值传递到当前ES段的DI地址处，
		;并且根据DF的值来影响DI的值，如果DF为0，则调用该指令后，
		;DI自增1，DF——用于字符串操作指令程序设计。
		STOSB;将输入一个字符送至BUF区
		INC CX;输入的字符个数+1
		JMP F6NEXT3;转输入下一个字符
F6DIGIT3:
		LEA SI,F6BUF
		MOV DX,16;需要转换为16为二进制数
		CALL F10T2;调用F10T2子模块
		CMP SI,-1
		JE F6PRO3;遇到非法字符就跳转到F6PRO3重新输入
		MOV [SI+13],AX;新折扣放入
		JMP F6PRO4;开始进货量的显示
		
F6PRO4:
		MOV DI,OFFSET Good;取Good地址
		MOV SI,DS:[DI];取GOOD内容
		LEA DI,F6BUF
		WRITE PROJECT4;输出进货量信息
		MOV AX,[SI+15];进货量->AX作为入口参数
		MOV DX,16;DX标志16位的
		CALL F2T10;调用F2T10输出折扣信息
		WRITE DELE;输出分隔符
		MOV CX,0;10进制数子串长度计数器清0
F6NEXT4:
		IN1	;1号功能调用
		CMP AL,0DH;判断是否是回车
		JNE F6P4;是一般字符就跳转F6P
		OR CX,CX;判断是否未输入
		JZ F6SUC;直接回车就跳转F6SUC
		JMP F6DIGIT4;不为0就转F6DIGIT准备调用F10T2模块
F6P4:
		;该指令为单字符输出指令，调用该指令后，
		;可以将累加器AL中的值传递到当前ES段的DI地址处，
		;并且根据DF的值来影响DI的值，如果DF为0，则调用该指令后，
		;DI自增1，DF——用于字符串操作指令程序设计。
		STOSB;将输入一个字符送至BUF区
		INC CX;输入的字符个数+1
		JMP F6NEXT4;转输入下一个字符
F6DIGIT4:
		LEA SI,F6BUF
		MOV DX,16;需要转换为16为二进制数
		CALL F10T2;调用F10T2子模块
		CMP SI,-1
		JE F6PRO4;遇到非法字符就跳转到F6PRO1重新输入
		MOV [SI+15],AX;新折扣放入
		JMP F6SUC;功能6结束模块
		
F6SUC:
		CRLF;输出一个换行
		WRITE F6SUCEND;输出完成信息
F6UNEND:
		POPAD;恢复现场
		POPA;恢复现场
		RET;返回
F6 ENDP

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
		CMP BL,'9';比较是不是比9的ASCII码还大
		JA ERR;比‘9’大就跳转到错误
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


CODE ENDS
	END START