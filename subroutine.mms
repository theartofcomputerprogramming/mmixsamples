// subroutine.mms
// examples of subroutine calls with PUSHJ and POP

// to aid section Subroutine calls in 1.3.1', Description of MMIX,
// from Chapter 1, Basic Concepts, of Fascicle 1, MMIX, by Donald Knuth

           LOC    Data_Segment
// an array at the beginning of the data segment
buf        GREG   @

// switch to code segment
           LOC    #100

// subroutine func expects 5 byte parameters in registers $0-$4
// it immediately writes the parameters to array in memory
func       STB    $0,buf
           STB    $1,buf,1
           STB    $2,buf,2
           STB    $3,buf,3
           STB    $4,buf,4

// func returns 6 byte values in registers $0-$5
// $5 or highest numbered return register gets first return value
// register $5 is the hole
           SET    $5,'r'

// extra return values are placed in registers $0 upward
           SET    $0,'e'
           SET    $1,'t'
           SET    $2,'u'
           SET    $3,'r'
           SET    $4,'n'

// func returns 6 registers $0-$5 to caller
// func returns to offset 0 to address in register rJ
           POP    6,0


// set local registers $0-$3
// Main intends to retain these values during function call
Main       SET    $0,'m'
           SET    $1,'a'
           SET    $2,'i'
           SET    $3,'n'

// register $4 is hole
// $4 will have the first return value from subroutine
// set $4 to some throwaway value
           SET    $4,'X'

// prepare 5 byte parameters to pass to func in registers $5-$9
           SET    $5,'p'
           SET    $6,'a'
           SET    $7,'r'
           SET    $8,'a'
           SET    $9,'m'

// save the four local registers $0-$3 and call func
// register $4 is overwritten with the number of saved registers i.e. 4
// register $4 is the hole, it will be inaccessible to func
// register $4 later will have the first return value
// registers $5, $6 and higher will be available to func as $0, $1 etc
// return address register rJ is set to @+4 i.e. next instruction
           PUSHJ  4,func

// get 6 return values from func in registers $4-$9
// write the values to array in memory
           STB    $4,buf,5
           STB    $5,buf,6
           STB    $6,buf,7
           STB    $7,buf,8
           STB    $8,buf,9
           STB    $9,buf,10

// write values saved in local registers $0-$3 before function call to memory
           STB    $0,buf,11
           STB    $1,buf,12
           STB    $2,buf,13
           STB    $3,buf,14

// halt
           TRAP  0,Halt,0

