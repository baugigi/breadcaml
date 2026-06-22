;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "parz2.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/pifu/.opam/4.14.3/lib/o64ml/c64defs.asm"
caml_PRIM__caml_nonstd_string_of_int = 1
caml_PRIM__caml_nonstd_print_string = 1
caml_PRIM__caml_fresh_oo_id = 1
!source "/home/pifu/.opam/4.14.3/lib/o64ml/loader.asm"
!source "/home/pifu/.opam/4.14.3/lib/o64ml/codegen.asm"

caml_program

caml_0000 +i54 caml_0005
caml_0001 +i00:+i5d 0:+i5d 1:+i28 1
caml_0005 +i63:+i5d 2:+i2b 0,caml_0001:+i39 14:+i63:+i5d 2:+i63:+i5d 2
          +i54 caml_001c:+i29
caml_000f +i2a 1:+i01:+i56 caml_001b:+i01:+i43:+i0b:+i21:+i01:+i44:+i0b:+i32
          +i26 4
caml_001b +i28 2
caml_001c +i2c 1,0,caml_000f,[]:+i00:+i39 12:+i54 caml_0023
caml_0020 +i00:+i36 12:+i25 2
caml_0023 +i35 13:+i36 12:+i09:+i2b 0,caml_0020:+i36 14:+i0d:+i0b:+i0e:+i22:+i03
          +i0b:+i0d:+i22:+i13 4:+i8f
caml_program_end

!source "/home/pifu/.opam/4.14.3/lib/o64ml/runtime.asm"
!source "/home/pifu/.opam/4.14.3/lib/o64ml/memory.asm"
!source "/home/pifu/.opam/4.14.3/lib/o64ml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_string_of_int)
	!byte <(caml_nonstd_print_string)
	!byte <(caml_fresh_oo_id)
caml_externals_hi
	!byte >(caml_nonstd_string_of_int)
	!byte >(caml_nonstd_print_string)
	!byte >(caml_fresh_oo_id)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
!h 01 00:+p $0038:!h 01 00
caml_glob_data
!h 00 02 13 00 01 00 00 02 11 00:+p $0002:!h 00 02 0f 00:+p $0008:!h 00 02
!h 0d 00:+p $000e:!h 00 02 0b 00:+p $0014:!h 00 02 09 00:+p $001a:!h 00 02
!h 07 00:+p $0020:!h 00 02 05 00:+p $0026:!h 00 02 03 00:+p $002c:!h 00 02
!h 01 00:+p $0032
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/pifu/.opam/4.14.3/lib/o64ml/showmem.asm"
