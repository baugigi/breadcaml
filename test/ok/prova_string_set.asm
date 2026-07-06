;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "./ok/prova_string_set.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/breadcaml/c64defs.asm"
caml_PRIM__caml_nonstd_print_char = 1
caml_PRIM__caml_fresh_oo_id = 1
caml_PRIM__caml_ml_string_length = 1
caml_PRIM__caml_string_set = 1
caml_PRIM__caml_create_string = 1
caml_PRIM__caml_nonstd_print_string = 1
!source "/home/piero/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i54 caml_0004
caml_0001 +i67 13:+i5d 0:+i28 1
caml_0004 +i63:+i5d 1:+i2b 0,caml_0001:+i39 12:+i54 caml_002a
caml_0009 +i00:+i5d 2:+i6c 42:+i68:+i0d:+i5f 3:+i00:+i7f -1:+i69:+i09:+i0c:+i7b
          +i55 caml_0026
caml_0016 +i5c:+i67 10:+i0c:+i72:+i6c 48:+i6e:+i0c:+i0f:+i5f 3:+i01:+i09:+i7f -1
          +i14 2:+i01:+i7a:+i55 caml_0016
caml_0026 +i63:+i13 2:+i01:+i28 2
caml_002a +i64:+i6c 20:+i09:+i0c:+i7d:+i55 caml_005c
caml_0030 +i5c:+i01:+i5d 4:+i6c 42:+i68:+i0c:+i5f 3:+i02:+i7f -1:+i69:+i09:+i0c
          +i7b:+i55 caml_004e
caml_003e +i5c:+i67 10:+i0c:+i72:+i6c 48:+i6e:+i0c:+i0e:+i5f 3:+i01:+i09:+i7f -1
          +i14 2:+i01:+i7a:+i55 caml_003e
caml_004e +i13 2:+i00:+i13 1:+i5d 5:+i63:+i36 12:+i21:+i01:+i09:+i7f 1:+i14 2
          +i01:+i7a:+i55 caml_0030
caml_005c +i13 2:+i2b 0,caml_0009:+i36 13:+i0b:+i21:+i5d 5:+i63:+i36 12:+i21
          +i13 1:+i8f
caml_program_end

!source "/home/piero/.opam/LTS/lib/breadcaml/runtime.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/memory.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_print_char)
	!byte <(caml_fresh_oo_id)
	!byte <(caml_ml_string_length)
	!byte <(caml_string_set)
	!byte <(caml_create_string)
	!byte <(caml_nonstd_print_string)
caml_externals_hi
	!byte >(caml_nonstd_print_char)
	!byte >(caml_fresh_oo_id)
	!byte >(caml_ml_string_length)
	!byte >(caml_string_set)
	!byte >(caml_create_string)
	!byte >(caml_nonstd_print_string)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
!h 01 00:+p $0002
caml_glob_data
!h fc 1e 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78
!h 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78 78
!h 78 78 78 78 78 78 78 78 78 78 78 78 78 00
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/breadcaml/showmem.asm"
