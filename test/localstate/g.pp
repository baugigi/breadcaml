*******************
*****  Index  *****
*******************

<name>    <@>   <size>
CODE  1229936      104
PRIM  1230040        0
DATA  1230040      284
DLPT  1230324        0
DLLS  1230324        0
CRCS  1230324       99
DBUG  1230423        4
SYMB  1230427      290

*******************
***  Externals  ***
*******************


*********************
***  Global data  ***
*********************

0     [248| "Out_of_memory"  -1 |248]
1     [248| "Sys_error"  -2 |248]
2     [248| "Failure"  -3 |248]
3     [248| "Invalid_argument"  -4 |248]
4     [248| "End_of_file"  -5 |248]
5     [248| "Division_by_zero"  -6 |248]
6     [248| "Not_found"  -7 |248]
7     [248| "Match_failure"  -8 |248]
8     [248| "Stack_overflow"  -9 |248]
9     [248| "Sys_blocked_io"  -10 |248]
10    [248| "Assert_failure"  -11 |248]
11    [248| "Undefined_recursive_module"  -12 |248]
12    0

******************
***  Bytecode  ***
******************

0      @=0      BRANCH 5

1      @=2      GETGLOBAL 12 (* 0 *)
2      @=4      OFFSETREF 1
3      @=6      GETGLOBALFIELD 12 0
4      @=9      RETURN 1

5      @=11     CONST 1000
6      @=13     MAKEBLOCK 1 0
7      @=15     SETGLOBAL 12
8      @=17     CLOSURE 0 1
9      @=20     PUSHCONST 0
10     @=21     PUSHACC 1
11     @=22     APPLY 1
12     @=23     POP 1
13     @=25     STOP
