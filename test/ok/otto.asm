;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "./ok/otto.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/breadcaml/c64defs.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i54 caml_000d
caml_0001 +i00:+i84 0,caml_0005:+i63:+i28 1
caml_0005 +i00:+i7f -1:+i32:+i21:+i32:+i25 2
caml_000b +i67 8:+i28 1
caml_000d +i2c 1,0,caml_0001,[]:+i2b 0,caml_000b:+i68:+i0c:+i21:+i0b:+i21:+i13 2
          +i8f
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
