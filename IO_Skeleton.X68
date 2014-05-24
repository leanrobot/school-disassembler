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


    ORG    $1000
START:      
    LEA stack, SP                ; first instruction of program
    LEA OP_jmp_table,A5

* Put program code here
    LEA     IO_OPEN, A1        *Print welcome message
    MOVE.B  #14, D0
    TRAP    #15

DISPLAY_AND_PROMPT_FOR_INPUT:
    LEA    IO_NEW_LINE, A1
    MOVE.B    #14, D0
    TRAP #15

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
    MOVE.B    #25, D6                  *Counter for display looping, starts at 30
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
    MOVE.L #$8, D3
    JSR IO_HEX2ASCII             *Loop through address converting Hex to ascii
    JSR IO_INSERT_TAB
    MOVE.B (A6)+,D4    
    ROL.W       #8,D4
    MOVE.B (A6)+,D4
    JSR OP_DETERMINE_OP_CODE                *Determine what the opcode is

    MOVE.B #$0, (A0)+ * Terminate the line buffer

    CMP.B   #0, D6                         *Compare counter to 30
    BEQ     IO_CLEAR_SCREEN
DISPLAY_LINE_BUFFER:
    SUB.B    #1, D6                        *Decrement counter
    
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
         *Begin error checking, send back to start if incorrect
         CMP.B    #$30, D1                    *Less than 30 is ASCII chars before 0
         BLT      IO_INVALID_CHARACTER_ENTERED
         CMP.B    #'F', D1                    *ASCII characters after F
         BGT      IO_INVALID_CHARACTER_ENTERED
         CMP.B    #'A', D1
         BLT      IO_CHECK_BETWEEN_9_AND_A
IO_END_CHAR_RANGE_CHECKING:      
         *End error checking
        
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
         
IO_CHECK_BETWEEN_9_AND_A:
         CMP.B    #$3A, D1
         BLT     IO_END_CHAR_RANGE_CHECKING

IO_INVALID_CHARACTER_ENTERED:
         LEA    IO_INVALID_CHARACTER_ERROR_MSG, A1
         MOVE.B    #14, D0
         TRAP      #15
         BRA DISPLAY_AND_PROMPT_FOR_INPUT



* ========== Convert # in data register to line buffer
* D2 contains hex value to convert
* D3 contains # of bytes, number length.
* A0 Contains the line buffer
IO_HEX2ASCII:
    MOVEM.L D0-D7/A1-A7, -(A7)
    CLR.L D1
    MOVE.B  #8, D4
    SUB.B   D3, D4
    * discard unneeded front bits
    IO_HEX2ASCII_DiscardLoop:
        CMP.B   #0, D4
        BLE     IO_HEX2ASCII_DiscardLoopDone
        ROL.L   #4, D2
        SUBQ.B  #1, D4
        BRA     IO_HEX2ASCII_DiscardLoop
    IO_HEX2ASCII_DiscardLoopDone:
    
    MOVE.B D3, D1           * counter for loop

    IO_HEX2ASCII_ConvertLoop:
        ROL.L #4, D2          * rotate the value once.
        MOVE.L D2, D3         * copy
        AND.L #$0000000F, D3
        CMP.B #$09,D3        * if F <= d3, letter.
        BGT IO_HEX2ASCII_IfLetter
        BLE IO_HEX2ASCII_IfDigit             * else, digit.

            IO_HEX2ASCII_IfLetter:
                ADD #$37,D3         * add $37
                BRA IO_HEX2ASCII_EndIf
            IO_HEX2ASCII_IfDigit:
                ADD #$30,D3         * add $30
        IO_HEX2ASCII_EndIf:
            MOVE.B D3,(A0)+       * write to line buffer

        SUB.B #1,D1         * decrement loop counter
    BNE IO_HEX2ASCII_ConvertLoop    * repeat loop?

    MOVEM.L (A7)+, D0-D7/A1-A7
    RTS

* A0 is the current place in line buffer
IO_INSERT_TAB:
    MOVE.B #$20,(A0)+
    MOVE.B #$20,(A0)+
    MOVE.B #$20,(A0)+
    MOVE.B #$20,(A0)+
    RTS
    
    
