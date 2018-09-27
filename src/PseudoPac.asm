include Irvine32.inc

.386
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
filename1 BYTE "1.pcmap",0
filename2 BYTE "2.pcmap",0
mapfilehandle DWORD 0
col WORD ?
ALIGN 2
pac WORD ?
ghostCount BYTE 0

mapOptPrompt BYTE "Which map? (1/2)",0Dh,0Ah,0

menuPrompt BYTE "Move Up (U)",0Dh,0Ah
		   BYTE "Move Down (D)",0Dh,0Ah
		   BYTE "Move Left (L)",0Dh,0Ah
		   BYTE "Move Right (R)",0Dh,0Ah
EOGPrompt  BYTE "Print Map (P)",0Dh,0Ah
SOGPrompt  BYTE "Start new game (S)",0Dh,0Ah
		   BYTE "End Game (E)",0Dh,0Ah,0Dh,0Ah,0
ALIGN 4
PosPrompt BYTE "Positions(row,col):",0Dh,0Ah,0
ALIGN 4
mapArr BYTE 1024 DUP(0)
ghostArr WORD 16 DUP(0)

.code
printMap proc uses edx
	mov edx, OFFSET mapArr
	call WriteString
	call Crlf
	call Crlf
	call printPosList
	ret
printMap endp

printMenu proc uses edx
	mov edx, OFFSET menuPrompt
	call WriteString
	ret
printMenu endp

printEOGMenu proc uses edx
	mov edx, OFFSET EOGPrompt
	call WriteString
	ret
printEOGMenu endp

printSOGMenu proc uses edx
	mov edx, OFFSET SOGPrompt
	call WriteString
	ret
printSOGMenu endp

printPosList proc uses ecx esi edx eax
	mov edx, OFFSET PosPrompt
	call WriteString
	mov al,'@'
	call WriteChar
	mov al,' '
	call WriteChar
	movzx eax,pac
	call printPos
	call Crlf
	mov esi,OFFSET ghostArr
	dec esi
	dec esi
	mov ecx,17
L1: cmp WORD PTR [esi+ecx*2],0
	jna L2
	mov al,'$'
	call WriteChar
	mov al,' '
	call WriteChar
	movzx eax,WORD PTR [esi+ecx*2]
	call printPos
	call Crlf
L2: loop L1
	call Crlf
	ret
printPosList endp

printPos proc uses ebx ecx edx
	xor ebx,ebx
	xor ecx,ecx
	movzx edx,col
	add edx,2
	mov ecx,eax
L1: cmp ecx,edx
	jb L2 
	sub ecx,edx
	inc ebx
	jmp L1
L2: mov eax,ebx
	push ecx
	call WriteDec
	mov al,' '
	call WriteChar
	pop eax
	call WriteDec
	ret
printPos endp

startGame proc uses eax ecx edx
IVI:mov edx, OFFSET mapOptPrompt
	call WriteString
	xor edx,edx
	call ReadChar
	cmp al,'1'
	je L1
	cmp al,'2'
	je L2
	jmp IVI
L2:	mov edx, 8
L1: add edx, OFFSET filename1
	push edx
L0:	cmp mapfilehandle,0
	jne opened
	pop edx
	call OpenInputFile
	mov mapfilehandle, eax
	mov edx, OFFSET mapArr
	mov ecx, 1023
	call ReadFromFile
	call checkCol
	call readMap
	ret
opened:
	mov eax,mapfilehandle
	call CloseFile
	mov mapfilehandle,0
	jmp L0
startGame endp

checkCol proc uses ecx
	mov ecx, 0
L2: cmp BYTE PTR mapArr[ecx],'*'
	je L1
	mov col,cx
	ret
L1: inc ecx
	jmp L2
checkCol endp

readMap proc uses ecx eax
	xor ecx,ecx	
	xor eax,eax
L1: cmp BYTE PTR mapArr[eax],0
	je L4
	cmp BYTE PTR mapArr[eax],'$'
	jne L2
	mov WORD PTR ghostArr[ecx*2],ax
	inc ecx
L2: cmp BYTE PTR mapArr[eax],'@'
	jne L3
	mov pac, ax
L3: inc ax
	jmp L1
L4: mov ghostCount, cl
	ret
readMap endp

movePac proc uses eax ebx ecx
	push ebp
	mov ebp, esp
	movzx eax, pac
	movzx ebx, pac
	cmp DWORD PTR [ebp+20],"UPUP"
	jne L1
	sub ax, col
	sub ax, 2
	jmp L4
L1: cmp DWORD PTR [ebp+20],"DOWN"
	jne L2
	add ax, col
	add ax, 2
	jmp L4
L2: cmp DWORD PTR [ebp+20],"LEFT"
	jne L3
	sub ax, 1
	jmp L4
L3: cmp DWORD PTR [ebp+20],"RGHT"
	jne Lrt
	add ax,1
L4: cmp BYTE PTR mapArr[eax],'*'
	je Lrt
	cmp BYTE PTR mapArr[eax],'$'
	jne L5
	dec ghostCount
L5: mov mapArr[eax],'@'
	mov pac, ax
	mov ecx, 17
L6: cmp bx, WORD PTR ghostArr[ecx*2-2]
	je L7
	loop L6
	jmp L8
L7: mov mapArr[ebx],'#'
	mov WORD PTR ghostArr[ecx*2-2],0
	jmp Lrt
L8: mov mapArr[ebx],' '
Lrt:pop ebp
	ret
movePac endp
	
main proc
	call printSOGMenu
L0: call ReadChar
	cmp mapfilehandle,0
	je SOG
	cmp ghostCount,0
	je EOG
	cmp al,'U'
	je Lmu
	cmp al,'u'
	je Lmu
	cmp al,'D'
	je Lmd
	cmp al,'d'
	je Lmd
	cmp al,'L'
	je Lml
	cmp al,'l'
	je Lml
	cmp al,'R'
	je Lmr
	cmp al,'r'
	je Lmr
EOG:cmp al,'P'
	je Lsp
	cmp al,'p'
	je Lsp
SOG:cmp al,'S'
	je Ls
	cmp al,'s'
	je Ls
	cmp al,'E'
	je Lse
	cmp al,'e'
	je Lse
	jmp Lnx
Lmu:push "UPUP"
	call movePac
	pop eax
	jmp Lnx
Lmd:push "DOWN"
	call movePac
	pop eax
	jmp Lnx
Lml:push "LEFT"
	call movePac
	pop eax
	jmp Lnx
Lmr:push "RGHT"
	call movePac
	pop eax
	jmp Lnx
Lsp:call printMap
	jmp Lnx
Ls :call startGame
	jmp Lnx
Lnx:cmp ghostCount,0
	je Lsg
	call printMenu
	jmp L0
Lsg:cmp mapfilehandle,0
	jne Lem
	call printSOGMenu
	jmp L0
Lem:call printEOGMenu
	jmp L0
Lse:cmp mapfilehandle,0
	je Lex
	mov eax,mapfilehandle
	call closeFile
Lex:invoke ExitProcess,0
main endp
end main