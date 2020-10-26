// exercise_2.1.8.mms

// solution to exercise 2.1.8 from The MMIX Supplement

// NEXT field offset is 0
NEXT       IS     0

// LAMBDA or NULL is 0
LAMBDA     IS     0

// register for card count variable N
n          IS     $0

// register for link variable X pointing to next card
x          IS     $1

           LOC    Data_Segment
// base address for assembler to use for data symbols
           GREG   @

// final answer
N          OCTA   0

// address of top of card pile
TOP        OCTA   @+6*8

// garbage
           OCTA   -1

// card pile as shown in figure (2) in section 2.1 of The MMIX Supplement
// bottom of card pile
// 10 of diamonds, face down
           OCTA   LAMBDA
           BYTE   #80,1,10," 10 D"

// 3 of spades, face up
           OCTA   @-2*8
           BYTE   #00,4,3,"  3 S"

// top of card pile
// 2 of diamonds, face up
           OCTA   @-2*8
           BYTE   #00,2,2,"  2 D"

           LOC    #100

// initialize card count
Main       SET    n,0         B1: N <- 0

// start with top of card pile
           LDOU   x,TOP       B1: X <- TOP

// check for bottom of card pile
0H         BZ     x,Stop      B2: Stop if X = LAMBDA

// increment card count
           INCL   n,1         B3: N <- N + 1

// update link variable X
           LDOU   x,x,NEXT    B3: X <- NEXT(X)

// loop back
           JMP    0B          B3: To B2

// write card pile size
Stop       STOU   n,N         N is number of cards in pile

           TRAP   0,Halt,0

