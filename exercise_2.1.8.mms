// exercise_2.1.8.mms

// solution to exercise 2.1.8 from The MMIX Supplement

// NEXT field offset is 0
NEXT       IS     0

// LAMBDA or NULL is 0
LAMBDA     IS     0

// card counter
n          IS     $0

// next card
next       IS     $1

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
           OCTA   LAMBDA
// 10 of diamonds, face down
           BYTE   #80,1,10," 10 D"

           OCTA   @-2*8
// 3 of spades, face up
           BYTE   #00,4,3,"  3 S"

// top of card pile
           OCTA   @-2*8
// 2 of diamonds, face up
           BYTE   #00,2,2,"  2 D"

           LOC    #100

// initialize card count
Main       SET    n,0

// start with top of card pile
           LDOU   next,TOP

// check for bottom of card pile
0H         BZ     next,1F

// increment card count
           INCL   n,1

// update next pointer
           LDOU   next,next,NEXT

// loop back
           JMP    0B

// write card pile size
1H         STOU   n,N

           TRAP   0,Halt,0

