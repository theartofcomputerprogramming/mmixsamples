// exercise_5.2.2.12.mms

// Based on: 5.2.2/batcher.mms, 5.2.2/batcher.tst
// Copyright: This file is part of the MMIX Supplement package
// (c) Martin Ruckert 2014
// Author: M.Ruckert, 16.5.2012

// MMIX implementation of Algorithm M (Merge exchange sort)
// 5.2.2 Sorting by Exchanging

// algorithm has two phases, sort phase then merge phase
// array is d-ordered for various d as powers of 2 in sort phase
// eg array of 16 elements will be 8-ordered, 4-ordered and 2-ordered
// at the end of sort phase
// then all the d-ordered sequences are merged incrementally into
// completely sorted array

key           IS      $0    Array of Records (OCTAs)
n             IS      $1    Number of Records

// p is a power of 2
p             IS      $2

// q is also a power of 2
q             IS      $3

// i is scaled offset key in array
i             IS      $4

// k is lower key to possibly exchange
k             IS      $5

// kd is higher key compared for possible exchange with lower key
kd            IS      $6

// d is distance between pairs of key to compare
d             IS      $7

// keyn is address of end of array
keyn          IS      $8

// temporary register
t             IS      $9

// r is used to select ranges of keys to possibly exchange in one pass
r             IS      $10

// temporary register
c             IS      $11

// M1 [Initialize p] Set p <- 2^{t-1}, where t = ceil(lg N) is the least
// integer such that 2^t >= N

// 64-bit ieee 754 is sign_bit 11_exponent_E_bits 52_fraction_F_bits
// number is 2^(E - 1023) * (1 + F / 2^52)
// in other words 1023 is added to real exponent to get biased exponent E
// example bits: 17 = sign: 0, E: _100 0000 0011, F: 0001 0000 ...
// so E = 1027 and 2^(1027 - 1023) = 2^4
// 2^4 * F / 2^52 = F / 2^48 = ... 0001 = 1
// so number is 2^4 + 1 = 17

// use floating point representation to get exponent of closest power of 2
// t $9 is float n rounded up
:Sort         FLOTU   t,ROUND_UP,n    01: M1 Initialize p

// c $11 is ff f0, set high 3 bytes or 12 bits
              SETH    c,#FFF0         02:

// c $11 is 00 0f ff ff ff ff ff ff, set low 52 bits
              NOR     c,c,c           03:

// verify: add all 1's to fraction to allow any carry to bump exponent up 1
              ADDU    t,t,c           04: Round N up to 2^t

// shift right t $9 52 bits to remove fraction and only leave exponent in t
              SRU     t,t,52          05: Extract t

// low wyde of t $9 holds 11-bit exponent
// 0x400 = 2^10 = 1024 = _100 0000 0000
// ~0x400 = _011 1111 1111
// t & ~0x400 clears bit 11 of t
// following only works for numbers between 1024 and 2047 which is the
// case for array size N > 1
// clearing bit 11 means subtracting 1024 = 1023 + 1
// which is good because we actually need to start with p = 2^(t - 1) below
              ANDNL   t,#400          06: t <- ceil(lg N) - 1

// keyn $8 is address of end of array
              8ADDU   keyn,n,key      07: keyn <- LOC(K_{N+1})

// initialize p $2 scaled by octabyte
              SET     p,8             08: p <- 1

// p $2 is 2^t scaled by octabyte
              SLU     p,p,t           09: p <- p * 2^t

// triple nested loop

// outer loop on p $2 decreasing powers of 2 to 1

// set scaling factor for q $3
M2            SET     q,8             10: M2 Initialize q, r, d

// q $3 also initialized to 2^t same as p $2
              SL      q,q,t           11: q <- 2^t

// initialize r $10 to 0 for first pass
              SET     r,0             12: r <- 0

// initialize d $7 to address of entry at offset p $2
              ADDU    d,p,key         13: d <- p

// start first iteration of loop
              JMP     M3              14:

// middle loop on q $3

// set d $7 to address of highest key to compare
M5            ADDU    d,key,d         15: M5 Loop on q

// decrease q $3 to smaller power of 2
              SR      q,q,1           16: q <- q / 2

              ANDNL   q,7             17: q <- 8 * floor(q / 8)

// set r $10 to p $2
              SET     r,p             18: r <- p

// initialize i $4 to offset of highest key to compare pairs of keys that
// are d-apart
M3            SUB     i,keyn,d        19: M3 Loop on i, i <- N + 1 - d

// start first iteration of loop over key pairs to compare in reverse
              JMP     0F              20:

// inner loop over all pairs of keys that are d-apart in reverse

// c $11 is i $4 & p $2
1H            AND     c,i,p           21:

// compare c $11 to r $10, result 1, 0, -1 back in c $11
              CMP     c,c,r           22: If i & p = r,

// unpredictable branch to skip comparison of key pair if equality test fails
              BNZ     c,0F            23:   go to M4

// fallthrough to compare pair of keys when equality test passes

// k $5 has first (lower) key of pair to compare
              LDO     k,key,i         24: M4 Compare/exchange

// kd $6 has second (higher) key of pair to compare at distance d
              LDO     kd,d,i          25:   R_{i + 1} : R_{i + d + 1}

// c $11 has result of comparing k $5 to kd $6: 1, 0, or -1
              CMP     c,k,kd          26:

// likely branch to skip exchange if lower key is not bigger
              PBNP    c,0F            27: If K_{i + 1} > K_{i + d + 1},

// fallthrough to exchange pair of keys since lower key is bigger

// write k $5 to key at i + d
              STO     k,d,i           28:   interchange R_{i + d + 1}

// write kd $6 to to key at i
              STO     kd,key,i        29:   and R_{i + 1}

// decrement i $4 to check next key
0H            SUB     i,i,8           30: i <- i - 1

// likely branch to continue loop over keys to compare
              PBNN    i,1B            31: 0 <= i < N - d

// update d
              SUB     d,q,p           32: M5 Loop on q, d <- q - p

              PBNZ    d,M5            33:

              SR      p,p,1           34: M6 Loop on p, p <- p / 2

              ANDNL   p,7             35: p <- 8 * floor(p / 8)

// likely branch to loop on p
              PBP     p,M2            36:

              POP     0,0             37:


// main program

              LOC     Data_Segment

              GREG    @

//Data          OCTA    5,3,2,5,7,11,-3,2,99,5,0,2,2,2,3,3,4
Data          OCTA    503,87,512,61,908,170,897,275
              OCTA    653,426,154,509,612,677,765,703

//Size          IS      17
Size          IS      16

//Sorted        OCTA    -3,0,2,2,2,2,2,3,3,3,4,5,5,5,7,11,99
Sorted        OCTA    61,87,154,170,275,426,503,509
              OCTA    512,612,653,677,703,765,897,908

              LOC     #100

Main          LDA     $1,Data
              SET     $2,Size
              PUSHJ   0,Sort

              SET     $255,0
              TRAP    0,Halt,0

