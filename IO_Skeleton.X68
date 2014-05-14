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
    
    *******************************************************************
    * Begin Looping portion of code.
    MOVE.L (IO_STARTADDR),(IO_CURR_ADDR)
MAIN_LOOP: 
    JSR IO_HEX2ASCII
    JSR OP_DETERMINE_OP_CODE
    JSR IO_MOVE_OP_CODE_TO_BUFFER  
    

     

    SIMHALT ;*********** END OF MAIN ********************

* Put variables and constants here
*==================================================================* IO

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
         
IO_HEX2ASCII:
         * D1 = loop counter
         * D2 = Original address
         * D3 = working address for loop
         
         MOVE.L   (IO_CURR_ADDR),D2    * Get the current instruction address
         MOVEQ    #8, D1               * Setup a loop from 8 --> 0.
IO_HEX2ASCII_LOOP:
         MOVE.L   D2,D3
         LSR      D1,D3
         AND.L    #$0000000F, D3
         
         *Convert to ASCII
         CMP.B    #9, D3
         BLE      IO_DIGIHEX2ASCII    
         BGT      IO_LETTERHEX2ASCII 
         
         * Write to line buffer
         MOVE.B D3,(LINE_BUF)+
         
         * Reloop
         SUBI #1,D1
         BNE IO_HEX2ASCII_LOOP
         
         RTS
         
IO_DIGIHEX2ASCII:
         ADD.B     #$30, D3
         RTS

IO_LETTERHEX2ASCII:
         ADD.B    #$37, D3
         RTS
    
IO_MOVE_OP_CODE_TO_BUFFER:
            * TODO
         
 
*IO CONSTANTS
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
IO_TAB          DC.B    9  

**IO VARIABLES
IO_LINE_BUF     DS.B    80

IO_CURR_ADDR    DS.L    1
  

*===============================================================================================* OP CODE

OP_DETERMINE_OP_CODE:
    MOVE.B #1,(OP_CODE_UNKNWN)
    LEA OP_CODE,A1
    * Hardcode 'D','A','T','A'
    MOVE.B #'D', (A1)+
    MOVE.B #'A', (A1)+
    MOVE.B #'T', (A1)+
    MOVE.B #'A', (A1)+
    MOVE.B #0,   (A1)+
    RTS

*===============================================================================================* EA

**GLOBAL VARIABLE BLOCK**
IO_STARTADDR    DS.L    1
IO_ENDADDR      DS.L    1
OP_CODE         DS.B    10
OP_CODE_UNKNWN  DS.B    1




    END    START        ; last line of source
    


    
    


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
