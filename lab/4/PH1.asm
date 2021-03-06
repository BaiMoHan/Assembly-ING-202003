		NAME MAIN
		EXTRN RADIX:FAR,F10T2:FAR,F2T10:FAR,F6:FAR
		PUBLIC AUTH,Good
	IF1	;将宏库在第一次扫描时加入一起汇编
		INCLUDE PHMACRO.LIB
	ENDIF
.386
STACK SEGMENT USE16 PARA STACK 'STACK'
 DB 200 DUP(0)
STACK ENDS

DATA SEGMENT USE16
	STACKBAK DB 400 DUP(0);定义一个堆栈用作切换
	BNAME DB 'peihan',0 ;老板姓名
	BPASS DB 'test',0,0,0;密码
	SHOPNAME DB 0AH,0DH,'------SHOP--------','$'
	AUTH DB 0 ;当前登录状态,0表示顾客状态
	N EQU 10
	M EQU 10000
	;提示信息
	TAB	DB '0123456789ABCDEF'
	ADDRESS DB '0000','$'
	ADDTEXT DB 0AH,0DH,'The SS address is',0AH,0DH,'$'
	NameText DB 0AH,0DH,'Please enter your username ', '$'
	PassText DB 0AH,0DH,'Please enter your password ', '$'
	CountText DB 0AH,0DH,'Compute successfully ','$'
	WrongName DB 0AH,0DH,'Wrong username','$'
	WrongPass DB 0AH,0DH,'Wrong password','$'
	FailSearch DB 0AH,0DH,'There is no such thing ','$'
	FailOrder DB 0AH,0DH,'Order failed ','$'
	SearchSuc DB 0AH,0DH,'Search successfully','$'
	ShopSuc DB 0AH,0DH,'Order successfully',0AH,0DH,'$'
	Success DB 0AH,0DH,'Load successfully','$'
	Choose	DB 0AH,0DH,'Please input your choice ','$'
	Query	DB 0AH,0DH,'Please enter the item name you want to query ', '$'
	;初始菜单信息
	OneText	DB 0AH,0DH,'1.Login or relogin','$'
	TwoText DB 0AH,0DH,'2.Search item and show information','$'
	ThrText DB 0AH,0DH,'3.Order for goods','$'
	FouText DB 0AH,0DH,'4.Compute recommendation degree','$'
	FivText DB 0AH,0DH,'5.Ranking','$'
	SixText	DB 0AH,0DH,'6.Modify product information','$'
	SenText	DB 0AH,0DH,'7.Migration environment','$'
	EigText	DB 0AH,0DH,'8.Show data address','$'
	NinText DB 0AH,0DH,'9.Exit','$'
	PROJECT1 DB 'Discount: $';折扣
	PROJECT2 DB 'Load price: $';进货价
	PROJECT3 DB 'Buy Price: $';销售价
	PROJECT4 DB 'Quantity of incoming goods: $';进货总数
	ENVIR	DB	'Migration environment!','$'
	;输入缓存区定义
	InName 	DB 80
			DB 0
			DB 80 DUP(0)
	InPass	DB 80
			DB 0
			DB 80 DUP(0)
	;商品信息
	InGood	DB 80
			DB 0
			DB 80 DUP(0)
	Good 	DW 0
	Good1	DB 'pen',0DH,6 DUP(0),10;商品名称及折扣
			DW 35,56,70,25,?	;推荐度未计算
	Good2	DB 'bag',0DH,6 DUP(0),10;商品名称及折扣
			DW 35,56,70,25,?	;推荐度未计算
	Good3	DB 'book',0DH,5 DUP(0),9;
			DW 12,30,25,5,?
	;除了2个已经具体定义了的商品信息以外，其他商品信息暂时假定为一样的
	GOODN	DB N-3 DUP('TempValue',0DH,8,15,0,20,0,30,0,2,0,?,?)
DATA ENDS

CODE SEGMENT USE16
ASSUME CS:CODE,DS:DATA,SS:STACK

