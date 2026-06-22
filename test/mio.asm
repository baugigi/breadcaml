;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "mio.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/pifu/.opam/4.14.3/lib/o64ml/c64defs.asm"
caml_PRIM__caml_nonstd_print_string = 1
caml_PRIM__caml_nonstd_print_char = 1
caml_PRIM__caml_fresh_oo_id = 1
!source "/home/pifu/.opam/4.14.3/lib/o64ml/loader.asm"
!source "/home/pifu/.opam/4.14.3/lib/o64ml/codegen.asm"

caml_program

caml_0000 +i54 caml_0009
caml_0001 +i00:+i5d 0:+i63:+i36 12:+i25 2
caml_0006 +i67 13:+i5d 1:+i28 1
caml_0009 +i63:+i5d 2:+i2b 0,caml_0006:+i39 12:+i2b 0,caml_0001:+i39 14:+i35 13
          +i36 14:+i21:+i8f
caml_program_end

!source "/home/pifu/.opam/4.14.3/lib/o64ml/runtime.asm"
!source "/home/pifu/.opam/4.14.3/lib/o64ml/memory.asm"
!source "/home/pifu/.opam/4.14.3/lib/o64ml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_print_string)
	!byte <(caml_nonstd_print_char)
	!byte <(caml_fresh_oo_id)
caml_externals_hi
	!byte >(caml_nonstd_print_string)
	!byte >(caml_nonstd_print_char)
	!byte >(caml_fresh_oo_id)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
!h 01 00:+p $0002:!h 01 00
caml_glob_data
!h fc 03 63 69 61 6f 00 01
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/pifu/.opam/4.14.3/lib/o64ml/showmem.asm"
