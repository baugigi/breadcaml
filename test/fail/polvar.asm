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

!source "/home/pifu/.opam/4.14.3/lib/oc64ml/header.asm"
caml_stack_start = $9c00
caml_stack_end = $a000
!source "/home/pifu/.opam/4.14.3/lib/oc64ml/loader.asm"

caml_objcode

caml_0000 +i54 caml_0003
caml_0001 +i67 -608347016:+i28 1
caml_0003 +i2b 0,caml_0001:+i68:+i0b:+i21:+i13 1:+i8f
caml_objcode_end

!source "/home/pifu/.opam/4.14.3/lib/oc64ml/runtime.asm"
!source "/home/pifu/.opam/4.14.3/lib/oc64ml/memory.asm"
!source "/home/pifu/.opam/4.14.3/lib/oc64ml/stdlib.asm"
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
!ifdef caml_SHOWMEM {
  !macro caml_mem @txt, @start, @end {
    !info @txt + "\t", @start, "\t", @end - 1, "\t", @end - @start
  }
  !ifndef caml_acme_allpasses { ;wait for ACME to complete all passes
caml_acme_allpasses
    !info "---SECTION---\tSTART ADDRESS\tEND ADDRESS\tSIZE"
    +caml_mem "Basic loader", caml_loader, caml_loader_end
    +caml_mem "Object code ", caml_objcode, caml_objcode_end
    +caml_mem "Runtime lib ", caml_runtime, caml_runtime_end
    +caml_mem "Garb.Collect", caml_memory, caml_memory_end
    +caml_mem "Standard lib", caml_stdlib, caml_stdlib_end
    +caml_mem "External lib", caml_stdlib_end, caml_glob_data
    +caml_mem "Global data ", caml_glob_data, caml_glob_end
    +caml_mem "Heap memory ", caml_glob_end, caml_stack_start
    +caml_mem "Stack memory", caml_stack_start, caml_stack_end
  }
}
