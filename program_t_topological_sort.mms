// program_t_topological_sort.mms

// Program T (Topological sort), 2.2.2 Sequential Allocation,
// The MMIX Supplement, Martin Ruckert


// usage: mmix program_t_topological_sort in.dat out.dat
// reads sequence of pairs of uint32_t values from in.dat
// each pair is a dependency relation between objects
// first value is predecessor, second is successor
// first pair is special: first value is 0, second is objects count
// last pair is special: both values are 0

              PREFIX  :TSort:

              LOC     :Data_Segment

// base address register for i/o buffer
              GREG    @

Fin           IS      3
Fout          IS      4
InName        BYTE    'a'  /* we fake input and output */
              BYTE    0
OutName       BYTE   'b' 
              BYTE    0

// open input filename stored in InName, in binary read mode
InOpen        OCTA    InName,:BinaryRead
// open output filename stored in OutName, in binary write mode
OutOpen       OCTA    OutName,:BinaryWrite

// buffer capacity in bytes
// each node is 2 tetras
// capacity is 256 nodes
SIZE          IS      256*2*4

// input buffer reused for output too
Buffer        TETRA   0,9,9,2,3,7,7,5,5,8,8,6,4,6,1,3,7,4,9,5,2,8,0,0

//Buffer        TETRA   0,3,1,2,1,3,0,0
//Sorted        TETRA   1,3,2,0

//Buffer        TETRA   0,9,9,2,3,7,7,5,5,8,8,6,4,6,1,3,7,4,9,5,2,8,0,0
//Sorted        TETRA   9,1,2,3,7,4,5,8,6,0

// reserve SIZE bytes for Buffer
              LOC     Buffer+SIZE

// base address register 
              GREG    @

Sentinel      OCTA    0        Terminates input buffer

// io parameters to fill input Buffer with SIZE bytes
IOArgs        OCTA    Buffer,SIZE

// start of avail memory allocation pool
Base          OCTA    0        Last OCTA in data segment.

// code segment
              LOC     #100

// the 3 lists

// sequentially allocated fixed list (array) of objects

// offset of COUNT field, holds number of predecessors
COUNT         IS      0
// offset of TOP field, link to list of successors, stack?
TOP           IS      4

// linked list of successor objects

// offset of SUC field, holds successor value
SUC           IS      0
// offset of NEXT field, link to next successor
NEXT          IS      4

// output queue of objects reusing original array of objects

// offset of QLINK field (reused COUNT field), link to next entry in queue
QLINK         IS      0

// register holds number of objects
n             IS      $0

// offset of next available node from allocation pool
:avail        IS      $1

// base address registers for COUNT and TOP fields
count         IS      $2
top           IS      $3

// base address registers for SUC and NEXT fields of successors list node
suc           IS      count
next          IS      top

// base address register for QLINK field of output queue
qlink         IS      count

// counter registers
i             IS      $4
j             IS      $5
k             IS      $6

// address of left tetra of pair
left          IS      $7
// address of right tetra of pair
right         IS      $8

// address of new node obtained from avail pool
p             IS      $9

// rear of queue is link index into array of objects
r             IS      $10

// register to hold successor value
s             IS      $12

// front of queue is link index into array of objects
f             IS      $13

// buffer capacity
size          IS      $14

// temporary register
t             IS      $15


// read input data
:TSort        LDA     $255,InOpen     01: T1 Initialize
              TRAP    0,:Fopen,Fin    02: Open input file

              LDA     $255,IOArgs     03:
              TRAP    0,:Fread,Fin    04: Read first input buffer

// prep to process input pairs
              SET     size,SIZE       05: Load buffer size

// initialize left and right to end of buffer to use negative indexing
              LDA     left,Buffer+SIZE   06: Point left to the buffer end
              ADDU    right,left,4    07: Point right to next TETRA

// i input pairs counter scaled to octabytes
// initialize i to -size use as negative offset from end of buffer
              NEG     i,size          08: i <- 0

// right of first pair is number of objects
              LDT     n,right,i       09: First pair is (0,n), n <- n

// increment i by size of 1 pair
              ADD     i,i,8           10: i <- i+1

// initialize avail memory allocation pool
// node size 8 bytes, two tetras for COUNT and TOP fields
              SET     :avail,8        11: Allocate QLINK[0]

// avail = 8*n + 8 = 8 * (n+1)
              8ADDU   :avail,n,:avail   12: Allocate n COUNT and TOP fields

// count is address of COUNT field of current node
              LDA     count,Base+COUNT  13: count <- LOC(COUNT[0])

// top is address of TOP field of current node
              LDA     top,Base+TOP    14: top <- LOC(TOP[0])

