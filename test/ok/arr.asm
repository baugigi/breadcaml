;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "./ok/arr.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/breadcaml/c64defs.asm"
caml_PRIM__caml_make_array = 1
caml_PRIM__caml_array_get_addr = 1
!source "/home/piero/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i54 caml_000e
caml_0001 +i00:+i0b:+i0c:+i0d:+i0e:+i0f:+i10:+i11:+i12 8:+i12 9:+i3e 0,10:+i5d 0
          +i28 1
caml_000e +i2b 0,caml_0001:+i6a:+i0b:+i21:+i68:+i0b:+i5e 1:+i13 1:+i13 1:+i8f
caml_program_end

!source "/home/piero/.opam/LTS/lib/breadcaml/runtime.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/memory.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_make_array)
	!byte <(caml_array_get_addr)
caml_externals_hi
	!byte >(caml_make_array)
	!byte >(caml_array_get_addr)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table

caml_glob_data

caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/breadcaml/showmem.asm"
