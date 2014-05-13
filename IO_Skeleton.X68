*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
CR      EQU     $0D
LF      EQU     $0A

    ORG    $7000
START:                  ; first instruction of program

* Put program code here
    LEA     IO_OPEN, A1        *Print welcome message
    MOVE.B  #14, D0
    TRAP    #15

    LEA    IO_STARTMSSG, A1       *Print request for address
    MOVE.B  #14, D0
    TRAP    #15
    
    MOVE.B  #2,D0           *Take in address from user and put in (A1)
    TRAP #15
    
    JSR     IO_CONVERT_ASCII_ADDR
    MOVE.L  D3,(IO_STARTADDR)
    
    CLR.L   D3              * RESET D3 to work with ending address
    
    LEA    IO_ENDMSSG, A1       *Print request for address
    MOVE.B  #14, D0
    TRAP    #15
    
    MOVE.B  #2,D0           *Take in address from user and put in (A1)
    TRAP #15
    
    JSR     IO_CONVERT_ASCII_ADDR
    MOVE.L  D3,(IO_ENDADDR)
    
    

     

    SIMHALT ;*********** END OF MAIN ********************

* Put variables and constants here

IO_CONVERT_ASCII_ADDR:
    MOVE.B  D1,D2           *Move length of address from D1 to D2    
IO_LOOP: 
     MOVE.B    (A1)+, D1
     JSR IO_AS2HEX
     ROL.L #4, D3
     ADD.B D1, D3
     SUB.B #1, D2
     BNE IO_LOOP
     
     RTS

*Convert ASCII to Hex
IO_AS2HEX:   
         CMP.B    #'A', D1    *Compare D1 
         BMI    IO_DIGIHEX     * BLT branches if D1 for digit
         BGE    IO_NUMHEX      *BGT branches if D1 for A-F
         RTS
         
         
IO_DIGIHEX:  
         SUB.B    #$30, D1   *Subtract 30 from D1 to convert from ASCII digit to Hex digit
         RTS                *Return to IO
            
IO_NUMHEX:   
         SUB.B    #$37, D1   *Subtract 37 from D1 to convert from ASCII A-F to Hex
         RTS
 

IO_OPEN     DC.B    ' ____ ____ ____ ', CR, LF 
         DC.B    '||6 |||8 |||k ||', CR, LF
         DC.B    '||__|||__|||__||', CR, LF
         DC.B    '|/__\|/__\|/__\|', CR, LF
         DC.B    ' ____ ____ ____ ____ ____ ____ ____ ____ ____ ____ ____ ____ ', CR,LF
         DC.B    '||D |||I |||S |||A |||S |||S |||E |||M |||B |||L |||E |||R ||', CR,LF
         DC.B    '||__|||__|||__|||__|||__|||__|||__|||__|||__|||__|||__|||__||', CR,LF
         DC.B    '|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|', CR,LF,0

IO_STARTMSSG    DC.B    'Enter a starting address: ',0
IO_ENDMSSG      DC.B    'Enter a ending address: ',0

IO_STARTADDR    DS.L    1
IO_ENDADDR      DS.L    1


    END    START        ; last line of source
    


    
    

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
