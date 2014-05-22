*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
CR      EQU     $0D
LF      EQU     $0A

stack   EQU     $A000    *sp initial
shift   EQU     12


    ORG    $4000
START:      
    LEA stack, SP                ; first instruction of program
    LEA OP_jmp_table,A5

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
    MOVEA.L D3, A6                   * Move the starting address to a6, current soemthign
    
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
    ****MOVEA.L (IO_STARTADDR),A6    *Move starting address to current address variable
MAIN_LOOP:
IO_READING:
    MOVE.L      (IO_ENDADDR),D0
    CMP.L       A6,D0
    BLT         PROMPT_TO_RESTART
    BGE         READ_IN_AND_PROCESS

PROMPT_TO_RESTART:
    LEA    IO_RESTART_PROMPT, A1
    MOVE.B    #14, D0
    TRAP      #15

    CLR.L     D1  

    MOVE.B    #5, D0
    TRAP      #15

    *Y/y = 59 OR 79
    *N/n = 4E or 6E
    CMP.B     #$59, D1
    BEQ    DISPLAY_AND_PROMPT_FOR_INPUT
    CMP.B     #$79, D1
    BEQ    DISPLAY_AND_PROMPT_FOR_INPUT

*DO NOT PUT METHODS BETWEEN PROMPT_TO_RESTART
    SIMHALT ;*********** END OF MAIN ********************

READ_IN_AND_PROCESS:
    LEA IO_LINE_BUF, A0                   * pointer to line buffer
    MOVE.L A6, D2               * Parameter setup for IO_HEX2ASCII
    JSR IO_HEX2ASCII             *Loop through address converting Hex to ascii
    JSR IO_INSERT_TAB
    MOVE.B (A6)+,D4    
    ROL.W       #8,D4
    MOVE.B (A6)+,D4
    JSR OP_DETERMINE_OP_CODE                *Determine what the opcode is

    MOVE.B #$0, (A0)+ * Terminate the line buffer

    LEA     IO_LINE_BUF, A1
    MOVE.B #13, D0
    TRAP #15

   

    BRA IO_READING

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
IO_RESTART_PROMPT   DC.B    'Would you like to run again? Enter Y/N: ', CR, LF, 0

**IO VARIABLES
IO_LINE_BUF     DS.B    80

IO_CURR_ADDR    DS.L    1
  

*===================================================================* OP CODE

*Address where opcode is to decode is in D4
* A0 is line buffer
OP_DETERMINE_OP_CODE:
    *MOVE.B #1,(OP_CODE_UNKNWN)
    * Hardcode 'D','A','T','A'
    *MOVE.B #'D', (A0)+
    *MOVE.B #'A', (A0)+
    *MOVE.B #'T', (A0)+
    *MOVE.B #'A', (A0)+
    *RTS

OP_DECODER:
    * ready data for comparisons by shifting digits 15 through 12 to
    * digits 0 through 3. 
    CLR.L       D0
    *MOVE.W      D4,A2
    *MOVE.B      (A2)+,D4
    *ROL.W       #8,D4
    *MOVE.B      (A2),D4
    MOVE.W      D4,D1
    MOVE.B      #shift,D1
    LSR.W       D1,D0
    
    * jump table implementation
    MULU        #6,D0
    JSR         0(A5,D0) 
    RTS                  *jumps back to READ_IN_AND_PROCESS
    
*ORI.B, ORI.W, ORI.L, BCLR.B, BCLS.L, CMPI.B, CMPI.W, CMPI.I
OP_Code0000:

*MOVE.B
OP_Code0001:

*MOVE.L, MOVEA.L
OP_Code0010:

*MOVE.W, MOVEA.W
OP_Code0011:

