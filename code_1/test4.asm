.386
STACK SEGMENT USE16 STACK
 DB 200 DUP(0)
STACK ENDS

DATA SEGMENT USE16
	BNAME DB 'PEIHAN',0 ;老板姓名
	BPASS DB 'test',0,0,0;密码
	SHOPNAME DB 0AH,0DH,'------SHOP--------','$'
	AUTH DB 0 ;当前登录状态,0表示顾客状态
	N EQU 30
	;提示信息
	NameText DB 0AH,0DH,'Please enter your username ', '$'
	PassText DB 0AH,0DH,'Please enter your password ', '$'
	WrongName DB 0AH,0DH,'Wrong username','$'
	WrongPass DB 0AH,0DH,'Wrong password','$'
	FailSearch DB 0AH,0DH,'There is no such thing ','$'
	FailOrder DB 0AH,0DH,'Order failed ','$'
	SearchSuc DB 0AH,0DH,'Search successfully','$'
	ShopSuc DB 0AH,0DH,'Order successfully','$'
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
	Good2	DB 'book',0DH,5 DUP(0),9;
			DW 12,30,25,5,?
	;除了2个已经具体定义了的商品信息以外，其他商品信息暂时假定为一样的
	GOODN	DB N-2 DUP('TempValue',0,8,15,0,20,0,30,0,2,0,?,?)
DATA ENDS

CODE SEGMENT USE16
ASSUME CS:CODE,DS:DATA,SS:STACK

START: 	MOV AX,DATA
		MOV DS,AX

MENU:	;输出菜单信息
		LEA DX,SHOPNAME
		MOV AH,9
		INT 21H
		LEA DX,OneText
		MOV AH,9
		INT 21H
		LEA DX,TwoText
		MOV AH,9
		INT 21H
		LEA DX,ThrText
		MOV AH,9
		INT 21H
		LEA DX,FouText
		MOV AH,9
		INT 21H
		LEA DX,FivText
		MOV AH,9
		INT 21H
		LEA DX,SixText
		MOV AH,9
		INT 21H
		LEA DX,SenText
		MOV AH,9
		INT 21H
		LEA DX,EigText
		MOV AH,9
		INT 21H
		LEA DX,NinText
		MOV AH,9
		INT 21H
		LEA DX,Choose
		MOV AH,9
		INT 21H
		;获取用户输入
		MOV AH,1
		INT 21H
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
		LEA DX,Success
		MOV AH,9
		INT 21H
		MOV AUTH,1
		JMP BACKMENU

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
		JMP MENU
		
FAILGOOD:	;没有找到商品
		LEA DX,FailSearch;显示提示信息
		MOV AH,9
		INT 21H
		JMP START

FUNCTHR:
		CMP Good,0
		JE FAILSHOP
		MOV AX,Good+12
		MOV BX,Good+13
		SUB AX,BX
		JNS ORDER	;为正就跳转下单
	
ORDER:
		INC BX
		MOV [BX],BX
		LEA DX,ShopSuc
		MOV AH,9
		INT 21H
		JMP MENU
		
		
FAILSHOP:	;显示订单失败信息
		LEA DX,FailOrder
		MOV AH,9
		INT 21H
		JMP MENU
		
FUNCFOU:
		MOV SI,Good
		MOV DI,SI
		MOV CX,N 
COMPUTE:
		MOV DI,SI
		MOV CX,N
		JMP BACKMENU
		
FUNCFIV:
		JMP BACKMENU
		
FUNCSIX:
		JMP BACKMENU
		
FUNCSEN:
		JMP BACKMENU
		
FUNCEIG:
		JMP BACKMENU

FUNCNIN:	
		;结束程序
		MOV AH,4CH
		INT 21H
		
		
CODE ENDS
	 END START
		








	
			
			
			
			