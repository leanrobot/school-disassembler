*-----------------------------------------------------------
* Title      : Razrs Dissambler
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
CR      EQU     $0D
LF      EQU     $0A
PARAMS  REG     D3-D7/A2-A5

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

    JSR IO_INSERT_TAB
    JSR IO_INSERT_TAB

    * EA_DECODE(d2=opcode case, d3=operation size)
    JSR EA_DECODE

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

* ___   __    _  _______  __   __  _______      _______  __   __  _______  _______  __   __  _______ 
*|   | |  |  | ||       ||  | |  ||       |    |       ||  | |  ||       ||       ||  | |  ||       |
*|   | |   |_| ||    _  ||  | |  ||_     _|    |   _   ||  | |  ||_     _||    _  ||  | |  ||_     _|
*|   | |       ||   |_| ||  |_|  |  |   |      |  | |  ||  |_|  |  |   |  |   |_| ||  |_|  |  |   |  
*|   | |  _    ||    ___||       |  |   |      |  |_|  ||       |  |   |  |    ___||       |  |   |  
*|   | | | |   ||   |    |       |  |   |      |       ||       |  |   |  |   |    |       |  |   |  
*|___| |_|  |__||___|    |_______|  |___|      |_______||_______|  |___|  |___|    |_______|  |___|  

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
    MOVE.B #$9,(A0)+
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
* _______  _______    _______  _______  ______   _______ 
*|       ||       |  |       ||       ||      | |       |
*|   _   ||    _  |  |       ||   _   ||  _    ||    ___|
*|  | |  ||   |_| |  |       ||  | |  || | |   ||   |___ 
*|  |_|  ||    ___|  |      _||  |_|  || |_|   ||    ___|
*|       ||   |      |     |_ |       ||       ||   |___ 
*|_______||___|      |_______||_______||______| |_______|

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
    * BCLR?
    MOVE.W      D4,D1
    ANDI.W      #$01C0,D1
    MOVE.W      #$0180,D2
    CMP.W       D1,D2
    BEQ         OP_BCLR
    * ORI?
    MOVE.W      D4,D1
    ANDI.W      #$FF00,D1
    MOVE.W      #$0000,D2
    CMP.W       D1,D2
    BEQ         OP_ORI
    * CMPI
    MOVE.W      #$0C00,D2
    CMP.W       D1,D2
    BEQ         OP_CMPI
    * else, error. 
    BNE         OP_NOT_FOUND_ERROR
    
    OP_0000_GetSize:
        MOVE.W      D4,D1
        ANDI.W      #$00C0,D1
        *Byte?
        MOVE.W      #$0000,D2
        CMP.W       D1,D2
        BEQ         OP_0000_byte
        *Word?
        MOVE.W      #$0040,D2
        CMP.W       D1,D2
        BEQ         OP_0000_word
        *Long?
        MOVE.W      #$0080,D2
        CMP.W       D1,D2
        BEQ         OP_0000_long
        *error
        BNE         OP_NOT_FOUND_ERROR
        
        OP_0000_byte:
            MOVE.B #'B', (A0)+
            MOVEQ #1, D3 *For EA
            RTS
        OP_0000_word:
            MOVE.B #'W', (A0)+
            MOVEQ #3, D3 *For EA
            RTS
        OP_0000_long:
            MOVE.B #'L', (A0)+
            MOVEQ #2, D3 *For EA
            RTS
            
    OP_BCLR:
        MOVE.W      D4,D1
        ANDI.W      #$0038,D1
        MOVE.W      #$0000,D2
        BEQ         OP_BCLR_L
        BNE         OP_BCLR_B
        
        OP_BCLR_L:
            MOVE.B #'B', (A0)+
            MOVE.B #'C', (A0)+
            MOVE.B #'L', (A0)+
            MOVE.B #'R', (A0)+
            MOVE.B #'.', (A0)+
            MOVE.B #'L', (A0)+ 
            *Set EA Case 1, op size long(2)
            MOVEQ #9, D2
            MOVEQ #2, D3           
            BRA         OP_Done_Decoding
        OP_BCLR_B:
            MOVE.B #'B', (A0)+
            MOVE.B #'C', (A0)+
            MOVE.B #'L', (A0)+
            MOVE.B #'R', (A0)+
            MOVE.B #'.', (A0)+
            MOVE.B #'B', (A0)+ 
            *Set EA Case 1, op size byte(1)
            MOVEQ #9, D2
            MOVEQ #1, D3
            BRA         OP_Done_Decoding
        
    OP_ORI:
        MOVE.B #'O', (A0)+
        MOVE.B #'R', (A0)+
        MOVE.B #'I', (A0)+
        MOVE.B #'.', (A0)+    OP_CMPI:    
        JSR         OP_0000_GetSize
        *Set EA Case 3, op size set by get size
        MOVEQ #3, D2
        BRA         OP_Done_Decoding
        
    OP_CMPI:
        MOVE.B #'C', (A0)+
        MOVE.B #'M', (A0)+
        MOVE.B #'P', (A0)+
        MOVE.B #'I', (A0)+
        MOVE.B #'.', (A0)+    OP_CMPI:    
        JSR         OP_0000_GetSize
        *Set EA Case 3, op size set by get size
        MOVEQ #3, D2
        BRA         OP_Done_Decoding
    

