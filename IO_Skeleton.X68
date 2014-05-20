*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
CR      EQU     $0D
LF      EQU     $0A

stack EQU $A000    *sp initial


    ORG    $4000
START:      
    LEA stack, SP                ; first instruction of program


* Put program code here
    LEA     IO_OPEN, A1        *Print welcome message
    MOVE.B  #14, D0
    TRAP    #15

DISPLAY_AND_PROMPT_FOR_INPUT:
    *Clears D2 and D3 for new input/checking address validity
    CLR.L    D2
    CLR.L    D3

    LEA    IO_STARTMSSG, A1       *Print request for address
    MOVE.B  #14, D0
    TRAP    #15
    MOVE.L  #$00000000, A1  *Clears A1 so that IO_STARTMSSG is not overwritten
    MOVE.B  #2,D0           *Take in address from user and put in (A1)
    TRAP #15
    
    JSR     IO_CONVERT_ASCII_ADDR    *Convert user ASCII input to hex address
    BRA     IO_CHECK_EVEN_START_ADDRESS   *Check start address is an even #
IO_STORE_START:
    MOVE.L  D3,IO_STARTADDR          *Store converted address in variable
    
    CLR.L   D3              * RESET D3 to work with ending address
    
    LEA    IO_ENDMSSG, A1       *Print request for address
    MOVE.B  #14, D0
    TRAP    #15
    MOVE.L  #$00000000, A1   *Clears A1 so that IO_ENDMSSG is not overwritten
    MOVE.B  #2,D0           *Take in address from user and put in (A1)
    TRAP #15
    
    JSR     IO_CONVERT_ASCII_ADDR     *Convert user ASCII input to hex address
    BRA     IO_CHECK_EVEN_END_ADDRESS *Check end address is an even #
IO_STORE_END:
    MOVE.L  D3,IO_ENDADDR             *Store converted address in variable
    
    * Verify starting address < ending address
    BRA     IO_CHECK_ENDING_ADDR
IO_INPUT_SUCCESSFUL:
    
    
    *******************************************************************
    * Begin Looping portion of code.
    MOVE.L (IO_STARTADDR),(IO_CURR_ADDR)    *Move starting address to current address variable
MAIN_LOOP: 
    LEA IO_LINE_BUF, A0                   * pointer to line buffer
    MOVE.L (IO_CURR_ADDR), D2               * Parameter setup for IO_HEX2ASCII
    JSR IO_HEX2ASCII                        *Loop through address converting Hex to ascii
    JSR IO_INSERT_TAB
    JSR OP_DETERMINE_OP_CODE                *Determine what the opcode is
    JSR IO_MOVE_OP_CODE_TO_BUFFER  
    *If current address does not equal ending address, go back to MAIN_LOOP


    SIMHALT ;*********** END OF MAIN ********************

* Put variables and constants here
*==================================================================* IO

IO_CONVERT_ASCII_ADDR:
    MOVE.B  D1,D2           *Move length of address from D1 to D2    

*puts final converted address into D3
IO_LOOP: 
     MOVE.B    (A1)+, D1
     JSR IO_AS2HEX          *Go to conversion loop for each digit
     ROL.L #4, D3
     ADD.B D1, D3
     SUB.B #1, D2
     BNE IO_LOOP
     RTS


*Checks that the start address is an even number
IO_CHECK_EVEN_START_ADDRESS:
     MOVE.L   D3, D4
     ANDI.B   #$1, D4
     CMPI.B    #$1, D4
     BEQ      IO_ADDRESS_ODD_PRINT_ERROR_MSSG
     BRA      IO_STORE_START

*Checks that the ending address is an even number
IO_CHECK_EVEN_END_ADDRESS:
     MOVE.L   D3, D4
     ANDI.B   #$1, D4
     CMPI.B    #$1, D4
     BEQ      IO_ADDRESS_ODD_PRINT_ERROR_MSSG
     BRA      IO_STORE_END
     
