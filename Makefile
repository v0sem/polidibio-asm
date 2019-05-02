all: CLEAR P4B.EXE

P4B.EXE: P4B.OBJ
    tlink /v P4B
P4B.OBJ: p4b.asm
    tasm /zi p4b.asm

WK.EXE: WK.OBJ
    tlink /t WK
WK.OBJ: working_functions.asm
    tasm /zi working_functions.asm

CLEAR:
    DEL P4B.OBJ
    DEL P4B.EXE