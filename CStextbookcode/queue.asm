;排序子模块QUEUE,冒泡排序
;功能：将一组16位无符号或有符号二进制数按从小到大的顺序
;排列后仍存储在原存储区中
;入口参数：
;SI——从数组存储区取数指针，初值为该存储区首址
;CX——待排序数组元素个数
;BP——对无符号或有符号数排序标记，(BP)=0则是无符号数,(BP)=1即有符号数
;所使用的寄存器
;DI——中间寄存器，保存数组首址
;AX——存放待比较数
;DX——内循环计数器，CX为外循环计数器
;本模块不破坏AX、DX、DI的内容
;出口参数：排好序的数仍存储在原数组存储区中;;;;;
		NAME QUEUE
		PUBLIC QUEUE
CODE SEGMENT USE16 PARA PUBLIC 'CODE'
		ASSUME	CS:CODE
QUEUE PROC
		PUSH AX;保护现场
		PUSH DX;保护现场
		PUSH DI;保护现场
		MOV DI,SI;保存存储数组首址，备份
		DEC CX;CX为待排序个数,第一个不用排,比较次数就是CX-1->CX
QU1:
		MOV DX,CX;CX->DX作内循环计数器
		MOV SI,DI;待排序数组首址->SI
QU2:
		MOV AX,[SI];从数组中取一个数->AX
		CMP BP,0;判断是否是对无符号数排序
		JE NO;如果是无符号数排序转NO
		CMP AX,[SI+2];对于有符号数，比较后一个数
		JLE NOXCH;如果前一个数小于等于后一个数则不交换
XCH:
		XCHG [SI+2],AX;前一个数大于后一个数
		MOV [SI],AX;两两交换，冒泡排序
NOXCH:
		ADD SI,2;移到下一个数
		DEC DX;内循环计数器-
		JNE QU2;如果两两比较还没完继续比较
		LOOP QU1;CX-1->CX,CX!=0就继续QU1的外层循环
		POP DI;恢复现场
		POP DX;恢复现场
		POP AX;恢复现场
		RET ;返回
NO:
		CMP AX,[SI+2];对无符号数还是看前一个数与后一个数的比较
		JBE NOXCH;前一个数小就不交换,因为无符号数比较指令不同,所以另开标号
		JMP XCH;前一个数大于后一个数就交换位置
QUEUE ENDP
CODE ENDS
	 END
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		