*-----------------------------------------------------------
* Title      : TestJJH
* Written by : James Hurd
* Date       : 
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    ADD.B       D0,D1
    *ADD.B       D0,A0
    ADD.B       D0,(A1)
    *ADD.B       D0,#1234
    ADD.B       D0,(A1)+
    ADD.B       D0,-(A1)
    ADD.B       D0,$8000
    ADD.B       D0,$4000
    
    *ADD.B       A0,D1
    *ADD.B       A0,A1
    *ADD.B       A0,(A1)
    *ADD.B       A0,#1234
    *ADD.B       A0,(A1)+
    *ADD.B       A0,-(A1)
    *ADD.B       A0,$8000
    ;ADD.B       A0,$4000
    
    ADD.B       (A0),D1
    *ADD.B       (A0),A1
    *ADD.B       (A0),(A1)
    *ADD.B       (A0),#1234
    *ADD.B       (A0),(A1)+
    *ADD.B       (A0),-(A1)
    *ADD.B       (A0),$8000
    *ADD.B       (A0),$4000
    
    ADD.B       (A0)+,D1
    *ADD.B       (A0)+,A1
    *ADD.B       (A0)+,(A1)
    *ADD.B       (A0)+,#1234
    *ADD.B       (A0)+,(A1)+
    *ADD.B       (A0)+,-(A1)
    *ADD.B       (A0)+,$8000
    *ADD.B       (A0)+,$4000
    
    ADD.B       -(A0),D1
    *ADD.B       -(A0),A1
    *ADD.B       -(A0),(A1)
    *ADD.B       -(A0),#1234
    *ADD.B       -(A0),(A1)+
    *ADD.B       -(A0),-(A1)
    *ADD.B       -(A0),$8000
    *ADD.B       -(A0),$4000
    
    ADD.B       $8002,D1
    *ADD.B       $8002,A1
    *ADD.B       $8002,(A1)
    *ADD.B       $8002,#1234
    *ADD.B       $8002,(A1)+
    *ADD.B       $8002,-(A1)
    *ADD.B       $8002,$8000
    *ADD.B       $8002,$4000
    
    ADD.B       $4002,D1
    *ADD.B       $4002,A1
    *ADD.B       $4002,(A1)
    *ADD.B       $4002,#1234
    *ADD.B       $4002,(A1)+
    *ADD.B       $4002,-(A1)
    *ADD.B       $4002,$8000
    *ADD.B       $4002,$4000
    
    SUB.B       D0,D1
    *SUB.B       D0,A0
    SUB.B       D0,(A1)
    *SUB.B       D0,#1234
    SUB.B       D0,(A1)+
    SUB.B       D0,-(A1)
    SUB.B       D0,$8000
    SUB.B       D0,$4000

    *SUB.B       A0,D1
    *SUB.B       A0,A1
    *SUB.B       A0,(A1)
    *SUB.B       A0,#1234
    *SUB.B       A0,(A1)+
    *SUB.B       A0,-(A1)
    *SUB.B       A0,$8000
    *SUB.B       A0,$4000
    
    SUB.B       (A0),D1
    *SUB.B       (A0),A1
    *SUB.B       (A0),(A1)
    *SUB.B       (A0),#1234
    *SUB.B       (A0),(A1)+
    *SUB.B       (A0),-(A1)
    *SUB.B       (A0),$8000
    *SUB.B       (A0),$4000
    
    SUB.B       (A0)+,D1
    *SUB.B       (A0)+,A1
    *SUB.B       (A0)+,(A1)
    *SUB.B       (A0)+,#1234
    *SUB.B       (A0)+,(A1)+
    *SUB.B       (A0)+,-(A1)
    *SUB.B       (A0)+,$8000
    *SUB.B       (A0)+,$4000
    
    SUB.B       -(A0),D1
    *SUB.B       -(A0),A1
    *SUB.B       -(A0),(A1)
    *SUB.B       -(A0),#1234
    *SUB.B       -(A0),(A1)+
    *SUB.B       -(A0),-(A1)
    *SUB.B       -(A0),$8000
    *SUB.B       -(A0),$4000
    
    SUB.B       $8002,D1
    *SUB.B       $8002,A1
    *SUB.B       $8002,(A1)
    *SUB.B       $8002,#1234
    *SUB.B       $8002,(A1)+
    *SUB.B       $8002,-(A1)
    *SUB.B       $8002,$8000
    *SUB.B       $8002,$4000
    
    SUB.B       $4002,D1
    *SUB.B       $4002,A1
    *SUB.B       $4002,(A1)
    *SUB.B       $4002,#1234
    *SUB.B       $4002,(A1)+
    *SUB.B       $4002,-(A1)
    *SUB.B       $4002,$8000
    *SUB.B       $4002,$4000


    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