*MOVE.B
OP_Code0001:
    OP_MOVE_B:
         MOVE.B #'M', (A0)+
         MOVE.B #'O', (A0)+
         MOVE.B #'V', (A0)+
         MOVE.B #'E', (A0)+
         MOVE.B #'.', (A0)+
         MOVE.B #'B', (A0)+     
         *Set EA Case 1, op size byte(1)
         MOVEQ #1, D2
         MOVEQ #1, D3
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
         *Set EA Case 1, op size long(2)
         MOVEQ #1, D2
         MOVEQ #2, D3
         BRA         OP_Done_Decoding     
         
    OP_MOVE_L:
         MOVE.B #'M', (A0)+
         MOVE.B #'O', (A0)+
         MOVE.B #'V', (A0)+
         MOVE.B #'E', (A0)+
         MOVE.B #'.', (A0)+
         MOVE.B #'L', (A0)+ 
         *Set EA Case 1, op size long(2)
         MOVEQ #1, D2
         MOVEQ #2, D3
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
         *Set EA Case 1, op size word(3)
         MOVEQ #1, D2
         MOVEQ #3, D3
         BRA         OP_Done_Decoding     
         
    OP_MOVE_W:
         MOVE.B #'M', (A0)+
         MOVE.B #'O', (A0)+
         MOVE.B #'V', (A0)+
         MOVE.B #'E', (A0)+
         MOVE.B #'.', (A0)+
         MOVE.B #'W', (A0)+ 
         *Set EA Case 1, op size word(3)
         MOVEQ #1, D2
         MOVEQ #3, D3
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
        *Set EA Case 6, no size
        MOVEQ #6, D2
        MOVEQ #0, D3
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
            *Set EA Case 6, op size byte(1)
            MOVEQ #6, D2
            MOVEQ #1, D3
            BRA         OP_Done_Decoding
        OP_NEG_W:
            MOVE.B #'N', (A0)+
            MOVE.B #'E', (A0)+
            MOVE.B #'G', (A0)+
            MOVE.B #'.', (A0)+
            MOVE.B #'W', (A0)+    
            *Set EA Case 6, op size word(3)
            MOVEQ #6, D2
            MOVEQ #3, D3
            BRA         OP_Done_Decoding
        OP_NEG_L:
            MOVE.B #'N', (A0)+
            MOVE.B #'E', (A0)+
            MOVE.B #'G', (A0)+
            MOVE.B #'.', (A0)+
            MOVE.B #'L', (A0)+   
            *Set EA Case 6, op size long(2)
            MOVEQ #6, D2
            MOVEQ #2, D3
            BRA         OP_Done_Decoding
    
    OP_LEA:
        MOVE.B #'L', (A0)+
        MOVE.B #'E', (A0)+
        MOVE.B #'A', (A0)+  
        *Set EA Case 2, no size info (0 is default)
        MOVEQ #2, D2
        MOVEQ #0, D3
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
        *Set EA Case 4, op size byte(1)
        MOVEQ #4, D2
        MOVEQ #1, D3
        BRA         OP_Done_Decoding
    OP_SUBQ_W:
        JSR     OP_SUBQ
        MOVE.B #'W', (A0)+
        *Set EA Case 4, op size word(3)
        MOVEQ #4, D2
        MOVEQ #3, D3
        BRA         OP_Done_Decoding
    OP_SUBQ_L:
        JSR     OP_SUBQ
        MOVE.B #'L', (A0)+
        *Set EA Case 4, op size long(2)
        MOVEQ #4, D2
        MOVEQ #2, D3
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
        *Set EA Case 7, op size word(3)
        MOVEQ #7, D2
        MOVEQ #3, D3
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
        *Set EA Case 2, op size byte(1)
        MOVEQ #2, D2
        MOVEQ #1, D3
        BRA         OP_Done_Decoding 
    OP_OR_W_DestDn:
        JSR         OP_OR_W
        *Set EA Case 2, op size word(3)
        MOVEQ #2, D2
        MOVEQ #3, D3
        BRA         OP_Done_Decoding 
    OP_OR_L_DestDn:
        JSR         OP_OR_L
        *Set EA Case 2, op size long(2)
        MOVEQ #2, D2
        MOVEQ #2, D3
        BRA         OP_Done_Decoding 
    OP_OR_B_DestEA:
        JSR         OP_OR_B
        *Set EA Case 2, op size byte(1)
        MOVEQ #2, D2
        MOVEQ #1, D3
        BRA         OP_Done_Decoding 
    OP_OR_W_DestEA:
        JSR         OP_OR_W
        *Set EA Case 2, op size word(3)
        MOVEQ #2, D2
        MOVEQ #3, D3
        BRA         OP_Done_Decoding 
    OP_OR_L_DestEA:
        JSR         OP_OR_L
        *Set EA Case 2, op size long(2)
        MOVEQ #2, D2
        MOVEQ #1, D3
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
        *Set EA Case 2, op size byte(1)
        MOVEQ #2, D2
        MOVEQ #1, D3
        BRA         OP_Done_Decoding     
    OP_SUB_W_DestDn:
        JSR         OP_SUB_W
        *Set EA Case 2, op size word(3)
        MOVEQ #2, D2
        MOVEQ #3, D3
        BRA         OP_Done_Decoding
    OP_SUB_L_DestDn:
        JSR         OP_SUB_L
        *Set EA Case 2, op size long(2)
        MOVEQ #2, D2
        MOVEQ #1, D3
        BRA         OP_Done_Decoding
    OP_SUB_B_DestEA:
        JSR         OP_SUB_B
        *Set EA Case 2, op size byte(1)
        MOVEQ #2, D2
        MOVEQ #1, D3
        BRA         OP_Done_Decoding 
    OP_SUB_W_DestEA:
        JSR         OP_SUB_W
        *Set EA Case 2, op size word(3)
        MOVEQ #2, D2
        MOVEQ #3, D3
        BRA         OP_Done_Decoding
    OP_SUB_L_DestEA:
        JSR         OP_SUB_L
        *Set EA Case 2, op size long(2)
        MOVEQ #2, D2
        MOVEQ #1, D3
        BRA         OP_Done_Decoding

