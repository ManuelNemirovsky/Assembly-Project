.486
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\msvcrt.inc
includelib msvcrt.lib

include drd.inc
includelib drd.lib

;sound
includelib \masm32\lib\winmm.lib 
include \masm32\include\winmm.inc


.data

msg db "Press OK if your ready to have fun!" , 0
cpt db "WARNING" , 0

is_arrow DWORD 0

robin_y DWORD 0 
robin_x DWORD 0

arrow_y DWORD 0 
arrow_x DWORD 0 

rock_y DWORD 0 
rock_x DWORD 0 

is_fired DWORD 0

is_mon2_dead DWORD 0 ; when its 1, we know that the monster is dead

is_mon2_fired DWORD 0

mon1_y DWORD 520 
mon1_x DWORD 0

mon2_y DWORD 150
mon2_x DWORD 712

mon3_y DWORD 325
mon3_x DWORD 700

mon3Bool1 DWORD 0
mon3Bool2 DWORD 0

mon2Bool1 DWORD 0
mon2Bool2 DWORD 0

firstRichAlive DWORD 1
secRichAlive DWORD 1
thirRichAlive DWORD 1

boolean_is_rock_no_need BYTE 0 ;boolean to check if we need to draw the rock
							   ;it will turn on when we killed the monster that shot the rock

mon1Way DWORD 1

GameSound db "Desmeon_-_Hellcat_[NCS_Release_.wav",0		  ;for the sound of the game
LoseSound db "Frank_Sinatra_My_Way_With_Lyrics.wav",0		  ;3 diffrent songs in the start of the game,
winSound db "Queen_-_We_are_the_champions_Chorus_only_.wav",0 ;when you win and when you lose.

changeWay DWORD 1

is_robin_win BYTE 0
is_robin_lose BYTE 0

imgDelMon1 BYTE 0
imgDelMon2 BYTE 0
imgDelMon3 BYTE 0
imgDelRock1 BYTE 0


aBg BYTE "forest.bmp",0
bg Img<0,0,0,0>

aRobin BYTE "robin.bmp",0 
robin Img<0,0,0,0>

aGold BYTE "gold.bmp",0 
gold Img<0,0,0,0>

aMonster1 BYTE "monster1.bmp",0 
monster1 Img<0,0,0,0>

aMonster2 BYTE "monster2.bmp",0 
monster2 Img<0,0,0,0>

aMonster3 BYTE "monster3.bmp",0 
monster3 Img<0,0,0,0>

aArrow BYTE "arrow.bmp",0
arrow Img<0,0,0,0>

aRock BYTE "rock.bmp",0
rock Img<0,0,0,0>	

aOpen BYTE "OpenningPic.bmp",0
open Img<0,0,0,0>

aRules BYTE "rules.bmp",0
rules Img<0,0,0,0>

aWin BYTE "WIN.bmp",0
win Img<0,0,0,0>

aLose BYTE "lose.bmp",0
lose Img<0,0,0,0>

.code

;This function is for making 
;the possibility to write
;couple of code lines in one line
X macro args:VARARG
	asm_txt TEXTEQU <>
	FORC char,<&args>
		IFDIF <&char>,<!\>
			asm_txt CATSTR asm_txt,<&char>
		ELSE
			asm_txt
			asm_txt TEXTEQU <>
		ENDIF
	ENDM
	asm_txt
endm

;This function is for making movement of robin hood
;include the part of the shooting.
;the function jump to each loop of movement and moves 
;robin accurding to the key.
;in this function their is the boolean that turn on 
;when we are shooting

moveRobin PROC
X	invoke GetAsyncKeyState, VK_RIGHT \ cmp eax, 0 \ jne right 
		 
X	invoke GetAsyncKeyState, VK_LEFT \ cmp eax, 0 \ jne left 

X	invoke GetAsyncKeyState, VK_UP \ cmp eax, 0 \ jne up 

X	invoke GetAsyncKeyState, VK_DOWN \ cmp eax, 0 \ jne down 