IO_CLEAR_SCREEN:
        LEA  IO_LOAD_MORE_DATA_TO_SCREEN, A1      *Prompt user to hit tap a key
        MOVE.B    #13, D0
        TRAP      #15
        
        MOVE.B    #4, D0                          *User presses any key
        TRAP      #15
    
        MOVE.B    #25, D6                          *Restart loop counter
        BRA       DISPLAY_LINE_BUFFER

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
IO_LOAD_MORE_DATA_TO_SCREEN    DC.B    'Press enter to load more data...', CR, LF, 0
IO_NEW_LINE    DC.B   '', CR, LF, 0
IO_INVALID_CHARACTER_ERROR_MSG    DC.B    'Invalid character entered.', CR, LF, 0

**IO VARIABLES
IO_LINE_BUF     DS.B    80
IO_DISPLAY_LOOP_COUNTER    DS.B  1
IO_CURR_ADDR    DS.L    1
  

*===================================================================* OP CODE

*Address where opcode is to decode is in D4
* A0 is line buffer
OP_DETERMINE_OP_CODE:

OP_DECODER:
    * ready data for comparisons by shifting digits 15 through 12 to
    * digits 0 through 3. 
    CLR.L       D0
    MOVE.W      D4,D0
    MOVE.B      #shift,D1
    LSR.W       D1,D0
    
    * jump table implementation
    MULU        #4,D0
    JSR         0(A5,D0) 
    RTS                  *jumps back to READ_IN_AND_PROCESS
    
*ORI.B, ORI.W, ORI.L, BCLR.B, BCLS.L, CMPI.B, CMPI.W, CMPI.I
OP_Code0000:

*MOVE.B
OP_Code0001:
    *only possibility, can we garuntee test data will compile? do we need error checking here?
    OP_MOVE_B:
         MOVE.B #'M', (A0)+
         MOVE.B #'O', (A0)+
         MOVE.B #'V', (A0)+
         MOVE.B #'E', (A0)+
         MOVE.B #'.', (A0)+
         MOVE.B #'B', (A0)+          *TODO EA Processing
         BRA         OP_Done_Decoding 
    
*MOVE.L, MOVEA.L
OP_Code0010:
    *If equal after bit mask, then MOVEA.L, else, MOVE.L
    MOVE.W      D4,D1
    MOVE.W      #$0040,D2
    ANDI.W      #$01C0,D1
    CMP.W       D2,D1
    BEQ         OP_MOVEA_L
    BNE         OP_MOVE_L
    
    OP_MOVEA_L:
         MOVE.B #'M', (A0)+
         MOVE.B #'O', (A0)+
         MOVE.B #'V', (A0)+
         MOVE.B #'E', (A0)+
         MOVE.B #'A', (A0)+
         MOVE.B #'.', (A0)+
         MOVE.B #'L', (A0)+ 
         *TODO EA Processing
         BRA         OP_Done_Decoding     
         
    OP_MOVE_L:
         MOVE.B #'M', (A0)+
         MOVE.B #'O', (A0)+
         MOVE.B #'V', (A0)+
         MOVE.B #'E', (A0)+
         MOVE.B #'.', (A0)+
         MOVE.B #'L', (A0)+ 
         *TODO EA Processing
         BRA         OP_Done_Decoding      

