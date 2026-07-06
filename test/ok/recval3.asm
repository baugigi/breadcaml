;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "./ok/recval3.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/breadcaml/c64defs.asm"
caml_PRIM__caml_alloc_dummy_float = 1
caml_PRIM__caml_add_float = 1
caml_PRIM__caml_update_dummy = 1
!source "/home/piero/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i54 caml_0003
caml_0001 +i35 12:+i28 1
caml_0003 +i64:+i5d 0:+i09:+i39 12:+i00:+i13 1:+i36 13:+i36 14:+i5e 1:+i42 1
          +i0b:+i5e 2:+i2b 0,caml_0001:+i68:+i0b:+i21:+i13 2:+i8f
caml_program_end

!source "/home/piero/.opam/LTS/lib/breadcaml/runtime.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/memory.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_alloc_dummy_float)
	!byte <(caml_add_float)
	!byte <(caml_update_dummy)
caml_externals_hi
	!byte >(caml_alloc_dummy_float)
	!byte >(caml_add_float)
	!byte >(caml_update_dummy)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
!h 01 00:+p $0002:+p $000a
caml_glob_data
!h fd 03 00 00 00 00 00 ff fd 03 7d 4c cc cc cd ff
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/breadcaml/showmem.asm"
