// exercise_2.1.7.mms

// solution to exercise 2.1.7 from The MMIX Supplement

// SUIT field offset is 9
SUIT       IS     9

// LAMBDA or NULL is 0
LAMBDA     IS     0

// temporary register for exercise choice a
ta         IS     $0

// temporary register for exercise choice b
tb         IS     $1

// temporary register for exercise choice c
tc         IS     $2

           LOC    Data_Segment
// base address for assembler to determine address of TOP
           GREG   @

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

// a) wrong
// LDA loads address of TOP into register ta
// works because address of TOP is known to assembler via GREG
Main       LDA    ta,TOP

// ta+SUIT is offset to TOP which is some location right after TOP
// byte is loaded from an address unrelated to card pile
// ta = -1
           LDB    ta,ta,SUIT

// b) wrong
// TOP and SUIT are known to assembler so TOP+SUIT is some location after TOP
           LDA    tb,TOP+SUIT

// again byte is loaded from address unrelated to card pile
// tb = -1
           LDB    tb,tb,0

// c) right
// octabyte at address of TOP i.e. CONTENTS(TOP) is loaded into register tc
// this octabyte is the address of the top card
           LDOU   tc,TOP

// byte is loaded from tc+SUIT that is the value of the SUIT field
// tc = 2
           LDB    tc,tc,SUIT

           TRAP   0,Halt,0