*MOVE.W, MOVEA.W
OP_Code0011:
 *If equal after bit mask, then MOVEA.L, else, MOVE.L
    MOVE.W      D4,D1
    MOVE.W      #$0040,D2
    ANDI.W      #$01C0,D1
    CMP.W       D2,D1
    BEQ         OP_MOVEA_W
    BNE         OP_MOVE_W
    
    OP_MOVEA_W:
         MOVE.B #'M', (A0)+
         MOVE.B #'O', (A0)+
         MOVE.B #'V', (A0)+
         MOVE.B #'E', (A0)+
         MOVE.B #'A', (A0)+
         MOVE.B #'.', (A0)+
         MOVE.B #'W', (A0)+ 
         *TODO EA Processing
         BRA         OP_Done_Decoding     
         
    OP_MOVE_W:
         MOVE.B #'M', (A0)+
         MOVE.B #'O', (A0)+
         MOVE.B #'V', (A0)+
         MOVE.B #'E', (A0)+
         MOVE.B #'.', (A0)+
         MOVE.B #'W', (A0)+ 
         *TODO EA Processing
         BRA         OP_Done_Decoding 

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
        
        OP_MOVEM_DISPLAY:
            MOVE.B #'M', (A0)+
            MOVE.B #'O', (A0)+
            MOVE.B #'V', (A0)+
            MOVE.B #'E', (A0)+
            MOVE.B #'M', (A0)+
            MOVE.B #'.', (A0)+
            RTS
        
        OP_MOVEM_MEM2REG:
            MOVE.W      D4,D1
            MOVE.W      #$0040,D2
            ANDI.W      #$0040,D1
            CMP.W       D1,D2
            BEQ         OP_MOVEM_MEM2REG_L
            BNE         OP_MOVEM_MEM2REG_W
            
            OP_MOVEM_MEM2REG_L:
                JSR         OP_MOVEM_DISPLAY
                MOVE.B #'L', (A0)+
                *TODO  EA
                BRA         OP_Done_Decoding
            OP_MOVEM_MEM2REG_W:
                JSR         OP_MOVEM_DISPLAY
                MOVE.B #'W', (A0)+
                *TODO  EA
                BRA         OP_Done_Decoding
        
        OP_MOVEM_REG2MEM:
            MOVE.W      D4,D1
            MOVE.W      #$0040,D2
            ANDI.W      #$0040,D1
            CMP.W       D1,D2 
            BEQ         OP_MOVEM_REG2MEM_L
            BNE         OP_MOVEM_REG2MEM_W     
            
            OP_MOVEM_REG2MEM_L:
                JSR         OP_MOVEM_DISPLAY
                MOVE.B #'L', (A0)+
                *TODO  EA
                BRA         OP_Done_Decoding
            OP_MOVEM_REG2MEM_W:
                JSR         OP_MOVEM_DISPLAY
                MOVE.B #'W', (A0)+
                *TODO  EA
                BRA         OP_Done_Decoding
        
*SUBQ.B, SUBQ.W, SUBQ.L
OP_Code0101:
    MOVE.W      D4,D1
    ANDI.W      #$01C0,D1 
    *SUBQ.B?
    MOVE.W      #$0100,D2
    CMP.W       D2,D1
    BEQ         OP_SUBQ_B
    *SUBQ.W?
    MOVE.W      #$0140,D2
    CMP.W       D2,D1
    BEQ         OP_SUBQ_W
    *SUBQ.L?
    MOVE.W      #$0180,D2
    CMP.W       D2,D1
    BEQ         OP_SUBQ_L
    *error?
    BNE         OP_NOT_FOUND_ERROR 
    
    OP_SUBQ:
        MOVE.B #'S', (A0)+
        MOVE.B #'U', (A0)+
        MOVE.B #'B', (A0)+
        MOVE.B #'Q', (A0)+
        MOVE.B #'.', (A0)+
        RTS
    
    OP_SUBQ_B:
        JSR     OP_SUBQ
        MOVE.B #'B', (A0)+
        *TODO add EA processing
        BRA         OP_Done_Decoding
    OP_SUBQ_W:
        JSR     OP_SUBQ
        MOVE.B #'B', (A0)+
        *TODO add EA processing
        BRA         OP_Done_Decoding
    OP_SUBQ_L:
        JSR     OP_SUBQ
        MOVE.B #'B', (A0)+
        *TODO add EA processing
        BRA         OP_Done_Decoding

