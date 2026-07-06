;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "./ok/compare.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/breadcaml/c64defs.asm"
caml_PRIM__caml_nonstd_print_char = 1
caml_PRIM__caml_fresh_oo_id = 1
caml_PRIM__caml_nonstd_print_string = 1
caml_PRIM__caml_equal = 1
caml_PRIM__caml_compare = 1
!source "/home/piero/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i54 caml_0004
caml_0001 +i67 13:+i5d 0:+i28 1
caml_0004 +i63:+i5d 1:+i2b 0,caml_0001:+i39 15:+i54 caml_0065
caml_0009 +i00:+i56 caml_0028:+i00:+i43:+i0a:+i43:+i5d 2:+i59 caml_001d:+i63
          +i0f:+i44:+i21:+i0a:+i56 caml_0019:+i35 12:+i54 caml_001a
caml_0019 +i35 13
caml_001a +i13 1:+i5a:+i54 caml_001f
caml_001d +i36 14:+i13 1
caml_001f +i0a:+i5d 2:+i63:+i36 15:+i21:+i02:+i44:+i32:+i25 4
caml_0028 +i28 1
caml_0029 +i35 16:+i36 16:+i79:+i28 1
caml_002d +i35 16:+i36 16:+i5e 3:+i28 1
caml_0031 +i35 16:+i36 16:+i5e 4:+i68:+i79:+i28 1
caml_0037 +i35 17:+i36 17:+i79:+i28 1
caml_003b +i35 17:+i36 17:+i5e 3:+i28 1
caml_003f +i35 17:+i36 17:+i5e 4:+i68:+i79:+i28 1
caml_0045 +i35 18:+i36 17:+i79:+i28 1
caml_0049 +i35 18:+i36 17:+i5e 3:+i28 1
caml_004d +i35 18:+i36 17:+i5e 4:+i68:+i7d:+i28 1
caml_0053 +i35 18:+i36 17:+i5e 4:+i68:+i7b:+i28 1
caml_0059 +i35 18:+i36 17:+i5e 4:+i68:+i79:+i28 1:+i29
caml_0060 +i2a 1:+i01:+i0b:+i6e:+i28 2
caml_0065 +i2b 0,caml_0060:+i09:+i39 16:+i00:+i13 1:+i36 19:+i0b:+i69:+i41 0
          +i39 17:+i35 20:+i0b:+i69:+i41 0:+i39 18:+i2c 1,0,caml_0009,[]:+i63
          +i09:+i2b 0,caml_0059:+i36 21:+i40 0:+i40 0:+i09:+i2b 0,caml_0053
          +i36 22:+i40 0:+i40 0:+i09:+i2b 0,caml_004d:+i36 23:+i40 0:+i40 0:+i09
          +i2b 0,caml_0049:+i36 24:+i40 0:+i40 0:+i09:+i2b 0,caml_0045:+i36 25
          +i40 0:+i40 0:+i09:+i2b 0,caml_003f:+i36 26:+i40 0:+i40 0:+i09
          +i2b 0,caml_003b:+i36 27:+i40 0:+i40 0:+i09:+i2b 0,caml_0037:+i36 28
          +i40 0:+i40 0:+i09:+i2b 0,caml_0031:+i36 29:+i40 0:+i40 0:+i09
          +i2b 0,caml_002d:+i36 30:+i40 0:+i40 0:+i09:+i2b 0,caml_0029:+i36 31
          +i40 0:+i40 0:+i36 32:+i5d 2:+i35 33:+i5d 2:+i00:+i0c:+i21:+i13 3:+i8f
caml_program_end

!source "/home/piero/.opam/LTS/lib/breadcaml/runtime.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/memory.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_print_char)
	!byte <(caml_fresh_oo_id)
	!byte <(caml_nonstd_print_string)
	!byte <(caml_equal)
	!byte <(caml_compare)
caml_externals_hi
	!byte >(caml_nonstd_print_char)
	!byte >(caml_fresh_oo_id)
	!byte >(caml_nonstd_print_string)
	!byte >(caml_equal)
	!byte >(caml_compare)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
+p $0002:+p $000c:+p $0016:!h 01 00 01 00 01 00 01 00:+p $0030:+p $0042
+p $0048:+p $005c:+p $0070:+p $0084:+p $008e:+p $009a:+p $00b0:+p $00bc
+p $00c8:+p $00da:+p $00e2:+p $00ec:+p $00f0
caml_glob_data
!h fc 04 3a 20 54 52 55 45 00 01 fc 04 3a 20 46 41 4c 53 45 00 fc 06 3a 20
!h 45 58 43 45 50 54 49 4f 4e 00 00 02 0b 00 01 00 00 02 09 00:+p $0024
!h 00 02 07 00:+p $002a:!h 00 02 0b 00 01 00 00 02 09 00:+p $0036:!h 00 02
!h 07 00:+p $003c:!h fc 09 63 6f 6d 70 61 72 65 20 70 31 20 70 32 20 3d 20
!h 30 00 fc 09 63 6f 6d 70 61 72 65 20 70 31 20 70 32 20 3e 20 30 00 fc 09
!h 63 6f 6d 70 61 72 65 20 70 31 20 70 32 20 3c 20 30 00 fc 04 70 31 20 3d
!h 20 70 32 00 fc 05 70 31 20 3d 3d 20 70 32 00 01 fc 0a 63 6f 6d 70 61 72
!h 65 20 70 31 20 70 31 27 20 3d 20 30 00 01 fc 05 70 31 20 3d 20 70 31 27
!h 00 01 fc 05 70 31 20 3d 3d 20 70 31 27 00 fc 08 63 6f 6d 70 61 72 65 20
!h 66 20 66 20 3d 20 30 00 fc 03 66 20 3d 20 66 00 fc 04 66 20 3d 3d 20 66
!h 00 01 fc 01 0e 00 fc 2c 6c 65 74 20 66 20 3d 20 28 2b 29 3b 3b 0d 6c 65
!h 74 20 70 31 20 3d 20 28 31 2c 20 66 2c 20 5b 33 3b 20 34 3b 20 35 5d 29
!h 3b 3b 0d 6c 65 74 20 70 31 27 20 3d 20 70 31 3b 3b 0d 6c 65 74 20 70 32
!h 20 3d 20 28 31 2c 20 66 2c 20 5b 33 3b 20 34 3b 20 35 5d 29 3b 3b 0d 00
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/breadcaml/showmem.asm"
