#
STRTOOL for L+++
16-Bit

STRING TOOLS

Copyright 2022 Novixx Systems.
;

#
GLOBAL VARIABLES

These should not be used as variable names in other
scripts.
;

VAR COMPARE_EQUAL == 0;

#
STRCOPY16 is a function for copying bytes from
one variable to another in binary/DOS mode.

IN --- SI = Source, DI = Destination.
OUT -- DI = Destination
;
DEF STRCOPY16();
	ASM *PUSHA*;

DEF STRCOPY16_GET_MORE();
	SET AL = [SI];
	SET [DI] = AL;
	SI++;
	DI++;
	IF AL = 0;
		GOTO STRCOPY16_IS_DONE;
	FI;
	GOTO STRCOPY16_GET_MORE;

DEF STRCOPY16_IS_DONE();
	ASM *POPA*;
	RETURN;

#
STRCOMP16 is a function for comparing bytes with
one variable and another in binary/DOS mode.

IN --- SI = String 1, DI = String 2.
OUT -- Variable COMPARE_EQUAL is 1 if same, 0 if different
;
DEF STRCOMP16();
	ASM *PUSHA*;

	DEF STRCOMP16_GET_MORE();
		SET AL = [SI];
		SET BL = [DI];
		#
			XIF is like assembly's CMP.
			Use THEN-GO if EQUAL and ELSE-GO if NOT EQUAL.
		;
		XIF AL = BL;
			
		ELSE-GO STRCOMP16_NOT_SAME;

		IF AL = 0;
			GOTO STRCOMP16_T_MNT;
		FI;

		SI++;
		DI++;
		GOTO STRCOMP16_GET_MORE;


	DEF STRCOMP16_NOT_SAME();
		ASM *POPA*;
		SET BYTE[COMPARE_EQUAL] = 0;
		RETURN;


	DEF STRCOMP16_T_MNT();
		ASM *POPA*;
		SET BYTE[COMPARE_EQUAL] = 1;
		RETURN;