X	invoke GetAsyncKeyState, VK_SPACE \ cmp eax, 0 \ jne shoot  

		jmp nothing

	right:
		cmp robin_x,725
		je nothing	
		inc robin_x
		ret

	left:
		cmp robin_x,0
		je nothing
		dec robin_x 
		ret	
	
	up:
		cmp robin_y,0
		je nothing
		dec robin_y
		ret	

	down:
		cmp robin_y,490
		je nothing
		inc robin_y
		ret


	shoot:
		mov is_arrow, 1
		ret
	
	nothing:
		ret
		
moveRobin ENDP

;This function is for checking when the rock and the arrow 
;are in the same coordinates using registers 
;and if they are in the same spot, then were jumping to the loop that 
;make the booleans of the dissappearing of the rock and the arrow on.

checkRockAroow PROC

	mov ecx , arrow_y
	mov eax , arrow_x

	mov ebx , rock_x
	cmp ebx , eax
	je checkNextX

	jmp nothing

	checkNextX:
		add eax , 62
		cmp ebx , eax
		jbe checkFirstY
		ret

	checkFirstY:
		mov ebx , rock_y
		cmp ecx , ebx
		jbe checkSecY
		ret

	checkSecY:
		add ecx , 20 ; for comparing the y of robins
		cmp ecx , ebx 
		jge loseArrowAndRock
		ret

	loseArrowAndRock:
		mov boolean_is_rock_no_need, 1
		mov is_arrow, 0
		mov is_fired, 0
		ret

	nothing:
		ret

checkRockAroow ENDP

;This function is for making the second monster shooting using the rock picture.
;the function has one boolean that if he is 1 were jumping to the loop that draws 
;the rock accurding to the coordinates of the second monster (were checking it before the draw loop).
;inside the draw loop, we check the x of the rock and if he is 0 were jumping to the 
;destroy of the rock loop that will chenge the boolean to 0 for stop drawing.
monster2Shooting PROC

	cmp is_mon2_fired, 1
	je drawRock

	cmp boolean_is_rock_no_need , 1
	je drawThisRock

	mov eax, mon2_x
	mov ebx, mon2_y

	mov is_mon2_fired, 1

	mov rock_x, eax
	mov rock_y, ebx

	add rock_y , 55
	sub rock_x , 88

	jmp nothing

	drawRock:
		cmp rock_x, 0
		je destroy_Rock

		invoke checkRockAroow

		dec rock_x
		invoke drd_imageDraw, offset rock, rock_x, rock_y
		ret

		drawThisRock:
			ret

	destroy_Rock:
		mov is_mon2_fired, 0
		ret

	nothing:
		ret	

monster2Shooting ENDP


;this function is for moving the first rich.
;the function has 4 movements that we jump to in loops.
;in each loop, accurding to the movement, we compare or the x 
;or the Y untill the place that we want to jump
;and then we jump to the next loop.
moveMonster1 PROC
	cmp mon1Way , 1
	jne secMov1
	cmp mon1_y , 0
	je nothing1
	inc mon1_x
	dec mon1_y
	ret

	secMov1:
		cmp mon1Way , 2
		jne thrMon1
		cmp mon1_x , 720
		jae nothing1
		inc mon1_x
		inc mon1_y
		ret

	thrMon1:
		cmp mon1Way , 3
		jne final1
		cmp mon1_y , 520
		jae nothing1
		dec mon1_x
		inc mon1_y
		ret

	final1:
		cmp mon1_x , 0
		je endd1
		dec mon1_x
		cmp mon1_x , 0
		ret

	nothing1:
		inc mon1Way
		ret

	endd1:
		mov mon1Way , 1
		ret

moveMonster1 ENDP


;This function is for the movement of the second rich
;is movement works with two booleans. he has
;two movements that go again and again 
;(but still have 4 movements and 4 loops).
;he has 2 boolean that we check when they are the same
;and accurding to that we know when to turn on each loop.
;when they are the same, we jump to the first loop
;and when they are not, we jump to the 3 loop that goes
;back to the first place.
;in the second loop and the 4 loop we inc each boolean.
moveMonster2 PROC
	mov eax , mon2Bool1
	mov ebx , mon2Bool2
	cmp eax , ebx
	je mon2switch1
	jne mon2switch3

	mon2switch1:
		cmp mon2_x , 350
		je mon2switch2
		dec mon2_x
		ret

	mon2switch2:
		cmp mon2_y , 489
		je incMon2Bool1
		inc mon2_y
		ret

	incMon2Bool1:
		inc mon2Bool1
		ret

	mon2switch3:
		cmp mon2_y , 150
		je mon2switch4
		dec mon2_y
		ret

	mon2switch4:
		cmp mon2_x , 712
		je incMon2Bool2
		inc mon2_x
		ret

	incMon2Bool2:
		inc mon2Bool2
		ret

