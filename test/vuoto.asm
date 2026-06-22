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

!to "vuoto.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/pifu/.opam/4.14.3/lib/o64ml/c64defs.asm"
!source "/home/pifu/.opam/4.14.3/lib/o64ml/loader.asm"
!source "/home/pifu/.opam/4.14.3/lib/o64ml/codegen.asm"

caml_program

caml_0000 +i8f
caml_program_end

!source "/home/pifu/.opam/4.14.3/lib/o64ml/runtime.asm"
!source "/home/pifu/.opam/4.14.3/lib/o64ml/memory.asm"
!source "/home/pifu/.opam/4.14.3/lib/o64ml/stdlib.asm"
!align $01, $00
caml_externals_lo
caml_externals_hi
!macro p .ptr { !wo caml_glob_data + .ptr }
caml_glob_table

caml_glob_data

caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/pifu/.opam/4.14.3/lib/o64ml/showmem.asm"