;新的NEW08H用到的变量
	COUNT DB 18;计数18次为1秒
	SEC DW ? ;存放40秒的ASCII码
	OLD_INT DW ?,?;原INT 08H的中断矢量
	DIREC DB 0;切换堆栈的方向标记,0->STACKBAK,1->STACK
	SETFLAG DB 0;安装中断的标记,1表示已经安装

;新的INT 08H的代码
NEW08H PROC FAR
		PUSHF	;送进标志位,因为用CALL,而IRET弹出三个栈元素
		CALL DWORD PTR CS:OLD_INT;完成原功能
		DEC CS:COUNT	;倒计时
		JZ SCHANGE;18次为1秒,18次后考虑可能要切换堆栈了
		IRET ;未计满就中断返回
UNCHANGE:
		IRET
	
SCHANGE:	;已经过了1秒,可能切换堆栈的情况
		MOV CS:COUNT,18;重置计数器
		STI ;开中断
		CALL GET_TIME
		CMP CS:SEC,3430H
		JNE UNCHANGE;不相等就退出08H
		;相等的话就进行堆栈的切换
		STI	;开中断
				INT 3
		PUSHA
		PUSH DS
		PUSH ES
		MOV AX,CS	;将DS、ES指向CS
		MOV DS,AX
		MOV ES,AX
		CMP CS:DIREC,0;判断切换的方向
		JE ToSTACKBAK;STACK->STACKBAK
		
ToSTACK:	;STACKBAK->STACK
;MOVSB 的英文是 move string byte，意思是搬移一个字节，
;它是把 DS:SI 所指地址的一个字节搬移到 ES:DI 所指的地址上
	; MOV CX ,100
	; LEA SI,FIRST
	; LEA DI,SECOND
	; CLD 正向移位
	; REP MOVSB
	; 以上程序段的功能是从缓冲区FIRST传送100个字节到SECOND缓冲区.
		;利用MOVSB指令复制
		MOV AX,DATA
		MOV DS,AX	;设置搬运的起始地址DS:SI
		MOV SI,OFFSET STACKBAK
		MOV AX,STACK
		MOV ES,AX	;设置搬运的目的地址ES:DI
		MOV SS,AX;新的栈基址为STACK
		MOV DI,0
		MOV CX,400;设置传送字节数
		CLD	;正向传播
		REP MOVSB
		CALL EIGHT
		MOV BYTE PTR CS:DIREC,0;改变方向
		JMP EXIT08H
	
ToSTACKBAK:	;STACK->STACKBAK
		MOV AX,STACK;设置起始地址DS:SI
		MOV DS,AX
		MOV SI,0
		MOV AX,DATA
		MOV SS,AX	;新的栈基址为DATA
		MOV ES,AX;设置目的地址ES:DI
		MOV DI,OFFSET STACKBAK
		MOV CX,400;设置传送字节数
		CLD;正向传播
		REP MOVSB
		MOV AX,DATA
		MOV DS,AX;恢复DS->DATA
		CALL EIGHT
		MOV BYTE PTR CS:DIREC,1;改变方向
		
		JMP EXIT08H

EXIT08H:
		POP ES
		POP DS
		POPA;恢复现场
		IRET
NEW08H ENDP
		
;取时间子程序,从RT/COMAS RAM中取得秒到SEC中
GET_TIME PROC
		PUSH AX;保护现场
		MOV AL,0;0是秒的偏移地址
		OUT 70H,AL;向70H写入秒的偏移地址
		JMP $+2	;延时
		IN AL,71H;把秒信息放置AL中
		MOV AH,AL;转换成对应的ASCII码
		AND AL,0FH
		SHR AH,4
		ADD AX,3030H
		XCHG AH,AL
		MOV WORD PTR CS:SEC,AX;保存到秒变量的2个字节中
		POP AX;恢复现场
		RET 
GET_TIME ENDP

START: 	MOV AX,DATA
		MOV DS,AX

