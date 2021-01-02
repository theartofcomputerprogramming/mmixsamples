// program_s_straight_selection_sort.mms

// Copyright: This file is part of the MMIX Supplement package
// (c) Martin Ruckert 2014
// Based on: 5.2.3/straightselectionsort.mms 5.2.3/straightselectionsort.tst
// Author: Michael Unverzart

// set location to data segment
              LOC     Data_Segment

// global base address register $254 for input array
              GREG    @

// unsorted input array
Data          OCTA    503,87,512,61,908,170,897,275
              OCTA    653,426,154,509,612,677,765,703

// number of keys to sort
Size          IS      16

// global base address register $253 for expected output
              GREG    @
// expected sorted result for verification
Sorted        OCTA    61,87,154,170,275,426,503,509
              OCTA    512,612,653,677,703,765,897,908

// code segment
              LOC     #100

// main program

// pass address of input array to callee $0
Main          LDA     $1,Data
// pass size of array to callee $1
              SET     $2,Size

// call Sort subroutine, no saved registers
              PUSHJ   0,Sort

// set exit status
              SET     $255,$0
// halt
              TRAP    0,Halt,0



// global base address register $252
              GREG    @

// algorithm s straight selection sort
              PREFIX    :sort:

// parameter
key           IS      $0        base address
n             IS      $1        number of elements

// local variables
j             IS      $2        scaled index (offset) S1: loop on j
k             IS      $3        scaled index (offset) S2: find max

kk            IS      $4        element at index k (Kk)
i             IS      $5        scaled current maximum offset

max           IS      $6        current maximum element (Ki)
t             IS      $7

// Sort params
// key $0 address of array of unsorted keys
// n $1 number of keys to sort

// j $2 initialized to offset of end of array
:Sort         SL      j,n,3           01: S1 Loop on j, j <- N

// start first iteration of loop
              JMP     1F              02:

// nested loop

// outer loop on j $2 backwards from end of array
// initialize k $3 to j $2
2H            SET     k,j             03: S2 Find max(K_1,..., K_j)

// initialize i $5 index of max key to j $2
              SET     i,j             04: i <- j

// initialize max $6 to key at offset i $5
// break here to see the sorted position that will be filled
              LDO     max,key,i       05: max <- K_i

// inner loop on k $3 forward from j $2 to find maximal key
3H            SUB     k,k,8           06: Loop on k

// get key at offset k $3 into kk $4
              LDO     kk,key,k        07: kk <- K_k

// compare max $6 to new key kk $4: result 1, 0, -1 in t $7
              CMP     t,max,kk        08: Compare max : K_k

// likely branch to continue without updating max if comparison is nonnegative
              PBNN    t,0F            09: If max < K_k

// fallthrough to update max $6 and its index i $5
// since max is smaller than new key
              SET     i,k             10: i <- k and
// break here to see candidate max $6 get updated
              SET     max,kk          11: max <- K_k

// continue forward scan of array checking for max
0H            PBP     k,3B            12: Repeat if k > 0

// reached end of array, max key and index has been found
// swap key at offset j $2 with key at offset i $5
              LDO     t,key,j         13: S3 Exchange with R_j
// break here to see max key placed in correct sorted position
              STO     max,key,j       14:

              STO     t,key,i         15:

// decrement j $2 to continue backward loop over array
1H            SUB     j,j,8           16: Decrement j

              PBP     j,2B            17: N > j > 0

// reached start of array, sorting is complete
// return, no return value
              POP     0,0

              PREFIX  :

