// program_b_bubble_sort.mms

// Based on: 5.2.2/bubble.mms, 5.2.2/bubble.tst 
// Copyright: This file is part of the MMIX Supplement package
// (c) Martin Ruckert 2014
// Author: M.Ruckert, 26.3.2012

// idea is to keep bubbling a bigger key up till it cannot go higher
// so biggest key will reach the top in first pass and other keys will
// move above smaller adjacent keys
// after each pass we track the point above which all the biggest keys
// are in order - this point is called BOUND
// then bubbling needs to take place only upto BOUND
// initialize BOUND to the last index of the array
// the upper half of the array grows to contain the biggest keys in order


key           IS      $0    Array of Records (OCTAs)
n             IS      $1    Number of Records

keyb          IS      $1    Reusing register for n
j             IS      $2    scaled
kj            IS      $3
kjj           IS      $4
t             IS      $5    scaled
c             IS      $6

// Sort params
// key $0 address of data array
// n $1 size of array

// get index of last key
:Sort         SUB     n,n,1           01: B1 Initialize BOUND 

// set keyb $1 to address of last key
// 8ADDU is 8*n + key
              8ADDU   keyb,n,key      02: BOUND <- N

// start first iteration of nested loop
              JMP     B2              03:

// nested loop

// outer loop till no bubbling occurs in inner loop
// inner loop on j $2 to bubble keys from start of array upto BOUND

// j $2 is negative scaled offset from address of BOUND entry

// kj $3 is new key to bubble
B3            LDO     kj,keyb,j       04: B3 Compare/exchange R_j : R_{j+1}

// increment j $2 to use as offset to adjacent higher index
B3A           ADD     j,j,8           05: j <- j + 1

// kjj $4 is adjacent key to compare bubble key to
              LDO     kjj,keyb,j      06: kjj <- K_{j+1}

// compare bubble key kj $3 to adjacent key kjj $4: result 1, 0, -1 in c $6
              CMP     c,kj,kjj        07: K_j > K_{j+1}

// unpredictable branch for bubble key kj $3 at most adjacent key kjj $4
              BNP     c,0F            08: If K_j > K_{j+1},

// bubble key kj $3 is bigger than adjacent key kjj $4, swap them
// write bubble key to higher index
              STO     kj,keyb,j       09:   interchange R_j <-> R_{j+1}

// decrement j $2 to get lower index t $5
              SUB     t,j,8           10: t <- j

// write adjacent key to lower index
              STO     kjj,keyb,t      11: K_j <- K_{j+1}

// likely branch to inner loop over remaining keys upto BOUND index
              PBN     j,B3A           12:

// reached BOUND index, continue with another pass over first half of array
              JMP     1F              13: To B4 (but skip test for termination)

// bubble key was smaller
// make adjacent key the bubble key
0H            SET     kj,kjj          14: kj <- K_j

// likely branch to inner loop to continue comparing new bubble key
// j $2 negative means it has not yet reached BOUND
              PBN     j,B3A           15:

// fallthrough on completion of one full inner loop when j $2 reaches BOUND

// t $5 zero means no key bubbled up
// branch to terminate nested loop
B4            BZ      t,9F            16: B4 Any exchanges?

// fallthrough on nonzero t $5 so some key bubbled up
// update BOUND keyb $1 to last index used for bubbling swap
1H            ADD     keyb,keyb,t     17: BOUND <- t

// initialize last bubble swap index tracker to 0
B2            SET     t,0             18: B2. Loop on j, t <- 0

// initialize j $2 to negative offset from BOUND entry keyb $1 to
// start of array
              SUB     j,key,keyb      19: j <- 1

// likely branch to inner loop over initial portion of array to begin
// bubbling
              PBN     j,B3            20: 1 <= j < BOUND

// return, no return value
9H            POP     0,0             21:


// data segment
              LOC     Data_Segment

// global base address register $254 for address of data array
              GREG    @
Data          OCTA    503,87,512,61,908,170,897,275
              OCTA    653,426,154,509,612,677,765,703

Size          IS      16

// global base address register $253 for address of sorted array
              GREG    @        
Sorted        OCTA    61,87,154,170,275,426,503,509
              OCTA    512,612,653,677,703,765,897,908

// code segment
              LOC     #100

// main program

// pass address of array of unsorted keys to $0
Main          LDA     $1,Data

// pass size of array to $1
              SET     $2,Size

// call Sort with 2 parameters, no saved registers
              PUSHJ   0,Sort
        
              SET     $255,0 

              TRAP    0,Halt,0