MENU:	;输出菜单信息
		WRITE SHOPNAME
		WRITE OneText
		WRITE TwoText
		WRITE ThrText
		WRITE FouText
		WRITE FivText
		WRITE SixText
		WRITE SenText
		WRITE EigText
		WRITE NinText
		WRITE Choose
		;获取用户输入
		INT 3
		IN1
		CMP AL,031H
		JE FUNCONE	;跳转到功能一
		CMP AL,032H
		JE FUNCTWO	
		CMP AL,033H
		JE FUNCTHR
		CMP AL,034H
		JE FUNCFOU
		CMP AL,035H
		JE FUNCFIV
		CMP AL,036H
		JE FUNCSIX
		CMP AL,037H
		JE FUNCSEN
		CMP AL,038H
		JE FUNCEIG
		CMP AL,039H
		JE FUNCNIN
		JMP START

FUNCONE:
		LEA DX,NameText	;提示用户输入信息
		MOV AH,9
		INT 21H
		;输入字符串
		LEA DX,InName
		MOV AH,10
		INT 21H
		CMP InName+1,030H;判断是否仅仅输入回车
		JE BACKMENU
		JMP NAMECHECK

NAMECHECK:	;检查输入的姓名
		MOV CL,InName+1	;采用输入串的长度作为循环次数
		MOV SI,0;SI作变址寄存器
LOOPNAME:
		MOV BL,BNAME[SI]
		CMP BL,InName[SI+2]
		JNE FAILNAME
		INC SI
		DEC CL 	;循环计数减1
		JNZ LOOPNAME
		CMP BName[SI],0	;看下一位是否为0
		JE	PASSCHECK	;检查密码
		JMP BACKMENU

PASSCHECK:	;检查输入的姓名
		LEA DX,PassText	;提示用户输入密码
		MOV AH,9
		INT 21H
		LEA DX,InPass
		MOV AH,10
		INT 21H
		MOV SI,0	;采用变址寻址
		MOV CL,InPass+1;采用输入串的长度作为循环次数
LOOPPASS:
		MOV BL,BPASS[SI]
		CMP BL,InPass[SI+2]
		JNE FAILPASS
		INC SI
		DEC CL	;循环计数减1
		JNZ LOOPPASS
		CMP BPASS[SI],0	;看下一位是否为0
		JE	LOADSUC	;跳转到登录成功
		JMP BACKMENU
		
LOADSUC:	;登录成功
		MOV AUTH,1
		LEA DX,Success
		MOV AH,9
		INT 21H
		MOV AUTH,1
		JMP MENU

FAILNAME:;姓名错误,回到菜单
		LEA DX,WrongName
		MOV AH,9
		INT 21H
		JMP BACKMENU
		
FAILPASS:;密码错误,回到菜单
		LEA DX,WrongPass
		MOV AH,9
		INT 21H
		JMP BACKMENU
		
BACKMENU:
		MOV AUTH,0
		JMP MENU

FUNCTWO:; 查询商品
		LEA DX,Query
		MOV AH,9
		INT 21H
		LEA DX,InGood
		MOV AH,10
		INT 21H
		MOV DX,N
		INC DX
		LEA BX,Good1
		SUB BX,21
GOODREST:
		DEC DX
		CMP DX,0
		JE FAILGOOD
		ADD BX,015H
		MOV DI,OFFSET InGood
		ADD DI,2
		MOV CX,10
		MOV SI,BX
GOODCMP:
		MOV AL,[SI]
		CMP AL,[DI]
		JNE GOODREST
		INC SI
		INC DI
		DEC CX
		JNZ GOODCMP
		;查询成功
		LEA DX,SearchSuc
		MOV AH,9
		INT 21H
		MOV Good,BX	;偏移地址存放到Good中
		;显示信息
		CRLF
		MOV SI,BX
		WRITE PROJECT1;折扣
		MOV AX,0
		MOV AL,[SI+10]
		MOV DX,16
		CALL F2T10
		CRLF;输出换行
		WRITE PROJECT2;进货价
		MOV AX,[SI+11]
		MOV DX,16
		CALL F2T10
		CRLF
		WRITE PROJECT3;销售价
		MOV AX,[SI+13]
		MOV DX,16
		CALL F2T10
		CRLF
		WRITE PROJECT4;进货量
		MOV AX,[SI+15]
		MOV DX,16
		CALL F2T10
		CRLF
		JMP MENU
		