*Prints odd address error message and returns main
IO_ADDRESS_ODD_PRINT_ERROR_MSSG:
     LEA   IO_ODD_ERROR_MSSG, A1
     MOVE.B   #14, D0
     TRAP     #15
     BRA   DISPLAY_AND_PROMPT_FOR_INPUT
     
*Checks to see that address is after starting address
IO_CHECK_ENDING_ADDR:
     CLR.L    D2
     CLR.L    D3
     MOVE.L   IO_STARTADDR, D2
     MOVE.L   IO_ENDADDR, D3
     CMP.L    D2, D3      *Compare start and end address
     BLE    IO_ENDADDR_AFTER_STARTADDR
     BRA    IO_INPUT_SUCCESSFUL    *Go back to main
     
*Displays message indicating ending address is smaller
*than starting address. Jumps to main to have user re-enter
IO_ENDADDR_AFTER_STARTADDR:

     CLR.L    IO_STARTADDR
     CLR.L    IO_ENDADDR
     LEA IO_END_BEFORE_START_MSG, A1    
     
     MOVE.B  #14, D0
     TRAP    #15
     BRA    DISPLAY_AND_PROMPT_FOR_INPUT

*Convert ASCII to Hex
IO_AS2HEX:   
         CMP.B    #'A', D1    *Compare D1 
         BMI    IO_DIGIHEX     * BLT branches if D1 for digit
         BGE    IO_NUMHEX      *BGT branches if D1 for A-F
IO_AS2HEX_COMPLETE:         
         RTS
         
         
IO_DIGIHEX:  
         SUB.B    #$30, D1   *Subtract 30 from D1 to convert from ASCII digit to Hex digit
         BRA  IO_AS2HEX_COMPLETE              *Return to IO
            
IO_NUMHEX:   
         SUB.B    #$37, D1   *Subtract 37 from D1 to convert from ASCII A-F to Hex
         BRA IO_AS2HEX_COMPLETE
         


* D2 contains hex value to convert
* A0 Contains the line buffer
IO_HEX2ASCII:
    MOVEM.L D0-D7/A1-A7, -(A7)
    CLR.L D1
    CLR.L D3
    MOVE.B #8, d1 * counter for loop
LOOP  ROL.L #4, D2          * rotate the value once.
      MOVE.L D2, D3         * copy
      AND.L #$0000000F, D3
      CMP.B #$09,D3        * if F <= d3, letter.
      BGT Letter
      BLE Digit             * else, digit.
Letter  ADD #$37,D3         * add $37
        BRA EndIf
Digit   ADD #$30,D3         * add $30
EndIf   MOVE.B D3,(A0)+

        SUB.B #1,D1         * decrement loop counter
        BNE LOOP          * repeat loop?

    MOVEM.L (A7)+, D0-D7/A1-A7
    RTS

* A0 is the current place in line buffer
IO_INSERT_TAB:
    MOVE.B #$20,(A0)+
    MOVE.B #$20,(A0)+
    MOVE.B #$20,(A0)+
    MOVE.B #$20,(A0)+
    RTS



         
*IO_INSERT_FIRST_TAB:         
*         MOVE.B    (A2)+, (A1)+
*         BNE       IO_INSERT_FIRST_TAB
*         MOVE.L    A1, IO_LINE_BUF
*         
*         LEA    IO_LINE_BUF, A3
*         MOVE.B    #14, D0
*         TRAP      #15
*         
*         *Add Tab to Line buffer
*         *MOVE.L A1, D4      *Move converted address into D4 for op_code determination
*         
*         BRA IO_HEX2ASCII_GET_DIGIT_DONE
         
    
IO_MOVE_OP_CODE_TO_BUFFER:
            * TODO
         RTS
         
 
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
IO_END_BEFORE_START_MSG    DC.B 'The ending address you entered is after the start address', CR, LF, 0
IO_ODD_ERROR_MSSG DC.B  'Illegal address. Please re-enter even addresses', CR, LF, 0
IO_TAB          DC.B    '    ', 0  

**IO VARIABLES
IO_LINE_BUF     DS.B    80

IO_CURR_ADDR    DS.L    1
  

*===============================================================================================* OP CODE

*Address where opcode is to decode is in D4
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