****NOT USED!!!
OP_Code1010:
    BRA         OP_NOT_FOUND_ERROR

*EOR.B, EOR.W, EOR.L, CMP.B, CMP.W, CMP.L
OP_Code1011:
    MOVE.W      D4,D1
    ANDI.W      #$01C0,D1
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
        *Set EA Case 2, op size byte(1)
        MOVEQ #2, D2
        MOVEQ #1, D3
        RTS
    OP_EOR_W:
        MOVE.B #'E', (A0)+
        MOVE.B #'O', (A0)+
        MOVE.B #'R', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'W', (A0)+
        *Set EA Case 2, op size word(3)
        MOVEQ #2, D2
        MOVEQ #3, D3
        RTS
    OP_EOR_L:
        MOVE.B #'E', (A0)+
        MOVE.B #'O', (A0)+
        MOVE.B #'R', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'L', (A0)+
        *Set EA Case 2, op size long(2)
        MOVEQ #2, D2
        MOVEQ #1, D3
        RTS
    
    OP_CMP_B:
        MOVE.B #'C', (A0)+
        MOVE.B #'M', (A0)+
        MOVE.B #'P', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'B', (A0)+
        *Set EA Case 2, op size byte(1)
        MOVEQ #2, D2
        MOVEQ #1, D3
        RTS    
    OP_CMP_W:
        MOVE.B #'C', (A0)+
        MOVE.B #'M', (A0)+
        MOVE.B #'P', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'W', (A0)+
        *Set EA Case 2, op size word(3)
        MOVEQ #2, D2
        MOVEQ #3, D3
        RTS  
    OP_CMP_L:
        MOVE.B #'C', (A0)+
        MOVE.B #'M', (A0)+
        MOVE.B #'P', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'L', (A0)+
        *Set EA Case 2, op size long(2)
        MOVEQ #2, D2
        MOVEQ #1, D3
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
        *Set EA Case 7, op size word(3)
        MOVEQ #7, D2
        MOVEQ #3, D3
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
        *Set EA Case 2, op size byte(1)
        MOVEQ #2, D2
        MOVEQ #1, D3
        BRA         OP_Done_Decoding     
    OP_ADD_W_DestDn:
        JSR         OP_ADD_W
        *Set EA Case 2, op size word(3)
        MOVEQ #2, D2
        MOVEQ #3, D3
        BRA         OP_Done_Decoding
    OP_ADD_L_DestDn:
        JSR         OP_ADD_L
        *Set EA Case 2, op size long(2)
        MOVEQ #2, D2
        MOVEQ #1, D3
        BRA         OP_Done_Decoding
    OP_ADD_B_DestEA:
        JSR         OP_ADD_B
        *Set EA Case 2, op size byte(1)
        MOVEQ #2, D2
        MOVEQ #1, D3
        BRA         OP_Done_Decoding 
    OP_ADD_W_DestEA:
        JSR         OP_ADD_W
        *Set EA Case 2, op size word(3)
        MOVEQ #2, D2
        MOVEQ #3, D3
        BRA         OP_Done_Decoding
    OP_ADD_L_DestEA:
        JSR         OP_ADD_L
        *Set EA Case 2, op size long(2)
        MOVEQ #2, D2
        MOVEQ #2, D3
        BRA         OP_Done_Decoding
        
     OP_ADDA_W:
        MOVE.B #'A', (A0)+
        MOVE.B #'D', (A0)+
        MOVE.B #'D', (A0)+
        MOVE.B #'A', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'W', (A0)+
        *Set EA Case 2, op size word(3)
        MOVEQ #5, D2
        MOVEQ #3, D3
        BRA         OP_Done_Decoding
    OP_ADDA_L:
        MOVE.B #'A', (A0)+
        MOVE.B #'D', (A0)+
        MOVE.B #'D', (A0)+
        MOVE.B #'A', (A0)+
        MOVE.B #'.', (A0)+
        MOVE.B #'L', (A0)+
        *Set EA Case 2, op size long(2)
        MOVEQ #5, D2
        MOVEQ #2, D3
        BRA         OP_Done_Decoding

