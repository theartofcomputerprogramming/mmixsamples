// exercise_2.1.9.mms

// solution to exercise 2.1.9 from The MMIX Supplement

// NEXT field offset is 0
NEXT          IS     0
TAG           IS     8
TITLE         IS     11

// LAMBDA or NULL is 0
LAMBDA        IS     0
TITLE_LEN     IS     5

// card
x             IS     $0
tag           IS     $1

// temp
t             IS     $255

              LOC    Data_Segment
// base address for data symbols
              GREG   @

NL            BYTE   #0a,0
LP            BYTE   '(',0
RP            BYTE   ')',0

Arg           OCTA   0,TITLE_LEN
// address of top of card pile
TOP           OCTA   @+5*8

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


// PrintCards subroutine
// check valid address of card
PrintCards    BNZ    x,0F

// return if null
              POP    0,0

// get tag field
0H            LDB    tag,x,TAG

// tag = 0 means face up
              BZ     tag,1F
// print leftparen for face down
              LDA    t,LP
              TRAP   0,Fputs,StdOut

// print title
1H            LDA    t,x,TITLE
              STOU   t,Arg
              LDA    t,Arg
              TRAP   0,Fwrite,StdOut

// tag = 0 is face up
              BZ     tag,2F
// print rightparen for face down
              LDA    t,RP
              TRAP   0,Fputs,StdOut

// print newline
2H            LDA    t,NL
              TRAP   0,Fputs,StdOut

// get next card
              LDOU   x,x,NEXT
// loop back
              JMP    PrintCards

// main
// get top card
Main          LDOU   $1,TOP

// pass top card in register 1 to PrintCards
              PUSHJ  0,PrintCards

              TRAP   0,Halt,0

