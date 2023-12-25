INCLUDE Irvine32.inc
INCLUDE macros.inc

fileOpen PROTO
fileWrite PROTO
fileRaed PROTO
getScore PROTO
startScreen PROTO
role_move1 PROTO
role_move2 PROTO
role_up PROTO		
role_down PROTO
move_obstacle PROTO
move_obstacle2 PROTO
move_obstacle3 PROTO


.data
Ground = 100 ;the length of ground
outHandle HANDLE ?
cellsWritten DWORD ?
rolePos COORD <11,16>   ;initialize position of role
groundPos COORD <11,25> ;initialize position of ground
obsPos COORD <110,24>	;initialize position of obstacle
obsPos2 COORD <110,24>
obsPos3 COORD <110,24>
obsCount DWORD 0
obsBound COORD <11,24>
startPos COORD <0,2>	;封面的字
buffer BYTE Ground DUP(44h)							;character types
attributes WORD 0Eh, 0h, Ground DUP(22h), 11h		;colors
titleStr BYTE "小馬快快跑",0
drawDelay DWORD 150	;to draw obstacle with a delay
startTime DWORD ?   ;
curPos COORD <90,1>
role_up_Y = 16		;用於判斷有沒有跳起來
score DWORD ?
scoreSize DWORD ($-score)
curInfo CONSOLE_CURSOR_INFO <1, FALSE>
range DWORD 8
range2 DWORD 3

;file
CurrentScore DWORD ? 
HighestScore DWORD 0
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
attribute WORD 3 DUP(44h)
attribute0 WORD 44h, 11h, 22h, 33h, 55h, 66h, 77h, 88h

;Running 75個
attributeI WORD 10 DUP(0h), 7 DUP(11h)  
		   WORD 36 DUP(0h), 2 DUP(11h), 19 DUP(0h)
attributeJ WORD 10 DUP(0h), 2 DUP(11h), 5 DUP(0h), 2 DUP(11h), 51 DUP(0h)
attributeK WORD 10 DUP(0h), 7 DUP(11h)
		   WORD 5 DUP(0h), 2 DUP(11h), 3 DUP(0h), 2 DUP(11h)
		   WORD 4 DUP(0h), 2 DUP(11h), 0h, 3 DUP(11h)
		   WORD 4 DUP(0h), 2 DUP(11h), 0h, 3 DUP(11h)
		   WORD 4 DUP(0h), 2 DUP(11h)
		   WORD 2 DUP(0h), 2 DUP(11h), 0h, 3 DUP(11h)
		   WORD 6 DUP(0h), 4 DUP(11h)
attributeL WORD 10 DUP(0h), 2 DUP(11h), 4 DUP(0h), 2 DUP(11h) 
		   WORD 4 DUP(0h), 2 DUP(11h), 3 DUP(0h), 2 DUP(11h)
		   WORD 4 DUP(0h), 2 DUP(11h), 4 DUP(0h), 2 DUP(11h)
		   WORD 2 DUP(0h), 2 DUP(11h), 4 DUP(0h), 2 DUP(11h)
		   WORD 2 DUP(0h), 2 DUP(11h)
		   WORD 2 DUP(0h), 2 DUP(11h), 4 DUP(0h), 2 DUP(11h)
		   WORD 2 DUP(0h), 2 DUP(11h), 4 DUP(0h), 2 DUP(11h)
attributeM WORD 10 DUP(0h), 2 DUP(11h), 6 DUP(0h), 2 DUP(11h)
		   WORD 4 DUP(0h), 3 DUP(11h), 2 DUP(0h), 2 DUP(11h)
		   WORD 2 DUP(0h), 2 DUP(11h), 4 DUP(0h), 2 DUP(11h)
		   WORD 2 DUP(0h), 2 DUP(11h), 4 DUP(0h), 2 DUP(11h)
		   WORD 2 DUP(0h), 2 DUP(11h)
		   WORD 2 DUP(0h), 2 DUP(11h), 4 DUP(0h), 2 DUP(11h)
		   WORD 4 DUP(0h), 4 DUP(11h)