*LSd.B*, LSd.W*, LSd.L*, ASd.B*, ASd.W*, ASd.L*, ROd.B*, ROd.W*, ROd.L*
OP_Code1110:
    *decide if LSd, ASd, or ROd
    *decide if memory shift 
    JSR         OP_1110_SizeMask
    MOVE.W      #$00C0,D2

    CMP.W       D1, D2

    BEQ         OP_1110_MemoryShifts
    BNE         OP_1110_RegisterShifts
    
OP_1110_RegisterShifts:
    *first check if LSd
    JSR         OP_1110_RegisterShiftMask   
    MOVE.W      #$0008,D2
    CMP.W       D2,D1
    BEQ         OP_LSd
    *Now check if ASd
    JSR         OP_1110_RegisterShiftMask     
    MOVE.W      #$0000,D2
    CMP.W       D2,D1
    BEQ         OP_ASd
    *Finally check if ROd
    JSR         OP_1110_RegisterShiftMask 
    MOVE.W      #$0018,D2
    CMP.W       D2,D1
    BEQ         OP_ROd
    *error
    BNE         OP_NOT_FOUND_ERROR 
    
OP_1110_MemoryShifts:  
    *LSd memory shift
    JSR         OP_1110_MemoryShiftMask
    MOVE.W      #$0200,D2
    CMP.W       D2,D1
    BEQ         OP_LSd
    *Check if ASd memory shift
    JSR         OP_1110_MemoryShiftMask
    MOVE.W      #$0000,D2
    CMP.W       D2,D1
    BEQ         OP_ASd 
    *check if memory shift
    JSR         OP_1110_MemoryShiftMask
    MOVE.W      #$0600,D2
    CMP.W       D2,D1
    BEQ         OP_ROd  
    *error
    BNE         OP_NOT_FOUND_ERROR
    
    OP_1110_RegisterShiftMask:
        MOVE.W      D4,D1
        ANDI.W      #$0018,D1
        RTS
    OP_1110_MemoryShiftMask:
        MOVE.W      D4,D1
        ANDI.W      #$0E00,D1
        RTS 
    OP_1110_SizeMask:
        MOVE.W      D4,D1
        ANDI.W      #$00C0,D1
        RTS    
    
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
        JSR         OP_1110_SizeMask
        MOVE.W      #$0000, D2
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
        * Memory shift only case not detailed, will always be word
        BNE         OP_1110_Word
        
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
* _______  _______  _______    _______  ______   ______   ______   
*|       ||       ||       |  |   _   ||      | |      | |    _ |  
*|    ___||    ___||    ___|  |  |_|  ||  _    ||  _    ||   | ||  
*|   |___ |   |___ |   |___   |       || | |   || | |   ||   |_||_ 
*|    ___||    ___||    ___|  |       || |_|   || |_|   ||    __  |
*|   |___ |   |    |   |      |   _   ||       ||       ||   |  | |
*|_______||___|    |___|      |__| |__||______| |______| |___|  |_|


