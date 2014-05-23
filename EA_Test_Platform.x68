	ORG $1000
START:
PARAMS	REG 	D3-D7/A2-A6
	MOVE.W #$7000, A0

	* MOVE.W A2, D4 == 380A
	* MOVE.W (A3), D5 == 3A13
	* MOVE.W -(A1), (A0)+ == 30E1
	*
	*

	MOVE.L #$000030E1, D4   
	JSR EA_DECODE
	SIMHALT

EA_DECODE:
	JSR EA_DECODE_CASE1
	RTS
EA_DECODE_CASE1:
	MOVEM.L PARAMS, -(A7)
	* get source mode ===============
	MOVE.L #$00000003, D6 * shift
	MOVE.L #$00000003, D7 * keep
	JSR EA_ShiftAndMask
	MOVE.L D2, D5

	* get source register
	MOVE.L #$00000000, D6 * shift
	MOVE.L #$00000003, D7 * keep
	JSR EA_ShiftAndMask
	
	MOVE.L D5, D6
	MOVE.L D2, D7

	* HandleOperand(src=d6, reg=d7)
	JSR EA_HandleOperand

	*Print comma & space.
	MOVE.B #$2C, (A0)+
	MOVE.B #$20, (A0)+

	* Get dest mode =================
	MOVE.L #$00000006, D6 * shift
	MOVE.L #$00000003, D7 * keep
	JSR EA_ShiftAndMask
	MOVE.L D2, D5

	* get dest register	
	MOVE.L #$00000009, D6 * shift
	MOVE.L #$00000003, D7 * keep
	JSR EA_ShiftAndMask

	MOVE.L D5, D6
	MOVE.L D2, D7
	JSR EA_HandleOperand

	MOVEM.L (A7)+, PARAMS
	RTS

* Mode = D6
* Register = D7
EA_HandleOperand:
	MOVEM.L PARAMS, -(A7)

	*if src == 0 --> directData
	CMP.B #0, D6
	BEQ EA_HandleOperand_IfDirectData

	*elif src == 1 --> direct address
	CMP.B #1, D6
	BEQ EA_HandleOperand_IfDirectAddress

	*elif src == 2 --> indirect address
	CMP.B #2, D6
	BEQ EA_HandleOperand_IfIndirectAddr

	*elif src == 3 --> post dec address
	CMP.B #3, D6
	BEQ EA_HandleOperand_IfPostDec

	*elif src == 4 --> pre dec address
	CMP.B #4, D6
	BEQ EA_HandleOperand_IfPreDec

	BRA EA_HandleOperand_IfElse 	* Not any of the supported modes, error.

	EA_HandleOperand_IfDirectData:
		JSR EA_DirectData
		BRA EA_HandleOperand_IfEnd
	EA_HandleOperand_IfDirectAddress:
		JSR EA_DirectAddress
		BRA EA_HandleOperand_IfEnd
	EA_HandleOperand_IfIndirectAddr:
		JSR EA_IndirectAddress
		BRA EA_HandleOperand_IfEnd
	EA_HandleOperand_IfPostDec:
		JSR EA_PostDecAddress
		BRA EA_HandleOperand_IfEnd
	EA_HandleOperand_IfPreDec:
		JSR EA_PreDecAddress
		BRA EA_HandleOperand_IfEnd
	EA_HandleOperand_IfElse:
	* TODO ERROR HANDLING HERE -----------
		BRA EA_HandleOperand_IfEnd
	EA_HandleOperand_IfEnd:

	MOVEM.L (A7)+, PARAMS
	RTS

EA_DirectData:
	MOVEM.L PARAMS, -(A7)

	MOVE.B #$44, (A0)+ 		* Data (D)
	*Print the register #
	MOVE.L D7, D2
	MOVE.L #$00000001, D3
	JSR IO_HEX2ASCII

	MOVEM.L (A7)+, PARAMS
	RTS

EA_DirectAddress:
	MOVEM.L PARAMS, -(A7)
	MOVE.B #$41, (A0)+ 		* Address (A)
	*Print the register #
	MOVE.L D7, D2
	MOVE.L #$00000001, D3
	JSR IO_HEX2ASCII

	MOVEM.L (A7)+, PARAMS
	RTS

EA_IndirectAddress:
	MOVEM.L PARAMS, -(A7)

	MOVE.B #$28, (A0)+		* '('
	JSR EA_DirectAddress
	MOVE.B #$29, (A0)+		* ')'

	MOVEM.L (A7)+, PARAMS
	RTS

EA_PostDecAddress:
	MOVEM.L PARAMS, -(A7)

	JSR EA_IndirectAddress
	MOVE.B #$2B, (A0)+		* '+'

	MOVEM.L (A7)+, PARAMS
	RTS

EA_PreDecAddress:
	MOVEM.L PARAMS, -(A7)

	MOVE.B #$2D, (A0)+		* '-'
	JSR EA_IndirectAddress

	MOVEM.L (A7)+, PARAMS
	RTS