attributeN WORD 73 DUP(0h), 2 DUP(11h)
attributeO WORD 67 DUP(0h), 2 DUP(11h), 4 DUP(0h), 2 DUP(11h)
attributeP WORD 69 DUP(0h), 4 DUP(11h), 2 DUP(0h)

;H0URSE 101格
attributeQ WORD 43 DUP(0h), 2 DUP(44h), 4 DUP(0h), 2 DUP(44h)
		   WORD 4 DUP(0h), 4 DUP(44h)
		   WORD 4 DUP(0h), 2 DUP(44h), 5 DUP(0h), 2 DUP(44h)
		   WORD 2 DUP(0h), 7 DUP(44h)
		   WORD 6 DUP(0h), 4 DUP(44h)
		   WORD 3 DUP(0h), 7 DUP(44h)
attributeR WORD 43 DUP(0h), 2 DUP(44h), 4 DUP(0h), 2 DUP(44h)
		   WORD 2 DUP(0h), 2 DUP(44h), 4 DUP(0h), 2 DUP(44h)
		   WORD 2 DUP(0h), 2 DUP(44h), 5 DUP(0h), 2 DUP(44h)
		   WORD 2 DUP(0h), 2 DUP(44h), 5 DUP(0h), 2 DUP(44h)
		   WORD 2 DUP(0h), 2 DUP(44h)
		   WORD 7 DUP(0h), 2 DUP(44h)
attributeT WORD 43 DUP(0h), 8 DUP(44h)
		   WORD 2 DUP(0h), 2 DUP(44h), 4 DUP(0h), 2 DUP(44h)
		   WORD 2 DUP(0h), 2 DUP(44h), 5 DUP(0h), 2 DUP(44h)
		   WORD 2 DUP(0h), 7 DUP(44h)
		   WORD 6 DUP(0h), 3 DUP(44h)
		   WORD 4 DUP(0h), 7 DUP(44h)
attributeU WORD 43 DUP(0h), 2 DUP(44h), 4 DUP(0h), 2 DUP(44h)
		   WORD 2 DUP(0h), 2 DUP(44h), 4 DUP(0h), 2 DUP(44h)
		   WORD 3 DUP(0h), 2 DUP(44h), 3 DUP(0h), 2 DUP(44h)
		   WORD 3 DUP(0h), 2 DUP(44h), 4 DUP(0h), 2 DUP(44h)
		   WORD 8 DUP(0h), 2 DUP(44h)
		   WORD 2 DUP(0h), 2 DUP(44h)
attributeV WORD 43 DUP(0h), 2 DUP(44h), 4 DUP(0h), 2 DUP(44h)
		   WORD 4 DUP(0h), 4 DUP(44h)
		   WORD 7 DUP(0h), 3 DUP(44h)
		   WORD 5 DUP(0h), 2 DUP(44h), 6 DUP(0h), 2 DUP(44h)
		   WORD 2 DUP(0h), 4 DUP(44h)
		   WORD 4 DUP(0h), 7 DUP(44h)

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

	call fileOpen 

Start_again:
	;讀取最高分數並印出"Highest: HighestScore" 
	mov curPos.X, 90
	INVOKE SetConsoleCursorPosition, 
			outHandle, 
			curPos
	call fileRead
	mWrite "Highest: "
	mov eax, HighestScore
	call WriteDec
	add curPos.X,14

	;角色位置重置
	mov rolePos.X, 11
	mov rolePos.Y, 16

	; Set the role to (11,16):
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
	mov drawDelay, 150	;重新設定速度
	mov curPos.X, 104	;重新開始分數的位置才不會跑掉
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

	xor edx, edx
	mov eax, score
	mov ebx, 7
	div ebx
	.IF edx == 0
		call Randomize ;初始化
		call Random32 ;生成隨機正整數到eax
		xor edx, edx ;餘數歸零
		div range2 ;0到2隨機數
		mov obsCount, edx
	.ENDIF
	
	call move_obstacle
	.IF obsCount == 1
		.IF obsPos.X == 74
			.IF obsPos2.X == 110
				call move_obstacle2
			.ENDIF
		.ENDIF
	.ENDIF
	.IF obsPos2.X != 110
		call move_obstacle2
	.ENDIF
	.IF obsCount == 2
		.IF obsPos.X == 74
			.IF obsPos2.X == 110
				call move_obstacle2
			.ENDIF
		.ENDIF
		.IF obsPos2.X == 74
			.IF obsPos3.X == 110
				call move_obstacle3
			.ENDIF
		.ENDIF
	.ENDIF
	.IF obsPos3.X != 110
		call move_obstacle3
	.ENDIF


	mov ax,rolePos.X
	add ax, 5
	;if obstacle and role in the same position, stop moving
	.IF obsPos.X <= ax && rolePos.Y >= 13
		jmp END_PLAY
		
	.ENDIF
	.IF obsPos2.X <= ax && rolePos.Y >= 13
		jmp END_PLAY
		
	.ENDIF
	.IF obsPos3.X <= ax && rolePos.Y >= 13
		jmp END_PLAY
		
	.ENDIF

	jmp PLAY