*BCS, BGE, BLT, BVC, BRA
OP_Code0110:
    BRA         OP_NOT_FOUND_ERROR
    MOVE.W      D4,D1
    ANDI.W      #$0F00,D1
    * BCS?
    MOVE.W      #$0500,D2
    CMP.W       D2,D1
    BEQ         OP_BCS
    * BGE?
    MOVE.W      #$0C00,D2
    CMP.W       D2,D1
    BEQ         OP_BGE
    * BLT?
    MOVE.W      #$0C00,D2
    CMP.W       D2,D1
    BEQ         OP_BLT
    * BVC?
    MOVE.W      #$0C00,D2
    CMP.W       D2,D1
    BEQ         OP_BVC
    * error
    BNE         OP_NOT_FOUND_ERROR    

    OP_BCS:
        MOVE.B #'B', (A0)+
        MOVE.B #'C', (A0)+
        MOVE.B #'S', (A0)+
        *TODO add EA processing
        BRA         OP_Done_Decoding
    OP_BGE:
        MOVE.B #'B', (A0)+
        MOVE.B #'G', (A0)+
        MOVE.B #'E', (A0)+
        *TODO add EA processing
        BRA         OP_Done_Decoding
    OP_BLT:
        MOVE.B #'B', (A0)+
        MOVE.B #'L', (A0)+
        MOVE.B #'T', (A0)+
        *TODO add EA processing
        BRA         OP_Done_Decoding
    OP_BVC:
        MOVE.B #'B', (A0)+
        MOVE.B #'V', (A0)+
        MOVE.B #'C', (A0)+
        *TODO add EA processing
        BRA         OP_Done_Decoding
    
****NOT USED!!!
OP_Code0111:
    BRA         OP_NOT_FOUND_ERROR

*DIVS.W, OR.B*, OR.W*, OR.L*
OP_Code1000:
    MOVE.W      D4,D1
    ANDI.W      #$01C0,D1  
    * DIVS.W?
    MOVE.W      #$01C0,D2
    CMP.W       D2,D1
    BEQ         OP_DIVS_W
    * OR.B <ea> + Dn -> Dn?
    MOVE.W      #$0000,D2
    CMP.W       D2,D1
    BEQ         OP_OR_B_DestDn
    * OR.W <ea> + Dn -> Dn?
    MOVE.W      #$0040,D2
    CMP.W       D2,D1
    BEQ         OP_OR_W_DestDn
    * OR.L <ea> + Dn -> Dn?
    MOVE.W      #$0080,D2
    CMP.W       D2,D1
    BEQ         OP_OR_L_DestDn 
    * OR.B Dn + <ea> -> <ea>?
    MOVE.W      #$0100,D2
    CMP.W       D2,D1
    BEQ         OP_OR_B_DestEA 
    * OR.W Dn + <ea> -> <ea>?
    MOVE.W      #$0140,D2
    CMP.W       D2,D1
    BEQ         OP_OR_W_DestEA 
    * OR.L Dn + <ea> -> <ea>?
    MOVE.W      #$0180,D2
    CMP.W       D2,D1
    BEQ         OP_OR_L_DestEA 
    * Error
    BNE         OP_NOT_FOUND_ERROR
    
    OP_DIVS_W:
        MOVE.B #'D', (A0)+
        MOVE.B #'I', (A0)+
        MOVE.B #'V', (A0)+
        MOVE.B #'S', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'W', (A0)+
        *TODO ea processing
        BRA         OP_Done_Decoding

    OP_OR_B:
        MOVE.B #'O', (A0)+
        MOVE.B #'R', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'B', (A0)+
        RTS
    OP_OR_W:
        MOVE.B #'O', (A0)+
        MOVE.B #'R', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'W', (A0)+
        RTS
    OP_OR_L:
        MOVE.B #'O', (A0)+
        MOVE.B #'R', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'L', (A0)+
        RTS
        
    OP_OR_B_DestDn:
        JSR         OP_OR_B
        *TODO EA processing
        BRA         OP_Done_Decoding 
    OP_OR_W_DestDn:
        JSR         OP_OR_W
        *TODO EA processing
        BRA         OP_Done_Decoding 
    OP_OR_L_DestDn:
        JSR         OP_OR_L
        *TODO EA processing
        BRA         OP_Done_Decoding 
    OP_OR_B_DestEA:
        JSR         OP_OR_B
        *TODO EA processing
        BRA         OP_Done_Decoding 
    OP_OR_W_DestEA:
        JSR         OP_OR_W
        *TODO EA processing
        BRA         OP_Done_Decoding 
    OP_OR_L_DestEA:
        JSR         OP_OR_L
        *TODO EA processing
        BRA         OP_Done_Decoding 
        