moveMonster2 ENDP

;This function is for the movement of the third rich
;is movement works with two booleans. he has
;two movements that go again and again 
;(but still have 4 movements and 4 loops).
;he has 2 boolean that we check when they are the same
;and accurding to that we know when to turn on each loop.
;when they are the same, we jump to the first loop
;and when they are not, we jump to the 3 loop that goes
;back to the first place.
;in the second loop and the 4 loop we inc each boolean.
moveMonster3 PROC
	mov eax , mon3Bool1
	mov ebx , mon3Bool2
	cmp eax , ebx
	je switch1
	jne switch3


	switch1:
		cmp mon3_x , 500
		je switch2
		dec mon3_x
		ret

	switch2:
		cmp mon3_y , 502
		je incMon3Bool1
		inc mon3_y
		ret

	incMon3Bool1:
		inc mon3Bool1
		ret

	switch3:
		cmp mon3_y , 325
		je switch4
		dec mon3_y
		ret

	switch4:
		cmp mon3_x , 700
		je incMon3Bool2
		inc mon3_x
		ret

	incMon3Bool2:
		inc mon3Bool2
		ret
moveMonster3 ENDP


;This function is for checking if robing hood
;won and got to the gold.
;first, we compare the x and then we 
;jump to a loop that compare the upper 
;y of robing and the gold, and then we are jumping to the 
;loop of the loweer y of robing and the gold.
;if we compare and its in the range, we will 
;jump to a loop that change the value of the 
;boolean is_robin_win to 1.
checkIfWin PROC

	cmp robin_x , 725
	je checkFirstY

	jmp nothing

	checkFirstY:
		cmp robin_y , 415
		jge checkSecY
		ret

	checkSecY:
		cmp robin_y , 490
		jle jIfWin
		ret

	jIfWin:
		mov is_robin_win , 1
		ret

	nothing:
		ret

checkIfWin ENDP 

;this function is for checking 
;if robing touch the third rich and lost.
;we take the x and y of robing and compare 
;it first with the upper x of the rich,
;then with the lower x of the rich and in the end 
;we compare it with the upper y and the lower y.
;each check is in a loop and in te end of the checking, the last loop
;calls to the loop that jump to lose game.
;in this loop we change the is_robin_lose boolean to 1.
hitMonster3 PROC
	
	mov ecx , robin_y
	mov eax , robin_x

	mov ebx , mon3_x
	cmp ebx , eax
	jge mon3CheckSecx

	jmp nothing

	mon3CheckSecx:
		add eax , 75
		cmp ebx , eax
		jbe mon3CheckFirstY
		ret

	mon3CheckFirstY:
		mov ebx , mon3_y
		cmp ecx , ebx
		jbe mon3CheckSecY
		ret

	mon3CheckSecY:
		add ecx , 110 ; for comparing the y of robins
		cmp ecx , ebx 
		jge youLose
		ret

	youLose:
		mov is_robin_lose , 1
		ret

	nothing:
		ret

hitMonster3 ENDP

;this function is for checking 
;if robing touch the first rich and lost.
;we take the x and y of robing and compare 
;it first with the upper x of the rich,
;then with the lower x of the rich and in the end 
;we compare it with the upper y and the lower y.
;each check is in a loop and in te end of the checking, the last loop
;calls to the loop that jump to lose game.
;in this loop we change the is_robin_lose boolean to 1.
hitMonster1 PROC

	mov ecx , robin_y
	mov eax , robin_x

	mov ebx , mon1_x
	cmp ebx , eax
	jge mon1CheckSecx

	jmp nothing

	mon1CheckSecx:
		add eax , 75
		cmp ebx , eax
		jbe mon1CheckFirstY
		ret

	mon1CheckFirstY:
		mov ebx , mon1_y
		cmp ecx , ebx
		jbe mon1CheckSecY
		ret

	mon1CheckSecY:
		add ecx , 110 ; for comparing the y of robins
		cmp ecx , ebx 
		jge youLose
		ret

	youLose:
		mov is_robin_lose , 1
		ret

	nothing:
		ret

