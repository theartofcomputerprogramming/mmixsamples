// program_m_maximum.mms

// usage: mmix program_m_find_the_maximum <data.dat | od -An -td8 -w8 --endian=big
// reads N bigendian numbers on stdin
// writes 1-based index and value of max on stdout
// Examples:
// mmix program_m_find_the_maximum <data.dat | od -An -td8 -w8 --endian=big
           LOC    Data_Segment
x0         GREG   @
X0         IS     @
N          IS     10

// Program M (Find the maximum)
j          IS     $0          01: j
m          IS     $1          02: m
kk         IS     $2          03: 8*k
xk         IS     $3          04: X[k]
t          IS     $255        05: Temp storage
           LOC    #100        06:

// address 0x100: 39 02 00 03
Maximum    SL     kk,$0,3     07: M1 [Initialize] k <- n, j <- n

// address 0x104: 8c 01 fe 02
           LDO    m,x0,kk     08: m <- X[n]

// address 0x108: f0 00 00 06
           JMP    DecrK       09: To M2 with k <- n - 1

// address 0x10c: 8c 03 fe 02
Loop       LDO    xk,x0,kk    10: M3 [Compare]

// address 0x110: 30 ff 03 01
           CMP    t,xk,m      11: t <- [X[k] > m] - [X[k] < m]

// address 0x114: 5c ff 00 03
           PBNP   t,DecrK     12: To M5 if X[k] <= m

// address 0x118: c1 01 03 00
ChangeM    SET    m,xk        13: M4 [Change m] m <- X[k]

// address 0x11c: 3d 00 02 03
           SR     j,kk,3      14: j <- k

// address 0x120: 25 02 02 08
DecrK      SUB    kk,kk,8     15: M5 [Decrease k] k <- k - 1

// address 0x124: 55 00 ff fa
           PBP    kk,Loop     16: M2 [All tested?] To M3 if k > 0

// address 0x128: f8 02 00 00
           POP    2,0         17: Return to main program


Main      GETA  t,8F
// fill array using Fread parameters at 8H
          TRAP  0,Fread,StdIn

// $0 is bytes offset of end of array
          SET   $0,N<<3
// $2 is array index
          SR    $1,$0,3
// call Maximum
// $0 is hole
// $1 renamed $0 for Maximum
          PUSHJ 0,Maximum

// hole $0 has first return value - the maximum - from Maximum
// index of max returned in $1
          STO   $1,x0,1<<3
          STO   $0,x0,2<<3

// Fwrite parameters at 9H: source buffer address followed by size bytes
          GETA  t,9F
          TRAP  0,Fwrite,StdOut

// exit
          TRAP  0,Halt,0

// parameters for Fread
// destination buffer X0 + 8*1, size 8*N bytes
8H        OCTA  X0+1<<3,N<<3

// parameters for Fwrite
// source buffer X0 + 8*1, size 8*2 bytes
9H        OCTA  X0+1<<3,2<<3
