;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "prova.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/bcamlc/c64defs.asm"
caml_PRIM__caml_ml_string_length = 1
caml_PRIM__caml_create_bytes = 1
caml_PRIM__caml_blit_string = 1
caml_PRIM__caml_string_of_bytes = 1
caml_PRIM__caml_fresh_oo_id = 1
!source "/home/piero/.opam/LTS/lib/bcamlc/loader.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/codegen.asm"

caml_program

caml_0000 +i54 caml_001a:+i29
caml_0002 +i2a 1:+i00:+i5d 0:+i0c:+i5d 0:+i0a:+i0c:+i6e:+i5d 1:+i0c:+i68:+i0c
          +i68:+i11:+i61 2:+i01:+i0d:+i0c:+i68:+i12 8:+i61 2:+i00:+i5d 3:+i28 5
caml_001a +i63:+i5d 4:+i2b 0,caml_0002:+i39 14:+i35 12:+i0a:+i36 13:+i36 14:+i22
          +i36 15:+i0b:+i36 14:+i22:+i35 16:+i0b:+i36 14:+i22:+i13 2:+i8f
caml_program_end

!source "/home/piero/.opam/LTS/lib/bcamlc/runtime.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/memory.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_ml_string_length)
	!byte <(caml_create_bytes)
	!byte <(caml_blit_string)
	!byte <(caml_string_of_bytes)
	!byte <(caml_fresh_oo_id)
caml_externals_hi
	!byte >(caml_ml_string_length)
	!byte >(caml_create_bytes)
	!byte >(caml_blit_string)
	!byte >(caml_string_of_bytes)
	!byte >(caml_fresh_oo_id)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
+p $0002:+p $000c:!h 01 00:+p $0014:+p $0018
caml_glob_data
!h fc 04 44 4c 1c 41 c3 a0 53 00 fc 03 93 43 49 41 4f 00 fc 01 92 00 fc 05
!h 7b 52 56 53 4f 46 46 7d 00 01
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/bcamlc/showmem.asm"