// initialize COUNT and TOP to 0 for all nodes
// k is current node index scaled to byte offset
// initialize k to n for reverse iteration
              SL      k,n,3           15: k <- n

// initialize both COUNT and TOP fields with one 0 octabyte
1H            STCO    0,k,count       16: Set (COUNT[k], TOP[k]) <- (0,0)

// count k down to zero
              SUB     k,k,8           17: for 0 <= k <= n

// branch likely taken because k runs sequentially from n to 0
              PBNN    k,1B            18: Anticipate QLINK[0] <- 0 (step T4)

// begin first iteration of loop to process input pairs
              JMP     T2              19:

// process one pair from input
// k has value of right of pair i.e. successor
T3            SL      k,k,3           20: T3 Record the relation

// update COUNT field of successor object
              LDT     t,k,count       21: Increase COUNT[k] by one
              ADD     t,t,1           22:
              STT     t,k,count       23:

// simplified AVAIL list
// p is new node from avail pool
              SET     p,:avail        24: P <= AVAIL

// update avail to sequentially next node in pool
              ADD     :avail,:avail,8   25:

              STT     k,suc,p         26: SUC(P) <- k

// scale j index to octabytes
              SL      j,j,3           27:

              LDTU    t,top,j         28: NEXT(P) <- TOP[j]
              STTU    t,next,p        29:

              STTU    p,top,j         30: TOP[j] <- P

// update left, right addresses to next pair
T2            LDT     j,left,i        31: T2 Next relation
              LDT     k,right,i       32:

// count up to zero bytes
              ADD     i,i,8           33: i <- i+1

// branch likely taken because input buffer is traversed sequentially
              PBNZ    j,T3            34: End of input or buffer?

// branch likely untaken
1H            BNP     i,T4            35: End of input?

// refill buffer with more input data
              TRAP    0,:Fread,Fin    36: Read next buffer

// reinitialize i to -size for negative indexing from end of buffer
              NEG     i,size          37: i <- 0
              JMP     T2              38:

T4            TRAP    0,:Fclose,Fin   39: T4 Scan for zeros

// end of input phase

// begin topological sort

// fill queue of objects with zero predecessors
// initialize rear of queue to zero
              SET     r,0             40: R <- 0

// k current node index scaled to octabytes
// initialize k to n for reverse iteration over array of objects
              SL      k,n,3           41: k <- n

// check object predecessor count
1H            LDT     t,k,count       42: Examine COUNT[k],

// branch likely taken
              PBNZ    t,0F            43: and if it is zero,

// object has no predecessors
// insert object value at rear of queue
// update rear to object index
              STT     k,qlink,r       44: set QLINK[R] <- k,
              SET     r,k             45: and R <- k

// decrement k by 1 octabyte toward zero
0H            SUB     k,k,8           46:
              PBP     k,1B            47: For n >= k > 0

// f is front of queue
              LDT     f,qlink,0       48: F <- QLINK[0]

// prepare to output sorted list
              LDA     $255,OutOpen    49: Open output file
              TRAP    0,:Fopen,Fout   50:

// initialize i to negative size to offset from buffer end
              NEG     i,size          51: Point i to the buffer start

              JMP     T5              52:

// branch likely taken
T5B           PBN     i,0F            53: Jump if buffer is not full

              LDA     $255,IOArgs     54:
              TRAP    0,:Fwrite,Fout    55: Flush output buffer

              NEG     i,size          56: Point i to the buffer start
0H            SUB     n,n,1           57: n <- n-1

              LDTU    p,top,f         58: P <- TOP[F]

              BZ      p,T7            59: If P = Lambda go to T7

T6            LDT     s,suc,p         60: T6 Erase relations

              LDT     t,s,count       61: Decrease COUNT[SUC(P)]
              SUB     t,t,1           62:
              STT     t,s,count       63:

              PBNZ    t,0F            64: If zero,

              STT     s,qlink,r       65: set QLINK[R] <- SUC(P),
              SET     r,s             66: and R <- SUC(P)
0H            LDT     p,next,p        67: P <- NEXT(P)

              PBNZ    p,T6            68: If P = Lambda go to T7


T7            LDT     f,qlink,f       69: T7 Remove from queue

T5            SR      t,f,3           70: T5 Output front of queue

              STT     t,left,i        71: Output the value of F

              ADD     i,i,4           72:

              PBNZ    f,T5B           73: If F = 0 go to T8

T8            LDA     $255,IOArgs     74: T8 End of process
              TRAP    0,:Fwrite,Fout    75: Flush output buffer
              TRAP    0,:Fclose,Fout    76: Close output file

              POP     1,0             77: Return n

              PREFIX  :


Main          PUSHJ    $0,TSort

// set exit status to TSort return value in $0
              SET      $255,$0
// halt
              TRAP     0,Halt,0

