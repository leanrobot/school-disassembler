
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

*************MOVE**************

    MOVE.B D0,D2
	MOVE.B (A5),D2
	MOVE.B (A5)+,D2
	MOVE.B -(A5),D2
	MOVE.B D2,$5000
	MOVE.B (A0),$5000
    MOVE.B #$10,D0
    
    
    MOVE.W D0,D2
	MOVE.W A0,D2
	MOVE.W (A5),D2
	MOVE.W A1,D2
	MOVE.W (A5)+,D2
	MOVE.W -(A5),D2
	MOVE.W D2,$5000
	MOVE.W (A0),$5000
    MOVE.W #$10,D0
    
    MOVE.L D0,D2
	MOVE.L A0,D2
	MOVE.L (A5),D2
	MOVE.L A1,D2
	MOVE.L (A5)+,D2
	MOVE.L -(A5),D2
	MOVE.L D2,$5000
	MOVE.L (A0),$5000
	MOVE.L #$8000,D0
	
	**********LEA**************
	LEA (A1),A2
	LEA $07FFF,A2    	* Word addr
	LEA $8000,A2 		* Word addr
	LEA $00008000,A2 	* Long word addr
	
	**********OR**************
    	*** <EA> --> Dn ***

	OR.B D0,D1
	OR.B (A1),D1
	OR.B (A1)+,D1
	OR.B -(A1),D1
	OR.B #$10,D1
	OR.B $100,D1
	OR.B $1234A,D1

	OR.W D0,D1
	OR.W (A1),D1
	OR.W (A1)+,D1
	OR.W -(A1),D1
	OR.W #$10,D1
	OR.W $100,D1
	OR.W $1234A,D1

	OR.L D0,D1
	OR.L (A1),D1
	OR.L (A1)+,D1
	OR.L -(A1),D1
	OR.L #$10,D1
	OR.L $100,D1
	OR.L $1234A,D1
	
		*** Dn --> <EA> ***

	OR.B D1,(A1)
	OR.B D1,(A1)+
	OR.B D1,-(A1)
	OR.B D1,$07FF * Word addr
	OR.B D1,$8000 * Long word addr

	OR.W D1,(A1)
	OR.W D1,(A1)+
	OR.W D1,-(A1)
	OR.W D1,$07FF * Word addr
	OR.W D1,$8000 * Long word addr

	OR.L D1,(A1)
	OR.L D1,(A1)+
	OR.L D1,-(A1)
	OR.L D1,$07FF * Word addr
	OR.L D1,$8000 * Long word addr
    
    **********ORI**************
    ORI.B #$0000,D1
	ORI.B #$0000,(A1)
	ORI.B #$0000,(A1)+
	ORI.B #$0000,-(A1)
	ORI.B #$0000, $07FF * Word addr
	ORI.B #$0000, $8000 * Word addr

	ORI.W #$0000,D1
	ORI.W #$0000,(A1)
	ORI.W #$0000,(A1)+
	ORI.W #$0000,-(A1)
	ORI.W #$0000, $07FF * Word addr
	ORI.W #$0000, $8000 * Word addr

	ORI.L #$0000,D1
	ORI.L #$0000,(A1)
	ORI.L #$0000,(A1)+
	ORI.L #$0000,-(A1)
	ORI.L #$0000, $07FF * Word addr
	ORI.L #$0000, $8000 * Word addr
    
    **********BCC***************
BRANCH NOP
	    BCC BRANCH
	    BCS BRANCH
    	BEQ BRANCH
    	BGE BRANCH
	    BGT BRANCH
    	BHI BRANCH
	    BLE BRANCH
    	BLS BRANCH
	    BLT BRANCH
	    BMI BRANCH
	    BNE BRANCH
	    BPL BRANCH
	    BVC BRANCH
	    BVS BRANCH
	    
*********MOVEM**************

	MOVEM D0-D7, $4500
	MOVEM $4500, D0-D7
    
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
