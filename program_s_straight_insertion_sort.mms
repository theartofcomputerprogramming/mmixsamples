// program_s_straight_insertion_sort.mms

// Based on: 5.2.1/insert3.mms, 5.2.1/insert3.tst
// Copyright: This file is part of the MMIX Supplement package
// (c) Martin Ruckert 2014
// Author: M.Ruckert, 26.3.2012

// base address of input array ie first key
key          IS      $0      Parameter 

// size of input array
n            IS      $1    

j            IS      $2      Local variables
i            IS      $3
k            IS      $4

ki           IS      $5
key1         IS      $6
keyn         IS      $7

d            IS      $8
c            IS      $9

// Sort params: key $0 address of first key, n $1 number of keys
// initialize key1 $6 to address of second key
:Sort         ADD     key1,key,8       01:

// initialize keyn $7 to address of end of array
              8ADDU   keyn,n,key       02:

// d $8 is distance from second key to end of array in octa
              SUBU    d,keyn,key1      03:

// initialize outer loop counter j $2 to negative distance
// j is negative offset from end of array that counts up
              SUBU    j,key1,keyn      04: j <- 1

// start first iteration of nested loop
              JMP     S1               05:

// nested loop

// outer loop on j $2
// get outer key into register k $4
S2            LDO     k,keyn,j         06: S2 Set up j, K, R

// initialize inner loop counter i $3 to offset before outer key
// i is offset from array start that counts down
              ADD     i,d,j            07: i <- j-1

// inner loop on i $3
// get inner key into ki $8
S3            LDO     ki,key,i         08: S3 Compare K : K_i

// compare k to ki with result in c $9: 1, 0, or -1
              CMP     c,k,ki           09:

// less likely branch with higher disorder
              BNN     c,S5             10: To S5 if K >= K_i

// inner key is bigger
// move inner key one up in memory, remember key1 is 1 address of second key
              STO     ki,key1,i        11: S4 Move R_i, decrease i

// decrement inner counter i $3 by octa
              SUB     i,i,8            12: i <- i-1

// likely branch with higher disorder
              PBNN    i,S3             13: To S3 if i >= 0

// found correct position of outer key, write to memory
S5            STO     k,key1,i         14: S5 R into$R_{i+1}

// increment outer counter j $2 by octa
              ADD     j,j,8            15: j <- j + 1

// likely branch for linear scan
S1            PBN     j,S2             16: S1 Loop on j, 1 <= j <= N

// return with no return value
              POP     0,0              17:

// place data in data segment
              LOC     Data_Segment

// base register $254 for addresses of data symbols
              GREG    @

// input array to sort
Data          OCTA    5,3,2,5,7,11,-3,2,99,5

// array size
Size          IS      10

// sorted array for verification
Sorted        OCTA    -3,2,2,3,5,5,5,7,11,99

// code segment
              LOC     #100

// main program

// prep params to Sort
// pass address of input array to $0
Main          LDA     $1,Data

// pass array size to $1
              SET     $2,Size

// call Sort, no registers saved
              PUSHJ   0,Sort

// set exit status 0
              SET     $255,0 

// halt
              TRAP    0,Halt,0