END_PLAY:
	mov  eax,500 ;delay 1 sec
    call Delay
	call Clrscr
	INVOKE Sleep, 1000
	mov startPos.Y, 15 
	INVOKE SetConsoleCursorPosition, 
		outHandle, 
		startPos
	mWrite "Game Over"
	inc startPos.Y
	INVOKE Sleep, 1000
	INVOKE SetConsoleCursorPosition, 
		outHandle, 
		startPos
	mWrite "Your score is "
	mov eax, score
	call WriteDec
	call fileRead	;讀最高值
	;如果這次比較高，就寫進檔案裡
	mov  eax, score
	.IF eax > HighestScore
		mov HighestScore, eax
		call fileWrite
		INVOKE Sleep, 1000
		inc startPos.Y
		INVOKE SetConsoleCursorPosition,  
			outHandle, 
			startPos
		
		mWrite "New record! Congratualation!"
		
		
	.ENDIF

	INVOKE Sleep, 1000
	inc startPos.Y
	INVOKE SetConsoleCursorPosition,  
		outHandle, 
		startPos
	mWrite "Press ""r"" to play again or ""Esc"" to leave"	
	mov obsPos.X, 110 ;障礙物位置重置
	mov obsPos2.X, 110 
	mov obsPos3.X, 110 

Readchar_again:
	call Readchar
	.IF ax == 1372h || ax == 1352h;按r再玩一次
		call Clrscr
		mov obsPos.X, 110
		jmp Start_again
	.ENDIF
	.IF ax == 011bh;按esc離開遊戲
		jmp EndMain
	.ENDIF
	jmp Readchar_again
	
EndMain:
	
	exit
main ENDP

fileOpen PROC
	;開寫檔，每次開會指向最前面
	INVOKE CreateFile,
		ADDR filename, 
		GENERIC_WRITE OR GENERIC_READ, 
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
	ret
QuitNow:
	exit
fileOpen ENDP

fileWrite PROC
	;指向文件開頭
	INVOKE SetFilePointer,
		fileHandle,0,0,FILE_BEGIN
	;寫檔
	INVOKE WriteFile, ; write text to file
		fileHandle, ; file handle
		ADDR Highestscore, ; buffer pointer
		scoreSize, ; number of bytes to write
		ADDR bytesWritten, ; number of bytes written
		0 ; overlapped execution flag
	ret
fileWrite ENDP

fileRead PROC
	;指向文件開頭
	INVOKE SetFilePointer,
		fileHandle,0,0,FILE_BEGIN
	INVOKE ReadFile,
		fileHandle,		; handle to file
		ADDR HighestScore,			; ptr to buffer
		scoreSize,		; num bytes to read
		ADDR bytesRead,		; bytes actually read
		NULL			; NULL (0) for syn mode	
	
	ret