***************************** Main Method for EA
* D2 = EA Case Code
* D3 = Size of Operation
EA_DECODE:
    * To save d reg space, move: 
    *       EA_Case into (A3)
    *       EA_Size into (A4)
    LEA EA_CASE, A3
    LEA EA_SIZE, A4
    MOVE.B D2, (A3)
    MOVE.B D3, (A4)

    * IF case == 1:
    CMP.B #1, (A3)
    BEQ     EA_DECODE_BranchCase1
    * If case == 2:
    CMP.B #2, (A3)
    BEQ     EA_DECODE_BranchCase2
    * if case == 4:
    CMP.B #4, (A3)
    BEQ     EA_DECODE_BranchCase4
    * if case == 5
    CMP.B #5, (A3)
    BEQ     EA_DECODE_BranchCase5
    * if case == 6
    CMP.B #6, (A3)
    BEQ     EA_DECODE_BranchCase6

    * IF CAse is anything else
    BRA EA_DECODE_UnsupportedCase

    EA_DECODE_BranchCase1:
        JSR EA_DECODE_CASE1
        BRA EA_DECODE_EndIf
    EA_DECODE_BranchCase2:
        JSR EA_DECODE_CASE2
        BRA EA_DECODE_EndIf
    EA_DECODE_BranchCase4:
    	JSR EA_DECODE_CASE4
        BRA EA_DECODE_EndIf
    EA_DECODE_BranchCase5:
        JSR EA_DECODE_CASE5
        BRA EA_DECODE_EndIf
    EA_DECODE_BranchCase6:
        JSR EA_DECODE_CASE6
        BRA EA_DECODE_EndIf
    EA_DECODE_UnsupportedCase:
        MOVE.B #$4E, (A0)+ * 'N'
        MOVE.B #$4F, (A0)+ * 'O'
        MOVE.B #$20, (A0)+ * ' '
        MOVE.B #$45, (A0)+ * 'E'
        MOVE.B #$41, (A0)+ * 'A'
        MOVE.B #$20, (A0)+ * ' '
        MOVE.B (A3), D2
        MOVE.L #1, D3
        JSR IO_HEX2ASCII

        BRA EA_DECODE_EndIf
    EA_DECODE_EndIf:
    RTS


***** Case 1 includes:
*       MOVE, MOVEA
EA_DECODE_CASE1:
    MOVEM.L PARAMS, -(A7)
    * get source mode ===============
    MOVE.L #$00000003, D6 * shift
    MOVE.L #$00000003, D7 * keep
    JSR EA_ShiftAndMask
    MOVE.L D2, D5

    * get source register
    MOVE.L #$00000000, D6 * shift
    MOVE.L #$00000003, D7 * keep
    JSR EA_ShiftAndMask
    
    MOVE.L D5, D6
    MOVE.L D2, D7

    * HandleOperand(src=d6, reg=d7)
    JSR EA_HandleOperand

    JSR EA_PrintCommaSpace

    * Get dest mode =================
    MOVE.L #$00000006, D6 * shift
    MOVE.L #$00000003, D7 * keep
    JSR EA_ShiftAndMask
    MOVE.L D2, D5

    * get dest register 
    MOVE.L #$00000009, D6 * shift
    MOVE.L #$00000003, D7 * keep
    JSR EA_ShiftAndMask

    MOVE.L D5, D6
    MOVE.L D2, D7
    JSR EA_HandleOperand

    MOVEM.L (A7)+, PARAMS
    RTS