* SUB.B*, SUB.W*, SUB.L*
OP_Code1001:
    MOVE.W      D4,D1
    ANDI.W      #$01C0,D1 
    * SUB.B <ea> + Dn -> Dn?
    MOVE.W      #$0000,D2
    CMP.W       D2,D1
    BEQ         OP_SUB_B_DestDn
    * SUB.W <ea> + Dn -> Dn?
    MOVE.W      #$0040,D2
    CMP.W       D2,D1
    BEQ         OP_SUB_W_DestDn
    * SUB.L <ea> + Dn -> Dn?
    MOVE.W      #$0080,D2
    CMP.W       D2,D1
    BEQ         OP_SUB_L_DestDn 
    * SUB.B Dn + <ea> -> <ea>?
    MOVE.W      #$0100,D2
    CMP.W       D2,D1
    BEQ         OP_SUB_B_DestEA 
    * SUB.W Dn + <ea> -> <ea>?
    MOVE.W      #$0140,D2
    CMP.W       D2,D1
    BEQ         OP_SUB_W_DestEA 
    * SUB.L Dn + <ea> -> <ea>?
    MOVE.W      #$0180,D2
    CMP.W       D2,D1
    BEQ         OP_SUB_L_DestEA 
    * Error
    BNE         OP_NOT_FOUND_ERROR
    
    OP_SUB_B:
        MOVE.B #'S', (A0)+
        MOVE.B #'U', (A0)+
        MOVE.B #'B', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'B', (A0)+
        RTS
    OP_SUB_W:
        MOVE.B #'S', (A0)+
        MOVE.B #'U', (A0)+
        MOVE.B #'B', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'W', (A0)+
        RTS
    OP_SUB_L:
        MOVE.B #'S', (A0)+
        MOVE.B #'U', (A0)+
        MOVE.B #'B', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'L', (A0)+
        RTS
        
    OP_SUB_B_DestDn:
        JSR         OP_SUB_B
        *TODO EA processing
        BRA         OP_Done_Decoding     
    OP_SUB_W_DestDn:
        JSR         OP_SUB_W
        *TODO EA processing
        BRA         OP_Done_Decoding
    OP_SUB_L_DestDn:
        JSR         OP_SUB_L
        *TODO EA processing
        BRA         OP_Done_Decoding
    OP_SUB_B_DestEA:
        JSR         OP_SUB_B
        *TODO EA processing
        BRA         OP_Done_Decoding 
    OP_SUB_W_DestEA:
        JSR         OP_SUB_W
        *TODO EA processing
        BRA         OP_Done_Decoding
    OP_SUB_L_DestEA:
        JSR         OP_SUB_L
        *TODO EA processing
        BRA         OP_Done_Decoding

****NOT USED!!!
OP_Code1010:
    BRA         OP_NOT_FOUND_ERROR

*EOR.B, EOR.W, EOR.L, CMP.B, CMP.W, CMP.L
OP_Code1011:
    MOVE.W      D4,D1
    ANDI.W      #$001C,D1
    *EOR.B?
    MOVE.W      #$0100,D2
    CMP.W       D2,D1
    BEQ         OP_EOR_B
    *EOR.W?
    MOVE.W      #$0140,D2
    CMP.W       D2,D1
    BEQ         OP_EOR_W
    *EOR.L?
    MOVE.W      #$01C0,D2
    CMP.W       D2,D1
    BEQ         OP_EOR_L
    *CMP.B?
    MOVE.W      #$0000,D2
    CMP.W       D2,D1
    BEQ         OP_CMP_B
    *CMP.W?
    MOVE.W      #$0040,D2
    CMP.W       D2,D1
    BEQ         OP_CMP_W
    *CMP.L?
    MOVE.W      #$0080,D2
    CMP.W       D2,D1
    BEQ         OP_CMP_L
    
    OP_EOR_B:
        MOVE.B #'E', (A0)+
        MOVE.B #'O', (A0)+
        MOVE.B #'R', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'B', (A0)+
        RTS
    OP_EOR_W:
        MOVE.B #'E', (A0)+
        MOVE.B #'O', (A0)+
        MOVE.B #'R', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'W', (A0)+
        RTS
    OP_EOR_L:
        MOVE.B #'E', (A0)+
        MOVE.B #'O', (A0)+
        MOVE.B #'R', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'L', (A0)+
        RTS
    
    OP_CMP_B:
        MOVE.B #'C', (A0)+
        MOVE.B #'M', (A0)+
        MOVE.B #'P', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'B', (A0)+
        RTS    
    OP_CMP_W:
        MOVE.B #'C', (A0)+
        MOVE.B #'M', (A0)+
        MOVE.B #'P', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'W', (A0)+
        RTS  
    OP_CMP_L:
        MOVE.B #'C', (A0)+
        MOVE.B #'M', (A0)+
        MOVE.B #'P', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'L', (A0)+
        RTS  

