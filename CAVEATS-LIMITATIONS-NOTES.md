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
  since OCaml uses the ASCII  and ISO 8859-1 standards, while the
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
  **C64lib.BigArray** module.

* **VARIANTS:**
  each  variant  type  may  have  at  most  **246  non-constant**
  and **32768 constant** constructors.

* **POLYMORPHIC VARIANTS:**
  a maximum  of **32768** different polymorphic variant tags  may
  be specified  globally in  all compilation  units.

* **FUNCTIONS:**
  the number of arguments plus the environment size cannot exceed
  **128**, due to the block size limit.

* **RECURSIVE DEFINITIONS:**
  no  more than  **127 values**  in a  `let rec ... and ...`  are
  admitted, due to the block size limit.

* **EXTERNAL PRIMITIVES:**
  **256 maximum**; if  you need more, you need  to factorize them
  by adding  extra arguments.
  Developers should  be aware of the  BreadCaml C_CALL semantics:
  the environment is not pushed onto the stack; all arguments are
  pushed  but the first; the  result is  assumed to be  stored in
  Accumulator by the primitive.