***** Case 2 includes:
EA_DECODE_CASE2:
    MOVEM.L PARAMS, -(A7)
    * D3 Stores OpMode
    * D5 Stores Register
    * D6 Stores EA Mode
    * D7 Store EA Register

    *Retrieve register bits
    MOVEM.L PARAMS, -(A7)  * scope -->
    MOVE.L #$00000009, D6   * shift
    MOVE.L #$00000003, D7   * keep
    JSR EA_ShiftAndMask
    MOVEM.L (A7)+, PARAMS  * end scope <--
    MOVE.L D2, D5

    *Retrieve EA Mode
    MOVEM.L PARAMS, -(A7)  * scope -->
    MOVE.L #$00000003, D6   * shift
    MOVE.L #$00000003, D7   * keep
    JSR EA_ShiftAndMask
    MOVEM.L (A7)+, PARAMS  * end scope <--
    MOVE.L D2, D6

    *Retrieve EA register
    MOVEM.L PARAMS, -(A7)  * scope -->
    MOVE.B #$00000000, D6   * shift
    MOVE.B #$00000003, D7   * keep
    JSR EA_ShiftAndMask
    MOVEM.L (A7)+, PARAMS  * end scope <--
    MOVE.L D2, D7

    *Retrieve OpMode
    MOVEM.L PARAMS, -(A7)  * scope -->
    MOVE.L #00000006, D6   * shift
    MOVE.L #00000003, D7   * keep
    JSR EA_ShiftAndMask
    MOVEM.L (A7)+, PARAMS  * end scope <--
    MOVE.L D2, D3

    * Opmode --> D3
    * if op mode >= 4, --> Dn + <EA>

    CMPI.B #4, D3
    BGE EA_DECODE_CASE2_IfDnEa
    BRA EA_DECODE_CASE2_IfEaDn

    EA_DECODE_CASE2_IfDnEa:
        MOVEM.L PARAMS, -(A7)  * scope -->
        MOVE.B D5, D7
        JSR EA_DirectData
        MOVEM.L (A7)+, PARAMS  * end scope <--

        JSR EA_PrintCommaSpace
        JSR EA_HandleOperand
        BRA EA_DECODE_CASE2_IfEnd

    EA_DECODE_CASE2_IfEaDn:
        JSR EA_HandleOperand
        JSR EA_PrintCommaSpace

        MOVEM.L PARAMS, -(A7)  * scope -->
        MOVE.B D5, D7
        JSR EA_DirectData
        MOVEM.L (A7)+, PARAMS  * end scope <--
        BRA EA_DECODE_CASE2_IfEnd
    EA_DECODE_CASE2_IfEnd:
    
    MOVEM.L (A7)+, PARAMS
    RTS

EA_DECODE_CASE4:
    MOVEM.L PARAMS, -(A7)

    * data is 9 shift, 3 keep.
    MOVE.L #$9, D6
    MOVE.L #$3, D7
    JSR EA_ShiftAndMask

    * if data is 0, it is really 8
    CMP.B #0, D2
    BNE EA_DECODE_CASE4_NoTransform
    MOVE.B #8, D2

    EA_DECODE_CASE4_NoTransform:
    MOVE.B #'#', (A0)+
    MOVE.B #'$', (A0)+
    * data is in D2 already.
    MOVE.L #1, D3
    JSR IO_HEX2ASCII

    JSR EA_PrintCommaSpace

    * EA Mode is 3 shift, 3 keep.
    MOVE.L #3, D6
    MOVE.L #3, D7
    JSR EA_ShiftAndMask
    MOVE.L D2, D3 		* temp store D3

    * EA Register is 0 shift, 3 keep.
    MOVE.L #0, D6
    MOVE.L #3, D7
    JSR EA_ShiftAndMask

    * call handle operand
    MOVE.L D3, D6
    MOVE.L D2, D7
    JSR EA_HandleOperand

    MOVEM.L (A7)+, PARAMS
    RTS

EA_DECODE_CASE5:
    MOVEM.L PARAMS, -(A7)

    * set the size

    * EA Mode is 3 shift, 3 keep.
    MOVE.L #3, D6
    MOVE.L #3, D7
    JSR EA_ShiftAndMask
    MOVE.L D2, D3       * temp store D3

    * EA Register is 0 shift, 3 keep.
    MOVE.L #0, D6
    MOVE.L #3, D7
    JSR EA_ShiftAndMask

    MOVE.L D3, D6
    MOVE.L D2, D7
    JSR EA_HandleOperand

    JSR EA_PrintCommaSpace

    * Address Register is 9 shift, 3 keep.
    MOVE.L #9, D6
    MOVE.L #3, D7
    JSR EA_ShiftAndMask

    MOVE.L D2, D7
    JSR EA_DirectAddress
    
    MOVEM.L (A7)+, PARAMS
    RTS

