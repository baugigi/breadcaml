# CAVEATS - LIMITATIONS - NOTES:

* **STANDARD LIBRARY:**
  the BreadCaml one  is almost compatible with  OCaml Stdlib, but
  some modules  are not  implemented.  Please read  the BreadCaml
  Stdlib manpages.

* **CLASSES AND OBJECTS:**
  **not implemented**, as they  would be excessively expensive in
  terms of required memory.

* **INTEGERS:**
  limited to the **[-16384, 16383]** interval.

* **FLOATS:**
  BreadCaml uses  the _C64 "MFLP" representation_,  with a 24-bit
  mantissa  and  an  8-bit  exponent, and  relies  on  BASIC  ROM
  routines for most operations.  See the **Stdlib** and **Float**
  modules documentation for more info.

* **CHARS:**
  Since OCaml uses the ASCII  and ISO 8859-1 standards, while the
  Commodore 64 uses the [PETSCII](https://en.wikipedia.org/wiki/PETSCII)
  character  sets,   programmers  should   be  aware   that  some
  conversions may be necessary.
  
* **STRINGS:**
  the maximum string length is **509 characters**, as the maximum
  BreadCaml block  size is 255  words (i.e., 509  characters plus
  the trailing null byte).

* **TUPLES, RECORDS, ARRAYS:**
  limited to  a maximum of  **255 elements**, due to  the maximum
  BreadCaml block  size.  Unboxed float  arrays may have  no more
  than **85 elements**.  For larger arrays, see also the provided
  **C64.BigArray** module.

* **VARIANTS:**
  each  variant  type  may  have  at  most  **246  non-constant**
  and **32768 constant** constructors.

* **FUNCTIONS:**
  the number of arguments plus the environment size cannot exceed
  **128**, due to the block size limit.

* **RECURSIVE DEFINITIONS:**
  no  more than  **127 values**  in a  `let rec ... and ...`  are
  admitted, due to the block size limit.

* **POLYMORPHIC VARIANTS:**
  the set of admitted polymorphic variants is restricted to  
  `` `( [A-Z] | [A-H][_'0-9A-Za-z] | I[_'0-9A-Za-g] ) `` i.e., 
  
  |             |             |                         |**`` `A  `` ... `` `Z``**|                         |
  |:-----------:|:-----------:|:-----------------------:|:-----------------------:|:-----------------------:|
  |**`` `A_ ``**|**`` `A' ``**|**`` `A0 ``...`` `A9 ``**|**`` `AA ``...`` `AZ ``**|**`` `Aa ``...`` `Az ``**|
  |      ⋮      |      ⋮      |            ⋮            |            ⋮            |            ⋮            |
  |      ⋮      |      ⋮      |            ⋮            |            ⋮            |**`` `Ha ``...`` `Hz ``**|
  |**`` `I_ ``**|**`` `I' ``**|**`` `I0 ``...`` `I9 ``**|**`` `IA ``...`` `IZ ``**|**`` `Ia ``...`` `Ig ``**|
  |             |             |                         |                         |                         |
  
  since they  are represented  in memory  with integers  using an
  OCaml internal hash function.
  
  Coming  soon: a  PPX  rewriter to  pre-process  OCaml code  and
  rename all polymorphic variants in the lambda-code properly.

* **EXTERNAL PRIMITIVES:**
  **256 maximum**; if  you need more, you need  to factorize them
  by adding  extra arguments.
  
  Developers should  be aware of the  BreadCaml C_CALL semantics:
  the environment is not pushed onto the stack; all arguments are
  pushed but  the first; the  result is  assumed to be  stored in
  Accumulator by the primitive.


## SOME NOTES ON THE BYTECODE EMITTED BY THE OCaml COMPILER:

* **RETURN:**
  A function  might be  called with more  arguments on  the stack
  than expected. If there is  any extra argument, RETURN does not
  give control back to the caller: instead, it assumes that there
  is a closure in the accumulator and gives it immediate control.

* **RESTART and GRAB:**
  GRAB checks  that the caller  passed enough arguments  onto the
  stack. If not,  it creates a closure, stores  all the available
  arguments in  it, points  the closure  code to  the instruction
  just  before GRAB  (which is  assumed  to be  a RESTART),  then
  returns to  the caller, as  if executing a  RETURN instruction.
  When the new closure is called, RESTART will push the arguments
  onto the stack again and fallthrough GRAB.

* **PUSHRETADDR and APPLY n, APPLY1, APPLY2, APPLY3:**
  A closure  application to  n arguments  is usually  compiled by
  ocamlc  by  emitting a  PUSHRETADDR  (which  pushes the  return
  address onto the stack),  followed by instructions that compute
  and push the arguments, and finally an APPLY n instruction that
  jump to  the closure  code; but  when n <  4, ocamlc  skips the
  PUSHRETADDR:  its work  is left  up  to APPLY1  (or APPLY2,  or
  APPLY3).