FAILGOOD:	;没有找到商品
		LEA DX,FailSearch;显示提示信息
		MOV AH,9
		INT 21H
		JMP START

FUNCTHR:
		;开始计时
		MOV AX,0
		CALL TIMER
		MOV BP,M;外层M次
TIMERLOOP:

		CMP Good,0
		JE FAILSHOP
		MOV AX,Good
		ADD AX,15
		MOV BX,AX
		MOV BX,2
		SUB AX,BX
		JNS ORDER	;为正就跳转下单
		JMP FAILSHOP;无效就跳转失败处
	
ORDER:
		INC BX
		MOV [BX],BX
		LEA DX,ShopSuc
		MOV AH,9
		INT 21H
MLOOP:
		;计算一遍所有商品的推荐度
		MOV SI,OFFSET Good1
		MOV DI,N 
CACLCULATE:
		MOVZX EAX,WORD PTR [SI+10];折扣
		;MOV AH,0;ax表示折扣
		MOVZX EBX,WORD PTR [SI+13];销售价
		MUL EBX;分子算出来了
		MOV EBX,10
		MOV EDX,0
		DIV EBX;折扣之后的实际价格
		MOV ECX,EAX;实际价格存到CX中
		MOVZX EAX,WORD PTR [SI+11];AX此时为进货价格
		;MOV BX,128;128存到BX中，等待与进货价格相乘
		;MUL BX
		SAL EAX,7
		MOV EDX,0
		DIV ECX;式子的第一项算出来了
		PUSH EAX;为了使用寄存器，就先把AX的值进栈
		MOVZX EAX,WORD PTR [SI+17];已售数量
		;MOV BX,64
		;MUL BX	;式子第二项的分子算出来了
		SAL EAX,6
		MOVZX EBX,WORD PTR [SI+15];进货数量
		MOV EDX,0
		DIV EBX;此时AX=已售数量*64/进货数量，现在只差第一项相加了
		POP EBX;	把第一项的值出栈放到BX中
		ADD EAX,EBX;第二项与第一项就全部加起来了
		MOV WORD PTR [SI+19],AX ;把推荐度放进货物对应位置处
		ADD SI,21	;移动到下一个商品处
		DEC DI	;控制计算数量，计数器自减
		JNZ CACLCULATE
		
		DEC BP	;外层循环计数器自减
		JNZ MLOOP;再全部计算一遍
		
		MOV AX,1	;时间出口
		CALL TIMER	
		
		JMP MENU	;回到菜单
		
		
FAILSHOP:	;显示订单失败信息
		LEA DX,FailOrder
		MOV AH,9
		INT 21H
		
		MOV AX,1	;时间出口
		CALL TIMER
		JMP MENU

	
FUNCFOU:
		MOV SI,OFFSET Good1
		MOV DI,N
LOPCALCULATE:		
		MOV AL,[SI+10];折扣
		MOV AH,0;AX表示折扣
		MOV BX,[SI+13];销售价
		MUL BX ;
		MOV BX,10
		MOV DX,0
		DIV BX;此时AX为实际销售价格
		MOV CX,AX;CX为实际销售价格
		MOV AX,[SI]+11;AX为进货价
		MOV BX,128
		MUL BX 
		MOV DX,0
		DIV CX 
		MOV BP,AX;进货价*128/实际销售价格
		MOV AX,[SI]+17;已售数
		MOV BX,64
		MUL BX ;AX为已售数*64
		MOV BX,[SI]+15;进货数量
		MOV DX,0
		DIV BX;AX为已售数量*64/进货数量
		ADD AX,BP;AX为推荐度
		MOV [SI+19],AX
		ADD SI,21
		DEC DI
		CMP DI,0
		JNE LOPCALCULATE
		LEA DX,CountText
		MOV AH,9
		INT 21H
		JMP MENU

		
FUNCFIV:
		JMP MENU
		
FUNCSIX:
		CMP AUTH,1
		JNE MENU
		CMP Good,0
		JE MENU
		CALL F6
		JMP MENU
		