hitMonster1 ENDP 

;this function is for checking 
;if robing touch the second rich and lost.
;we take the x and y of robing and compare 
;it first with the upper x of the rich,
;then with the lower x of the rich and in the end 
;we compare it with the upper y and the lower y.
;each check is in a loop and in te end of the checking, the last loop
;calls to the loop that jump to lose game.
;in this loop we change the is_robin_lose boolean to 1.
hitMonster2 PROC

	mov ecx , robin_y
	mov eax , robin_x

	mov ebx , mon2_x
	cmp ebx , eax
	je mon2CheckSecx

	mon2CheckSecx:
		add eax , 75
		cmp ebx , eax
		jbe mon2CheckFirstY
		ret

	mon2CheckFirstY:
		mov ebx , mon2_y
		cmp ecx , ebx
		jbe mon2CheckSecY
		ret

	mon2CheckSecY:
		add ecx , 110 ; for comparing the y of robins
		cmp ecx , ebx 
		jge youLose
		ret

	youLose:
		mov is_robin_lose , 1
		ret

	nothing:
		ret

hitMonster2 ENDP

;this function is for checking 
;if robing touch the rock and lost.
;we take the x and y of robing and compare 
;it first with the upper x of the rich,
;then with the lower x of the rich and in the end 
;we compare it with the upper y and the lower y.
;each check is in a loop and in te end of the checking, the last loop
;calls to the loop that jump to lose game.
;in this loop we change the is_robin_lose boolean to 1.
hitRock PROC

	mov ecx , robin_y
	mov eax , robin_x

	mov ebx , rock_x
	cmp ebx , eax
	jge checkRockSecx

	jmp nothing

	checkRockSecx:
		add eax , 75
		cmp ebx , eax
		jbe checkRockFirstY
		ret

	checkRockFirstY:
		mov ebx , rock_y
		cmp ecx , ebx
		jbe checkRockSecY
		ret

	checkRockSecY:
		add ecx , 110 ; for comparing the y of robins
		cmp ecx , ebx 
		jge youLose
		ret

	youLose:
		mov is_robin_lose , 1
		ret

	nothing:
		ret

hitRock ENDP

;this function is for checking if the first moster 
;is dead and then we dont need to draw 
;her any more and we can delete her.
;the function need to delet her 1 time and it do it by 
;inc boolean that if he is 1, we need to jump 
;above the delet order.
;after that, we move the x and y to the corner of the game.
checkIfMon1Dead PROC

	cmp firstRichAlive, 1
	jne movFirstRich

	ret

	movFirstRich:
		
		cmp imgDelMon1 , 1
		je noDelAgain1

		invoke drd_imageDelete, offset monster1

		mov imgDelMon1 , 1
		noDelAgain1:

		mov mon1_x , 732
		mov mon1_y , 0 

		ret
checkIfMon1Dead ENDP


checkIfMon2Dead PROC

	cmp secRichAlive, 1
	jne movSecRich

	ret

	movSecRich:

		cmp imgDelMon2 , 1
		je noDelAgain2

		invoke drd_imageDelete, offset monster2
		mov imgDelMon2 , 1

		noDelAgain2:

		mov boolean_is_rock_no_need , 1 
		mov is_mon2_dead , 1
		mov mon2_x , 712
		mov mon2_y , 0
		ret
checkIfMon2Dead ENDP


checkIfMon3Dead PROC

	cmp thirRichAlive, 1
	jne movThrRich

	ret

	movThrRich:

		cmp imgDelMon3 , 1
		je noDelAgain3
		
		invoke drd_imageDelete, offset monster3
		mov imgDelMon3 , 1

		noDelAgain3:

		mov mon3_x , 700
		mov mon3_y , 0 
		ret
checkIfMon3Dead ENDP

