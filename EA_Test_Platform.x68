	ORG $1000
START:
PARAMS	REG 	D3-D7/A2-A5

	MOVEA #$7000, A6
	MOVE.L #$11223344, (A6)+
	MOVE.L #$55667788, (A6)+
	MOVEA #$7000, A6

	MOVE.L #2, D6
	JSR EA_GetData
	SIMHALT

* D6 = # of words to read, must be 1 or 2
EA_GetData:
	MOVEM.L PARAMS, -(A7)
	*ADD.L #$2, A6
	CLR.L D2
	EA_GetData_Loop:
	CMPI.B #0, D6
	BLE EA_GetData_LoopDone
		MOVE.L #16, D0
		LSL.L D0, D2
		ADD.W (A6)+, D2
		
		SUBQ.B #1, D6
		BRA EA_GetData_Loop
	EA_GetData_LoopDone:

	MOVEM.L (A7)+, PARAMS
	RTS


	END START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
