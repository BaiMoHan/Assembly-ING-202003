;子模块ED_CIPHER
;子模块ED_CIPHER包含两个子程序：ENCRYPT和DECLASSI
;1.ENCRYPT子程序的功能为:
;从键盘输入待加密的16进制字符串,经加密后送入密文表IN_CHAR中
;入口参数:
;外部变量CIPHER+2为密码表首址
;出口参数:
;密文表IN_CHAR存放已加密的密文,供解密时用
;所使用的寄存器和主要变量
;DI——往密文表送加密后的密文指针
;BX——按XLAT指令规定保存密码表首址
;AX、DX按DOS功能调用规定使用
;IN_CHAR——密文表，即16进制数字经加密后的存储区
;2.DECLASSI子程序的功能为：
;将密文表IN_CHAR中存放的密文解密后存放在明文表OBJECT中
;入口参数:
;外部变量DEC_CIPHER为解密表首址
;IN_CHAR为密文表首址
;出口参数：
;明文表OBJECT存放已解密的明文;
;所使用的寄存器和主要变量：
;SI——从密文表中取密文指针
;DI——往明文表中送解密后的明文指针
;BX——按XLAT指令规定保存密码表首址
;AX、DX按DOS功能调用规定使用
;OBJECT——明文表，即将密文表中的密文解密成明文后的数据存储区
;;;
		NAME ED_CIPHER
		PUBLIC ENCRYPT,DECLASSI
		EXTRN CIPHER:BYTE,DEC_CIPHER:BYTE
IO	MACRO A,B;DOS系统功能调用宏
	LEA DX,A
	MOVV AH,B 
	INT 21H
	ENDM
.386
DATA SEGMENT USE16 PARA PUBLIC 'DATA'
OBJECT DB 40 DUP(0);解密后的明文数据存储区
IN_CHAR	DB 40 DUP(0);密文表（加密后的16进制串存储区）
CRLF	DB 0AH,0DH,'$'
ERR0	DB 0AH,0DH,'ILLEGAL DIGIT!',0AH,0DH,'$'
DATA ENDS
CODE	SEGMENT USE16 PARA PUBLIC 'CODE'
		ASSUME CE:CODE,DS:DATA,ES:DATA
ENCRYPT PROC
		LEA DI,IN_CHAR;密文表首址->DI
		LEA BX,CIPHER+2;密码表首址->BX
IN_TXT:
		MOV AH,1;输入一位待加密的16进制数->AL
		INT 21H
		CMP AL,1AH;是否为结束符Ctrl+Z
		JNE GM;不是就跳转GM
		STOSB;是结束符就送至加密表
		RET ;返回主程序
GM:
		CMP AL,'0'
		JB ER0;比0小就是错误
		CMP AL,'9'
		JBE NUM;转数字
		CMP AL,'A'
		JB ER0;比A小就是错误
		CMP AL,'F'
		JA ER0;比F大就是错误
		SUB AL,7;为了后面更好的转数值
NUM:	
		SUB AL,30H;ASCII码转数值
		XLAT CIPHER+2;查密码表将16进制转为密文
		STOSB;将密文存入密文表
		JMP IN_TXT;转IN_TXT准备再输入明文
ER0:
		IO ERR0,9;显示错误信息
		JMP IN_TXT;转IN_TXT准备再输入明文
ENCRYPT ENDP

DECLASSI PROC
		LEA SI,IN_CHAR;密文表首址->SI
		LEA DI,OBJECT;明文表首址->DI
		LEA BX,DEC_CIPHER;解密表首址->BX
NEXT0:
		LODSB;取一密文字符->AL
		CMP AL,1AH;是否为结束符Ctrl+Z
		JE RET3;是结束符就转RET3
		SUB AL,41H;不是结束符酒形成解密表位移量->AL
		XLAT DEC_CIPHER;从解密表转换为明文->AL
		STOSB;明文送至明文表
RET3:
		STOSB;结束符送至明文表
		RET;返回主程序
DECLASSI ENDP
CODE ENDS
	ENDS














