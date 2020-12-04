// program_l_list_insertion.mms

// Based on: 5.2.1/listi.mms, 5.2.1/listi.tst
// Copyright: This file is part of the MMIX Supplement package
// (c) Martin Ruckert 2014
// Authors: B. Hegerle <bhegerle@ea...>, Martin Ruckert, 2005-11-22 21:41

// idea is to set link field in each node to point to next node in
// increasing sorted order
// special head node at start of array is the beginning of the sorted
// linked list

              PREFIX  :Sort:
// base address register for LINK fields
link          IS      $0      Parameter

// size of array of nodes
n             IS      $1      N

// base address register for KEY fields
key           IS      $2

// offset of current unsorted node to sort
j             IS      $3    Local variables

// address of current sorted node to compare
p             IS      $4

// trails p, offset of node pointing to current sorted node to compare
q             IS      $5

// current unsorted key
k             IS      $6

// current sorted key
kp            IS      $7

// temporary
t             IS      $9

// offset of LINK field in node
// LINK contains offset of next sorted node
LINK          IS      0

// offset of KEY field in node
KEY           IS      8

// Sort params
// link $0 address of data array
// n $1 number of elements

// set key $2 as base address for KEY field offsets
:Sort         ADDU    key,link,KEY    01: L1 Loop on j

// initialize j $3 as offset to last node scaled by node size
              SL      j,n,4           02: j <- N

// initialize head node to point to last node
              STOU    j,link,0        03: L_0 <- N

// initialize last node to point to head node
              STCO    0,link,j        04: L_N <- 0

// start first iteration of nested loop
              JMP     0F              05: Go to decrease j

// nested loop

// outer loop over array of unsorted nodes in reverse

// initialize p $4 to offset of smallest sorted key
L2            LDOU    p,link,0        06: L2 Set up p, q, K. p <- L_0

// initialize q $5 to point to node pointing to p, so q trails p
              SET     q,0             07: q <- 0

// set k $6 as new unsorted key for entire inner loop
              LDO     k,key,j         08: K <- K_j

// inner loop over linked list of nodes sorted in increasing order

// kp $7 is current sorted key
L3            LDO     kp,key,p        09: L3 Compare K:K_p

// compare unsorted key k $6 to sorted key kp $7: result 1, 0, -1 in $9
              CMP     t,k,kp          10:

// less likely branch if unsorted key is at most sorted key
              BNP     t,L5            11: To L5 if K <= K_p

// unsorted key is bigger, keep going
// update q $5 to trail p $4
              SET     q,p             12: L4 Bump p, q. q <- p

// set p $4 to point to next sorted node
              LDOU    p,link,q        13: p <- L_q

// likely branch for p != 0 continue traversing sorted list in inner loop
              PBNZ    p,L3            14: To L3 if p != 0

// unsorted key is smaller or at end of sorted list
// found correct position of unsorted node
// "insert" unsorted node before current sorted node
// this is where trailing pointer q is needed

// update node of trailing pointer q $5 to point to unsorted node j $3
L5            STOU    j,link,q        15: L5 Insert into list. L_q <- j

// update unsorted node to point to current sorted node p $4
              STOU    p,link,j        16: L_j <- p

// decrement outer counter j $3 by one node to next unsorted node
0H            SUB     j,j,16          17: j <- j - 1

// continue outer loop over unsorted nodes
              PBP     j,L2            18: N > j >= 1

// return, no return value
              POP     0,0

              PREFIX  :


// data segment
              LOC     Data_Segment

// base address register $254
              GREG    @
// array of unsorted data with link field for sorting
Head          OCTA    0,0     the artificial R_0 record with its link field

Data          OCTA    0,5,0,3,0,2,0,5,0,7,0,11,0,-3,0,2,0,99,0,5

Size          IS      10

// base address register $253
              GREG @    

Sorted        OCTA    -3,2,2,3,5,5,5,7,11,99

// code segment
              LOC     #100

// main program

// pass address of array of unsorted data to $0
Main          LDA     $1,Head

// pass array size to $1
              SET     $2,Size

// call Sort, no registers saved
              PUSHJ   0,Sort

// code block to verify sorted linked data
// traverses links in Head array and compares key in node from Head
// to key in Sorted array
// exit 0 for success, i.e. linked nodes of Head are sorted
// exit 1 for failure
              PREFIX  :LEqual:

p             IS      $2
kp            IS      $3
k             IS      $5
t             IS      $6
j             IS      $7
S             IS      $8
n             IS      $9
K             IS      $10
L             IS      $11

              LDA     L,:Head
              LDA     K,:Head+8
              LDOU    p,L,0
              SET     j,0
              LDA     S,:Sorted

              SET     n,:Size

              SL      n,n,3
              JMP     0F

1H            LDO     kp,K,p
              LDO     k,S,j
              CMP     t,k,kp
              BZ      t,2F

// error exit status 1
3H            SET     $255,1 
              TRAP    0,:Halt,0

// get next key from Head to verify
2H            LDOU    p,L,p

// increment index to next entry of expected result array Sorted
              ADD     j,j,8
0H            CMP     t,j,n

// fall through if end of Sorted array or of sorted links is reached
              BN      t,1B
              BNZ     p,3B

              PREFIX  :

// exit status 0
              SET     $255,0 
              TRAP    0,Halt,0


