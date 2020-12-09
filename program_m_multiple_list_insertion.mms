// program_m_multiple_list_insertion.mms

// Based on: 5.2.1/mlisti.mms, 5.2.1/mlisti.tst
// Copyright: This file is part of the MMIX Supplement package
// (c) Martin Ruckert 2014
// Author:    Martin Ruckert

// basic idea is to modify Algorithm L (List insertion) and replace the
// head node for the single list of sorted nodes with multiple head
// nodes of separate lists through the array of records
// each head node/linked list corresponds to a bucket or range of keys
// the range is of non-negative numbers upto a power of 2 that fits all keys
// for example the range could be 0-1024
// and a number of buckets is chosen to partition the range, say 4

// the only extra space needed is for the extra head nodes compared to
// Algorithm L

// the only difference in processing is to compute the head node to use
// for a particular key when trying to insert it into a list of sorted keys
// otherwise this works the same as Algorithm L

              PREFIX  :

// data segment
              LOC     Data_Segment

// number of distribution linked lists (buckets)
M             IS      4

// keys must be in the range [0, 2^e)
e             IS      10

// number of keys to sort
Size          IS      16

// base address register $254 for data array
              GREG    @

// array of keys to sort
// still need extra first record because 0 index is special just as in
// program_l_list_insertion.mms, even though this first record is no longer
// used as the head of a linked list
R0            OCTA    0,0    artificial first record

Data          OCTA    0,503,0,87,0,512,0,61,0,908,0,170,0,897,0,275
              OCTA    0,653,0,426,0,154,0,509,0,612,0,677,0,765,0,703


// base address register $253 for array of heads for linked lists
              GREG    @

// array of heads of sorted linked lists
Heads         OCTA    0

// reserve space for Heads array
              LOC    Heads+8*M

// base address register $252 for expected sorted keys in Sorted array
              GREG    @

// sorted array for verification
Sorted        OCTA    61,87,154,170,275,426,503,509
              OCTA    512,612,653,677,703,765,897,908

// code segment
              LOC     #100

// main program

// address of data array passed to $0
Main          LDA     $1,R0

// size of data array passed to $1
              SET     $2,Size

// address of list heads array passed to $2
              LDA     $3,Heads

// size of list heads array passed to $3
              SET     $4,M

// call Sort, no registers saved
              PUSHJ   0,Sort

              LDA     $1,:Heads
              SET     $2,:M
              LDA     $3,:Sorted
              SET     $4,:Size

              PUSHJ   $0,:List:Equal    
             
              SET     $255,0 
              TRAP    0,Halt,0

// multiple list insertion

              PREFIX  :MListSort:

// base address register for LINK fields
link          IS      $0    Parameter

n             IS      $1

// base address register for array of linked list heads
head          IS      $2

// number of linked lists
m             IS      $3

// keys must be in the range [0..2^e)
e             IS      :e

key           IS      $4

j             IS      $5    scaled Local variables

p             IS      $6
q             IS      $7
k             IS      $8
kp            IS      $9

i             IS      $10    scaled    
t             IS      $11

// offset of LINK field of node
// LINK contains offset of next sorted node
LINK          IS      0

// offset of KEY field of node
KEY           IS      8


// Sort params
// link $0 is address of data array
// n $1 is size of data array
// head $2 is address of array of heads of linked lists
// m $3 is size of array of heads

// i $10 is size of array of linked list heads scaled by octa
:Sort         SL      i,m,3           01: i <- M

// start first iteration of loop to initialize array of heads
              JMP     1F              02:

// loop to initialize array of heads
// set each head to 0 the null link
0H            STCO    0,head,i        03: Clear heads

// decrement i $10 by octa
1H            SUB     i,i,8           04: i <- i - 1

// likely branch to sequential loop over heads array
              PBNN    i,0B            05:

// turns head $2 into offset from link
// so each head can be treated like a LINK field
              SUBU    head,head,link  06: Make head a relative address

// key $4 is base address for KEY fields
              ADDU    key,link,KEY    07: Loop on j

// initialize j $5 to size of data array scaled by 2 octas
              SL      j,n,4           08: j <- N

// start first iteration of nested loop
              JMP     0F              09:

// nested loop

// outer loop on j $5 over unsorted keys of data array in reverse

// get new unsorted key into k $8
M2            LDO     k,key,j         10: Set up p, q, K. K <- K_j

// there are M buckets, each bucket size is 2^e / M
// so a key K belongs to bucket index K / (2^e / M) or M * K / 2^e

// i $10 will be bucket index scaled by octa
              MUL     i,m,k           11: i <- M * K_j

// divide i $10 by 2^e scaled by octa which is 2^(e-3) 
// okay for i to not be multiple of octa since mmix ignores unaligned bits
// when loading an octa from an address
              SRU     i,i,e-3         12: i <- floor(M * K_j / 2^e)

// initialize q $7 to bucket index scaled by octa
              ADDU    q,head,i        13: q <- relative address of H_i

// start first iteration of loop over associated sorted list
              JMP     4F              14: Jump to load and test p

// inner loop over sorted sublist

// get next sorted key into kp $9
M3            LDO     kp,key,p        15: Compare K:K_p

// compare unsorted new key $8 to sorted key kp $9: result 1, 0, -1 in $11
              CMP     t,k,kp          16:

// less likely branch for unsorted new key at most sorted key
              BNP     t,M5            17: To L5 if K <= K_p

// unsorted key is bigger, keep going through list of sorted keys
// update q $7 to trail p $6
              SET     q,p             18: Bump p, q. q <- p

// p $6 points to next sorted node
4H            LDOU    p,link,q        19: p <- L_q

// likely branch on p != 0 to continue scanning linked list of sorted keys
              PBNZ    p,M3            20: To L3 if p != 0

// unsorted key is smaller or at end of sorted list

// update node of trailing pointer q $7 to point to unsorted node j $5
M5            STOU    j,link,q        21: Insert into list. L_q <- j

// update unsorted node to point to current sorted node p
              STOU    p,link,j        22: L_j <- p

// decrement outer counter j $5 by 2 octas to process next unsorted node
              SUB     j,j,16          23:

// likely branch to continue outer loop over unsorted nodes
0H            PBP     j,M2            24: N > j >=1

// return, no return value
              POP     0,0


              PREFIX  :List:
H             IS      $0    Heads Parameter
m             IS      $1    Number of heads
S             IS      $2    Sorted keys
n             IS      $3    Number of keys
kp            IS      $4    Local variables
p             IS      $5
k             IS      $6
t             IS      $7
j             IS      $8
key           IS      $9
link          IS      $10

Equal         SET     j,0
              SL      n,n,3
              SET     p,0
              LDA     link,:R0
              LDA     key,:R0+8
              JMP     0F


1H            BNZ     p,4F
              LDO     p,H,0
              SUB     m,m,1
              BN      m,3F
              ADD     H,H,8
              JMP     1B

4H            LDO     kp,key,p
              LDO     k,S,j
              CMP     t,k,kp
              BZ      t,2F

3H            SET     $255,1 
              TRAP    0,:Halt,0
2H            LDOU    p,link,p
              ADD     j,j,8
0H            CMP     t,j,n
              BN      t,1B
              BNZ     p,3B


              PREFIX  :

