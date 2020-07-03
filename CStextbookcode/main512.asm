;主模块MAIN
;功能：
;1.当用户需要重新输入密码时调用IN_CIPHER子模块
;2.加密解密命令处理：
;#;显示命令提示符,等待用户键入加密或解密命令
;#E;调用子模块ED_CIPHER中的子程序ENCRYPT
;#D;调用子模块ED_CIPHER中的子程序DECLASSI
;#^Z;结束操作,返回DOS
;所使用的寄存器
;AX,DX按DOS1、2、9、10号功能调用规定使用
		NAME MAIN
EXTRN IN_CIPHER:NEAR,ENCRYPT:NEAR,DECLASSI:NEAR
IO MACRO A,B;DOS系统功能调用宏
	LEA DX,AX
	MOV AH,B
	INT 21H
	ENDM
.386
DATA SEGMENT USE16 PARA PUBLIC 'DATA'
STR0	DB	0AH,0DH,'Cipher has existed, do you modify it? $'
ERR1	DB	'Illegal comment! $'
CRLF	DB 	0AH,0DH,'$'
DATA ENDS
STACK SEGMENT USE16 STACK 'STACK'
		DB DUP(0)
STACK ENDS
CODE SEGMENT USE16 PARA PUBLIC 'CODE'
		ASSUME CS:CODE,DS:DATA,SS:STACK
START:
		MOV AX,DATA
		MOV DS,AX
		MOV ES,AX
		IO STR0,9;宏调用9号功能输出字符串
		MOV AH,1;输入一个字符
		INT 21H
		CMP AL,'Y';判断是否需要改变密码
		JE Z
		CMP AL,'y';可能是小写y
		JE Z
		JMP COMMA;不改变密码转COMMA
Z:		CALL IN_CIPHER
COMMA:
		IO CRLF,9;输出一个换行回车
		MOV DL,'#'
		MOV AH,2;显示命令提示符'#'
		INT 21H
		MOV AH,1;输入命令
		INT 21H
		CMP AL,0DH;回车就是退出
		JE EXIT;回车跳转退出
		CMP AL,'E';E命令
		JNE DD0;不是E命令就转DD0
		IO CRLF,9;输出一个换行回车
		CALL ENCRYPT;调用加密子程序
		JMP COMMA;转输入新命令
DD0:
		CMP  AL,'D';判断是否为D命令
		JNE ER1;不是就转错误ER1
		CALL DECLASSI;D命令调用DECLASSI子程序
		JMP COMMA;转输入新命令
ER1:
		IO ERR1,9;不是E命令也不是D命令，则显示出错
		JMP COMMA;转输入新命令
EXIT:
		MOV AH,4CH
		INT 21H
CODE	ENDS
		END START
		













