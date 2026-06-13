;; ——————————————————————————————————————————————————————————————————————
;; Progetto O64ml / The O64ml Project
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

;; Created by O64ml - The OCaml Compiler for the Commodore 64

!to "hanoi_naif.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/o64ml/c64defs.asm"
caml_PRIM__caml_nonstd_read_line = 1
caml_PRIM__caml_nonstd_print_char = 1
caml_PRIM__caml_nonstd_string_of_int = 1
caml_PRIM__caml_nonstd_print_string = 1
caml_PRIM__caml_float_of_string = 1
caml_PRIM__caml_int_of_float = 1
caml_PRIM__caml_fresh_oo_id = 1
!source "/home/piero/.opam/LTS/lib/o64ml/loader.asm"
!source "/home/piero/.opam/LTS/lib/o64ml/codegen.asm"

caml_program

caml_0000 +i54 caml_0010
caml_0001 +i63:+i5d 0:+i36 12:+i25 2
caml_0005 +i67 13:+i5d 1:+i28 1
caml_0008 +i00:+i5d 2:+i5d 3:+i28 1
caml_000c +i00:+i5d 4:+i5d 5:+i28 1
caml_0010 +i63:+i5d 6:+i2b 0,caml_000c:+i39 12:+i2b 0,caml_0008:+i39 15
          +i2b 0,caml_0005:+i39 16:+i2b 0,caml_0001:+i39 17:+i54 caml_004a:+i29
caml_001c +i2a 3:+i03:+i83 1,caml_0032:+i1f caml_0027:+i06:+i7f -1:+i0f:+i11
          +i10:+i32:+i20 4
caml_0027 +i02:+i0b:+i36 13:+i22:+i03:+i7f -1:+i0d:+i0c:+i0e:+i32:+i24 4,8
caml_0032 +i02:+i0b:+i36 13:+i26 6:+i29
caml_0037 +i2a 1:+i35 14:+i80 1:+i37 14,0:+i36 15:+i21:+i67 58:+i5d 1:+i00
          +i36 15:+i21:+i67 62:+i5d 1:+i01:+i36 15:+i21:+i63:+i36 16:+i25 3
caml_004a +i63:+i3f 0:+i39 14:+i2b 0,caml_0037:+i39 13:+i2c 1,0,caml_001c,[]
          +i1f caml_0059:+i63:+i36 17:+i21:+i6b:+i6a:+i69:+i11:+i20 4
caml_0059 +i13 1:+i8f
caml_program_end

!source "/home/piero/.opam/LTS/lib/o64ml/runtime.asm"
!source "/home/piero/.opam/LTS/lib/o64ml/memory.asm"
!source "/home/piero/.opam/LTS/lib/o64ml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_read_line)
	!byte <(caml_nonstd_print_char)
	!byte <(caml_nonstd_string_of_int)
	!byte <(caml_nonstd_print_string)
	!byte <(caml_float_of_string)
	!byte <(caml_int_of_float)
	!byte <(caml_fresh_oo_id)
caml_externals_hi
	!byte >(caml_nonstd_read_line)
	!byte >(caml_nonstd_print_char)
	!byte >(caml_nonstd_string_of_int)
	!byte >(caml_nonstd_print_string)
	!byte >(caml_float_of_string)
	!byte >(caml_int_of_float)
	!byte >(caml_fresh_oo_id)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
!h 01 00 01 00 01 00 01 00 01 00 01 00
caml_glob_data

caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/o64ml/showmem.asm"
