;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "./ok/list.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/breadcaml/c64defs.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i54 caml_003a:+i29
caml_0002 +i2a 1:+i01:+i56 caml_000f:+i01:+i44:+i0b:+i32:+i22:+i0c:+i43:+i0c
          +i21:+i40 0
caml_000f +i28 2:+i29
caml_0011 +i2a 1:+i01:+i83 0,caml_001e:+i00:+i56 caml_0024:+i01:+i88 0,caml_0024
          +i01:+i7f -1:+i0b:+i44:+i32:+i26 4
caml_001e +i00:+i56 caml_0024:+i00:+i43:+i3f 0:+i28 2
caml_0024 +i63:+i28 2
caml_0026 +i00:+i0b:+i70:+i28 1
caml_002a +i35 12:+i09:+i2b 0,caml_0026:+i36 13:+i22:+i6a:+i0b:+i36 14:+i22:+i0a
          +i56 caml_0038:+i00:+i43:+i28 3
caml_0038 +i67 -1:+i28 3
caml_003a +i2c 1,0,caml_0002,[]:+i00:+i39 13:+i2c 1,0,caml_0011,[]:+i00:+i39 14
          +i2b 0,caml_002a:+i68:+i0b:+i21:+i13 3:+i8f
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
+p $001a:!h 01 00 01 00
caml_glob_data
!h 00 02 0b 00 01 00 00 02 09 00:+p $0002:!h 00 02 07 00:+p $0008:!h 00 02
!h 05 00:+p $000e:!h 00 02 03 00:+p $0014
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/breadcaml/showmem.asm"
