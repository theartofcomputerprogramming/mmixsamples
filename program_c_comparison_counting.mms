// program_c_comparison_counting.mms

// Copyright: This file is part of the MMIX Supplement package
// (c) Martin Ruckert 2014
// Authors: Martin Ruckert, Kenneth Laskoski <kennethlaskoski@po...>

              PREFIX  :Sort:

k             IS      $0          Parameter

// count register holds COUNT[i]
count         IS      $1
n             IS      $2

i             IS      $3          Local variables
j             IS      $4
ki            IS      $5
kj            IS      $6
cj            IS      $7
ci            IS      $8
t             IS      $9

// Sort function parameters
// $0: address of array to sort
// $1: address of array of counts
// $2: number of elements to sort

// loop to initialize COUNT array to 0
// initialize i in $3 to n in $2 scaled to octa for reverse iteration
:Sort         SL      i,n,3           01: C1 Clear COUNTs

// start first iteration of loop
              JMP     0F              02:

// store constant 0
1H            STCO    0,count,i       03: COUNT[i] <- 0

// decrement i in $3 scaled to octa
0H            SUB     i,i,8           04: 

// branch likely taken because linear scan
              PBNN    i,1B            05: N > i >= 0

// sort nested loop
// initialize i in $3 to n in $2 scaled to octa
              SL      i,n,3           06: C2 Loop on i

// start first iteration of loop
              JMP     1F              07: 

// outer loop on i
// get COUNT[i] into register $8
2H            LDO     ci,count,i      08:

// get K[i] into register $5
              LDO     ki,k,i          09:

// inner loop on j
// get K[j] into register $6
3H            LDO     kj,k,j          10:

// compare K[i] and K[j] with result in $9
              CMP     t,ki,kj         11: C4 Compare K_i:K_j

// branch if $9 >= 0
              PBNN    t,4F            12: Jump if K_i >= K_j

// increment COUNT[j] because K[j] > K[i]
// get COUNT[j] into register $7
              LDO     cj,count,j      13: COUNT[j]

// increment $7 scaled to octa
              ADD     cj,cj,8         14:   + 1

// write incremented value to COUNT[j]
              STO     cj,count,j      15:   -> COUNT[j]

// continue loop
              JMP     5F              16:

// increment COUNT[i] because K[i] >= K[j]
4H            ADD     ci,ci,8         17: COUNT[i] <- COUNT[i] + 1

// decrement j in $4 scaled by octa
5H            SUB     j,j,8           18: C3 Loop on j

// back to start of inner loop
// branch likely taken as array traversed sequentially
              PBNN    j,3B            19:

              STO     ci,count,i      20:

// decrement i in $3 scaled to octa
1H            SUB     i,i,8           21:

// initialize j in $4 to i-1 scaled to octa for reverse iteration
              SUB     j,i,8           22: N > i > j >= 0

// back to start of outer loop
// branch likely taken as array traversed sequentially
              PBNN    j,2B            23:

// no return value
              POP     0,0

              PREFIX  :

              LOC     Data_Segment
// base address register for input array
              GREG    @

Data          OCTA 5,-2,-3,6

Size          IS      4

// base address register 
              GREG    @    
Count         OCTA    0

// reserve memory for COUNT array
              LOC     Count+Size*8

// expected counts array for verification
              GREG    @
Solution      OCTA 8*2,8*1,8*0,8*3

              GREG    @
// expected sorted array for verification
Sorted        OCTA -3,-2,5,6

// code segment
              LOC     #100

// main program
// set parameters to pass to Sort function
Main          LDA     $1,Data
              LDA     $2,Count
              SET     $3,Size

// call Sort, no registers are saved
              PUSHJ   0,Sort

              SET     $255,0 

              TRAP    0,Halt,0

