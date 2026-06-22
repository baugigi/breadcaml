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

!to "hanoi.prg", cbm
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
!source "/home/pifu/.opam/4.14.3/lib/o64ml/loader.asm"
!source "/home/pifu/.opam/4.14.3/lib/o64ml/codegen.asm"

caml_program

caml_0000 +i54 caml_0038:+i29
caml_0002 +i2a 1:+i00:+i56 caml_000e:+i01:+i0b:+i44:+i32:+i22:+i0b:+i43:+i40 0
          +i28 2
caml_000e +i01:+i28 2
caml_0010 +i63:+i5d 0:+i36 12:+i25 2
caml_0014 +i67 13:+i5d 1:+i28 1
caml_0017 +i00:+i5d 2:+i5d 3:+i28 1
caml_001b +i00:+i5d 4:+i5d 5:+i28 1:+i29
caml_0020 +i2a 1:+i00:+i5d 6:+i0c:+i5d 6:+i0a:+i0c:+i6e:+i5d 7:+i0c:+i68:+i0c
          +i68:+i11:+i61 8:+i01:+i0d:+i0c:+i68:+i12 8:+i61 8:+i00:+i5d 9:+i28 5
caml_0038 +i63:+i5d 10:+i2b 0,caml_0020:+i39 21:+i2b 0,caml_001b:+i39 12
          +i2c 1,0,caml_0002,[]:+i00:+i39 13:+i2b 0,caml_0017:+i39 18
          +i2b 0,caml_0014:+i39 22:+i2b 0,caml_0010:+i39 29:+i63:+i5d 10:+i63
          +i5d 10:+i54 caml_005a:+i29
caml_004d +i2a 1:+i01:+i56 caml_0059:+i01:+i43:+i0b:+i21:+i01:+i44:+i0b:+i32
          +i26 4
caml_0059 +i28 2
caml_005a +i2c 1,0,caml_004d,[]:+i00:+i39 16:+i54 caml_00af:+i29
caml_005f +i2a 3:+i03:+i83 1,caml_007b:+i1f caml_006a:+i06:+i7f -1:+i0f:+i11
          +i10:+i32:+i20 4
caml_006a +i09:+i1f caml_0073:+i07:+i7f -1:+i11:+i10:+i12 8:+i32:+i20 4
caml_0073 +i0a:+i0f:+i0e:+i40 0:+i40 0:+i0c:+i36 13:+i26 8
caml_007b +i63:+i0d:+i0c:+i40 0:+i40 0:+i28 4
caml_0081 +i1f caml_0088:+i03:+i6a:+i69:+i68:+i36 14:+i20 4
caml_0088 +i36 15:+i36 16:+i26 3
caml_008b +i35 17:+i80 1:+i37 17,0:+i36 18:+i21:+i00:+i36 19:+i21:+i36 20
          +i36 21:+i22:+i5d 3:+i63:+i36 22:+i25 2
caml_009a +i00:+i44:+i36 23:+i21:+i36 24:+i36 21:+i22:+i0b:+i43:+i36 23:+i21
          +i36 21:+i26 3
caml_00a7 +i00:+i57 3,[caml_00a9,caml_00ab,caml_00ad]
caml_00a9 +i35 25:+i28 1
caml_00ab +i35 26:+i28 1
caml_00ad +i35 27:+i28 1
caml_00af +i2b 0,caml_00a7:+i39 23:+i2b 0,caml_009a:+i39 19:+i63:+i3f 0:+i39 17
          +i2b 0,caml_008b:+i39 15:+i2c 1,0,caml_005f,[]:+i00:+i39 14
          +i2b 0,caml_0081:+i36 28:+i5d 3:+i63:+i36 29:+i21:+i0b:+i21:+i63
          +i36 22:+i21:+i13 2:+i8f
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
!macro p .ptr { !wo caml_glob_data + .ptr }
caml_glob_table
!h 01 00 01 00 01 00 01 00 01 00 01 00 01 00 01 00:+p $0002:!h 01 00 01 00
!h 01 00:+p $0006:+p $000c:+p $0010:+p $0014:+p $0018:!h 01 00
caml_glob_data
!h fc 01 3a 00 fc 02 2d 3e 00 01 fc 01 41 00 fc 01 42 00 fc 01 43 00 fc 0a
!h 4e 75 6d 65 72 6f 20 64 69 20 64 69 73 63 68 69 3f 20 00 01
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/pifu/.opam/4.14.3/lib/o64ml/showmem.asm"