*	*** Initial Setup
*	* D1 is the case
*	* D4 is the word instruction
*	* D5 is the instruction length
*
*	MOVE.W #$7000, A0
*
*	MOVE.B #1, D1
*	MOVE.L #$00003209, D4   * MOVE.W A1, D1
*							* source mode = 111, dest = 000
*
*	* Print Source =============================================================
*	MOVE.L #$00000003, D6 * shift
*	MOVE.L #$00000003, D7 * keep
*	JSR EA_ShiftAndMask
*
*	CMP.B #%000, D2				* mode = direct data register
*	BEQ EA_Decode_IfModeDirect
*	CMP.B #%001, D2 			* mode = direct address register
*	BEQ EA_Decode_IfModeDirect
*
*	EA_DecodeSource_IfModeDirect:
*		*save source mode in d3
*		MOVE.L D2, D3
*
*		* get register.
*		MOVE.L #$00000000, D6 * shift
*		MOVE.L #$00000003, D7 * keep
*		JSR EA_ShiftAndMask
*
*		* setup sub call.
*		MOVE.L D3, D6
*		MOVE.L D2, D7
*
*		* call direct source mode
*		JSR EA_DirectSourceMode
*
*	*Print comma & space.
*	MOVE.B #$2C, (A0)+
*	MOVE.B #$20, (A0)+
*	* Print Destination ========================================================
*
*
*	SIMHALT
*
**D4 = word instruction
**D6 = Source Mode bits
**D7 = Source Mode register #
*EA_DirectSourceMode:
*	* Choose D or A to print
*	MOVEM.L PARAMS, -(A7)
*	CMP.W #$0, D6
*	BEQ EA_DirectSourceMode_IfD
*	BRA EA_DirectSourceMode_IfA
*
*	EA_DirectSourceMode_IfD:
*		MOVE.B #$44, (A0)+ 		* Data (D)
*		BRA EA_DirectSourceMode_IfADEnd
*	EA_DirectSourceMode_IfA:
*		MOVE.B #$41, (A0)+ 		* Address (A)
*		BRA EA_DirectSourceMode_IfADEnd
*	EA_DirectSourceMode_IfADEnd:
*
*	*Print the register #
*	MOVE.L D7, D2
*	MOVE.L #$00000001, D3
*	JSR IO_HEX2ASCII
*
*
*	MOVEM.L (A7)+, PARAMS
*	RTS



* D4 = shift & mask data (LW)
* D6 = Shift right amount (LW)
* D7 = # of bits wanted (LW)
* Return in D2 (LW)
EA_ShiftAndMask:
	MOVEM.L PARAMS, -(A7)
	CLR.L 	D2
	LSR.L 	D6, D4
	* build masking data
	CLR.L D1 				* D1 = #$0000 0000
	* for D7 > 0
	EA_ShiftAndMask_ForLoop:
		CMP.B 	#0, D7
		BLE EA_ShiftAndMask_ForLoopDone

		LSL.L 	#1, D1
		ADD.L 	#%00000000000000000000000000000001, D1
		SUBQ.L 	#1, D7 		* Decrement loop
		BRA EA_ShiftAndMask_ForLoop
	EA_ShiftAndMask_ForLoopDone:
	AND.L 	D1, D4
	MOVE.L 	D4, D2

	MOVEM.L (A7)+, PARAMS
	RTS
* ============================ END EA_ShiftAndMask

* ========== Convert # in data register to line buffer
* D2 contains hex value to convert
* D3 contains # of bytes, number length.
* A0 Contains the line buffer
IO_HEX2ASCII:
    MOVEM.L D0-D7/A1-A7, -(A7)
    CLR.L D1
    MOVE.B 	#8, D4
    SUB.B 	D3, D4
    * discard unneeded front bits
    IO_HEX2ASCII_DiscardLoop:
    	CMP.B 	#0, D4
    	BLE 	IO_HEX2ASCII_DiscardLoopDone
    	ROL.L 	#4, D2
    	SUBQ.B 	#1, D4
    	BRA 	IO_HEX2ASCII_DiscardLoop
    IO_HEX2ASCII_DiscardLoopDone:
    
    MOVE.B D3, D1 			* counter for loop

    IO_HEX2ASCII_ConvertLoop:
        ROL.L #4, D2          * rotate the value once.
        MOVE.L D2, D3         * copy
        AND.L #$0000000F, D3
        CMP.B #$09,D3        * if F <= d3, letter.
        BGT IO_HEX2ASCII_IfLetter
        BLE IO_HEX2ASCII_IfDigit             * else, digit.

            IO_HEX2ASCII_IfLetter:
                ADD #$37,D3         * add $37
                BRA IO_HEX2ASCII_EndIf
            IO_HEX2ASCII_IfDigit:
                ADD #$30,D3         * add $30
        IO_HEX2ASCII_EndIf:
            MOVE.B D3,(A0)+       * write to line buffer

        SUB.B #1,D1         * decrement loop counter
    BNE IO_HEX2ASCII_ConvertLoop    * repeat loop?

    MOVEM.L (A7)+, D0-D7/A1-A7
    RTS


	END START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
