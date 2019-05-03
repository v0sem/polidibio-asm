all: CLEAR P4A.EXE P4B.EXE

P4B.EXE: P4B.OBJ
    tlink /v P4B
P4B.OBJ: p4b.asm
    tasm /zi p4b.asm

P4A.EXE: P4A.OBJ
    tlink /tv P4A
P4A.OBJ: p4a.asm
    tasm /zi p4a.asm

CLEAR:
    DEL P4B.OBJ
    DEL P4B.EXE
    DEL P4A.OBJ
    DEL P4A.COM