;; ——————————————————————————————————————————————————————————————————————
;; Progetto BreadCaml / The BreadCaml Project
;; Copyright (C) 21-Apr-2026 Piero Furiesi
;;
;; Questo  programma è  software libero;  è possibile  ridistribuirlo e/o
;; modificarlo secondo i  termini della GNU General  Public License (GPL)
;; versione  2,  come specificato  nel  file  LICENZA-it nella  directory
;; principale del progetto.
;;
;; This program is  free software; you can redistribute  it and/or modify
;; it under the terms of the  GNU General Public License (GPL) version 2,
;; as specified in the LICENSE-en file in the project root.
;; ——————————————————————————————————————————————————————————————————————

;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "hanoi_iter.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/pifu/.opam/4.14.3/lib/o64ml/c64defs.asm"
caml_PRIM__caml_nonstd_read_line = 1
caml_PRIM__caml_nonstd_print_char = 1
caml_PRIM__caml_nonstd_string_of_int = 1
caml_PRIM__caml_nonstd_print_string = 1
caml_PRIM__caml_float_of_string = 1
caml_PRIM__caml_int_of_float = 1
caml_PRIM__caml_ml_string_length = 1
caml_PRIM__caml_create_bytes = 1
caml_PRIM__caml_blit_string = 1
caml_PRIM__caml_string_of_bytes = 1
caml_PRIM__caml_fresh_oo_id = 1
caml_PRIM__caml_equal = 1
caml_PRIM__caml_lessthan = 1
!source "/home/pifu/.opam/4.14.3/lib/o64ml/loader.asm"
!source "/home/pifu/.opam/4.14.3/lib/o64ml/codegen.asm"

caml_program

caml_0000 +i54 caml_0029
caml_0001 +i63:+i5d 0:+i36 12:+i25 2
caml_0005 +i67 13:+i5d 1:+i28 1
caml_0008 +i00:+i5d 2:+i5d 3:+i28 1
caml_000c +i00:+i5d 4:+i5d 5:+i28 1:+i29
caml_0011 +i2a 1:+i00:+i5d 6:+i0c:+i5d 6:+i0a:+i0c:+i6e:+i5d 7:+i0c:+i68:+i0c
          +i68:+i11:+i61 8:+i01:+i0d:+i0c:+i68:+i12 8:+i61 8:+i00:+i5d 9:+i28 5
caml_0029 +i63:+i5d 10:+i36 13:+i40 248:+i39 33:+i2b 0,caml_0011:+i39 24
          +i2b 0,caml_000c:+i39 12:+i2b 0,caml_0008:+i39 21:+i2b 0,caml_0005
          +i39 25:+i2b 0,caml_0001:+i39 35:+i54 caml_01cb:+i29
caml_003a +i2a 1:+i01:+i83 0,caml_0044:+i01:+i7f -1:+i0b:+i0d:+i40 0:+i32:+i26 4
caml_0044 +i00:+i28 2
caml_0046 +i65:+i0b:+i72:+i84 0,caml_004c:+i35 14:+i54 caml_004d
caml_004c +i35 15
caml_004d +i68:+i68:+i0d:+i68:+i36 16:+i22:+i41 0:+i0a:+i0c:+i21:+i0a:+i0c
          +i36 17:+i22:+i54 caml_0071
caml_005c +i5c:+i00:+i14 1:+i01:+i36 18:+i21:+i14 0:+i00:+i0c:+i36 17:+i22:+i00
          +i14 1:+i01:+i0d:+i21:+i14 0:+i00:+i0c:+i36 17:+i22
caml_0071 +i00:+i36 19:+i21:+i56 caml_005c:+i63:+i28 4
caml_0077 +i00:+i43:+i55 caml_007f:+i00:+i44:+i55 caml_007f:+i64:+i28 1
caml_007f +i63:+i28 1:+i29
caml_0082 +i2a 1:+i35 20:+i80 1:+i37 20,0:+i36 21:+i21:+i01:+i0b:+i40 0:+i36 22
          +i21:+i36 23:+i36 24:+i22:+i5d 3:+i63:+i36 25:+i25 3
