# CAVEATS - LIMITATIONS - NOTES:

* **STANDARD LIBRARY:**
  The  BreadCaml  version is  nearly  compatible  with the  OCaml
  Stdlib,  but some  modules  are  unimplemented, only  partially
  implemented, or exhibit significant differences.  
  Please consult the BreadCaml `Stdlib` documentation.

* **CLASSES AND OBJECTS:**
  _not implemented_, as they  would be excessively expensive in
  terms of required memory.

* **INTEGERS:**
  BreadCaml `int`  values are represented as  15-bit integers, so
  they are limited to the `[-16384, 16383]` interval.

* **FLOATS:**
  BreadCaml uses  the _C64 "MFLP" representation_,  with a 24-bit
  mantissa  and  an  8-bit  exponent, and  relies  on  BASIC  ROM
  routines for most operations.  
  See  the `Stdlib`  and `Float`  modules documentation  for more
  info.

*  **CHARS AND  STRINGS:**
  since  OCaml  interprets  `char`  values ​​using  the  ASCII  and
  ISO/IEC 8859-1 standards, whereas the Commodore 64 uses PETSCII
  character sets, the BreadCaml  preprocessor converts all string
  and character literals in the source code to PETSCII.  
  The BreadCaml  library is also  based on the  PETSCII standard;
  the   original  OCaml   definitions   are   provided  via   the
  `Char.ASCII` and `String.ASCII` modules.  
  The maximum string  length is `509` characters,  as the maximum
  BreadCaml block  size is 255  words (i.e., 509  characters plus
  the trailing null byte).

* **TUPLES, RECORDS, ARRAYS:**
  limited  to  a  maximum  `255` elements,  due  to  the  maximum
  BreadCaml block  size. Unboxed  float arrays  may have  no more
  than `85` elements.  
  The  OCaml `Bigarray`  module  is not  implemented; for  larger
  arrays, see the provided `Largearray` module instead.

* **VARIANTS:**
  each  variant type  may  have at  most  `246` non-constant  and
  `32768` constant constructors.

* **POLYMORPHIC  VARIANTS:**
  since  polymorphic variant  tags are  converted into  63-bit or
  31-bit  integers by  the  OCaml compiler's  hash function,  the
  BreadCaml  preprocessor remaps  them to  tags whose  hash is  a
  15-bit  integer.   A global  database  is  used to  ensure  the
  consistency  of  this  transformation  across  all  compilation
  units.  
  Consequently, a maximum of `32768` distinct polymorphic variant
  tags  can be  specified across  all compilation  units.  
  Please consult the compiler's man page for further information.

* **FUNCTIONS:**
  the number of arguments plus the environment size cannot exceed
  `128`, due to the block size limit.

* **RECURSIVE DEFINITIONS:**
  no  more than  `127` values  in a  `let rec  ... and  ...`  are
  admitted, due to the block size limit.

* **EXTERNAL PRIMITIVES:**
  a maximum  of `256` external primitives  is supported;  if your
  program requires  more, you should attempt  refactoring them by
  parameterization.  
  Developers should  be aware of the  BreadCaml C_CALL semantics:
  the environment is not pushed onto the stack; all arguments are
  pushed but  the first; the  result is  assumed to be  stored in
  Accumulator by the primitive.
