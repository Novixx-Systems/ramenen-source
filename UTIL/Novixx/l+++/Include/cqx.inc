#
CQX for L+++
16-Bit

CQX96 API FUNCTIONS

Copyright 2022 Novixx Systems (GoombaProgrammer).
;

#
GLOBAL VARIABLES

These should not be used as variable names in other
scripts.
;

VAR CQX_COMPARE_EQUAL == 0;

#
PRINTSTRING is a function for outputting text
in CQX96 mode.

IN --- SI = Text to output (ASCIZ).
OUT -- Nothing
;
DEF PRINTSTRING();
	3();
	RETURN;


#
GETINPUT is a function for getting input
in CQX96 mode.

IN --- AX = Location of destination string, BX = max chars
OUT -- Nothing
;
DEF GETINPUT();
	0012h();
	RETURN;


#
LOADFILE is a function for loading a file
in CQX96 mode.

IN --- AX = File name, CX = location to load file in
OUT -- BX = Size of file
;
DEF LOADFILE();
	0021h();
	RETURN;


#
COMPARE is a function for comparing bytes
in CQX96 mode.

IN --- SI = string 1, DI = string 2
OUT -- BX = Size of file
;
DEF COMPARE();
	0033h();
	ASM *JC CQX_COMPARE_SAME*;
	SET BYTE[CQX_COMPARE_EQUAL] = 0;
	RETURN;
	DEF CQX_COMPARE_SAME();
		SET BYTE[CQX_COMPARE_EQUAL] = 1;
		RETURN;
