;P192例5.11主函数main
;主模块中寄存器及主要变量的使用分配如下
;AX——中间寄存器
;BX——往ARR字存储区送数指针，初值为ARR
;CX——作以逗号分隔的一个十进制数字串长度计数器，初值为0
;DX——按系统功能调用的规定使用
;DI——往BUF字节存储区送输入的字符指针，初值为BUF
;SI——调用F10T2子模块的入口参数，作从BUF区取字符指针
;ARR——经转换得到的二进制数组存储区首址
;COUNT——ARR存储区中数据元素个数计数器，初值为0
;SIGN——输入字符串处理结束标志，1——处理结束，0——处理未结束
;编写该例的主模块时，调用了宏库MACRO.LIB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	NAME MAIN
	EXTRN F10T2:NEAR F2T10:NEAR QUEUE:NEAR
	IF1	;将宏库在第一次扫描时加入一起汇编
		INCLUDE MACRO.LIB
	ENDIF
.386
DATA SEGMENT USE16 PARA PUBLIC 'DATA'
BUF		DB	8 DUP(0);输入的一个10进制数字串存储区
ARR 	DB 	32 DUP(0);转换后的二进制数组存储区
SIGN 	DB 	0;是否输完的标志，1为输完，0为未输完
COUNT 	DW	0;转换后的二进制数组元素个数计数器
ERROR	DB	'IS ILLEAGAL DIGIT! $'
DATA ENDS
		STACK0 <200 DUP(0)>;调用宏指令定义堆栈
CODE SEGMENT USE16 PARA PUBLIC 'CODE'
		ASSUME DS:DATA,CS:CODE,SS:STACK
START:
		MOV AX,DATA
		MOV DS,AX
		MOV ES,AX
		LEA BX,ARR;数组ARR首址->BX
		MOV COUNT,0;初始0->ARR数据元素个数计数器COUNT
		MOV SIGN,0;初始0->串输入处理完标志SIGN
BEG:
		LEA DI,BUF;数字串存储区首址->DI
		MOV CX,0;十进制数字串长度计数器清0
NEXT0:
		MOV AH,1;1号功能调用，输入一个字符->AL
		INT 21H
		CMP AL,',';判断输入的字符是否是逗号
		JE DIGIT;是逗号说明一个数输完
		CMP AL,0DH;判断是回车吗
		JNE P;是一般字符就跳转P
		CMP COUNT,0;输入回车就是结束,判断是否输入了数
		JE EXIT;一个数也没有输入，就直接转结束
		INC SIGN;已经全部输完，标志置1
		JMP DIGIT;转DIGIT准备调用F10T2子模块
P:	
		;该指令为单字符输出指令，调用该指令后，
		;可以将累加器AL中的值传递到当前ES段的DI地址处，
		;并且根据DF的值来影响DI的值，如果DF为0，则调用该指令后，
		;DI自增1，DF——用于字符串操作指令程序设计。
		STOSB;将输入一个字符送至BUF区
		INC CX;输入的字符个数+1
		JMP NEXT0;转输入下一个字符

DIGIT:
		LEA SI,BUF
		MOV DX,16;需要转换为16位二进制数
		CALL F10T2;调用F10T2子模块 
		CMP SI,-1
		JE ERR;如果是非法数则跳转出错处处理
		MOV [BX],AX;转换的16位二进制数送入ARR区
		ADD BX,2;移到ARR的下一区
		INC COUNT;计数器+1
		CMP SIGN,1;是否全部输完
		JE END0;全部输完就转排序
		JMP BEG;未全部输完就继续输入下一个数
END0:	;排序
		MOV CX,COUNT;待排序数的个数->CX
		LEA SI,ARR;待排序数数组首址->SI
		MOV BP,1;对有符号数排序标志置1
		CALL QUEUE;调用排序子模块QUEUE对有符号数排序
		CRLF	;输出回车换行
		MOV BX,COUNT;待输出数的个数->BX
		LEA SI,ARR;待输出数组的首址->SI
OUT2:	;输出排序后的数组
		MOV AX,[SI];取一个待输出数送AX
		ADD SI,2;移动至下一个待输出数
		MOV DX,16;待输出数是16位2进制数
		CALL F2T10;调用F2T10子模块将AX中的数输出
		OUT1 ',';输出逗号作为隔离符
		DEC BX
		JNE OUT2;BX!=0,未输完，则继续输出
		JMP EXIT;输完就转结束
ERR:	;非法数给出错误提示
		WRITE ERROR
EXIT:	;退出
		MOV AH,4CH
		INT 21H
CODE	ENDS
	END START












