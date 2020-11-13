// program_a_addition_of_polynomials.mms

// Program A (addition of polynomials), 2.2.4 Circular Lists
// The MMIX Supplement, Martin Ruckert

// Copyright: This file is part of the MMIX Supplement package
// (c) Martin Ruckert 2014

// node layout little different from p.25
// 3 octas = 3*8 = 24 bytes
// S is sign bit, A, B, C, D are exponents of x, y, z, w
//   7   6   5   4   3   2   1   0
//  --- --- --- --- --- --- --- ---
// |             LINK              |
//  --- --- --- --- --- --- --- ---
// |S|  A  |   B   |   C   |   D   |
//  --- --- --- --- --- --- --- ---
// |             COEF              |
//  --- --- --- --- --- --- --- ---

              LOC     Data_Segment
// base address register
              GREG    @

// address: 0x2000 0000 0000 0000
// polynomial P: 5xy + 7x + 7yz + 20
// 1F is address of local symbol 1H in forward direction
// P points to special node at end of polynomial with ABC = -1
P             OCTA    1F,-1,0

// first term of polynomial: 5xy
1H            OCTA    1F; WYDE 1,1,0,0; OCTA 5 

// second term of polynomial: 7x
1H            OCTA    1F; WYDE 1,0,0,0; OCTA 7

// third term of polynomial: 7yz
1H            OCTA    1F; WYDE 0,1,1,0; OCTA 7

// fourth and last term of polynomial: 20
// links to special node
1H            OCTA    P;  WYDE 0,0,0,0; OCTA 20 

// address: 0x2000 0000 0000 0078
// polynomial Q: 3xy - 7yz + 3y - 20
Q             OCTA    1F,-1,0
1H            OCTA    1F; WYDE 1,1,0,0; OCTA 3 
1H            OCTA    1F; WYDE 0,1,1,0; OCTA -7
1H            OCTA    1F; WYDE 0,1,0,0; OCTA 3
1H            OCTA    Q;  WYDE 0,0,0,0; OCTA -20 

// address: 0x2000 0000 0000 00f0
// result verification polynomial S: 8xy + 7x + 3y
S             OCTA    1F,-1,0
1H            OCTA    1F; WYDE 1,1,0,0; OCTA 8 
1H            OCTA    1F; WYDE 1,0,0,0; OCTA 7
1H            OCTA    S; WYDE 0,1,0,0; OCTA 3

// base address register
              GREG    @

// address: 0x2000 0000 0000 0150
// storage pool nodes
Free          OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    1F,0,0
1H            OCTA    0,0,0

// for global storage pool base address
avail         GREG    0


              PREFIX  :Add:

COEF          IS      16    Definition of coefficient field
ABC           IS      8     Definition of ABC exponent field
LINK          IS      0     Definition of link field

p             IS      $0     
q             IS      $1    

q1            IS      $2    Q1
q2            IS      $3
abcp          IS      $4    ABC(P)
coefp         IS      $5    coefficient P
coefq         IS      $6    coefficient Q
t             IS      $7    temporary variable t

              LOC     #100

// add polynomials P and Q passed in registers $0 and $1
// Q is modified in place to contain sum
:Add          SET     q1,q            01: A1 Initialize Q1 <- Q

              LDOU    q,q,LINK        02: Q <- LINK(Q)
0H            LDOU    p,p,LINK        03: P <- LINK(P)

              LDO     coefp,p,COEF    04: coefp <- COEF(P)

              LDO     abcp,p,ABC      05: A2 ABC(P): ABC(Q)

// main loop
2H            LDO     t,q,ABC         06: t <- ABC(Q)

              CMP     t,abcp,t        07: Compare ABC(P) and ABC(Q)

// zero means terms must be summed
              BZ      t,A3            08: If equal, go to A3

// P term bigger than Q term means term must be inserted
              BP      t,A5            09: If greater, go to A5

// P term less than Q term means go to next term of Q
              SET     q1,q            10: If less, set Q1 <- Q

              LDOU    q,q,LINK        11: Q <- LINK(Q)

              JMP     2B              12: Repeat

// negative exponent means at end of P and done
A3            BN      abcp,6F         13: A3 Add coefficients

// add two terms
              LDO     coefq,q,COEF    14: coefq <- COEF(Q)

              ADD     coefq,coefq,coefp    15: coefq <- coefq + coefp

              STO     coefq,q,COEF    16: COEF(Q) <- COEF(Q) + COEF(P)

              PBNZ    coefq,:Add      17: Jump if nonzero

// sum is zero
              SET     q2,q            18: A4 Delete zero term Q2 <- Q

              LDOU    q,q,LINK        19: Q <- LINK(Q)

              STOU    q,q1,LINK       20: LINK(Q1) <- Q

// return node to avail pool
              STOU    :avail,q2,LINK  21:

              SET     :avail,q2       22: AVAIL <= Q2

// go to next term of P
              JMP     0B              23: Go to advance P

// insert new term
A5            SET     q2,:avail       24: A5 Insert new term

// get new node from avail pool
              LDOU    :avail,:avail,LINK    25: Q2 <= AVAIL

              STO     coefp,q2,COEF   26: COEF(Q2) <- COEF(P)

              STOU    abcp,q2,ABC     27: ABC(Q2) <- ABC(P)

              STOU    q,q2,LINK       28: LINK(Q2) <- Q

              STOU    q2,q1,LINK      29: LINK(Q1) <- Q2

              SET     q1,q2           30: Q1 <- Q2

// go to next term of P
              JMP     0B              31: Go to advance P

6H            POP     0,0             32: Return from subroutine

              PREFIX  :


// initialize storage pool
Main          LDA     avail,Free
              LDA     $1,P
              LDA     $2,Q
              PUSHJ   $0,Add    

              LDA     $1,S
              LDA     $2,Q
              PUSHJ   $0,Compare    
              BNZ     $0,Fail

              SET     $255,0
              TRAP    0,Halt,0

Fail          SET     $255,1

// halt
              TRAP    0,Halt,0

              PREFIX  :CompPoly
COEF          IS      16           Definition of coefficient field
ABC           IS      8            Definition of ABC exponent field
LINK          IS      0            Definition of link field

S             IS      $0
Q             IS      $1
xS            IS      $2
xQ            IS      $3
cS            IS      $4
cQ            IS      $5
t             IS      $6

:Compare      LDOU    S,S,LINK
              LDOU    Q,Q,LINK
              LDO     xS,S,ABC    
              LDO     xQ,Q,ABC
              CMP     t,xS,xQ
              BNZ     t,Fail
              LDO     cS,S,COEF
              LDO     cQ,Q,COEF
              CMP     t,cS,cQ
              BNZ     t,Fail
              BNN     xQ,:Compare
              POP     0,0

Fail          SET     $0,1    
              POP     1,0

              PREFIX  :

