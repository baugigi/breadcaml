;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "./ok/ifatt7.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/breadcaml/c64defs.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i54 caml_0018
caml_0001 +i64:+i6a:+i0c:+i09:+i0c:+i7d:+i55 caml_0014
caml_0008 +i5c:+i01:+i0d:+i70:+i14 2:+i01:+i09:+i7f 1:+i14 2:+i01:+i7a
          +i55 caml_0008
caml_0014 +i63:+i13 2:+i00:+i28 2
caml_0018 +i2b 0,caml_0001:+i6c 7:+i0b:+i21:+i13 1:+i8f
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
