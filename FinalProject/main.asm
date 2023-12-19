INCLUDE Irvine32.inc
INCLUDE macros.inc

fileAct PROTO
getScore PROTO
startScreen PROTO
role_move1 PROTO
role_move2 PROTO
role_up PROTO		
role_down PROTO
move_obstacle PROTO


.data
Ground = 100 ;the length of ground
outHandle HANDLE ?
cellsWritten DWORD ?
rolePos COORD <11,16>   ;initialize position of role
groundPos COORD <11,25> ;initialize position of ground
obsPos COORD <110,24>	;initialize position of obstacle
obsBound COORD <11,24>
startPos COORD <55,15>	;封面的字
buffer BYTE Ground DUP(44h)							;character types
attributes WORD 0Eh, 0h, Ground DUP(22h), 11h		;colors
titleStr BYTE "小馬快快跑",0
drawDelay DWORD 150	;to draw obstacle with a delay
startTime DWORD ?   ;
curPos COORD <104,1>
role_up_Y = 16		;用於判斷有沒有跳起來
score DWORD ?
scoreSize DWORD ($-score)
curInfo CONSOLE_CURSOR_INFO <100, FALSE>

;file
testMsg BYTE "This is test message."
testSize DWORD ($-testMsg)
line BYTE ?
lineSize DWORD ?
errMsg BYTE "Cannot create file",0dh,0ah,0
filename BYTE "Score.txt",0
fileHandle DWORD ? ; handle to output file
bytesWritten DWORD ? ; number of bytes written
bytesRead DWORD ? ; number of bytes read

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
;跑起來的小馬顏色
attributeD WORD 5 DUP(0h), 88h,  2 DUP(66h), 2 DUP(0h)
attributeE WORD 2 DUP(88h), 6 DUP(66h), 2 DUP(0h)
attributeF WORD 2 DUP(0h), 6 DUP(66h), 2 DUP(0h)
attributeG WORD 0h, 77h, 66h, 4 DUP(0h), 66h, 2 DUP(0h)
attributeH WORD 3 DUP(0h), 4 DUP(0h), 77h, 2 DUP(0h)
;覆蓋小馬顏色
attribute_black WORD 10 DUP(0h)

;障礙物顏色
attributeA WORD 3 DUP(44h)
attributeB WORD 3 DUP(44h)
attributeC WORD 3 DUP(44h)



.code
main PROC
	;set console title
	INVOKE SetConsoleTitle, ADDR titleStr
	; Get the console ouput handle
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov outHandle, eax	; save console handle

	;將cursor設為invisible比較美觀
	INVOKE SetConsoleCursorInfo, 
		outHandle, 
		ADDR curInfo
	;開始畫面
	call startScreen
	

Start_again:
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

	mov curPos.X, 104 ;重新開始分數的位置才不會跑掉
	INVOKE SetConsoleCursorPosition, 
			outHandle, 
			curPos
	mWrite "Score:"
	;得到開始時間
	INVOKE GetTickCount ; get starting tick count
	mov startTime,eax ; save it
	;顯示零
	add curPos.X, 7
	INVOKE SetConsoleCursorPosition, 
			outHandle, 
			curPos
	mov eax,0
	call WriteDec ; display it

	

;要先判斷有沒有輸入	
	
;Start moving	
PLAY:
	

	;用ReadKey可以不用等待讀取輸入，但輸入不限於空白鍵
	call ReadKey	;按的鍵好像會存到al中
    cmp al, 20h     ;用 ASCII 空格字符的碼檢查是否為非空白字符
    jne  spaceNotPressed ;space not pressed
	;不可連續跳兩下
	.IF rolePos.Y == 16
		call role_up
	.ENDIF

spaceNotPressed:
	;印出分數
	INVOKE getScore
	;use delay to let obstacle look moving
	INVOKE Sleep, drawDelay		
	;如果角色跳起來，就讓他往下 
	;若現在Y座標小於一開始的位置，呼叫role_down
	.IF rolePos.Y < role_up_Y
		call role_down
	.ENDIF

	;讓小馬跑起來
	.IF rolePos.Y == 16
		call role_move1
		invoke Sleep, 50
		call role_move2
	.ENDIF

	call move_obstacle

	mov ax,rolePos.X
	add ax, 5
	;if obstacle and role in the same position, stop moving
	.IF obsPos.X <= ax && rolePos.Y >= 13
		
		jmp END_PLAY
		
	.ENDIF
	jmp PLAY
