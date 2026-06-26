;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "vuoto.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/pifu/.opam/LTS/lib/breadcaml/c64defs.asm"
!source "/home/pifu/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/pifu/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i8f
caml_program_end

!source "/home/pifu/.opam/LTS/lib/breadcaml/runtime.asm"
!source "/home/pifu/.opam/LTS/lib/breadcaml/memory.asm"
!source "/home/pifu/.opam/LTS/lib/breadcaml/stdlib.asm"
!align $01, $00
caml_externals_lo
caml_externals_hi
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table

caml_glob_data

caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/pifu/.opam/LTS/lib/breadcaml/showmem.asm"
