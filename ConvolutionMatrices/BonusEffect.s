	AREA	BonusEffect, CODE, READONLY
	IMPORT	main
	IMPORT	getPicAddr
	IMPORT	putPic
	IMPORT	getPicWidth
	IMPORT	getPicHeight
	EXPORT	start
	PRESERVE8

start

	BL	getPicAddr	; load the start address of the image in R4
	MOV	R4, R0
	BL	getPicHeight	; load the height of the image (rows) in R5
	MOV	R6, R0
	BL	getPicWidth	; load the width of the image (columns) in R6
	MOV	R5, R0
	MOV R0, R4
	LDR R1, =Matrix
	MOV R2, R5
	MOV R3, R6
;R0 - Start address
;R1 - Matrix start address
;R2 - Pic Width
;R3 - Pic Height
applyConvolutionMatrix
	MOV R7, #0
	MOV R8, #0
	MOV R4, R0
	MOV R5, R2
	MOV R6, R3
	
OuterLoop
	CMP R7, R5
	BNE startInnerLoop
	MOV R7, #0
	ADD R8, #1
	CMP R8, R6
	BEQ copy
startInnerLoop
	STMFD sp!, {R7-R8}
	MOV R10, #0
	MOV R11, #0
	MOV R12, #0
	MOV R3, #0
	SUB R8, #1
	SUB R7, #1
innerLoop
	CMP R3, #9 ;If the current value in a 1d representation of the matrix is equal to 9
	BEQ endInnerLoop ;End the inner loop
	CMP R8, #0 
	BLT skipPixel
	CMP R7, #0
	BLT skipPixel
	CMP R7, R5
	BEQ skipPixel
	CMP R8, R6
	BEQ skipPixel
	MUL R9, R8, R5
	ADD R9, R7
	LDR R1, [R4, R9, LSL #2]
	LDR R0, =Matrix
	LDR R0, [R0, R3, LSL #2]
	AND R2, R1, #0x000000FF
	MUL R2, R0, R2
	ADD R10, R2
	AND R2, R1, #0x0000FF00
	LSR R2, #8
	MUL R2, R0, R2
	ADD R11, R2
	AND R2, R1, #0x00FF0000
	LSR R2, #16
	MUL R2, R0, R2
	ADD R12, R2
skipPixel
	ADD R3, #1
	CMP R3, #3
	BNE checkSix
	BEQ notSix
checkSix
	CMP R3, #6
	BNE notNewMatrixRow
notSix
	SUB R7, #2
	ADD R8, #1
	B innerLoop
notNewMatrixRow
	ADD R7, #1
	B innerLoop
endInnerLoop
	LDMFD sp!, {R7-R8}
	MOV R1, R10
	BL divide
	MOV R10, R0
	MOV R1, R11
	BL divide
	MOV R11, R0
	MOV R1, R12
	BL divide
	MOV R12, R0
	LSL R11, #8
	LSL R12, #16
    ADD R10, R11
	ADD R10, R12
	MUL R3, R5, R6
	ADD R9, R4, R3, LSL #2
	MUL R11, R8, R5
	ADD R11, R7
	STR R10, [R9, R11, LSL #2]
	ADD R7, #1
	B OuterLoop
;getRed
;Returns the red component value of a colour
;Parameters: Colour: R0, Returns R value in R0
getRed
	AND R0, #0x000000FF
	BX lr
	
;getGreen
;Returns the red component value of a colour
;Parameters: Colour: R0, Returns G value in R0
getGreen
	AND R0, #0x0000FF00
	LSR R0, #8
	BX lr
	
;getBlue
;Returns the blue component value of a colour
;Parameters: Colour: R0, Returns B value in R0
getBlue
	AND R0, #0x00FF0000
	LSR R0, #16
	BX lr

;Divide
;Divides A by 9
;Parameters: A : R1,  Returns quotient in R0
divide
	MOV R0, R1
	CMP R0, #0
	BGE checkGreater
	MOV R0, #0
checkGreater
	CMP R0, #0x000000FF
	BLT stopdivide
	MOV R0, #0x000000FF
stopdivide
	BX lr


copy
	MOV R7, #0
	MOV R8, #0
	MUL R3, R5, R6
	ADD R9, R4, R3, LSL #2
	BL	getPicAddr	; load the start address of the image in R4
	MOV	R4, R0
copyLoop
	CMP R7, R3
	BEQ put
	LDR R1, [R9, R7, LSL #2]
	STR R1, [R4, R7, LSL #2]
	ADD R7, #1
	B copyLoop
put
	BL putPic
stop	B	stop
	AREA	TestData, DATA, READWRITE
Matrix	DCD 0, -1, 0
		DCD -1, 5, -1
		DCD	0, -1, 0

	END	