END_PLAY:
	mov  eax,500 ;delay 1 sec
    call Delay
	call Clrscr
	INVOKE SetConsoleCursorPosition, 
		outHandle, 
		startPos
	mWrite "Game Over"
	inc startPos.Y
	INVOKE SetConsoleCursorPosition, 
		outHandle, 
		startPos
	mWrite "Your score is "
	mov eax, score
	call WriteDec
	;retry
	inc startPos.Y
	INVOKE SetConsoleCursorPosition, 
		outHandle, 
		startPos
	mWrite "Press space to play again"
	call Readchar
	.IF ax == 3920h
		call Clrscr
		mov obsPos.X, 110
		jmp Start_again
	.ENDIF

	call Crlf
	;call fileAct	;測試寫檔讀檔
EndMain:
	
	exit
main ENDP

fileAct PROC
	INVOKE CreateFile,
		ADDR filename, 
		GENERIC_WRITE, 
		DO_NOT_SHARE, 
		NULL,
		OPEN_EXISTING, 
		FILE_ATTRIBUTE_NORMAL, 
		0
	mov fileHandle,eax ; save file handle
	.IF eax == INVALID_HANDLE_VALUE
		mov edx,OFFSET errMsg ; Display error message
		call WriteString
		jmp QuitNow
	.ENDIF
	INVOKE WriteFile, ; write text to file
		fileHandle, ; file handle
		ADDR testMsg, ; buffer pointer
		testSize, ; number of bytes to write
		ADDR bytesWritten, ; number of bytes written
		0 ; overlapped execution flag
	INVOKE CloseHandle, fileHandle

	INVOKE CreateFile,
		ADDR filename, 
		GENERIC_READ, 
		DO_NOT_SHARE, 
		NULL,
		OPEN_EXISTING, 
		FILE_ATTRIBUTE_NORMAL, 
		0
	mov fileHandle,eax ; save file handle
	.IF eax == INVALID_HANDLE_VALUE
		mov edx,OFFSET errMsg ; Display error message
		call WriteString
		jmp QuitNow
	.ENDIF

	INVOKE SetFilePointer,
		fileHandle,0,0,FILE_BEGIN

	INVOKE ReadFile,
		fileHandle,		; handle to file
		ADDR line,			; ptr to buffer
		testSize,		; num bytes to read
		ADDR bytesRead,		; bytes actually read
		NULL			; NULL (0) for syn mode

	mov  edx,OFFSET line
    call WriteString
	INVOKE CloseHandle, fileHandle
QuitNow:
	ret
fileAct ENDP

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
	;除以1000讓數字變小
	mov edx, 0h			
	mov ecx, 03E8h
	div ecx
	call WriteDec ; display it
	mov score, eax
	;15秒增加速度，到330秒極限
	mov edx, 0h
	mov ecx, 0fh
	div ecx
	.IF edx == 0
		sub drawDelay, 1
	.ENDIF

	jmp quit
errorTime:
	mWrite "Reach Highest Goal!"
quit:
	ret
getScore ENDP

startScreen PROC
	INVOKE SetConsoleCursorPosition, 
		outHandle, 
		startPos
	mWrite "Press space to start"
notSpace:
	call Readchar
	.IF ax == 3920h
		call Clrscr	;clear screen
		jmp startGame
	.ENDIF
	jmp notSpace
startGame:
	ret
startScreen ENDP

role_move1 PROC
;切換馬腳的兩種動作的第一種
;erase old position
	FORC num, <123456789>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attribute_black, 
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

	FORC num, <1234DEFGH>
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
role_move1 ENDP

role_move2 PROC
;切換馬腳的兩種動作的第二種
;erase old position
	FORC num, <123456789>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attribute_black, 
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
role_move2 ENDP

role_up PROC
;向上7格
	;erase old position
	FORC num, <123456789>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attribute_black, 
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
	sub rolePos.Y, 15
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
			ADDR attribute_black, 
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

move_obstacle PROC
	;draw obstacle with color red
	FORC num, <ABC>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attribute&num, 
			3, 
			obsPos, 
			ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			3, 
			obsPos, 
			ADDR cellsWritten
		dec obsPos.Y			;每次畫一列，往上畫
	ENDM
	;back to previous position Y回到第一列，X倒退三行
	add obsPos.X, 3
	add obsPos.Y, 3
	;erase obstacle 
	FORC num, <ABC>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attribute_black, 
			3, 
			obsPos, 
			ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			3, 
			obsPos, 
			ADDR cellsWritten
		dec obsPos.Y
	ENDM
	;to the next position Y回到第一列，X前進六行
	sub obsPos.X, 6
	add obsPos.Y, 3
	;若障礙物到達末端，從頭開始
	.IF obsPos.X == 5
		add obsPos.X, 3
		FORC num, <ABC>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attribute_black, 
			3, 
			obsPos, 
			ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			3, 
			obsPos, 
			ADDR cellsWritten
		dec obsPos.Y
	ENDM
	mov obsPos.X, 110 
	add obsPos.Y, 3
	.ENDIF
	ret
move_obstacle ENDP
END main