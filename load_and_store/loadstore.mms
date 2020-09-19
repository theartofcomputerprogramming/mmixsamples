// loadstore.mms
// examples of load and store instructions

// comment line can start with any non-alphanumeric character
// but don't use semicolon or poundsign to start a comment line
// there is no multiline comment block
// trailing part of line after statement is ignored
// so comments may be added following a space after a statement

// program is loaded at address 0x0 by default
// registers have $ prefix
// hex values have # prefix
// generally everything is case-sensitive

// assembler storage directives
// tell assembler to place this data in memory

// address 0x0:
           BYTE #12

// address 0x1:
// high bit set
           BYTE #83

// address 0x2:
// high bit set
           BYTE #a7

// address 0x4:
// address 0x3 skipped for 2-byte alignment
           WYDE #8765

// address 0x8: 87 65 43 21
// addresses 0x6 - 0x7 skipped for 4-byte alignment
           TETRA #87654321

// address 0x10: fe dc ba 98 76 54 32 10
// addresses 0xc - 0xf skipped for 8-byte alignment
           OCTA #fedcba9876543210

// Data_Segment address needed to demonstrate store instructions
// address 0x18: 0x2000 0000 0000 0000
           OCTA #2000000000000000

// now the code

// $0 is argc
// $1 is argv, 0x4000 0000 0000 0008, second octa of Pool_Segment
// $255 first GREG is numeric code for Main (offset of Main)
// $2, $3 like pretty much all other registers are zero at start

// instructions are 4 bytes
// no spaces after commas

// load bytes

// address 0x20:
// instruction 0:
// use $2 as base address, $3 as offset
// symbol Main is required
Main       LDB $4,$2,$3 // trailing comment: program starts at Main

// address 0x24:
// instruction 1:
// third operand is immediate instead of register
// loads same byte as instruction 0
           LDB $5,$2,#0

// instruction 2:
// sign extension
           LDB $6,$2,#1

// instruction 3:
// unsigned load, no sign extension
           LDBU $7,$2,#2

// load wydes

// instruction 4:
           LDW $8,$2,#0

// instruction 5:
// different address but loads same wyde as previous instruction
           LDW $9,$2,#1

// instruction 6:
// sign extension
           LDW $10,$2,#2

// instruction 7:
// different address into same wyde as above
// no sign extension for unsigned load
           LDWU $11,$2,#3

// load tetras

// instruction 8:
// sign extension
           LDT $12,$2,#8

// instruction 9:
// different address into same tetra as before, also sign extension
           LDT $13,$2,#a

// instruction 10:
// unsigned load of same tetra as before, no sign extension
           LDTU $14,$2,#b

// instruction 11:
// load high tetra, loads tetra into upper half of register
// useful to detect overflow in arithmetic with tetras
           LDHT $15,$2,#8

// load octas

// instruction 12:
// no sign extension possible when loading octa
           LDO $16,$2,#10

// instruction 13:
// different address into same octa as above
           LDO $17,$2,#17

// instruction 14:
// unsigned load of same octa addressed in middle
           LDOU $18,$2,#14

// instruction 15:
// load Data_Segment address where data can be written: 0x2000 0000 0000 0000
           LDOU $3,#0018

// instruction 16:
// form new address from base and offset
           LDA $19,$3,#20

// use $3 as base address for store instructions
// writable data storage starts at Data_Segment 0x2000 0000 0000 0000
// now store values to memory that were previously loaded into registers

// store bytes

// instruction 17:
           STB $4,$3,#0

// instruction 18:
           STB $5,$3,#1

// instruction 19:
// no integer overflow, $6 is 0x...ff83 = -125 is in byte range -128..127
           STB $6,$3,#2

// instruction 20:
// this causes overflow because $9 is 0x1283, obviously greater than 127
// sets rA overflow bit 0x40
           STB $9,$3,#3

// instruction 21:
// clear arithmetic status register rA
           PUT rA,#0

// instruction 22:
// unsigned store never overflows
           STBU $12,$3,#4

// instruction 23:
// sets rA overflow bit again
           STB $10,$3,#5

// instruction 24:
// clear arithmetic status register rA
           PUT rA,#0

// store wydes

// instruction 25:
// no overflow, $6 has 0x...ff83 = -125 in wyde range -32768..32767
           STW $6,$3,#6

// instruction 26:
// overflow
           STW $12,$3,#9

// instruction 27:
// clear arithmetic status register rA
           PUT rA,#0

// instruction 28:
// unsigned store, no overflow
           STWU $13,$3,#b

// store tetras

// instruction 29:
// overflow
           STT $15,$3,#c

// instruction 30:
// clear arithmetic status register rA
           PUT rA,#0

// instruction 31:
// unsigned tetra store, no overflow
           STTU $16,$3,#10

// store octas

// instruction 32:
// no overflow for signed or unsigned octa stores
           STO $16,$19,#0

// instruction 33:
// no overflow for signed or unsigned octa stores
           STOU $16,$19,#a

// instruction 34:
// store 1-byte constant into octa
           STCO #ff,$19,#11

// instruction 35:
// store high tetra into octa
           STHT $15,$19,#18

// program exit
           TRAP 0,Halt,0
