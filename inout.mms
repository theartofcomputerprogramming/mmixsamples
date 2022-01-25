// inout.mms

// Example from 1.4.2' Coroutines, Fascicle 1, MMIX, by Donald Knuth
// Based on https://github.com/theartofcomputerprogramming/mmixware/blob/githubmaster/inout.mms
// Reformatted with comments from Fascicle 1
// sample input on stdin: a2b5e3426fg0zyw3210pq89r.
// sample output on stdout: abb bee eee e44 446 66f gzy w22 220 0pq 999 999 999 r.

// * Coroutine example for 1.4.2

// 01: * An example of coroutines
// $255 is already available as the first global register
t             IS    $255              02: Temporary data of short duration

// in is $254
in            GREG                 // 03: Address for resuming the first coroutine

// out is $253
out           GREG                 // 04: Address for resuming the second coroutine

// 05: * Input and output buffers
              LOC  Data_Segment       06:
// $252 holds base address for output and input buffer symbols
              GREG  @                 07: Base address
// OutBuf is output buffer of tetras initialized to 15 spaces, newline, terminating null
// each character of the string is separate tetra
// tetra is used for convenient compact initialization
// because output is groups of 3 characters separated by space
// so plan is for each tetra to hold one group
// the three output characters will go into high bytes 0, 1, 2 of tetra
OutBuf        TETRA "               ",#a,0     08: (see exercise 3)

Period        BYTE  '.'               09:
// two arguments for Fgets, input destination buffer, bytes to read
InArgs        OCTA  InBuf,1000        10:
// InBuf is input buffer filled by Fgets
// InBuf is address of this location which is two octas past OutBuf and period
// note this location is still in data segment but the next assembler directive
// changes the location to 0x100 which is where code usually starts out in the text segment
// InBuf is last address used in data segment so there's more than enough bytes
// available for 1000-byte buffer
InBuf         LOC   #100              11:

// 12: * Subroutine for character input
// inptr is $251
inptr         GREG                 // 13: (the current input position)
1H            LDA   t,InArgs          14: Fill the input buffer
              TRAP  0,Fgets,StdIn     15:
              LDA   inptr,InBuf       16: Start at beginning of buffer
// $250 is period character
// why not Period IS '.'? because CSN does not take constants?
0H            GREG  Period            17:

// set input buffer pointer to address of Period constant if Fgets returned error
// period signals end of input
// so NextChar always returns valid character
              CSN   inptr,t,0B        18: If error occurred, read a '.'

// NextChar subroutine called with PUSHJ, has own local registers on register stack
// $0 has new byte
NextChar      LDBU  $0,inptr,0        19: Fetch the next character
// increment position in input buffer
              INCL  inptr,1           20:
// terminating null
// refill buffer
// works first time because all memory is zeroed out at startup except for assembled program
              BZ    $0,1B             21: Branch if at end of buffer
              CMPU  t,$0,' '          22:
// skip whitespace
              BNP   t,NextChar        23: Branch if character is whitespace
// return one character in $0
              POP   1,0               24: Return to caller

// 25: * First coroutine
// In1 is the input parsing coroutine
// count is $249
count         GREG                 // 26: (the repetition counter)

1H            GO    in,out,0          27: Send a character to the Out coroutine

In1           PUSHJ $0,NextChar       28: Get a new character
              CMPU  t,$0,'9'          29:
// nondigit
              PBP   t,1B              30: Branch if it exceeds '9'
              SUB   count,$0,'0'      31:
// nondigithttps://research.swtch.com/duff
              BN    count,1B          32: Branch if it is less than '0'

// now count $249 has digit
// next character must be repeated
// call NextChar subroutine, saving no registers, return value will be in $0
              PUSHJ $0,NextChar       33: Get another character

// switch to return location in Out1 coroutine, address of next instruction to return to is placed in in $254
// return value character is in $0
1H            GO    in,out,0          34: Send it to Out

// In2
              SUB   count,count,1     35: Decrease the repetition counter
              PBNN  count,1B          36: Repeat if necessary
// loop back to repeatedly pass character to Out1 coroutine
              JMP   In1               37: Otherwise begin a new cycle

// 38: * Second coroutine
// Out1 is the output formatting coroutine
// outptr $248 is current output position
outptr        GREG                 // 39: (the current output position)

1H            LDA   t,OutBuf          40: Empty the output buffer
              TRAP  0,Fputs,StdOut    41:

Out1          LDA   outptr,OutBuf     42: Start at beginning of buffer

// switch to return location in In1 coroutine kept in in $254
// address of next instruction to return to here is placed in out $253
2H            GO    out,in,0          43: Get a new character from In

// Out2
// $0 has character returned by In1
              STBU  $0,outptr,0       44: Store it as the first of three
              CMP   t,$0,'.'          45:

              BZ    t,1F              46: Branch if it was '.'

              GO    out,in,0          47: Otherwise get another character

// Out3
              STBU  $0,outptr,1       48: Store it as the second of three
              CMP   t,$0,'.'          49: Branch if it was '.'
              BZ    t,2F              50: Otherwise get another character

              GO    out,in,0          51: Store it as the third of three

// Out4
              STBU  $0,outptr,2       52:
              CMP   t,$0,'.'          53: Branch if it was '.'
              BZ    t,3F              54:
              INCL  outptr,4          55: Otherwise advance to next group
// $247
0H            GREG  OutBuf+4*16       56:
              CMP   t,outptr,0B       57:
              PBNZ  t,2B              58: Branch if fewer than 16 groups

              JMP   1B                59: Otherwise finish the line

3H            INCL  outptr,1          60: Move past a stored character
2H            INCL  outptr,1          61: Move past a stored character
// $246 is newline
0H            GREG  #a                62: (newline character)
1H            STBU  0B,outptr,1       63: Store newline after period
// $245 is null
0H            GREG  0                 64: (null character)
              STBU  0B,outptr,2       65: Store null after newline

              LDA   t,OutBuf          66:
              TRAP  0,Fputs,StdOut    67: Output the final line
              TRAP  0,Halt,0          68: Terminate the program

// 69: * Initialization
Main          LDA   inptr,InBuf       70: Initialize NextChar
              GETA  in,In1            71: Initialize In
              JMP   Out1              72: Start with Out (see exercise 2)