*NOP, JSR, RTS, NEG.B, NEG.W, NEG.L, LEA.L, MOVEM.W*, MOVEM.L*
OP_Code0100:
    * is it NOP?
    MOVE.W      D4,D1
    MOVE.W      #$4E71, D2
    CMP.W       D2, D1
    BEQ         OP_NOP
    * is  it JSR?
    MOVE.W      D4,D1
    MOVE.W      #$4E80,D2
    ANDI.W      #$FFC0,D1
    CMP.W       D2,D1
    BEQ         OP_JSR
    * is it RTS?
    MOVE.W      D4,D1
    MOVE.W      #$4775,D2
    CMP.W       D2, D1
    BEQ         OP_RTS
    * is it NEG?
    MOVE.W      D4,D1    
    MOVE.W      #$4400,D2
    ANDI.W      #$FF00,D1
    CMP.W       D2, D1
    BEQ         OP_NEG   
    * is it LEA.L?
    MOVE.W      D4,D1
    MOVE.W      #$41C0,D2
    ANDI.W      #$F1C0,D1
    CMP.W       D2,D1
    BEQ         OP_LEA
    * is it MOVEM?
    MOVE.W      D4,D1
    MOVE.W      #$4880,D2
    ANDI.W      #$FB80,D1
    CMP.W       D2,D1
    BEQ         OP_MOVEM
    * invalid op_code was given
    BNE         OP_NOT_FOUND_ERROR

    OP_NOP:
        MOVE.B #'N', (A0)+
        MOVE.B #'O', (A0)+
        MOVE.B #'P', (A0)+
        BRA         OP_Done_Decoding      

    OP_JSR:
        MOVE.B #'J', (A0)+
        MOVE.B #'S', (A0)+
        MOVE.B #'R', (A0)+   
        *TODO effective Address Processing
        BRA         OP_Done_Decoding
    
    OP_RTS:
        MOVE.B #'R', (A0)+
        MOVE.B #'T', (A0)+
        MOVE.B #'S', (A0)+
        BRA         OP_Done_Decoding
    
    OP_NEG:
        *find out length
        MOVE.W     D4,D1
        ANDI.W     #$00C0,D1
        * .B? 
        MOVE.W     #$0000,D2
        CMP.W      D2,D1
        BEQ        OP_NEG_B
        * .W?
        MOVE.W     #$0040,D2
        CMP.W      D2,D1
        BEQ        OP_NEG_W
        * .L?
        MOVE.W     #$0080,D2
        CMP.W      D2,D1
        BEQ        OP_NEG_L
        BNE        OP_NOT_FOUND_ERROR
         
        OP_NEG_B:
            MOVE.B #'N', (A0)+
            MOVE.B #'E', (A0)+
            MOVE.B #'G', (A0)+
            MOVE.B #'.', (A0)+
            MOVE.B #'B', (A0)+    
            *TODO effective Address Processing
            BRA         OP_Done_Decoding
 
        OP_NEG_W:
            MOVE.B #'N', (A0)+
            MOVE.B #'E', (A0)+
            MOVE.B #'G', (A0)+
            MOVE.B #'.', (A0)+
            MOVE.B #'W', (A0)+    
            *TODO effective Address Processing
            BRA         OP_Done_Decoding
 
        OP_NEG_L:
            MOVE.B #'N', (A0)+
            MOVE.B #'E', (A0)+
            MOVE.B #'G', (A0)+
            MOVE.B #'.', (A0)+
            MOVE.B #'L', (A0)+   
            *TODO effective Address Processing
            BRA         OP_Done_Decoding
    
    OP_LEA:
        MOVE.B #'L', (A0)+
        MOVE.B #'E', (A0)+
        MOVE.B #'A', (A0)+  
        *TODO effective Address Processing
        BRA         OP_Done_Decoding
    
    OP_MOVEM:
        MOVE.W      D4,D1
        MOVE.W      #$0400,D2
        ANDI.W      #$0400,D1
        CMP.W       D1,D2
        BEQ         OP_MOVEM_MEM2REG
        BNE         OP_MOVEM_REG2MEM
        
        OP_MOVEM_MEM2REG:
            MOVE.W      D4,D1
            MOVE.W      #$0040,D2
            ANDI.W      #$0040,D1
            CMP.W       D1,D2
            BEQ         OP_MOVEM_MEM2REG_L
            BNE         OP_MOVEM_MEM2REG_W
            
            OP_MOVEM_MEM2REG_L:
                *TODO print and EA
                BRA         OP_Done_Decoding
            OP_MOVEM_MEM2REG_W:
                *TODO print and EA
                BRA         OP_Done_Decoding
        
        OP_MOVEM_REG2MEM:
            MOVE.W      D4,D1
            MOVE.W      #$0040,D2
            ANDI.W      #$0040,D1
            CMP.W       D1,D2 
            BEQ         OP_MOVEM_REG2MEM_L
            BNE         OP_MOVEM_REG2MEM_W     
            
            OP_MOVEM_REG2MEM_L:
                *TODO print and EA
                BRA         OP_Done_Decoding
            OP_MOVEM_REG2MEM_W:
                *TODO print and EA
                BRA         OP_Done_Decoding
        
*SUBQ.B, SUBQ.W, SUBQ.L
OP_Code0101:

*BCS, BGE, BLT, BVC, BRA
OP_Code0110:

****NOT USED!!!
OP_Code0111:
    BRA         OP_NOT_FOUND_ERROR
*DIVS.W, OR.B*, OR.W*, OR.L*
OP_Code1000:

*SUB.B*, SUB.W*, SUB.L*
OP_Code1001:

****NOT USED!!!
OP_Code1010:
     BRA         OP_NOT_FOUND_ERROR

*EOR.B, EOR.W, EOR.L, CMP.B, CMP.W, CMP.L
OP_Code1011:

*MULS.W
OP_Code1100:

*ADD.B*, ADD.W*, ADD.L*, ADDA.W, ADDA.L
OP_Code1101:

*LSd.B*, LSd.W*, LSd.L*, ASd.B*, ASd.W*, ASd.L*, ROd.B*, ROD.W*, ROd.L*
OP_Code1110:

****NOT USED!!!
OP_Code1111:
    BRA         OP_NOT_FOUND_ERROR

OP_Done_Decoding:
    RTS

OP_NOT_FOUND_ERROR:
    MOVE.B #'E', (A0)+
    MOVE.B #'R', (A0)+
    MOVE.B #'R', (A0)+
    MOVE.B #'O', (A0)+
    MOVE.B #'R', (A0)+
    MOVE.B #'!', (A0)+    
    RTS    

*===============================================================================================* OP CODE CONSTANTS
*OP CODE CONSTANTS

OP_jmp_table   
    JMP         OP_Code0000
    JMP         OP_Code0001
    JMP         OP_Code0010
    JMP         OP_Code0011
    JMP         OP_Code0100
    JMP         OP_Code0101
    JMP         OP_Code0110
    JMP         OP_Code0111
    JMP         OP_Code1000
    JMP         OP_Code1001
    JMP         OP_Code1010
    JMP         OP_Code1011
    JMP         OP_Code1100
    JMP         OP_Code1101
    JMP         OP_Code1111

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
