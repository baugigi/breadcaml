;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "./ok/poly.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/breadcaml/c64defs.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i54 caml_0029
caml_0001 +i00:+i81:+i56 caml_000e:+i00:+i83 67,caml_000c:+i00:+i6c 78:+i7a
          +i56 caml_000b:+i54 caml_0027
caml_000b +i28 1
caml_000c +i67 100:+i28 1
caml_000e +i00:+i43:+i0a:+i83 68,caml_0021:+i00:+i83 73,caml_001e:+i00
          +i83 83,caml_0018:+i13 1:+i54 caml_0027
caml_0018 +i01:+i44:+i0a:+i0b:+i70:+i28 3
caml_001e +i01:+i44:+i28 2
caml_0021 +i01:+i44:+i0a:+i0b:+i6e:+i28 3
caml_0027 +i67 -1:+i28 1
caml_0029 +i2b 0,caml_0001:+i36 12:+i0b:+i21:+i13 1:+i8f
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
+p $0002
caml_glob_data
!h 00 02 93 00 c9 00
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/breadcaml/showmem.asm"
