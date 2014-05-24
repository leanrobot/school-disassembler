
*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $7000
START:                  ; first instruction of program
**************ADD**************
    
    ADD.B       D0,D1
    ADD.B       D0,(A1)
    ADD.B       D0,(A1)+
    ADD.B       D0,-(A1)
    ADD.B       D0,$8000
    ADD.B       D0,$4000  
    ADD.B       (A0),D1
    ADD.B       (A0)+,D1
    ADD.B       -(A0),D1
    ADD.B       $8002,D1
    ADD.B       $4002,D1
    
    ADD.W       D0,D1
    ADD.W       D0,(A1)
    ADD.W       D0,(A1)+
    ADD.W       D0,-(A1)
    ADD.W       D0,$8000
    ADD.W       D0,$4000
    ADD.W       A0,D1
    ADD.W       (A0),D1
    ADD.W       (A0)+,D1
    ADD.W       -(A0),D1
    ADD.W       $8002,D1
    ADD.W       $4002,D1

 	ADD.L       D0,D1
    ADD.L       D0,(A1)
    ADD.L       D0,(A1)+
    ADD.L       D0,-(A1)
    ADD.L       D0,$8000
    ADD.L       D0,$4000
    ADD.L       A0,D1
    ADD.L       (A0),D1   
    ADD.L       (A0)+,D1  
    ADD.L       -(A0),D1  
    ADD.L       $8002,D1 
    ADD.L       $4002,D1


**************ADDA************** 
   
    ADDA.W       D1,A2
    ADDA.W       A0,A2
    ADDA.W       (A1),A2
    ADDA.W       #1234,A2
    ADDA.W       (A1)+,A2
    ADDA.W       -(A1),A2
    ADDA.W       $8000,A2
    ADDA.W       $4000,A2
 	
	ADDA.L       D1,A2
    ADDA.L       A0,A2
    ADDA.L       (A1),A2
    ADDA.L       #1234,A2
    ADDA.L       (A1)+,A2
    ADDA.L       -(A1),A2
    ADDA.L       $8000,A2
    ADDA.L       $4000,A2
   
**************MULS**************
 
    MULS.W       D1,D0
    MULS.W       (A1),D0
    MULS.W       #1234,D0
    MULS.W       (A1)+,D0
    MULS.W       -(A1),D0
    MULS.W       $8000,D0
    MULS.W       $4000,D0
    
**************DIVS**************

 	DIVS.W       D1,D0
    DIVS.W       (A1),D0
    DIVS.W       #1234,D0
    DIVS.W       (A1)+,D0
    DIVS.W       -(A1),D0
    DIVS.W       $8000,D0
    DIVS.W       $4000,D0
    
*************SUB**************
    
    SUB.B       D0,D1
    SUB.B       D0,(A1)
    SUB.B       D0,(A1)+
    SUB.B       D0,-(A1)
    SUB.B       D0,$8000
    SUB.B       D0,$4000  
    SUB.B       (A0),D1
    SUB.B       (A0)+,D1
    SUB.B       -(A0),D1
    SUB.B       $8002,D1
    SUB.B       $4002,D1
    
    SUB.W       D0,D1
    SUB.W       D0,(A1)
    SUB.W       D0,(A1)+
    SUB.W       D0,-(A1)
    SUB.W       D0,$8000
    SUB.W       D0,$4000
    SUB.W       A0,D1
    SUB.W       (A0),D1
    SUB.W       (A0)+,D1
    SUB.W       -(A0),D1
    SUB.W       $8002,D1
    SUB.W       $4002,D1

 	SUB.L       D0,D1
    SUB.L       D0,(A1)
    SUB.L       D0,(A1)+
    SUB.L       D0,-(A1)
    SUB.L       D0,$8000
    SUB.L       D0,$4000
    SUB.L       A0,D1
    SUB.L       (A0),D1   
    SUB.L       (A0)+,D1  
    SUB.L       -(A0),D1  
    SUB.L       $8002,D1 
    SUB.L       $4002,D1


    MOVE.B D0,D1
    MOVE.B #$10,D0
    MOVE.W D0,D1
    MOVE.W #$10,D0
    JSR TEST
    LEA TESTI, A0
    NOP
    NOP
    MOVE.L D0,D2
    MOVEA.L D5,A4
    NOP
    JSR TEST
    NOP
    LEA TESTI, A0
    ASL.L #4,D0 
    ASL.B #4,D2
    ASL.W #4,D4 
    ASR.B #4,D0
    ASR.L #4,D7 
    ASR.W #4,D0
    ASR.L #4,D0 
    ASL.B #4,D0
    JSR TEST
    NOP
    LEA TESTI, A0
    LEA TESTI, A0
    LEA TESTI, A0
    LEA TESTI, A0
    LEA TESTI, A0
    NOP
    NOP
    NOP
    JSR TEST
    NEG D0
    NEG D1
    NEG $000
    NEG $7999
    NOP
    NOP
    NOP
    LSL.L #4,D0 
    LSL.B #4,D2
    LSL.W #4,D4 
    LSR.B #4,D0
    LSR.L #4,D7 
    LSR.W #4,D0
    LSR.L #4,D0 
    LSL.B #4,D0
    LSR.L #4,D4 
    LSL.B #4,D0
    LSR.L #4,D0 
    LSL.B #4,D5
    LSR.L #4,D0 
    LSL.B #4,D0
    LSR.L #4,D0 
    LSL.B #4,D0
    MOVE.B D0,D1
    MOVE.B #$10,D0
    MOVE.W D0,D1
    MOVE.W #$10,D0
    JSR TEST
    LEA TESTI, A0
    NOP
    NOP
    MOVE.L D0,D2
    MOVEA.L D5,A4
    NOP
    JSR TEST
    NOP
    LEA TESTI, A0
    NOP
    NOP
    JSR TEST
    NOP
    LEA TESTI, A0
    LEA TESTI, A0
    LEA TESTI, A0
    LEA TESTI, A0
    LEA TESTI, A0
    JSR TEST
    NEG D0
    NEG D1
    NEG $000
    NEG $7999
    ROL.L #4,D0 
    ROL.B #4,D2
    ROL.W #4,D4 
    ROR.B #4,D0
    ROR.L #4,D7 
    ROR.W #4,D0
    ROR.L #4,D0 
    ROL.B #4,D0
    
TEST RTS


TESTI DC.B 'yoyoma'
    END    START        ; last line of source
    

    
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
