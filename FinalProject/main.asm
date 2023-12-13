INCLUDE Irvine32.inc
INCLUDE macros.inc

getScore PROTO
role_up PROTO		
role_down PROTO

.data
Ground = 100 ;the length of ground
outHandle HANDLE ?
cellsWritten DWORD ?
rolePos COORD <11,16>   ;initialize position of role
groundPos COORD <11,25> ;initialize position of ground
obsPos COORD <110,24>	;initialize position of obstacle
obsBound COORD <11,24>
buffer BYTE Ground DUP(44h)							;character types
attributes WORD 0Eh, 0h, Ground DUP(22h), 11h		;colors
titleStr BYTE "小馬快快跑",0
drawDelay DWORD 150	;to draw obstacle with a delay
startTime DWORD ?   ;
curPos COORD <110,1>
role_up_Y = 16

;小馬顏色
attribute1 WORD 6 DUP(0h), 66h, 0h, 66h, 0h
attribute2 WORD 6 DUP(0h), 66h, 2 DUP(88h), 0h
attribute3 WORD 5 DUP(0h), 88h, 11h, 66h, 11h, 0h
attribute4 WORD 5 DUP(0h), 66h, 4 DUP(66h)
attribute5 WORD 88h, 4 DUP(0h), 88h,  2 DUP(66h), 2 DUP(0h)
attribute6 WORD 2 DUP(88h), 6 DUP(66h), 2 DUP(0h)
attribute7 WORD 2 DUP(0h), 7 DUP(66h), 0h
attribute8 WORD 2 DUP(0h), 66h, 3 DUP(0h), 66h, 0h, 77h, 0h
attribute9 WORD 2 DUP(0h), 77h, 3 DUP(0h), 77h, 3 DUP(0h)

.code
main PROC
	;set console title
	INVOKE SetConsoleTitle, ADDR titleStr

	; Get the console ouput handle
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov outHandle, eax	; save console handle
	call Clrscr	;clear screen

	; Set the role to (11,10):
	FORC num, <123456789>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attribute&num, 
			10, 
			rolePos, 
			ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			10, 
			rolePos, 
			ADDR cellsWritten
		inc rolePos.Y
	ENDM

	sub rolePos.Y, 9

	;draw the ground
	INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attributes+4, 
			Ground, 
			groundPos, 
			ADDR cellsWritten
	; Write character codes to "D"
	INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			Ground, 
			groundPos, 
			ADDR cellsWritten
	;得到開始時間
	INVOKE SetConsoleCursorPosition, 
			outHandle, 
			curPos
	INVOKE GetTickCount ; get starting tick count
	mov startTime,eax ; save it
	;顯示零
	mov eax,0
	call WriteDec ; display it

;要先判斷有沒有輸入	
	
;Start moving	
PLAY:
	;用ReadKey可以不用等待讀取輸入，但輸入不限於空白鍵
	call ReadKey
	jz   nokeyPressed      ; no key pressed
	call role_up
	call role_up
nokeyPressed:
	;印出分數
	INVOKE getScore
	;use delay to let obstacle look moving
	INVOKE Sleep, drawDelay		
	;如果角色跳起來，就讓他往下 
	;若現在Y座標小於18(不知道為什麼是18)，呼叫role_down
	.IF rolePos.Y < role_up_Y
		call role_down
		call role_down
		
	.ENDIF
	;draw obstacle with color blue
	INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attributes+204, 
			1, 
			obsPos, 
			ADDR cellsWritten
	; Write character codes to "D"
	INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			1, 
			obsPos, 
			ADDR cellsWritten
	;back to previous position to erase previous obstacle
	inc obsPos.X		
	;erase obstacle 
	INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attributes+2, 
			1, 
			obsPos, 
			ADDR cellsWritten
	; Write character codes to "D"
	INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			1, 
			obsPos, 
			ADDR cellsWritten
	;to the next position
	sub obsPos.X, 2
	mov ax,rolePos.X
	;if obstacle and role in the same position, stop moving
	.IF obsPos.X == ax
		mov ax,rolePos.Y
		add ax, 8
		.IF obsPos.Y == ax
			jmp END_PLAY
		.ENDIF
	.ENDIF
	jmp PLAY
END_PLAY:
	exit
main ENDP

getScore PROC, 
	;用經過的milliseconds當作分數
	;讓數字從相同地方印出
	INVOKE SetConsoleCursorPosition, 
			outHandle, 
			curPos
	INVOKE GetTickCount ; get new tick count
	cmp eax,startTime	; lower than starting one
	jb errorTime
	sub eax,startTime	; get elapsed milliseconds
	;除以16讓數字增加幅度變小
	mov edx, 0h			
	mov ecx, 10h
	div ecx
	call WriteDec ; display it
	jmp quit
errorTime:
	mWrite "Reach Highest Goal!"
quit:
	ret
getScore ENDP

role_up PROC
;向上一格
	;erase old position
	FORC num, <123456789>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			0h, 
			10, 
			rolePos, 
			ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			10, 
			rolePos, 
			ADDR cellsWritten
		inc rolePos.Y
	ENDM

	;draw a new one
	sub rolePos.Y, 9
	dec rolePos.Y

	FORC num, <123456789>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attribute&num, 
			10, 
			rolePos, 
			ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			10, 
			rolePos, 
			ADDR cellsWritten
		inc rolePos.Y
	ENDM

	sub rolePos.Y, 9
	ret
role_up ENDP

role_down PROC
;向下一格
	;erase old position
	FORC num, <123456789>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			0h, 
			10, 
			rolePos, 
			ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			10, 
			rolePos, 
			ADDR cellsWritten
		inc rolePos.Y
	ENDM

	;draw a new one
	sub rolePos.Y, 9
	inc rolePos.Y

	FORC num, <123456789>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attribute&num, 
			10, 
			rolePos, 
			ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			10, 
			rolePos, 
			ADDR cellsWritten
		inc rolePos.Y
	ENDM

	sub rolePos.Y, 9
	ret
role_down ENDP

END main