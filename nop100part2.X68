
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
    NOP
    NOP
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
    NOP
    
TEST RTS
TESTI DC.B 'yoyoma'
    
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
