;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "./ok/stringhe1.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/breadcaml/c64defs.asm"
caml_PRIM__caml_nonstd_print_char = 1
caml_PRIM__caml_fresh_oo_id = 1
caml_PRIM__caml_nonstd_print_string = 1
!source "/home/piero/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i54 caml_0004
caml_0001 +i67 13:+i5d 0:+i28 1
caml_0004 +i63:+i5d 1:+i2b 0,caml_0001:+i39 13:+i35 12:+i5d 2:+i63:+i36 13:+i21
          +i35 14:+i5d 2:+i63:+i36 13:+i21:+i35 15:+i5d 2:+i63:+i36 13:+i21
          +i35 16:+i5d 2:+i63:+i36 13:+i21:+i35 17:+i5d 2:+i63:+i36 13:+i21
          +i35 18:+i5d 2:+i63:+i36 13:+i21:+i35 19:+i5d 2:+i63:+i36 13:+i21
          +i35 20:+i5d 2:+i63:+i36 13:+i21:+i35 21:+i5d 2:+i63:+i36 13:+i21:+i8f
caml_program_end

!source "/home/piero/.opam/LTS/lib/breadcaml/runtime.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/memory.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_print_char)
	!byte <(caml_fresh_oo_id)
	!byte <(caml_nonstd_print_string)
caml_externals_hi
	!byte >(caml_nonstd_print_char)
	!byte >(caml_fresh_oo_id)
	!byte >(caml_nonstd_print_string)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
+p $0002:!h 01 00:+p $0084:+p $0106:+p $018a:+p $020e:+p $0294:+p $0396
+p $049a:+p $069a
caml_glob_data
!h fc 40 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 31 32 33 34 35 36 00 01 fc 40 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 31 32 33 34 35 36 37 00 fc 41 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 31 32
!h 33 34 35 36 37 38 00 01 fc 41 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 31 32 33 34 35 36 37 38 39 00 fc 42 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 31 32
!h 33 34 35 36 37 38 39 30 00 01 fc 80 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 31 32
!h 33 34 35 00 fc 81 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 31 32 33 34 35 36 00 01
!h fc ff 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 31 32
!h 33 34 35 36 37 38 00 01 fc ff 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 31 32 33 34 35 36 37 38 39 00
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/breadcaml/showmem.asm"
