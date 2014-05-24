
*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $7000
START:                  ; first instruction of program
    NOP
    NOP
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
