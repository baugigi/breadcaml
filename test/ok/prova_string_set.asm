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

caml_top_of_memory = 40959
caml_stack_pages = 12
PRIM_caml_print_string = 1
PRIM_caml_fresh_oo_id = 1
PRIM_caml_ml_string_length = 1
PRIM_caml_string_set = 1
PRIM_caml_create_string = 1

use_ACC0 = 1
use_ACC1 = 1
use_PUSH = 1
use_PUSHACC1 = 1
use_PUSHACC2 = 1
use_PUSHACC3 = 1
use_PUSHACC4 = 1
use_PUSHACC5 = 1
use_POP = 1
use_ASSIGN = 1
use_APPLY1 = 1
use_RETURN = 1
use_CLOSURE = 1
use_GETGLOBAL = 1
use_PUSHGETGLOBAL = 1
use_SETGLOBAL = 1
use_BRANCH = 1
use_BRANCHIF = 1
use_CHECKSIGNALS = 1
use_CCALL1 = 1
use_CCALL3 = 1
use_CONST0 = 1
use_CONSTINT = 1
use_PUSHCONST0 = 1
use_PUSHCONST1 = 1
use_PUSHCONSTINT = 1
use_ADDINT = 1
use_MODINT = 1
use_NEQ = 1
use_LTINT = 1
use_GTINT = 1
use_OFFSETINT = 1
use_STOP = 1
!source "/home/piero/.opam/4.04.1/lib/oc64ml/header.asm"
!source "/home/piero/.opam/4.04.1/lib/oc64ml/interp.asm"
!source "/home/piero/.opam/4.04.1/lib/oc64ml/runtime.asm"
!source "/home/piero/.opam/4.04.1/lib/oc64ml/stdlib.asm"

caml_bytecode
!set caml_ptr_baseaddr = *
!macro p .ptr { !wo (caml_ptr_baseaddr + .ptr) }
!h 54:+p $000a:!h 35 00 00 5d 00 28 02 63 5d 01 2b 00:+p $0003:!h 39 02 00 54
+p $0085:!h 00 5d 02 6c 55 00 68 0d 5f 03 00 7f fe ff 69 09 0c 7b 55:+p $0047
!h 5c 67 15 00 0c 72 6c 61 00 6e 0c 0f 5f 03 01 09 7f fe ff 14 04 00 01 7a 55
+p $002c:!h 63 13 04 00 01 28 04 00 5d 04 6c 55 00 68 0c 5f 03 01 7f fe ff 69
!h 09 0c 7b 55:+p $007e:!h 5c 67 15 00 0c 72 6c 61 00 6e 0c 0e 5f 03 01 09 7f
!h fe ff 14 04 00 01 7a 55:+p $0063:!h 63 13 04 00 00 28 04 2b 00:+p $004e
!h 69 6c 29 00 09 0c 7d 55:+p $00ab:!h 5c 01 0d 21 5d 00 63 36 02 00 21 01 09
!h 7f 02 00 14 04 00 01 7a 55:+p $0093:!h 13 04 00 2b 00:+p $0017:!h 36 04 00
!h 0b 21 5d 00 63 36 02 00 21 13 04 00 8f

caml_externals_lo
        !byte <(caml_print_string)
        !byte <(caml_fresh_oo_id)
        !byte <(caml_ml_string_length)
        !byte <(caml_string_set)
        !byte <(caml_create_string)

caml_externals_hi
        !byte >(caml_print_string)
        !byte >(caml_fresh_oo_id)
        !byte >(caml_ml_string_length)
        !byte >(caml_string_set)
        !byte >(caml_create_string)


!align $01, $00
!set caml_ptr_baseaddr = *
caml_globals_init_heap

!by  $fc :!by  $01 :!by  $0d :!by  $00 :!by  $fc :!by  $1e :!by  $78 :!by  $78
!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78
!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78
!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78
!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78
!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78
!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78
!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78 :!by  $78
!by  $78 :!by  $00
caml_globals_init_stack

+p $0002 :!by  $01 :!by  $00 :+p $0006
caml_globals_init_end
