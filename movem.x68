D7 = 1 if pop, 0 if push
EA_PrintRegList:
	MOVEM.L PARAMS, (-A7)
	*read the next byte
	CLR.L D0
	MOVE.B (A6)+, D0
	*read the next byte