EA_DECODE_CASE6:
    MOVEM.L PARAMS, -(A7)
    
    * Mode is 3 shift, 3 keep
    MOVE.L  #3, D6
    MOVE.L  #3, D7
    JSR EA_ShiftAndMask
    MOVE.L  D2, D3   *temp store D3
    
    *Register is 0 shift, 3 keep
    MOVE.L  #0, D6
    MOVE.L  #3, D7
    JSR EA_ShiftAndMask
    
    *call handle operand
    MOVE.L  D3, D6
    MOVE.L  D2, D7
    JSR EA_HandleOperand
    
    MOVEM.L (A7)+, PARAMS
    RTS


* Mode = D6
* Register = D7
EA_HandleOperand:
    MOVEM.L PARAMS, -(A7)

    *if mode == 0 --> directData
    CMP.B #0, D6
    BEQ EA_HandleOperand_IfDirectData

    *elif mode == 1 --> direct address
    CMP.B #1, D6
    BEQ EA_HandleOperand_IfDirectAddress

    *elif mode == 2 --> indirect address
    CMP.B #2, D6
    BEQ EA_HandleOperand_IfIndirectAddr

    *elif mode == 3 --> post dec address
    CMP.B #3, D6
    BEQ EA_HandleOperand_IfPostDec

    *elif mode == 4 --> pre dec address
    CMP.B #4, D6
    BEQ EA_HandleOperand_IfPreDec

    *elif mode == 7 --> immediate data
    CMP.B #7, D6
    BEQ EA_HandleOperand_ifImmMode

    BRA EA_HandleOperand_IfElse     * Not any of the supported modes, error.

    EA_HandleOperand_IfDirectData:
        JSR EA_DirectData
        BRA EA_HandleOperand_IfEnd
    EA_HandleOperand_IfDirectAddress:
        JSR EA_DirectAddress
        BRA EA_HandleOperand_IfEnd
    EA_HandleOperand_IfIndirectAddr:
        JSR EA_IndirectAddress
        BRA EA_HandleOperand_IfEnd
    EA_HandleOperand_IfPostDec:
        JSR EA_PostDecAddress
        BRA EA_HandleOperand_IfEnd
    EA_HandleOperand_IfPreDec:
        JSR EA_PreDecAddress
        BRA EA_HandleOperand_IfEnd
    EA_HandleOperand_IfElse:
    * TODO ERROR HANDLING HERE -----------
        BRA EA_HandleOperand_IfEnd
    EA_HandleOperand_ifImmMode:
    	* check the register
    	* if reg == 0 --> (xxx).W
    	CMP.B 	#0, D7
    	BEQ 	EA_HandleOperand_IfWordAddr
    	* if reg == 1 --> (xxx).L
    	CMP.B 	#1, D7
    	BEQ		EA_HandleOperand_IfLongWordAddr
    	* if reg == 4 --> #data
    	CMP.B #4, D7
    	BEQ 	EA_HandleOperand_IfImmData
    	BRA EA_HandleOperand_IfElse
    EA_HandleOperand_IfWordAddr:
    	JSR EA_WordAddr
    	BRA EA_HandleOperand_IfElse
    EA_HandleOperand_IfLongWordAddr:
    	JSR EA_LongWordAddr
    	BRA EA_HandleOperand_IfElse
    EA_HandleOperand_IfImmData:
    	JSR EA_ImmData 
    	BRA EA_HandleOperand_IfElse
    EA_HandleOperand_IfEnd:

    MOVEM.L (A7)+, PARAMS
    RTS

* register # = D7
EA_DirectData:
    MOVEM.L PARAMS, -(A7)

    MOVE.B #$44, (A0)+      * Data (D)
    *Print the register #
    MOVE.L D7, D2
    MOVE.L #$00000001, D3
    JSR IO_HEX2ASCII

    MOVEM.L (A7)+, PARAMS
    RTS

* register # = D7
EA_DirectAddress:
    MOVEM.L PARAMS, -(A7)
    MOVE.B #$41, (A0)+      * Address (A)
    *Print the register #
    MOVE.L D7, D2
    MOVE.L #$00000001, D3
    JSR IO_HEX2ASCII

    MOVEM.L (A7)+, PARAMS
    RTS

* register # = D7
EA_IndirectAddress:
    MOVEM.L PARAMS, -(A7)

    MOVE.B #$28, (A0)+      * '('
    JSR EA_DirectAddress
    MOVE.B #$29, (A0)+      * ')'

    MOVEM.L (A7)+, PARAMS
    RTS

* register # = D7
EA_PostDecAddress:
    MOVEM.L PARAMS, -(A7)

    JSR EA_IndirectAddress
    MOVE.B #$2B, (A0)+      * '+'

    MOVEM.L (A7)+, PARAMS
    RTS

