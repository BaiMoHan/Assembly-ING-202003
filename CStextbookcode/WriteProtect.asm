;P163例题6.1修改软中断INT 13H 实现对磁盘的写保护
.386
CODE SEGMENT USE16
	ASSUME CS:CODE,SS:STACK
OLD_INT DW ?,?;新程序中使用的变量,用以存放旧中断矢量
;新中断处理程序（INT 13H）的代码
NEW13H:
		CMP AH,3;判断是否调用第一种磁盘写功能
		JE QUIT
		CMP AH,0BH;判断是否调用第二种磁盘写功能
		JE QUIT
		JMP DWORD PTR OLD_INT;允许继续原中断处理程序功能
		;访问OLD_INT时默认的段寄存器为CS
QUIT:
		PUSH BP
		MOV BP,SP
		OR WORD PTR[BP]+6,01H;1->CF,表示出错，修改了中断返回后的标志寄存器内容
		POP BP
		MOV AH,3;错误号为写保护
		IRET;弹出的标志寄存器的CF值已被修改为1
;初始化（安装新中断矢量并常驻）程序
START:
		XOR AX,AX;清空AX为0
		MOV DS,AX;0->DS,矢量表从0开始
		MOV AX,DS:[13H*4];取原INT 13H的中断矢量的偏移部分
		MOV OLD_INT,AX;将偏移部分保存
		MOV AX,DS:[13H*4+2];取原来INT 13H的中断矢量的段值
		MOV OLD_INT+2,AX;将段值保存
		
		CLI	;修改中断矢量表时必须关中断，放置中途被外部中断打断而出错
		MOV WORD PTR DS:[13H*4],OFFSET NEW13H;将新的偏移值送中断矢量表
		MOV DS:[13H*4+2],CS;将新的段值送中断矢量表
		STI	;开中断
		MOV DX,OFFSET START+15;计算中断处理程序占用的字节数,+15是为了在计算节数时能向上取整
		MOV CL,4
		SHR DX,CL;将字节数换算成节数（每节代表16个字节）
		ADD DX,10H;驻留的长度还需包括程序段前缀的内容（100H个字节）
		MOV AL,0;退出码为0
		MOV AH,31H;退出时，将（DX）节的主存单元驻留（不释放）
		INT 21H
CODE ENDS
STACK	SEGMENT STACK USE16
		DB 200 DUP(0)
STACK ENDS
		END START
		