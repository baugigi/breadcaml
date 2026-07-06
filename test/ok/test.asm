;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "./ok/test.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/breadcaml/c64defs.asm"
caml_PRIM__caml_fresh_oo_id = 1
caml_PRIM__caml_nonstd_print_string = 1
!source "/home/piero/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i63:+i5d 0:+i64:+i84 1,caml_0007:+i35 12:+i5d 1:+i54 caml_0009
caml_0007 +i35 13:+i5d 1
caml_0009 +i8f
caml_program_end

!source "/home/piero/.opam/LTS/lib/breadcaml/runtime.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/memory.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_fresh_oo_id)
	!byte <(caml_nonstd_print_string)
caml_externals_hi
	!byte >(caml_fresh_oo_id)
	!byte >(caml_nonstd_print_string)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
+p $0002:+p $0006
caml_glob_data
!h fc 01 56 00 fc 01 46 00
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/breadcaml/showmem.asm"
