;子模块：IN_CIPHER
;功能:建立对16进制数字串加密的密码（由16位大写字母组成）
;并送入密码表CIPHER,同时生成解密码送入解密表DEC_CIPHER
;入口参数:无
;出口参数:
;公共变量CIPHER和DEC_CIPHER
;CIPHER——密码表首址，CIPHER+2中存放对16进制数字加密的密码
;DEC_CIPHER——解密表首址，存放对加密的密文进行解密的解密码
;所使用的寄存器和主要变量
;SI——从加密表取字符指针
;DI——往解密表送字符指针
;DX——检查密码大写字符不重复外循环变量
;CX——串操作指令SCAS执行重复次数
;BX——存放密码表位移量
;AX——按DOS功能调用规定使用
;CIPHER——密码表（按输入缓冲区定义）,以CIPHER+2开始的16个字节中
;存放初始密码
;DEC_CIPHER——解密表(16个字节),初值位与密码表中初始密码对应的解密码表;;
;;;;
		NAME IN_CIPHER
		PUBLIC IN_CIPHER,CIPHER,DEC_CIPHER
IO MACRO A,B;DOS功能调用宏
		LEA DX,AX——按DOS功能调用规定使用
		MOV AH,B
		INT 21H
		ENDM
.386
DATA SEGMENT USE16 PARA PUBLIC'DATA'
STR0	DB	0AH,0DH,'PLEASE INPUT CIPHER:$'
CIPHER	DB 17,0,'NJKADCEPBIOFMLGH';密码表
DEC_CIPHER	DB	3,8,5,4,6,0BH,0EH,0FH,9,1,2,0DH,0CH,0,0AH,7;解密表 
ERR0	DB	0AH,0DH,'INPUR IS WRONG,ENCODE!$'
CRLF	DB	0AH,0DH,'$'
DATA ENDS
CODE	SEGMENT USE16 PARA PUBLIC 'CODE'
		ASSUME DS:DATA,CS:CODE,ES:DATA
IN_CIPHER PROC
BEGIN:
		IO STR0,9
		IO CIPHER,10;输入16位密码
		CMP CIPHER+1,16;判断是否输入了16位
		JNE ERR;不是16位就出错
	;以下为检查收入的16位密码中是否含有重复字符
		LEA SI,CIPHER+2;取输入密码串首址->SI
		MOV DX,16;串长度->DX
CHECK1:
		LODSB;从输入密码串中取以字符->AL,(SI)指向下一个字符
		DEC DX;其后剩下的字符串长度->DX
		JE CHE2;已全部检查完了DX=0,跳转至CHE2
		MOV CX,DX;SCAS指令执行的重复次数
		MOV DI,SI;为SCAS指令置指针
		REPNZ SCASB;将(AL)与其后字符逐一比较,看是否有相等字符
		JE ERR;有相等说明出现了重复字符,转出错处理
		JMP CHECK1;均不等,说明此字符在串中独一无二,检查下一个字符
CHE2:
		LEA SI,CIPHER+2;密码表首址->SI
		LEA DI,DEC_CIPHER;解密表首址->DI
		MOV CX,0;解密值
CHECK2:
		MOV BL,[SI];取一个密码字符->BL
		INC SI
		MOV BH,0;将BL拓展为16位
		CMP BL,'A';检查输入的16位密码是否为大写字母
		JB ERR;不是大写字母就跳转错误
		CMP BL,'Z';看是不是在A-Z之间
		JA ERR;超过Z就跳转错误
		SUB BL,'A';是大写字母就形成解密表位移量
		MOV [BX+DI],CL;将解密值送入解密表
		INC CL;解密值+1
		CMP CL,10H;检查解密值是否到16进制最大10H
		JNE CHECK2;否就形成下一个解密值
END0:	RET;返回
ERR:
		IO ERR0,9;显示错误
		JE BEGIN;转BEGIN重输
IN_CIPHER ENDP
CODE ENDS
	END





