caml_0094 +i00:+i43:+i0a:+i43:+i0a:+i56 caml_00b7:+i02:+i44:+i0a:+i44:+i0c:+i43
          +i0b:+i56 caml_00a9:+i01:+i43:+i0b:+i5e 11:+i56 caml_00a9:+i35 26
          +i28 6
caml_00a9 +i02:+i45:+i0a:+i56 caml_00b6:+i00:+i43:+i0c:+i5e 11:+i56 caml_00b4
          +i35 27:+i28 7
caml_00b4 +i13 4:+i54 caml_00b7
caml_00b6 +i13 4
caml_00b7 +i01:+i44:+i0a:+i56 caml_00d8:+i03:+i44:+i0a:+i43:+i0c:+i43:+i0b
          +i56 caml_00ca:+i01:+i43:+i0b:+i5e 11:+i56 caml_00ca:+i35 28:+i28 7
caml_00ca +i02:+i45:+i0a:+i56 caml_00d7:+i00:+i43:+i0c:+i5e 11:+i56 caml_00d5
          +i35 29:+i28 8
caml_00d5 +i13 4:+i54 caml_00d8
caml_00d7 +i13 4
caml_00d8 +i02:+i45:+i0a:+i56 caml_00ec:+i04:+i44:+i43:+i0a:+i56 caml_00eb:+i00
          +i43:+i0c:+i43:+i5e 11:+i56 caml_00e9:+i35 30:+i28 6
caml_00e9 +i13 1:+i54 caml_00ec
caml_00eb +i13 1
caml_00ec +i35 31:+i28 5
caml_00ee +i00:+i45:+i0b:+i44:+i0c:+i43:+i0a:+i56 caml_0105:+i00:+i43
          +i84 1,caml_0105:+i02:+i0c:+i40 0:+i36 32:+i21:+i0a:+i44:+i0b:+i43
          +i0d:+i41 0:+i28 5
caml_0105 +i01:+i56 caml_0116:+i01:+i43:+i84 1,caml_0116:+i02:+i0b:+i40 0
          +i36 32:+i21:+i0a:+i44:+i0d:+i0c:+i43:+i41 0:+i28 5
caml_0116 +i02:+i56 caml_0127:+i02:+i43:+i84 1,caml_0127:+i01:+i0b:+i40 0
          +i36 32:+i21:+i0d:+i0b:+i44:+i0c:+i43:+i41 0:+i28 5
caml_0127 +i35 33:+i5b
caml_0129 +i00:+i43:+i0a:+i56 caml_0153:+i01:+i44:+i0b:+i44:+i0c:+i43:+i0c
          +i56 caml_014d:+i02:+i44:+i0d:+i43:+i0a:+i0d:+i5e 12:+i56 caml_0145
          +i01:+i0b:+i40 0:+i0d:+i40 0:+i0e:+i40 0:+i28 7
caml_0145 +i01:+i0e:+i0e:+i40 0:+i0c:+i40 0:+i40 0:+i28 7
caml_014d +i63:+i0b:+i40 0:+i0c:+i40 0:+i28 5
caml_0153 +i01:+i44:+i0a:+i56 caml_015f:+i00:+i44:+i68:+i0c:+i43:+i40 0:+i40 0
          +i28 3
caml_015f +i35 33:+i5b
caml_0161 +i00:+i43:+i0a:+i56 caml_0172:+i00:+i43:+i84 1,caml_0172:+i01:+i45
          +i69:+i40 0:+i0c:+i44:+i0c:+i44:+i41 0:+i28 2
caml_0172 +i01:+i44:+i0a:+i56 caml_0182:+i00:+i43:+i84 1,caml_0182:+i02:+i45
          +i0b:+i44:+i0d:+i69:+i40 0:+i41 0:+i28 3
caml_0182 +i02:+i45:+i0a:+i56 caml_0193:+i00:+i43:+i83 1,caml_018b:+i13 3
          +i54 caml_0194
