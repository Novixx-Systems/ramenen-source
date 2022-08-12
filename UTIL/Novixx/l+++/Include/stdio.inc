#
STDIO for L+++
16-Bit

STANDARD INPUT/OUTPUT

Copyright 2022 Novixx Systems.
;

#
GLOBAL VARIABLES

These should not be used as variable names in other
scripts.
;

VAR OUT16_TEMP_BUFFER == 0;

#
OUT16 is a function for outputting text
in binary/DOS mode.

IN --- SI = Text to output (ASCIZ).
OUT -- Nothing
;
DEF OUT16();
	SET AH = 0EH;
	DEF OUT16_PRINT_REPEATE();
		ASM *LODSB*;
		IF AL = 0;
			RETURN;
		FI;
		INT(16);
		GOTO OUT16_PRINT_REPEATE;


#
SCAN16 is a function for getting input
in binary/DOS mode.

IN --- AX = Location of destination string.
OUT -- AL = Last key pressed.
;
DEF SCAN16();
	ASM *PUSHA*;

	SET DI = AX;
	SET CX = 0;


	DEF SCAN16_GET_KEY_REPEAT();	
		WAIT;

		IF AL = 13;
			GOTO SCAN16_D_DONE;
		FI;
		IF AL = 8;
			GOTO SCAN16_BS_BACKSPACE;
		FI;

		ASM *CMP AL, ' '*;
		ASM *JB SCAN16_GET_KEY_REPEAT*;

		ASM *CMP AL, '~'*;
		ASM *JA SCAN16_GET_KEY_REPEAT*;

		GOTO SCAN_16_BS_NOBACKSPACE;


	DEF SCAN16_BS_BACKSPACE();
		IF CX = 0;	
			GOTO SCAN16_GET_KEY_REPEAT;
		FI;
		ASM *PUSHA*;
		ASM *MOV AH, 0EH*;	
		ASM *MOV AL, 8*;
		INT(10H);
		ASM *MOV AL, 32*;
		ASM *INT 10H*;
		ASM *MOV AL, 8*;
		INT(10H);
		ASM *POPA*;

		DI--;	
				

		CX--;	

		GOTO SCAN16_GET_KEY_REPEAT;


	DEF SCAN_16_BS_NOBACKSPACE();
		ASM *PUSHA*;
		SET AH = 0EH;
		INT(10H);
		ASM *POPA*;

		ASM *STOSB*;
		CX++;
		ASM *CMP CX, 250*;
		ASM *JAE NEAR SCAN16_D_DONE*;

		GOTO SCAN16_GET_KEY_REPEAT;


	DEF SCAN16_D_DONE();
		ADD AX;
		ASM *XOR AX, AX*;
		ASM *STOSW*;

		ASM *POPA*;
		
		GET AX;
		RETURN;
