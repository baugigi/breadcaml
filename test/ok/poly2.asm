;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "./ok/poly2.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/breadcaml/c64defs.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i54 caml_0012
caml_0001 +i00:+i81:+i56 caml_0008:+i00:+i84 14593,caml_0010:+i67 100:+i28 1
caml_0008 +i00:+i43:+i84 87,caml_0010:+i00:+i44:+i6a:+i70:+i28 1
caml_0010 +i67 34:+i28 1
caml_0012 +i2b 0,caml_0001:+i6c 73:+i0b:+i21:+i13 1:+i8f
caml_program_end

!source "/home/piero/.opam/LTS/lib/breadcaml/runtime.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/memory.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/stdlib.asm"
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
!source "/home/piero/.opam/LTS/lib/breadcaml/showmem.asm"
