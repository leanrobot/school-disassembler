

    ORG $1000
PARAMS  REG     D0-D1/D3-D7/A2-A5
START:
    
    MOVE.L #$FFFF, D4
    JSR ReverseBits
    SIMHALT

*D4 = word
*returns in D2
ReverseBits:
    MOVEM.L PARAMS, -(A7)
    * counter = 16
    MOVE.L #16, D0

    LoopStart:
    CMP.B #0, D0
    BEQ LoopDone
        LSL.W #1, D5
        LSR.W #1, D4
        BCC AddZero
        ADD.W #1, D5
        AddZero:

        SUB.B #1, D0
        BRA LoopStart
    LoopDone:

    MOVEM.L (A7)+, PARAMS
    RTS


    END START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
