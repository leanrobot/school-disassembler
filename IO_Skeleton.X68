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
    JSR IO_HEX2ASCII                        *Loop through address converting Hex to ascii
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
         
IO_HEX2ASCII:
         * D1 = loop counter
         * D2 = Original address
         * D3 = working address for loop
         
         MOVE.L   (IO_CURR_ADDR),D2    * Get the current instruction address
         MOVEQ    #8, D1               * Setup a loop from 8 --> 0.
         CLR.L    (A3)
         CLR.L    D4
         CLR.L    D5
         MOVE.L   D2, (A3)               * Move address to D2 to D3 to work with
IO_HEX2ASCII_GET_DIGIT:
         MOVE.B   (A3)+, D5         *Move one byte to D5 to work with
         MOVE.B    D5, D6           *Copy byte to rotate, to get first digit of byte
         ROR.B      #4, D5
         ANDI.B  #$0F, D5
         JSR IO_HEX2ASCII_LOOP         * Go to conversion loop for each digit
         ROL.L    #8, D4
         ADD.B    D5, D4
         SUB.B    #1, D1               * Decrement loop counter
         *Do it again, to get second digit of byte
         MOVE.B   D6, D5               *Move copy back into D5 to get second digit
         ANDI.B   #$05, D5
         JSR IO_HEX2ASCII_LOOP
         ROL.L    #8, D4
         ADD.B    D5, D4
         SUB.B    #1, D1              *Decrement loop counter
         BEQ    IO_ADD_TO_BUFFER      *Add address to buffer
         CMP.B    #4, D1              *If not 0, see if <= or >4
         BLE    IO_HEX2ASCII_SECOND_HALF     *Move to function to hold second half
         BGT    IO_HEX2ASCII_GET_DIGIT       *If still greater than 4, keep going
IO_HEX2ASCII_GET_DIGIT_DONE:
         *Concatenate the two registers
         *Move d4 into another address register
         RTS
         
         
IO_HEX2ASCII_SECOND_HALF:
         MOVE.L    D4, A2    *Move first half of address to A2 to save
         CLR.L     D4        *Clear D4 for second half
IO_HEX2ASCII_SECOND_HALF_LOOP:
         MOVE.B   (A3)+, D5         *Move one byte to D5 to work with
         MOVE.B    D5, D6           *Copy byte to rotate, to get first digit of byte
         ROR.B     #4, D5
         ANDI.B   #$0F, D5
         JSR IO_HEX2ASCII_LOOP         * Go to conversion loop for each digit
         ROL.L    #8, D4
         ADD.B    D5, D4
         SUB.B    #1, D1               * Decrement loop counter
         *Do it again, to get second digit of byte
         MOVE.B   D6, D5               *Move copy back into D5 to get second digit
         ANDI.B   #$05, D5
         JSR IO_HEX2ASCII_LOOP
         ROL.L    #8, D4
         ADD.B    D5, D4
         SUB.B    #1, D1              *Decrement loop counter
         BEQ    IO_ADD_TO_BUFFER      *Add address to buffer
         BEQ   IO_HEX2ASCII_GET_DIGIT_DONE
         BNE   IO_HEX2ASCII_SECOND_HALF_LOOP
         

IO_HEX2ASCII_LOOP:
         *MOVE.L   D2,D3
         *LSR      D1,D3
         *AND.L    #$0000000F, D3
         
         *Convert to ASCII
         CMP.B    #9, D5
         BLE      IO_DIGIHEX2ASCII    
         BGT      IO_LETTERHEX2ASCII 
IO_HEX2ASCII_LOOP_COMPLETE:
         RTS
         * Write to address register
IO_ADD_TO_BUFFER:         
         *MOVE.B D3,(A1)+        *Can't increment line buffer, so this is an address register now
         
         * Reloop
         *SUBI #1,D1
         *BNE IO_HEX2ASCII_LOOP
         
         MOVE.L D4, IO_LINE_BUF *Move converted address into line buffer
         
         CLR.L   (A1)
         
         MOVE.L    IO_LINE_BUF, A1
         MOVE.L    IO_TAB, A2
         
IO_INSERT_FIRST_TAB:         
         MOVE.B    (A2)+, (A1)+
         BNE       IO_INSERT_FIRST_TAB
         MOVE.L    A1, IO_LINE_BUF
         
         LEA    IO_LINE_BUF, A3
         MOVE.B    #14, D0
         TRAP      #15
         
         *Add Tab to Line buffer
         *MOVE.L A1, D4      *Move converted address into D4 for op_code determination
         
         BRA IO_HEX2ASCII_GET_DIGIT_DONE
         
IO_DIGIHEX2ASCII:
         ADD.B     #$30, D5
         BRA IO_HEX2ASCII_LOOP_COMPLETE

IO_LETTERHEX2ASCII:
         ADD.B    #$37, D5
         BRA IO_HEX2ASCII_LOOP_COMPLETE
    
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