FUNCSEN:;迁移工作环境，切换堆栈
		PUSH CS
		POP DS
		CMP SETFLAG,1
		JE F7;已经被安装
		MOV AX,3508H;取出中断向量，放在ES:BX中
		INT 21H
		MOV CS:OLD_INT,BX
		MOV CS:OLD_INT+2,ES
		MOV DX,OFFSET NEW08H;迁移程序DS:DX
		MOV AX,2508H
		INT 21H
		MOV BYTE PTR CS:SETFLAG,1;设置安装标记
		CRLF
		MOV AX,DATA
		MOV DS,AX
		WRITE ENVIR
F7:
		MOV AX,DATA
		MOV DS,AX;恢复DS
		JMP MENU
		
FUNCEIG:;显示当前代码段首址
		CALL EIGHT
		JMP MENU
EIGHT PROC
		PUSHA	;保护现场
		PUSHAD
		MOV DI,OFFSET ADDRESS
		ADD DI,3	;地址变到第四位，倒着放
		MOV CL,4
		;MOV AX,CS
		MOV AX,SS
		MOV SI,4
		MOV BX,OFFSET TAB
TRANSLATE:
		MOV DX,0
		MOV BP,0010H
		DIV BP
		XCHG AX,DX	;交换商和余数
		MOV AH,0
		XLAT 	;用余数来译码转换
		MOV [DI],AL
		DEC DI		;为了输出是从高位到低位，要倒着放
		MOV AX,DX	;把商重新放回AX
		DEC CL
		JNZ	TRANSLATE
		LEA DX,ADDTEXT
		MOV AH,9
		INT 21H
		LEA DX,ADDRESS
		MOV AH,9
		INT 21H
		POPAD	;恢复现场
		POPA
		RET
EIGHT	ENDP
		

FUNCNIN:	
	;LDS reg,mem
	;这条指令的功能是把mem指向的百地址,
	;高位存放在DS中度,低位存放在reg中.
		LDS DX,DWORD PTR OLD_INT;取出原来的08H中断矢量
		MOV AX,2508H
		INT 21H;恢复原08H中断矢量
		;结束程序
		MOV AH,4CH
		INT 21H
		

;时间计数器(ms),在屏幕上显示程序的执行时间(ms)
;使用方法:
;	   MOV  AX, 0	;表示开始计时
;	   CALL TIMER
;	   ... ...	;需要计时的程序
;	   MOV  AX, 1	
;	   CALL TIMER	;终止计时并显示计时结果(ms)
;输出: 改变了AX和状态寄存器
TIMER	PROC
	PUSH  DX
	PUSH  CX
	PUSH  BX
	MOV   BX, AX
	MOV   AH, 2CH
	INT   21H	     ;CH=hour(0-23),CL=minute(0-59),DH=second(0-59),DL=centisecond(0-100)
	MOV   AL, DH
	MOV   AH, 0
	IMUL  AX,AX,1000
	MOV   DH, 0
	IMUL  DX,DX,10
	ADD   AX, DX
	CMP   BX, 0
	JNZ   _T1
	MOV   CS:_TS, AX
_T0:	POP   BX
	POP   CX
	POP   DX
	RET
_T1:	SUB   AX, CS:_TS
	JNC   _T2
	ADD   AX, 60000
_T2:	MOV   CX, 0
	MOV   BX, 10
_T3:	MOV   DX, 0
	DIV   BX
	PUSH  DX
	INC   CX
	CMP   AX, 0
	JNZ   _T3
	MOV   BX, 0
_T4:	POP   AX
	ADD   AL, '0'
	MOV   CS:_TMSG[BX], AL
	INC   BX
	LOOP  _T4
	PUSH  DS
	MOV   CS:_TMSG[BX+0], 0AH
	MOV   CS:_TMSG[BX+1], 0DH
	MOV   CS:_TMSG[BX+2], '$'
	LEA   DX, _TS+2
	PUSH  CS
	POP   DS
	MOV   AH, 9
	INT   21H
	POP   DS
	JMP   _T0
_TS	DW    ?
 	DB    'Time elapsed in ms is '
_TMSG	DB    12 DUP(0)
TIMER   ENDP

		
		
CODE ENDS
	 END START
		








	
			
			
			
			