;this function is for checking if the rock 
;is dead and then we dont need to draw 
;her any more and we can delete her.
;the function need to delet her 1 time and it do it by 
;inc boolean that if he is 1, we need to jump 
;above the delet order.
;after that, we move the x and y to the corner of the game.
;we also change the boolean_is_rock_no_need to 1 for stop drawing rocks
checkIfRockDead PROC

	cmp boolean_is_rock_no_need , 1
	je deleteRock

	ret

	deleteRock:
		cmp imgDelRock1 , 1
		je noDelAgainRock

		invoke drd_imageDelete, offset rock
		
		mov imgDelRock1 , 1

		noDelAgainRock:

		mov  is_mon2_fired , 0
		mov rock_x , 775 
		mov rock_y , 0

		ret
checkIfRockDead ENDP

;this function ifs for check if robin hit the monster
; with the arrow and then jump to the delete 
;of the monster and move her.
;we check the x and y of the top and the buttom and then 
;we jump to destroy the monster and the arrow.
monster1Arrow PROC

	mov ecx , arrow_y
	mov eax , arrow_x
	add eax , 62

	mov ebx , mon1_x
	cmp ebx , eax
	je mon1checkY

	jmp nothing

	mon1checkY:
		mov ebx , mon1_y
		cmp ecx , ebx
		jge mon1checkSecY
		ret

	mon1checkSecY:
		add ebx , 69 ; for comparing the y of monster
		cmp ecx , ebx 
		jbe destroyMon1
		ret

	destroyMon1:
		mov firstRichAlive , 0
		jmp destroy_arrow
		ret
		
	destroy_arrow:
		mov is_arrow, 0
		mov is_fired, 0
		ret

	nothing:
		ret

monster1Arrow ENDP

monster2Arrow PROC
	mov ecx , arrow_y
	mov eax , arrow_x
	add eax , 62

	mov ebx , mon2_x
	cmp ebx , eax
	je mon2checkY

	jmp nothing
	mon2checkY:
		mov ebx , mon2_y
		cmp ecx , ebx
		jge mon2checkSecY
		ret
	mon2checkSecY:
		add ebx , 111 ; for comparing the y of monster
		cmp ecx , ebx
		jbe destroyMon2
		ret
	destroyMon2:
		mov secRichAlive , 0
		mov is_mon2_dead , 1
		jmp destroy_arrow
		ret
	destroy_arrow:
		mov is_arrow, 0
		mov is_fired, 0
		ret

	nothing:
		ret
monster2Arrow ENDP


monster3Arrow PROC

	mov ecx , arrow_y
	mov eax , arrow_x
	add eax , 62

	mov ebx , mon3_x
	cmp ebx , eax
	je mon3checkY

	jmp nothing

	mon3checkY:
		mov ebx , mon3_y
		cmp ecx , ebx
		jge mon3checkSecY
		ret

	mon3checkSecY:
		add ebx , 98 ; for comparing the y of monster
		cmp ecx , ebx 
		jbe destroyMon3
		ret

	destroyMon3:
		mov thirRichAlive , 0
		jmp destroy_arrow
		ret

	destroy_arrow:
		mov is_arrow, 0
		mov is_fired, 0
		ret

	nothing:
		ret

monster3Arrow ENDP

Shoot PROC

	cmp is_arrow, 0
	je destroy_arrow

	cmp is_fired, 1
	je draw

	mov eax, robin_x
	mov ebx, robin_y

	mov is_fired, 1

	mov arrow_x, eax
	mov arrow_y, ebx

	add arrow_y , 55
	add arrow_x , 75

	draw: 
		cmp arrow_x, 737
		jge destroy_arrow

		mov ebx ,arrow_x
		add ebx , 62

		invoke monster1Arrow

		invoke monster2Arrow

		invoke monster3Arrow

		inc arrow_x
		invoke drd_imageDraw, offset arrow, arrow_x, arrow_y
		ret

		destroy_arrow:
		mov is_arrow, 0
		mov is_fired, 0
		ret

Shoot ENDP

makeSomething PROC

	

makeSomething ENDP


