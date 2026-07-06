;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "./ok/strlen.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/breadcaml/c64defs.asm"
caml_PRIM__caml_nonstd_print_char = 1
caml_PRIM__caml_fresh_oo_id = 1
caml_PRIM__caml_ml_string_length = 1
caml_PRIM__caml_nonstd_print_string = 1
!source "/home/piero/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i54 caml_0004
caml_0001 +i67 13:+i5d 0:+i28 1
caml_0004 +i63:+i5d 1:+i2b 0,caml_0001:+i39 14:+i54 caml_0017:+i29
caml_000a +i2a 1:+i01:+i0b:+i5d 2:+i79:+i56 caml_0012:+i35 12:+i54 caml_0013
caml_0012 +i35 13
caml_0013 +i5d 3:+i63:+i36 14:+i25 3
caml_0017 +i2b 0,caml_000a:+i6c 126:+i36 15:+i0c:+i22:+i67 127:+i36 16:+i0c:+i22
          +i67 128:+i36 17:+i0c:+i22:+i67 129:+i36 18:+i0c:+i22:+i67 130:+i36 19
          +i0c:+i22:+i67 253:+i36 20:+i0c:+i22:+i67 254:+i36 21:+i0c:+i22
          +i67 255:+i36 22:+i0c:+i22:+i67 256:+i36 23:+i0c:+i22:+i67 508:+i36 24
          +i0c:+i22:+i67 509:+i36 25:+i0c:+i22:+i13 1:+i8f
caml_program_end

!source "/home/piero/.opam/LTS/lib/breadcaml/runtime.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/memory.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_print_char)
	!byte <(caml_fresh_oo_id)
	!byte <(caml_ml_string_length)
	!byte <(caml_nonstd_print_string)
caml_externals_hi
	!byte >(caml_nonstd_print_char)
	!byte >(caml_fresh_oo_id)
	!byte >(caml_ml_string_length)
	!byte >(caml_nonstd_print_string)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
+p $0002:+p $0008:!h 01 00:+p $000e:+p $0090:+p $0112:+p $0196:+p $021a
+p $02a0:+p $03a0:+p $04a2:+p $05a4:+p $06a8:+p $08a8
caml_glob_data
!h fc 02 4f 4b 00 01 fc 02 4b 4f 00 01 fc 40 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 31 32 33 34 35 36 00 01 fc 40
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 31 32 33 34 35 36 37 00 fc 41 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 31 32 33 34 35 36 37 38 00 01 fc 41 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 31 32
!h 33 34 35 36 37 38 39 00 fc 42 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 31 32 33 34 35 36 37 38 39 30 00 01 fc 7f
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 31 32 33 00 fc 80 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 31 32 33 34 00 01 fc 80 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 31 32 33 34
!h 35 00 fc 81 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 31 32 33 34 35 36 00 01 fc ff
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 31 32 33 34
!h 35 36 37 38 00 01 fc ff 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d 2d 2d 2d 30 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 30 31 32 33 34 35 36 37 38 39 00
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/breadcaml/showmem.asm"
