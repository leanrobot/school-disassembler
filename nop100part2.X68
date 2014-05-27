

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
	

	OR.W D0,D1
	OR.W (A1),D1
	OR.W (A1)+,D1
	OR.W -(A1),D1
	

	OR.L D0,D1
	OR.L (A1),D1
	OR.L (A1)+,D1
	OR.L -(A1),D1
	
    OR.B #$10,D1
    OR.B $100,D1
    OR.B $1234A,D1

    OR.W #$10,D1
    OR.W $100,D1
    OR.W $1234A,D1

    OR.L #$10,D1
    OR.L $100,D1
    OR.L $1234A,D1

		*** Dn --> <EA> ***

	OR.B D1,(A1)
	OR.B D1,(A1)+
	OR.B D1,-(A1)

	OR.W D1,(A1)
	OR.W D1,(A1)+
	OR.W D1,-(A1)


	OR.L D1,(A1)
	OR.L D1,(A1)+
	OR.L D1,-(A1)
	
    OR.B D1,$07FF * Word addr
    OR.B D1,$8000 * Long word addr
    OR.W D1,$07FF * Word addr
    OR.W D1,$8000 * Long word addr
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
	
**************NEG*********************    
    
    NEG.B       D1
    NEG.B       (A1)
    NEG.B       (A1)+
    NEG.B       -(A1)
    NEG.B       $8000
    NEG.B       $4000

	NEG.W       D1
    NEG.W       (A1)
    NEG.W       (A1)+
    NEG.W       -(A1)
    NEG.W       $8000
    NEG.W       $4000

	NEG.L       D1
    NEG.L       (A1)
    NEG.L       (A1)+
    NEG.L       -(A1)
    NEG.L       $8000
    NEG.L       $4000

************BRA**************

LABEL1  
    BRA LABEL1
    
************MOVEA**************    
    MOVEA.W D0,A2
	MOVEA.W A1,A2
	MOVEA.W (A1),A2
	MOVEA.W (A1)+,A2
	MOVEA.W -(A1),A2
	MOVEA.W $07FFF,A2 		* Word addr
	MOVEA.W $FFFF8000,A2 	* Word addr TODO NOT SURE

	MOVEA.L D0,A2
	MOVEA.L A1,A2
	MOVEA.L (A1),A2
	MOVEA.L (A1)+,A2
	MOVEA.L -(A1),A2
	MOVEA.L $8005,A2		* Long Word addr
    
************EOR************** 
    EOR.B    D0, D1
    EOR.B    D0,(A1)
    EOR.B    D0,(A1)+
    EOR.B    D0,-(A1)
    EOR.B    D0,$8000
    EOR.B    D0,$4000
   
    EOR.W    D0, D1
    EOR.W    D0,(A1)
    EOR.W    D0,(A1)+
    EOR.W    D0,-(A1)
    EOR.W    D0,$8000
    EOR.W    D0,$4000
    
    EOR.L    D0, D1
    EOR.L    D0,(A1)
    EOR.L    D0,(A1)+
    EOR.L    D0,-(A1)
    EOR.L    D0,$8000
    EOR.L    D0,$4000
    
************CMP************** 
    CMP.B    D0, D1
    CMP.B    (A1),D1
    CMP.B    (A1)+,D1
    CMP.B    -(A1),D1
    CMP.B    $8000,D1
    CMP.B    $4000,D1
    CMP.B    #123,D1   
    
    CMP.W    D0, D1
    CMP.W    A1, D1  
    CMP.W    (A1),D1
    CMP.W    (A1)+,D1
    CMP.W    -(A1),D1
    CMP.W    $8000,D1
    CMP.W    $4000,D1
    CMP.W    #1234,D1   
    
    CMP.L    D0, D1
    CMP.L    A1, D1  
    CMP.L    (A1),D1
    CMP.L    (A1)+,D1
    CMP.L    -(A1),D1
    CMP.L    $8000,D1
    CMP.L    $4000,D1
    CMP.L    #12340000,D1   
    
    ************CMPI************** 
    CMPI.B    #12, D1
    CMPI.B    #12, (A1)
    CMPI.B    #12, (A1)+
    CMPI.B    #12, -(A1)
    CMPI.B    #12, $8000
    CMPI.B    #12, $4000
    
    CMPI.W    #1234, D1
    CMPI.W    #1234, (A1)
    CMPI.W    #1234, (A1)+
    CMPI.W    #1234, -(A1)
    CMPI.W    #1234, $8000
    CMPI.W    #1234, $4000
    
    CMPI.L    #12345678, D1
    CMPI.L    #12345678, (A1)
    CMPI.L    #12345678, (A1)+
    CMPI.L    #12345678, -(A1)
    CMPI.L    #12345678, $8000
    CMPI.L    #12345678, $4000
    