*MULS.W
OP_Code1100:
    MOVE.W      D4,D1
    MOVE.W      #$01C0,D2
    ANDI.W      #$01C0,D1
    CMP.W       D2,D1
    BEQ         OP_MULS_W
    BNE         OP_NOT_FOUND_ERROR
    
    OP_MULS_W:
        MOVE.B #'M', (A0)+
        MOVE.B #'U', (A0)+
        MOVE.B #'L', (A0)+
        MOVE.B #'S', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'W', (A0)+    
        *TODO effective Address Processing
        BRA         OP_Done_Decoding    

*ADD.B*, ADD.W*, ADD.L*, ADDA.W, ADDA.L
OP_Code1101:
    MOVE.W      D4,D1
    ANDI.W      #$01C0,D1 
    * ADD.B <ea> + Dn -> Dn?
    MOVE.W      #$0000,D2
    CMP.W       D2,D1
    BEQ         OP_ADD_B_DestDn
    * ADD.W <ea> + Dn -> Dn?
    MOVE.W      #$0040,D2
    CMP.W       D2,D1
    BEQ         OP_ADD_W_DestDn
    * ADD.L <ea> + Dn -> Dn?
    MOVE.W      #$0080,D2
    CMP.W       D2,D1
    BEQ         OP_ADD_L_DestDn 
    * ADD.B Dn + <ea> -> <ea>?
    MOVE.W      #$0100,D2
    CMP.W       D2,D1
    BEQ         OP_ADD_B_DestEA 
    * ADD.W Dn + <ea> -> <ea>?
    MOVE.W      #$0140,D2
    CMP.W       D2,D1
    BEQ         OP_ADD_W_DestEA 
    * ADD.L Dn + <ea> -> <ea>?
    MOVE.W      #$0180,D2
    CMP.W       D2,D1
    BEQ         OP_ADD_L_DestEA 
    * ADDA.W?
    MOVE.W      #$00C0,D2
    CMP.W       D2,D1
    BEQ         OP_ADDA_W
    * ADDA.L?
    MOVE.W      #$01C0,D2
    CMP.W       D2,D1
    BEQ         OP_ADDA_W
    * Error
    BNE         OP_NOT_FOUND_ERROR
    
    OP_ADD_B:
        MOVE.B #'A', (A0)+
        MOVE.B #'D', (A0)+
        MOVE.B #'D', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'B', (A0)+
        RTS
    OP_ADD_W:
        MOVE.B #'A', (A0)+
        MOVE.B #'D', (A0)+
        MOVE.B #'D', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'W', (A0)+
        RTS
    OP_ADD_L:
        MOVE.B #'A', (A0)+
        MOVE.B #'D', (A0)+
        MOVE.B #'D', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'L', (A0)+
        RTS
        
    OP_ADD_B_DestDn:
        JSR         OP_ADD_B
        *TODO EA processing
        BRA         OP_Done_Decoding     
    OP_ADD_W_DestDn:
        JSR         OP_ADD_W
        *TODO EA processing
        BRA         OP_Done_Decoding
    OP_ADD_L_DestDn:
        JSR         OP_ADD_L
        *TODO EA processing
        BRA         OP_Done_Decoding
    OP_ADD_B_DestEA:
        JSR         OP_ADD_B
        *TODO EA processing
        BRA         OP_Done_Decoding 
    OP_ADD_W_DestEA:
        JSR         OP_ADD_W
        *TODO EA processing
        BRA         OP_Done_Decoding
    OP_ADD_L_DestEA:
        JSR         OP_ADD_L
        *TODO EA processing
        BRA         OP_Done_Decoding
        
     OP_ADDA_W:
        MOVE.B #'A', (A0)+
        MOVE.B #'D', (A0)+
        MOVE.B #'D', (A0)+
        MOVE.B #'A', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'W', (A0)+
        *TODO EA processing
        BRA         OP_Done_Decoding
    OP_ADDA_L:
        MOVE.B #'A', (A0)+
        MOVE.B #'D', (A0)+
        MOVE.B #'D', (A0)+
        MOVE.B #'A', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'L', (A0)+
        *TODO EA processing
        BRA         OP_Done_Decoding

