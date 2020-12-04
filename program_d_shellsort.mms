// program_d_shellsort.mms

// Based on: 5.2.1/shell.mms, 5.2.1/shell.tst
// Copyright: This file is part of the MMIX Supplement package
// (c) Martin Ruckert 2014
// Authors: M. Ruckert, 27.4.2012, Blake Hegerle 

              PREFIX  :Sort:

// base address of input array ie first key
key           IS      $0     Parameter

// size of input array
n             IS      $1    

// base address of increments array
inc           IS      $2

// size of increments array
t             IS      $3

s             IS      $4     Local variables
j             IS      $5    
i             IS      $6

k             IS      $7
ki            IS      $8

keyh          IS      $9
keyn          IS      $10

d             IS      $11
h             IS      $12
c             IS      $13

// Sort params
// key $0 address of first key
// n $1 number of keys
// inc $2 address of increments array
// t $3 number of increments

// keyn $10 is address of end of array
:Sort         8ADDU   keyn,n,key      01: keyn <- LOC(K_{N+1})

// s $4 is number of increments scaled by octa to use as offset
              SL      s,t,3           02: s <- t-1

// start first iteration of loop
              JMP     D1              03:

// set increment for nested loop in h $12
D2            LDO     h,inc,s         04: D2 Loop on j, h <- h_s

// scale increment by octa to use as offset into data array
              SL      h,h,3           05:

// keyh $9 is address of first unsorted key at increment offset from the start
// keyh is used as base address for moving keys up by the increment
              ADDU    keyh,key,h      06: keyh <- LOC(K_{h+1})

// d $11 is distance from unsorted key to end of array in bytes
              SUBU    d,keyn,keyh     07: d <- N - h

// initialize outer loop counter j $2 to negative distance
// j $5 is negative offset of unsorted key from end of array that counts up
              SUBU    j,keyh,keyn     08: j <- h+1

// start first iteration of nested loop
              JMP     0F              09:

// nested loop

// outer loop over unsorted keys

// initialize inner loop counter i $6
D3            ADD     i,d,j           10: D3 Set up j, K, R, i <- j-h

// get current unsorted key into k $7
              LDO     k,keyn,j        11:

// inner loop on i $6 over sorted keys in reverse

// get current sorted key into ki $8
D4            LDO     ki,key,i        12: D4 Compare K : K_i

// compare k to ki with result in c $13: 1, 0, or -1
              CMP     c,k,ki          13:

// less likely branch with higher disorder
              BNN     c,D6            14: To D6 if K >= K_i

// unsorted new key is smaller, keep going
// move sorted key one increment up in memory
              STO     ki,keyh,i       15: D5 Move R_i, decrease i

// decrement inner counter i $6 by one increment
              SUB     i,i,h           16: i <- i-h

// likely branch with higher disorder to get next sorted key
              PBNN    i,D4            17: To D4 if i >= 0

// unsorted new key is bigger, stop
// found correct position of unsorted key, write to memory
D6            STO     k,keyh,i        18: D6 R into R_{i+1}

// increment outer counter j $5 by octa
              ADD     j,j,8           19: j <- j + 1

// likely branch for sequential counter
0H            PBN     j,D3            20: To D3 if j < N

// decrement offset into increments array
D1            SUB     s,s,8           21: D1 Loop on s

// likely branch
              PBNN    s,D2            22: 0 <= s < t

// return with no return value
              POP     0,0

// global namespace
              PREFIX  :

// place input data in memory
              LOC     Data_Segment

// base address $254 for Data array
              GREG    @

// data to sort
Data          OCTA    503,87,512,61,908,170,897,275
              OCTA    653,426,154,509,612,677,765,703

// size of data array
Size          IS      16

// base address $253 for Sorted array
              GREG @

// sorted array for verification
Sorted        OCTA    61,87,154,170,275,426,503,509
              OCTA    512,612,653,677,703,765,897,908

// base address $252 for H array
              GREG @

// increments array
H             OCTA 1,3,5,9,17,33,65,129,257,513

// size of increments array
t             IS      4

// code segment
              LOC     #100

// main program

// prep params to Sort
// pass address of data array to $0
Main          LDA     $1,Data

// pass array size to $1
              SET     $2,Size

// pass address of increments array to $2
              LDA     $3,H

// pass size of increments array to $3
              SET     $4,t

// call Sort, no registers saved
              PUSHJ   0,Sort

// set exit status 0
              SET     $255,0

// halt program
              TRAP    0,Halt,0

