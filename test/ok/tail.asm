;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "./ok/tail.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/breadcaml/c64defs.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i54 caml_000e:+i29
caml_0002 +i2a 1:+i00:+i88 1,caml_000c:+i01:+i0b:+i70:+i0b:+i7f -1:+i32:+i26 4
caml_000c +i01:+i28 2
caml_000e +i2c 1,0,caml_0002,[]:+i64:+i6c 7:+i0c:+i22:+i13 1:+i8f
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