*LSd.B*, LSd.W*, LSd.L*, ASd.B*, ASd.W*, ASd.L*, ROd.B*, ROd.W*, ROd.L*
OP_Code1110:
    *decide if LSd, ASd, or ROd
    *first check if LSd
    MOVE.W      D4,D1
    MOVE.W      #$0008,D2
    ANDI.W      #$0018,D1
    CMP.W       D2,D1
    BEQ         OP_LSd
    *Now check if ASd
    MOVE.W      #$0000,D2
    CMP.W       D2,D1
    BEQ         OP_ASd
    *Finally check if ROd, error if not
    MOVE.W      #$0018,D2
    CMP.W       D2,D1
    BEQ         OP_ROd  
    BNE         OP_NOT_FOUND_ERROR
    
    OP_1110_CheckRightOrLeft:
        MOVE.W      D4,D1
        MOVE.W      #$0100,D2
        ANDI.W      #$0100,D1
        CMP.W       D2,D1
        BEQ         OP_Left
        BNE         OP_Right

        OP_Left:
            MOVE.B #'L', (A0)+
            RTS
        OP_Right:   
            MOVE.B #'R', (A0)+
            RTS
            
    OP_1110_GetSize:
        MOVE.W      D4,D1
        * first check for byte size
        MOVE.W      #$0000,D2
        ANDI.W      #$00C0,D1
        CMP.W       D2,D1
        BEQ         OP_1110_Byte
        * then check for word
        MOVE.W      #$0040,D2    
        CMP.W       D2,D1
        BEQ         OP_1110_Word
        * last check for long or its an error
        MOVE.W      #$0080,D2    
        CMP.W       D2,D1
        BEQ         OP_1110_Long
        
        OP_1110_Byte:
            MOVE.B #'B', (A0)+
            RTS
        OP_1110_Word:
            MOVE.B #'W', (A0)+
            RTS
        OP_1110_Long:
            MOVE.B #'L', (A0)+
            RTS

    OP_LSd:
        MOVE.B #'L', (A0)+
        MOVE.B #'S', (A0)+
        JSR         OP_1110_CheckRightOrLeft
        MOVE.B #'.', (A0)+
        JSR         OP_1110_GetSize
         *TODO add EA processing
        BRA         OP_Done_Decoding
        
    OP_ASd:
        MOVE.B #'A', (A0)+
        MOVE.B #'S', (A0)+
        JSR         OP_1110_CheckRightOrLeft
        MOVE.B #'.', (A0)+
        JSR         OP_1110_GetSize
         *TODO add EA processing
        BRA         OP_Done_Decoding
    
    OP_ROd:
        MOVE.B #'R', (A0)+
        MOVE.B #'O', (A0)+
        JSR         OP_1110_CheckRightOrLeft
        MOVE.B #'.', (A0)+
        JSR         OP_1110_GetSize
         *TODO add EA processing
        BRA         OP_Done_Decoding

****NOT USED!!!
OP_Code1111:
    BRA         OP_NOT_FOUND_ERROR


OP_Done_Decoding:
    RTS


OP_NOT_FOUND_ERROR:
    MOVE.B #'D', (A0)+
    MOVE.B #'A', (A0)+
    MOVE.B #'T', (A0)+
    MOVE.B #'A', (A0)+
    
    JSR IO_INSERT_TAB
    MOVE.B #'$',(A0)+
    *Printing hex word of undecodable instruction
    MOVE.L D4, D2
    MOVE.B #$4,D3
    JSR IO_HEX2ASCII
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
    JMP         OP_Code1110
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
