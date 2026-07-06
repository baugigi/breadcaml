;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "./ok/arr4.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/breadcaml/c64defs.asm"
caml_PRIM__caml_array_get = 1
caml_PRIM__caml_array_set = 1
caml_PRIM__caml_obj_dup = 1
caml_PRIM__caml_array_get_addr = 1
!source "/home/piero/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i54 caml_002b
caml_0001 +i00:+i4f:+i0a:+i68:+i7a:+i56 caml_0028:+i63:+i0c:+i5e 0:+i68:+i0c
          +i7f -2:+i09:+i0c:+i7d:+i55 caml_0020
caml_0011 +i5c:+i01:+i7f 1:+i0f:+i5e 0:+i0c:+i10:+i5f 1:+i01:+i09:+i7f 1:+i14 2
          +i01:+i7a:+i55 caml_0011
caml_0020 +i63:+i13 2:+i00:+i0c:+i7f -1:+i0e:+i5f 1:+i13 1
caml_0028 +i13 1:+i00:+i28 1
caml_002b +i2b 0,caml_0001:+i36 12:+i5d 2:+i68:+i0b:+i0d:+i21:+i5e 3:+i13 1
          +i13 1:+i8f
caml_program_end

!source "/home/piero/.opam/LTS/lib/breadcaml/runtime.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/memory.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_array_get)
	!byte <(caml_array_set)
	!byte <(caml_obj_dup)
	!byte <(caml_array_get_addr)
caml_externals_hi
	!byte >(caml_array_get)
	!byte >(caml_array_set)
	!byte >(caml_obj_dup)
	!byte >(caml_array_get_addr)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
+p $0002
caml_glob_data
!h 00 0a 01 00 03 00 05 00 07 00 09 00 0b 00 0d 00 0f 00 11 00 13 00
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/breadcaml/showmem.asm"