main PROC
	invoke MessageBox, NULL, addr msg , addr cpt, MB_OK
	invoke drd_init, 800, 600, INIT_WINDOW 
	invoke PlaySound,addr GameSound,NULL,SND_ASYNC
	invoke drd_imageLoadFile,offset aBg, offset bg
	invoke drd_imageLoadFile,offset aRobin, offset robin  
	invoke drd_imageLoadFile,offset aGold, offset gold
	invoke drd_imageLoadFile,offset aMonster1, offset monster1
	invoke drd_imageLoadFile,offset aMonster2, offset monster2
	invoke drd_imageLoadFile,offset aMonster3, offset monster3
	invoke drd_imageLoadFile,offset aArrow, offset arrow
	invoke drd_imageLoadFile,offset aRock, offset rock
	invoke drd_imageLoadFile,offset aOpen, offset open
	invoke drd_imageLoadFile,offset aRules, offset rules
	invoke drd_imageLoadFile,offset aWin, offset win
	invoke drd_imageLoadFile,offset aLose, offset lose

	invoke drd_imageSetTransparent, offset robin, 0FFFFFFh
	invoke drd_imageSetTransparent, offset gold, 0FFFFFFh
	invoke drd_imageSetTransparent, offset monster1, 0FFFFFFh
	invoke drd_imageSetTransparent, offset monster2, 0FFFFFFh
	invoke drd_imageSetTransparent, offset monster3, 0FFFFFFh
	invoke drd_imageSetTransparent, offset arrow, 0FFFFFFh
	invoke drd_imageSetTransparent, offset rock, 0FFFFFFh

	openGame:
		invoke drd_imageDraw , offset open , 0 , 0
		invoke drd_processMessages
		invoke drd_flip
		X	invoke GetAsyncKeyState, 52h \ cmp eax, 0 \ jne again
		X	invoke GetAsyncKeyState, 53h \ cmp eax, 0 \ jne rulesLoop
		jmp openGame

	rulesLoop:
		invoke drd_imageDraw , offset rules , 0 , 0
		invoke drd_processMessages
		invoke drd_flip
		X	invoke GetAsyncKeyState, 52h \ cmp eax, 0 \ jne again
		X	invoke GetAsyncKeyState, 54h \ cmp eax, 0 \ jne openGame
		jmp rulesLoop

	winLoop:
		invoke drd_imageDraw , offset win , 0 , 0
		invoke drd_processMessages
		invoke drd_flip
		jmp winLoop

	loseLoop:
		invoke drd_imageDraw , offset lose , 0 , 0
		invoke drd_processMessages
		invoke drd_flip
		jmp loseLoop

	playLoseSound:
		invoke PlaySound,NULL,NULL,SND_ASYNC
		invoke PlaySound,addr LoseSound,NULL,SND_ASYNC
		jmp loseLoop

	playWinSound:
		invoke PlaySound,NULL,NULL,SND_ASYNC
		invoke PlaySound,addr winSound,NULL,SND_ASYNC
		jmp winLoop

	again:
		invoke drd_imageDraw , offset bg , 0,0
		invoke Sleep,1

		;Were making check if the character is dead
		cmp firstRichAlive, 1
		jne skip1Draw

		invoke moveMonster1
		invoke drd_imageDraw , offset monster1 , mon1_x , mon1_y	
		skip1Draw:

		;Were making check if the character is dead
		cmp secRichAlive , 1
		jne skip2Draw

		invoke moveMonster2
		invoke drd_imageDraw , offset monster2 , mon2_x , mon2_y
		skip2Draw:

		;Were making check if the character is dead
		cmp thirRichAlive , 1
		jne skip3Draw

		invoke moveMonster3
		invoke drd_imageDraw , offset monster3 , mon3_x , mon3_y

		skip3Draw:
			
		invoke drd_imageDraw , offset robin , robin_x , robin_y 
		invoke drd_imageDraw , offset gold, 725 , 490
		invoke drd_processMessages

		cmp is_mon2_dead , 1
		je skipMon2Shooting

		invoke monster2Shooting

		skipMon2Shooting:

		invoke moveRobin 
		invoke Shoot
		invoke checkIfWin
		invoke hitMonster1
		invoke hitMonster2
		invoke hitMonster3
		invoke hitRock
		invoke checkIfMon1Dead
		invoke checkIfMon2Dead
		invoke checkIfMon3Dead
		invoke checkIfRockDead

		cmp is_robin_win , 1
		je playWinSound

		cmp is_robin_lose , 1
		je playLoseSound

		invoke drd_flip
		jmp again
		ret



main ENDP


end main