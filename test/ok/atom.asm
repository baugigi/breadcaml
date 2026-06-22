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

caml_top_of_memory = 40959
caml_stack_pages = 4

use_PUSHACC1 = 1
use_POP = 1
use_APPLY1 = 1
use_RETURN = 1
use_CLOSURE = 1
use_GETGLOBAL = 1
use_PUSHGETGLOBAL = 1
use_SETGLOBAL = 1
use_ATOM0 = 1
use_MAKEBLOCK2 = 1
use_BRANCH = 1
use_CONST0 = 1
use_PUSHCONST0 = 1
use_STOP = 1
!source "/home/piero/.opam/4.04.1/lib/oc64ml/header.asm"
!source "/home/piero/.opam/4.04.1/lib/oc64ml/interp.asm"
!source "/home/piero/.opam/4.04.1/lib/oc64ml/runtime.asm"
!source "/home/piero/.opam/4.04.1/lib/oc64ml/stdlib.asm"

caml_bytecode
!set caml_ptr_baseaddr = *
!macro p .ptr { !wo (caml_ptr_baseaddr + .ptr) }
!h 54:+p $000d:!h 35 00 00 36 02 00 40 00 28 02 63 39 02 00 3a 39 00 00 2b 00
+p $0003:!h 68 0b 21 13 02 00 8f

caml_externals_lo

caml_externals_hi


!align $01, $00
!set caml_ptr_baseaddr = *
caml_globals_init_heap

caml_globals_init_stack

!by  $01 :!by  $00 :!by  $01 :!by  $00
caml_globals_init_end
