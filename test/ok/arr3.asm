;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "./ok/arr3.prg", cbm
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

caml_0000 +i54 caml_0015
caml_0001 +i35 12:+i36 13:+i25 2
caml_0004 +i00:+i4f:+i7f -1:+i68:+i0c:+i5e 0:+i0b:+i0d:+i5e 0:+i68:+i0e:+i5f 1
          +i00:+i0c:+i0e:+i5f 1:+i28 3
caml_0015 +i2b 0,caml_0004:+i39 13:+i35 14:+i5d 2:+i09:+i39 12:+i00:+i13 1:+i09
          +i2b 0,caml_0001:+i68:+i0b:+i21:+i63:+i0c:+i5e 3:+i13 2:+i8f
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
!h 01 00 01 00:+p $0002
caml_glob_data
!h 00 05 03 00 05 00 07 00 09 00 0b 00
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/breadcaml/showmem.asm"