fileRead ENDP

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
	add rolePos.X, 17
	add rolePos.Y, 3
	; Set the role to (28, 19):
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

	;畫出"Running"
	FORC num, <IJKLMNOP>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attribute&num, 
			75, 
			startPos, 
			ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			75, 
			startPos, 
			ADDR cellsWritten
		inc startPos.Y
	ENDM
	add startPos.Y, 3
	;畫出"HOURSE"
	FORC num, <QRTUV>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attribute&num, 
			101, 
			startPos, 
			ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			101, 
			startPos, 
			ADDR cellsWritten
		inc startPos.Y
	ENDM
	add startPos.Y, 4
	add startPos.X, 50
	INVOKE SetConsoleCursorPosition, 
		outHandle, 
		startPos
	mWrite "Press ""space"" to start"
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
			ADDR attribute, 
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
	;生成隨機顏色
		call Randomize ;初始化
		call Random32 ;生成隨機正整數到eax
		xor edx, edx ;餘數歸零
		div range ;0到7隨機數
		mov ax, attribute0[edx*2] ; 根據隨機數選擇對應的顏色
		FORC num, <024>
			mov attribute[&num], ax ; 設定顏色
		ENDM
	mov obsPos.X, 110 
	add obsPos.Y, 3
	.ENDIF
	ret
move_obstacle ENDP

move_obstacle2 PROC
	;draw obstacle with color red
	FORC num, <ABC>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attribute, 
			3, 
			obsPos2, 
			ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			3, 
			obsPos2, 
			ADDR cellsWritten
		dec obsPos2.Y			;每次畫一列，往上畫
	ENDM
	;back to previous position Y回到第一列，X倒退三行
	add obsPos2.X, 3
	add obsPos2.Y, 3
	;erase obstacle 
	FORC num, <ABC>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attribute_black, 
			3, 
			obsPos2, 
			ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			3, 
			obsPos2, 
			ADDR cellsWritten
		dec obsPos2.Y
	ENDM
	;to the next position Y回到第一列，X前進六行
	sub obsPos2.X, 6
	add obsPos2.Y, 3
	;若障礙物到達末端，從頭開始
	.IF obsPos2.X == 5
		add obsPos2.X, 3
		FORC num, <ABC>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attribute_black, 
			3, 
			obsPos2, 
			ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			3, 
			obsPos2, 
			ADDR cellsWritten
		dec obsPos2.Y
	ENDM
	;生成隨機顏色
		call Randomize ;初始化
		call Random32 ;生成隨機正整數到eax
		xor edx, edx ;餘數歸零
		div range ;0到7隨機數
		mov ax, attribute0[edx*2] ; 根據隨機數選擇對應的顏色
		FORC num, <024>
			mov attribute[&num], ax ; 設定顏色
		ENDM
	mov obsPos2.X, 110 
	add obsPos2.Y, 3
	.ENDIF
	ret
move_obstacle2 ENDP

move_obstacle3 PROC
	;draw obstacle with color red
	FORC num, <ABC>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attribute, 
			3, 
			obsPos3, 
			ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			3, 
			obsPos3, 
			ADDR cellsWritten
		dec obsPos3.Y			;每次畫一列，往上畫
	ENDM
	;back to previous position Y回到第一列，X倒退三行
	add obsPos3.X, 3
	add obsPos3.Y, 3
	;erase obstacle 
	FORC num, <ABC>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attribute_black, 
			3, 
			obsPos3, 
			ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			3, 
			obsPos3, 
			ADDR cellsWritten
		dec obsPos3.Y
	ENDM
	;to the next position Y回到第一列，X前進六行
	sub obsPos3.X, 6
	add obsPos3.Y, 3
	;若障礙物到達末端，從頭開始
	.IF obsPos3.X == 5
		add obsPos3.X, 3
		FORC num, <ABC>
		INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attribute_black, 
			3, 
			obsPos3, 
			ADDR cellsWritten
		INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			3, 
			obsPos3, 
			ADDR cellsWritten
		dec obsPos3.Y
	ENDM
	;生成隨機顏色
		call Randomize ;初始化
		call Random32 ;生成隨機正整數到eax
		xor edx, edx ;餘數歸零
		div range ;0到7隨機數
		mov ax, attribute0[edx*2] ; 根據隨機數選擇對應的顏色
		FORC num, <024>
			mov attribute[&num], ax ; 設定顏色
		ENDM
	mov obsPos3.X, 110 
	add obsPos3.Y, 3
	.ENDIF
	ret
move_obstacle3 ENDP
END main