* register # = D7
EA_PreDecAddress:
    MOVEM.L PARAMS, -(A7)

    MOVE.B #$2D, (A0)+      * '-'
    JSR EA_IndirectAddress

    MOVEM.L (A7)+, PARAMS
    RTS

* no arguments
EA_WordAddr:
	MOVEM.L PARAMS, -(A7)

	MOVE.L #1, D6
	JSR EA_GetData 					* returned in D2

	MOVE.B #$24, (A0)+ 		* '$'
	MOVE.L #$4, D3
	* Data is in D2 already
	JSR IO_HEX2ASCII 		* '<addr>'

	MOVEM.L (A7)+, PARAMS
	RTS

EA_LongWordAddr:
	MOVEM.L PARAMS, -(A7)

	MOVE.L #2, D6
	JSR EA_GetData 					* returned in D2

	MOVE.B #$24, (A0)+ 		* '$'
	MOVE.L #$8, D3
	* Data is in D2 already
	JSR IO_HEX2ASCII 		* '<addr>'

	MOVEM.L (A7)+, PARAMS
	RTS

* size of operation is (A4)
EA_ImmData:
	MOVEM.L PARAMS, -(A7)

	* if size == 1 --> byte
	CMP.B #$1, (A4)
	BEQ EA_ImmData_IfByte
	* elif size == 3 --> word
	CMP.B #$3, (A4)
	BEQ EA_ImmData_IfWord
	* elif size ==2 --> long
	CMP.B #$2, (A4)
	BEQ EA_ImmData_IfLongWord

	BRA EA_ImmData_IfEnd

	EA_ImmData_IfByte:
		MOVE.B #$1, D6
		JSR EA_GetData
		MOVE.B #$2, D3
		BRA EA_ImmData_IfEnd
	EA_ImmData_IfWord:
		MOVE.B #$1, D6
		JSR EA_GetData
		MOVE.B #$4, D3
		BRA EA_ImmData_IfEnd
	EA_ImmData_IfLongWord:
		MOVE.B #$2, D6
		JSR EA_GetData
		MOVE.B #$8, D3
		BRA EA_ImmData_IfEnd
	EA_ImmData_IfEnd:

	MOVE.B #$23, (A0)+ 		* '#'
	MOVE.B #$24, (A0)+ 		* '$'
	JSR IO_HEX2ASCII

	MOVEM.L (A7)+, PARAMS
	RTS


* D6 = # of words to read, must be 1 or 2
EA_GetData:
	MOVEM.L PARAMS, -(A7)
	*ADD.L #$2, A6
	CLR.L D2
	EA_GetData_Loop:
	CMPI.B #0, D6
	BLE EA_GetData_LoopDone
		MOVE.L #16, D0
		LSL.L D0, D2
		ADD.W (A6)+, D2
		
		SUBQ.B #1, D6
		BRA EA_GetData_Loop
	EA_GetData_LoopDone:

	MOVEM.L (A7)+, PARAMS
	RTS


* D4 = shift & mask data (LW)
* D6 = Shift right amount (LW)
* D7 = # of bits wanted (LW)
* Return in D2 (LW)
EA_ShiftAndMask:
    MOVEM.L PARAMS, -(A7)
    CLR.L   D2
    LSR.L   D6, D4
    * build masking data
    CLR.L D1                * D1 = #$0000 0000
    * for D7 > 0
    EA_ShiftAndMask_ForLoop:
        CMP.B   #0, D7
        BLE EA_ShiftAndMask_ForLoopDone

        LSL.L   #1, D1
        ADD.L   #%00000000000000000000000000000001, D1
        SUBQ.L  #1, D7      * Decrement loop
        BRA EA_ShiftAndMask_ForLoop
    EA_ShiftAndMask_ForLoopDone:
    AND.L   D1, D4
    MOVE.L  D4, D2

    MOVEM.L (A7)+, PARAMS
    RTS

EA_PrintCommaSpace:
    *Print comma & space.
    MOVE.B #$2C, (A0)+
    MOVE.B #$20, (A0)+
    RTS
* ============================ END EA_ShiftAndMask

*===============================================================================================* GLOBAL VARIABLE BLOCK


**GLOBAL VARIABLE BLOCK**
IO_STARTADDR    DS.L    1
IO_ENDADDR      DS.L    1
OP_CODE         DS.B    10
OP_CODE_UNKNWN  DS.B    1

EA_CASE         DS.B    1
EA_SIZE         DS.B    1




    END    START        ; last line of source










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