************BCLR************** 
    BCLR.L    D1, D0
    BCLR.B    D1, (A1)
    BCLR.B    D1, (A1)+
    BCLR.B    D1, -(A1)
    BCLR.B    D1, $4000
    BCLR.B    D1, $8000
    
    
    BCLR.L    #1234, D1
    BCLR.B    #1234, (A1)
    BCLR.B    #1234, (A1)+
    BCLR.B    #1234, -(A1)
    BCLR.B    #1234, $4000
    BCLR.B    #1234, $8000
    
    BCLR.L    D1, D0
    
************LSL**************
    
    LSL.B    D1, D3
    LSL.B    #1, D1
    
    LSL.W    D1, D3
    LSL.W    #1, D1
    LSL.W    (A1)      
    LSL.W    (A1)+
    LSL.W    -(A1)
    LSL.W    $4000
    LSL.W    $8000
    
    LSL.L    D1, D3
    LSL.L    #1, D1
    
    
************LSR**************
    LSR.B    D1, D3
    LSR.B    #1, D1
    
    LSR.W    D1, D3
    LSR.W    #1, D1
    LSR.W    (A1)      
    LSR.W    (A1)+
    LSR.W    -(A1)
    LSR.W    $4000
    LSR.W    $8000
    
    LSR.L    D1, D3
    LSR.L    #1, D1
    
************ASL**************
    ASL.B    D1, D3
    ASL.B    #1, D1
    
    ASL.W    D1, D3
    ASL.W    #1, D1
    ASL.W    (A1)      
    ASL.W    (A1)+
    ASL.W    -(A1)
    ASL.W    $4000
    ASL.W    $8000
    
    ASL.L    D1, D3
    ASL.L    #1, D1
    
************ASL**************
    ASR.B    D1, D3
    ASR.B    #1, D1
    
    ASR.W    D1, D3
    ASR.W    #1, D1
    ASR.W    (A1)      
    ASR.W    (A1)+
    ASR.W    -(A1)
    ASR.W    $4000
    ASR.W    $8000
    
    ASR.L    D1, D3
    ASR.L    #1, D1
    
************ROL************** 
    ROL.B    D1, D3
    ROL.B    #1, D1
    
    ROL.W    D1, D3
    ROL.W    #1, D1
    ROL.W    (A1)      
    ROL.W    (A1)+
    ROL.W    -(A1)
    ROL.W    $4000
    ROL.W    $8000
    
    ROL.L    D1, D3
    ROL.L    #1, D1   

************ROR**************
    ROR.B    D1, D3
    ROR.B    #1, D1
    
    ROR.W    D1, D3
    ROR.W    #1, D1
    ROR.W    (A1)      
    ROR.W    (A1)+
    ROR.W    -(A1)
    ROR.W    $4000
    ROR.W    $8000
    
    ROR.L    D1, D3
    ROR.L    #1, D1
    
************SUBQ**************
    SUBQ.B    #1, D2
    SUBQ.B    #8, (A1)
    SUBQ.B    #2, (A1)+
    SUBQ.B    #3, -(A1)
    SUBQ.B    #3, $4000
    SUBQ.B    #2, $8000
    
    SUBQ.W    #1, D2
    SUBQ.W    #6, A1
    SUBQ.W    #8, (A1)
    SUBQ.W    #2, (A1)+
    SUBQ.W    #3, -(A1)
    SUBQ.W    #3, $4000
    SUBQ.W    #2, $8000
    
    SUBQ.L    #1, D2
    SUBQ.L    #6, A1
    SUBQ.L    #8, (A1)
    SUBQ.L    #2, (A1)+
    SUBQ.L    #3, -(A1)
    SUBQ.L    #3, $4000
    SUBQ.L    #2, $8000
    
 ************JSR and RTS**************
    JSR TEST

 ************BLT and BRA**************
    MOVE.B    #$4, D0
    MOVE.B    #$5, D1
    CMP.B     D0, D1
    BLT TEST_BLT
BLT_TEST_DONE   

 ************BGE and BRA**************
    
    MOVE.B    #$5, D0
    MOVE.B    #$5, D1
    CMP.B D0, D1
    BGE TEST_BGE
BGE_TEST_DONE
    
 ************BCS**************
     BCS   TEST_BCS
BCS_TEST_DONE 

 ************BVC**************
     BVC   TEST_BVC
BVC_TEST_DONE 
    
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
    
TEST_BLT:
    BRA BLT_TEST_DONE

TEST_BGE:
    BRA BGE_TEST_DONE
    
TEST_BCS:
    BRA BCS_TEST_DONE
    
TEST_BVC:
    BRA BVC_TEST_DONE
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
