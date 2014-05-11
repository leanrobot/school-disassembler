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
	MOVEA.W $07FFF,A2 	; Word addr
	MOVEA.W $FFFF8000,A2 ; Word addr TODO NOT SURE

	MOVEA.L D0,A2
	MOVEA.L A1,A2
	MOVEA.L (A1),A2
	MOVEA.L (A1)+,A2
	MOVEA.L -(A1),A2
	MOVEA.L $8005,A2	; Long Word addr

	* Incorrect Tests

****************************
* LEA Tests

	* Correct Tests
	LEA (A1),A2
	LEA $07FFF,A2 ; Word addr
	LEA $8000,A2 ; Word addr
	LEA $00008000,A2; Long word addr

	* Incorrect Tests

****************************
* OR Tests
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

	* TODO Half done, need to add DN -> <EA> 

****************************
* Bcc tests

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


	END START
