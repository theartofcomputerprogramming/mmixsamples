// arithmetic.mms
// examples of arithmetic operators

// to aid section Arithmetic operators in 1.3.1', Description of MMIX
// from Chapter 1, Basic Concepts, of Fascicle 1, MMIX, by Donald Knuth

// comment line can start with any non-alphannumeric character
// but avoid using semicolon, poundsign or whitespace to start a comment line
// there is no multiline comment block
// trailing part of line after statement is ignored
// so comments may be added following a space after a statement

// program is loaded at address 0x0 by default
// registers have $ prefix
// hex values have # prefix
// generally everything is case-sensitive

// place some int32_t in memory

// address 0x0:
           TETRA 3

// address 0x4:
           TETRA 7

// address 0x8:
// -5 = ffff fffb
           TETRA #fffffffb

// place some int64_t in memory

// address 0x10:
// largest signed number 2^63 - 1: 7fff ffff ffff ffff
           OCTA #7fffffffffffffff

// address 0x18:
// smallest signed number -2^63: 8000 0000 0000 0000
           OCTA #8000000000000000

// a uint64_t

// address 0x20:
// largest unsigned number 2^64 - 1: ffff ffff ffff ffff
           OCTA #ffffffffffffffff

// now the code

// $0 is argc
// $1 is address of argv, 0x4000 0000 0000 0008, second octa of Pool_Segment
// $255 first GREG is numeric code for Main (offset of Main)
// registers $2 $3 ... $254 are zero at start

// this program can be run in the debugger without a commandline
// $0=argc will be zero in this case
// $1=argv will have an address of an empty array of strings

// instructions are 4 bytes
// no spaces after commas

// address 0x20:
// instruction 0:
// symbol Main is required
// $3 = 3
Main       LDT $3,$2,#0

// instruction 1:
// $4 = 7
           LDT $4,$2,#4

// instruction 2:
// $5 = -5 = ffff ffff ffff fffb
           LDT $5,$2,#8

// instruction 3:
// $6 = 2^63 - 1 = 7fff ffff ffff ffff
           LDO $6,$2,#10

// instruction 4:
// $7 = -2^63 = 8000 0000 0000 0000
           LDO $7,$2,#18

// instruction 5:
// $8 = 2^64 - 1 = ffff ffff ffff ffff
           LDOU $8,$2,#20

// arithmetic operators

// instruction 6:
// $9 = 3 + 7 = 10
           ADD $9,$3,$4

// instruction 7:
// $10 = 3 + -5 = -2
           ADD $10,$3,$5

// instruction 8:
// overflow
// $13 = (2^63 - 1) + 1 = -2^63
// rA = 0x40
           ADD $11,$6,1

// instruction 9:
// clear arithmetic status register rA
           PUT rA,0

// instruction 10:
// immediates are unsigned bytes
// $12 = 3 + 255 = 258
           ADD $12,$3,#ff

// instruction 11:
// $13 = 3 - 7 = -4
           SUB $13,$3,$4

// instruction 12:
// $14 = 3 - 1 = 2
           SUB $14,$3,1

// instruction 13:
// $15 = 3 * -5 = -15
           MUL $15,$3,$5

// instruction 14:
// overflow
// $16 = (2^63 - 1) * 2 = -2
// rA = 0x40
           MUL $16,$6,2

// instruction 15:
// clear arithmetic status register rA
           PUT rA,0

// instruction 16:
// rR remainder register
// $17 = 7 / -5 = floor(-1.4) = -2
// rR = -3
           DIV $17,$4,$5

// instruction 17:
// transfer value from rR to general register
// $18 = -3
           GET $18,rR

// instruction 18:
// divide by zero sets rA integer divide check bit
// $19 = 3 / 0 = 0
// rR = 3
// rA = 0x80
           DIV $19,$3,0

// instruction 19:
// clear arithmetic status register rA
           PUT rA,0

// instruction 20:
// treat -5 as unsigned
// $20 = 7 + ...ffff fffb = 0111 + ...1111 1011 = ...0000 0010 = 2
           ADDU $20,$4,$5

// instruction 21:
// $21 = 3 - 7 = ...ffff fffc
           SUBU $21,$3,$4

// instruction 22:
// treat -5 as unsigned
// sets rH  himult register
// $22 = 3 * -5u = low 8 bytes of product
// rH = high 8 bytes of product = 2
           MULU $22,$3,$5

// instruction 23:
// treat -5 as unsigned
// $23 = -5u / 3 = 0x5555 5555 5555 5553
// rR = 2 
           DIVU $23,$5,$3

// instruction 24:
// prepare 16-byte dividend from previous himult
// rD = 2
           PUT rD,2

// instruction 25:
// form 16-byte dividend from previous himult
// rD = 2
// $24 = $22 / 3 = -5u
           DIVU $24,$22,$3

// instruction 26:
// clear high dividend register
           PUT rD,0

// TODO
           2ADDU $25,$4,$4

           4ADDU $26,$3,1

           8ADDU $27,$3,1

           16ADDU $28,$3,1

           NEG $29,1,$5

           NEG $30,$5

           NEGU $31,4,$3

           NEGU $32,$3

           SL $33,$4,$3

           SLU $34,$4,$3

           SR $35,$4,$3

           SRU $36,$4,$3

           CMP $37,$3,$4

           CMPU $38,$3,$5

// program exit
           TRAP 0,Halt,0