caml_018b +i00:+i44:+i0c:+i69:+i40 0:+i0e:+i41 0:+i28 4
caml_0193 +i13 3
caml_0194 +i35 33:+i5b
caml_0196 +i00:+i43:+i0a:+i56 caml_01a7:+i00:+i43:+i84 1,caml_01a7:+i01:+i45
          +i0c:+i44:+i69:+i40 0:+i0c:+i44:+i41 0:+i28 2
caml_01a7 +i01:+i44:+i0a:+i56 caml_01b7:+i00:+i43:+i84 1,caml_01b7:+i02:+i45
          +i69:+i40 0:+i0b:+i44:+i0d:+i41 0:+i28 3
caml_01b7 +i02:+i45:+i0a:+i56 caml_01c8:+i00:+i43:+i83 1,caml_01c0:+i13 3
          +i54 caml_01c9
caml_01c0 +i00:+i44:+i0c:+i0e:+i69:+i40 0:+i41 0:+i28 4
caml_01c8 +i13 3
caml_01c9 +i35 33:+i5b
caml_01cb +i2b 0,caml_0196:+i39 14:+i2b 0,caml_0161:+i39 15:+i2b 0,caml_0129
          +i39 32:+i2b 0,caml_00ee:+i39 18:+i2b 0,caml_0094:+i39 22:+i63:+i3f 0
          +i39 20:+i2b 0,caml_0082:+i39 17:+i2b 0,caml_0077:+i39 19
          +i2c 1,0,caml_003a,[]:+i00:+i39 16:+i2b 0,caml_0046:+i36 34:+i5d 3
          +i63:+i36 35:+i21:+i0b:+i21:+i63:+i36 25:+i21:+i13 2:+i8f
caml_program_end

!source "/home/pifu/.opam/4.14.3/lib/o64ml/runtime.asm"
!source "/home/pifu/.opam/4.14.3/lib/o64ml/memory.asm"
!source "/home/pifu/.opam/4.14.3/lib/o64ml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_read_line)
	!byte <(caml_nonstd_print_char)
	!byte <(caml_nonstd_string_of_int)
	!byte <(caml_nonstd_print_string)
	!byte <(caml_float_of_string)
	!byte <(caml_int_of_float)
	!byte <(caml_ml_string_length)
	!byte <(caml_create_bytes)
	!byte <(caml_blit_string)
	!byte <(caml_string_of_bytes)
	!byte <(caml_fresh_oo_id)
	!byte <(caml_equal)
	!byte <(caml_lessthan)
caml_externals_hi
	!byte >(caml_nonstd_read_line)
	!byte >(caml_nonstd_print_char)
	!byte >(caml_nonstd_string_of_int)
	!byte >(caml_nonstd_print_string)
	!byte >(caml_float_of_string)
	!byte >(caml_int_of_float)
	!byte >(caml_ml_string_length)
	!byte >(caml_create_bytes)
	!byte >(caml_blit_string)
	!byte >(caml_string_of_bytes)
	!byte >(caml_fresh_oo_id)
	!byte >(caml_equal)
	!byte >(caml_lessthan)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
!h 01 00:+p $0002:!h 01 00 01 00 01 00 01 00 01 00 01 00 01 00 01 00 01 00
+p $0010:!h 01 00 01 00:+p $0014:+p $001c:+p $0024:+p $002c:+p $0034
+p $003c:!h 01 00 01 00:+p $0044:!h 01 00
caml_glob_data
!h fc 06 53 74 64 6c 69 62 2e 45 78 69 74 00 fc 01 3a 00 fc 03 41 2d 3e 42
!h 00 01 fc 03 41 2d 3e 43 00 01 fc 03 42 2d 3e 41 00 01 fc 03 42 2d 3e 43
!h 00 01 fc 03 43 2d 3e 41 00 01 fc 03 43 2d 3e 42 00 01 fc 0a 4e 75 6d 65
!h 72 6f 20 64 69 20 64 69 73 63 68 69 3f 20 00 01
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/pifu/.opam/4.14.3/lib/o64ml/showmem.asm"
