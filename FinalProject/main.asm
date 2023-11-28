INCLUDE Irvine32.inc

.data
outHandle HANDLE ?
cellsWritten DWORD ?
xyPos COORD <10,10>
; Array of character codes:
buffer BYTE 44h
;BufSize DWORD ($ - buffer)
; Array of attributes:
attributes WORD 0Ch,0h

.code
main PROC
	; Get the console ouput handle
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov outHandle, eax	; save console handle
	call Clrscr

	; Set the colors to (10,2):
	INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attributes, 
			sizeof buffer, 
			xyPos, 
			ADDR cellsWritten

	; Write character codes  :
	INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			sizeof buffer, 
			xyPos, 
			ADDR cellsWritten
	;if press a button
	call ReadChar
	;erase the charactor
	INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attributes+2, 
			sizeof buffer, 
			xyPos, 
			ADDR cellsWritten

	INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			sizeof buffer, 
			xyPos, 
			ADDR cellsWritten
	;draw a new one
	dec xyPos.Y
	INVOKE WriteConsoleOutputAttribute, 
			outHandle, 
			ADDR attributes, 
			sizeof buffer, 
			xyPos, 
			ADDR cellsWritten

	; Write character codes  :
	INVOKE WriteConsoleOutputCharacter, 
			outHandle, 
			ADDR buffer, 
			sizeof buffer, 
			xyPos, 
			ADDR cellsWritten
	call WaitMsg
	exit
main ENDP
END main
