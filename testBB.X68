*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $7000
START:                  ; first instruction of program

* Put program code here

    * Test code for EOR
    EOR.B    D0, D1
    *EOR.B    D0, A1    *ERROR, does not take An
    EOR.B    D0,(A1)
    EOR.B    D0,(A1)+
    EOR.B    D0,-(A1)
    EOR.B    D0,$8000
    EOR.B    D0,$4000
    *EOR.B    D0,#1234   *ERROR, does not take direct data
    *EOR.B    A1,D1    *ERROR, first param must be Dn 
   
    EOR.W    D0, D1
    *EOR.W    D0, A1    *ERROR, does not take An
    EOR.W    D0,(A1)
    EOR.W    D0,(A1)+
    EOR.W    D0,-(A1)
    EOR.W    D0,$8000
    EOR.W    D0,$4000
    *EOR.W    D0,#1234    *ERROR, does not take direct data
    *EOR.W    A1,D1    *ERROR, first param must be Dn 
    
    EOR.L    D0, D1
    *EOR.L    D0, A1    *ERROR, does not take An
    EOR.L    D0,(A1)
    EOR.L    D0,(A1)+
    EOR.L    D0,-(A1)
    EOR.L    D0,$8000
    EOR.L    D0,$4000
    *EOR.L    D0,#1234 *ERROR, does not take direct data
    *EOR.L    A1,D1    *ERROR, first param must be Dn 
    
    *Test code for CMP
    CMP.B    D0, D1
    *CMP.B    A1, D1  *ERROR, can be only be used with W and L
    CMP.B    (A1),D1
    CMP.B    (A1)+,D1
    CMP.B    -(A1),D1
    CMP.B    $8000,D1
    CMP.B    $4000,D1
    CMP.B    #123,D1   
    *CMP.B    D0,A1   *ERROR, destination must be Dn
    
    CMP.W    D0, D1
    CMP.W    A1, D1  
    CMP.W    (A1),D1
    CMP.W    (A1)+,D1
    CMP.W    -(A1),D1
    CMP.W    $8000,D1
    CMP.W    $4000,D1
    CMP.W    #1234,D1   
    *CMP.W    D0,A1   *ERROR, destination must be Dn
    
    CMP.L    D0, D1
    CMP.L    A1, D1  
    CMP.L    (A1),D1
    CMP.L    (A1)+,D1
    CMP.L    -(A1),D1
    CMP.L    $8000,D1
    CMP.L    $4000,D1
    CMP.L    #12340000,D1   
    *CMP.L    D0,A1   *ERROR, destination must be Dn
    
    *Test code for CMPI
    CMPI.B    #12, D1
    *CMPI.B    #12, A1 *ERROR, destination cannot be An
    CMPI.B    #12, (A1)
    CMPI.B    #12, (A1)+
    CMPI.B    #12, -(A1)
    CMPI.B    #12, $8000
    CMPI.B    #12, $4000
    *CMPI.B    #12, #123 *ERROR, destination cannot be direct data  
    *CMPI.B    #1234,D1   *ERROR, data size does not match operation
    
    CMPI.W    #1234, D1
    *CMPI.W    #1234, A1 *ERROR, destination cannot be An
    CMPI.W    #1234, (A1)
    CMPI.W    #1234, (A1)+
    CMPI.W    #1234, -(A1)
    CMPI.W    #1234, $8000
    CMPI.W    #1234, $4000
    *CMPI.W    #12, #123 *ERROR, destination cannot be direct data  
    *CMPI.W    #12345678,D1   *ERROR, data size does not match operation
    
    CMPI.L    #12345678, D1
    *CMPI.L    #12345678, A1 *ERROR, destination cannot be An
    CMPI.L    #12345678, (A1)
    CMPI.L    #12345678, (A1)+
    CMPI.L    #12345678, -(A1)
    CMPI.L    #12345678, $8000
    CMPI.L    #12345678, $4000
    *CMPI.L    #12345678, #123 *ERROR, destination cannot be direct data  
    *CMPI.L    #12345678987,D1   *ERROR, data size does not match operation
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
