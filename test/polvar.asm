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

!source "/home/pifu/.opam/4.14.3/lib/oc64ml/header.asm"
caml_stack_start = $9c00
caml_stack_end = $a000
PRIM_caml_string_of_int = 1
PRIM_caml_print_string = 1
PRIM_caml_fresh_oo_id = 1
!source "/home/pifu/.opam/4.14.3/lib/oc64ml/loader.asm"

caml_objcode

caml_0000 +i54 caml_0005
caml_0001 +i00:+i5d 0:+i5d 1:+i28 1
caml_0005 +i63:+i5d 2:+i2b 0,caml_0001:+i39 12:+i54 caml_0030
caml_000a +i00:+i87 15426,caml_001e:+i00:+i87 15649,caml_001c:+i00
          +i87 16095,caml_0016:+i00:+i87 16318,caml_0014:+i67 9:+i28 1
caml_0014 +i67 8:+i28 1
caml_0016 +i00:+i87 15872,caml_001a:+i67 7:+i28 1
caml_001a +i67 6:+i28 1
caml_001c +i67 5:+i28 1
caml_001e +i00:+i6c 14534:+i7c:+i56 caml_002f:+i00:+i87 14980,caml_002a:+i00
          +i87 15203,caml_0028:+i67 4:+i28 1
caml_0028 +i66:+i28 1
caml_002a +i00:+i87 14757,caml_002e:+i65:+i28 1
caml_002e +i64
caml_002f +i28 1
caml_0030 +i2b 0,caml_000a:+i6c 27301:+i0b:+i21:+i36 12:+i21:+i13 1:+i8f
caml_objcode_end

!source "/home/pifu/.opam/4.14.3/lib/oc64ml/runtime.asm"
!source "/home/pifu/.opam/4.14.3/lib/oc64ml/memory.asm"
!source "/home/pifu/.opam/4.14.3/lib/oc64ml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_string_of_int)
	!byte <(caml_print_string)
	!byte <(caml_fresh_oo_id)
caml_externals_hi
	!byte >(caml_string_of_int)
	!byte >(caml_print_string)
	!byte >(caml_fresh_oo_id)
!macro p .ptr { !wo caml_glob_data + .ptr }
caml_glob_table
!h 01 00
caml_glob_data

caml_glob_end
!source "/home/pifu/.opam/4.14.3/lib/oc64ml/trailer.asm"
