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

!source "/home/piero/.opam/4.14.2/lib/oc64ml/c64defs.asm"
caml_stack_start = $9c00
caml_stack_end = $a000
!source "/home/piero/.opam/4.14.2/lib/oc64ml/loader.asm"

caml_objcode

caml_0000 +i54 caml_0005
caml_0001 +i35 12:+i80 1:+i37 12,0:+i28 1
caml_0005 +i67 1000:+i3f 0:+i39 12:+i2b 0,caml_0001:+i68:+i0b:+i21:+i13 1:+i8f
caml_objcode_end

!source "/home/piero/.opam/4.14.2/lib/oc64ml/runtime.asm"
!source "/home/piero/.opam/4.14.2/lib/oc64ml/memory.asm"
!source "/home/piero/.opam/4.14.2/lib/oc64ml/stdlib.asm"
!align $01, $00
caml_externals_lo
caml_externals_hi
!macro p .ptr { !wo caml_glob_data + .ptr }
caml_glob_table
!h 01 00
caml_glob_data

caml_glob_end
;; questo non dovrebbe stare qui...
!if caml_stack_start < caml_glob_end {
  !serious "ERROR: Not enough memory for stack."
}

;; mostra l'occupazione della memoria
!ifdef caml_SHOWMEM {
  !macro caml_mem @txt, @start, @end {
    !if @end > @start {
      !info @txt + "\t", @start, "\t", @end - 1, "\t", @end - @start
    } else {
      !info @txt + "\t", "<N/A>        \t<N/A>        \t0 (0x0)"
    }
  }
  !ifndef caml_acme_allpasses { ;wait for ACME to complete all passes
caml_acme_allpasses
    !info "SECTION     \tSTART ADDRESS\tEND ADDRESS\tSIZE"
    +caml_mem " BASIC loader", caml_loader, caml_loader_end
    +caml_mem " Object code ", caml_objcode, caml_objcode_end
    +caml_mem " Custom libs ", caml_objcode_end, caml_runtime
    +caml_mem " Runtime libs", caml_runtime, caml_runtime_end
    +caml_mem " Memory GC   ", caml_memory, caml_memory_end
    +caml_mem " Standard lib", caml_stdlib, caml_stdlib_end
    +caml_mem " Prim.jumptbl", caml_stdlib_end, caml_glob_table
    +caml_mem " Global table", caml_glob_table, caml_glob_data
    +caml_mem " Global data ", caml_glob_data, caml_glob_end
    +caml_mem " Heap memory ", caml_glob_end, caml_stack_start
    +caml_mem " Stack memory", caml_stack_start, caml_stack_end
  }
}
