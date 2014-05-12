	ORG 7000

* -----------------
* Title: Test Program
* Author: Tom
* -----------------

START:

* REQUIRED EA MODES
* Dn, An, (An), #DATA, (An)+, -(An), (xxx).W, (xxx.L)


**********************
* Add Commands


**********************
* Move Commands

	*Correct section
	MOVE.B D0,D2
	MOVE.B (A5),D2
	MOVE.B (A5)+,D2
	MOVE.B -(A5),D2
	MOVE.B D2,$5000
	MOVE.B (A0),$5000

	MOVE.W D0,D2
	MOVE.W A0,D2
	MOVE.W (A5),D2
	MOVE.W A1,D2
	MOVE.W (A5)+,D2
	MOVE.W -(A5),D2
	MOVE.W D2,$5000
	MOVE.W (A0),$5000

	MOVE.L D0,D2
	MOVE.L A0,D2
	MOVE.L (A5),D2
	MOVE.L A1,D2
	MOVE.L (A5)+,D2
	MOVE.L -(A5),D2
	MOVE.L D2,$5000
	MOVE.L (A0),$5000

	* No Incorrect tests written

*************************
* MOVEA Tests
	* Correct Tests
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

	* Incorrect Tests

****************************
* LEA Tests

	* Correct Tests
	LEA (A1),A2
	LEA $07FFF,A2    	* Word addr
	LEA $8000,A2 		* Word addr
	LEA $00008000,A2 	* Long word addr

	* Incorrect Tests

****************************
* OR Tests

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


******************************
* ORI Tests

	* Correct tests
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

	* Incorrect Tests

****************************
* Bcc tests
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

	* Incorrect Tests

******************************
* MOVEM Tests

	MOVEM D0-D7, $4500
	MOVEM $4500, D0-D7

	* Incorrect Tests

******************************


	END START
