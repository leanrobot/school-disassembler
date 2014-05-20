	ORG $1000
START:
    MOVE.B #8, d1 * counter for loop
    MOVEA LINE,A1 * load string buffer
    MOVE.L #$001F70C2, D2
LOOP  ROL.L #4, D2          * rotate the value once.
      MOVE.L D2, D3         * copy
      AND.L #$0000000F, D3
      CMP.B #$09,D3        * if F <= d3, letter.
      BGT Letter
      BLE Digit             * else, digit.
Letter  ADD #$37,D3         * add $37
        BRA EndIf
Digit   ADD #$30,D3         * add $30
EndIf   SUB.B #1,D1         * decrement loop counter
        BNE LOOP          * repeat loop?
        
LINE    DS.B 80

	END START
	

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
