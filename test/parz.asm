;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "parz.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/pifu/.opam/4.14.3/lib/o64ml/c64defs.asm"
caml_PRIM__caml_nonstd_print_string = 1
caml_PRIM__caml_nonstd_print_char = 1
caml_PRIM__caml_fresh_oo_id = 1
caml_PRIM__caml_nonstd_string_of_int = 1
!source "/home/pifu/.opam/4.14.3/lib/o64ml/loader.asm"
!source "/home/pifu/.opam/4.14.3/lib/o64ml/codegen.asm"

caml_program

caml_0000 +i54 caml_0009
caml_0001 +i00:+i5d 0:+i63:+i36 12:+i25 2
caml_0006 +i67 13:+i5d 1:+i28 1
caml_0009 +i63:+i5d 2:+i2b 0,caml_0006:+i39 12:+i2b 0,caml_0001:+i39 14
          +i54 caml_0038
caml_0010 +i00:+i7f 1:+i28 1
caml_0013 +i00:+i36 13:+i21:+i36 13:+i25 2:+i29
caml_0019 +i2a 1:+i01:+i0b:+i36 13:+i21:+i36 13:+i26 4
caml_0020 +i00:+i1b:+i1a:+i26 3:+i29
caml_0025 +i2a 1:+i01:+i0b:+i36 13:+i2b 2,caml_0020:+i36 13:+i26 4:+i29
caml_002d +i2a 1:+i01:+i0b:+i21:+i6a:+i70:+i28 2
caml_0034 +i00:+i5d 3:+i36 14:+i25 2
caml_0038 +i2b 0,caml_0034:+i09:+i2b 0,caml_002d:+i39 13:+i2b 0,caml_0025:+i09
          +i2b 0,caml_0019:+i09:+i2b 0,caml_0013:+i09:+i2b 0,caml_0010:+i6c 10
          +i0b:+i0f:+i22:+i0f:+i21:+i67 10:+i0b:+i0e:+i22:+i0f:+i21:+i67 10:+i0b
          +i0d:+i22:+i0f:+i21:+i13 5:+i8f
caml_program_end

!source "/home/pifu/.opam/4.14.3/lib/o64ml/runtime.asm"
!source "/home/pifu/.opam/4.14.3/lib/o64ml/memory.asm"
!source "/home/pifu/.opam/4.14.3/lib/o64ml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_print_string)
	!byte <(caml_nonstd_print_char)
	!byte <(caml_fresh_oo_id)
	!byte <(caml_nonstd_string_of_int)
caml_externals_hi
	!byte >(caml_nonstd_print_string)
	!byte >(caml_nonstd_print_char)
	!byte >(caml_fresh_oo_id)
	!byte >(caml_nonstd_string_of_int)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
!h 01 00 01 00 01 00
caml_glob_data

caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/pifu/.opam/4.14.3/lib/o64ml/showmem.asm"
