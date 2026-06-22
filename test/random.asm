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
caml_PRIM__caml_nonstd_print_char = 1
caml_PRIM__caml_nonstd_string_of_int = 1
caml_PRIM__caml_nonstd_print_string = 1
caml_PRIM__caml_fresh_oo_id = 1
caml_PRIM__caml_nonstd_mem_peek = 1
caml_PRIM__caml_create_bytes = 1
caml_PRIM__caml_nonstd_random_get_state = 1
caml_PRIM__caml_nonstd_random_set_state = 1
caml_PRIM__caml_nonstd_random_int = 1
!source "/home/pifu/.opam/4.14.3/lib/oc64ml/loader.asm"

caml_objcode

caml_0000 +i54 caml_0017
caml_0001 +i67 13:+i5d 0:+i28 1
caml_0004 +i00:+i5d 1:+i5d 2:+i28 1
caml_0008 +i00:+i87 0,caml_000c:+i00:+i28 1
caml_000c +i00:+i6d:+i28 1
caml_000f +i00:+i36 3:+i40 0:+i5b
caml_0013 +i00:+i36 2:+i40 0:+i5b
caml_0017 +i2b 0,caml_0013:+i39 13:+i2b 0,caml_000f:+i39 15:+i63:+i5d 3
          +i2b 0,caml_0008:+i39 17:+i2b 0,caml_0004:+i39 19:+i2b 0,caml_0001
          +i39 20:+i67 255:+i6c 128:+i5e 4:+i63:+i5d 3:+i63:+i5d 3:+i63:+i5d 5
          +i54 caml_0058:+i29
caml_002e +i2a 2:+i63:+i5d 6:+i0c:+i43:+i5d 7:+i03:+i0c:+i21:+i68:+i5d 6:+i0e
          +i49:+i01:+i5d 7:+i00:+i28 5
caml_003f +i64:+i68:+i5d 8:+i73:+i69:+i79:+i28 1
caml_0046 +i35 12:+i36 13:+i25 2
caml_0049 +i00:+i85 0,caml_004e:+i35 14:+i36 15:+i25 2
caml_004e +i00:+i68:+i36 16:+i21:+i72:+i28 1
caml_0054 +i63:+i5d 8:+i36 17:+i25 2
caml_0058 +i2b 0,caml_0054:+i39 16:+i2b 0,caml_0049:+i09:+i2b 0,caml_0046:+i09
          +i2b 0,caml_003f:+i39 18:+i2b 0,caml_002e:+i0c:+i0b:+i21:+i02:+i0b
          +i21:+i01:+i0b:+i21:+i13 1:+i13 2:+i63:+i3f 0:+i68:+i3f 0:+i6c 10000
          +i69:+i0b:+i09:+i0c:+i7d:+i55 caml_008b
caml_0077 +i5c:+i63:+i36 18:+i21:+i56 caml_007f:+i04:+i80 1:+i54 caml_0081
caml_007f +i03:+i80 1
caml_0081 +i01:+i36 19:+i21:+i01:+i09:+i7f 1:+i14 2:+i01:+i7a:+i55 caml_0077
caml_008b +i13 2:+i63:+i36 20:+i21:+i35 21:+i5d 2:+i02:+i43:+i36 19:+i21:+i63
          +i36 20:+i21:+i35 22:+i5d 2:+i01:+i43:+i36 19:+i21:+i13 3:+i8f
caml_objcode_end

!source "/home/pifu/.opam/4.14.3/lib/oc64ml/runtime.asm"
!source "/home/pifu/.opam/4.14.3/lib/oc64ml/memory.asm"
!source "/home/pifu/.opam/4.14.3/lib/oc64ml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_print_char)
	!byte <(caml_nonstd_string_of_int)
	!byte <(caml_nonstd_print_string)
	!byte <(caml_fresh_oo_id)
	!byte <(caml_nonstd_mem_peek)
	!byte <(caml_create_bytes)
	!byte <(caml_nonstd_random_get_state)
	!byte <(caml_nonstd_random_set_state)
	!byte <(caml_nonstd_random_int)
caml_externals_hi
	!byte >(caml_nonstd_print_char)
	!byte >(caml_nonstd_string_of_int)
	!byte >(caml_nonstd_print_string)
	!byte >(caml_fresh_oo_id)
	!byte >(caml_nonstd_mem_peek)
	!byte >(caml_create_bytes)
	!byte >(caml_nonstd_random_get_state)
	!byte >(caml_nonstd_random_set_state)
	!byte >(caml_nonstd_random_int)
!macro p .ptr { !wo caml_glob_data + .ptr }
caml_glob_table
+p $0002:!h 01 00:+p $0026:!h 01 00 01 00 01 00 01 00 01 00 01 00:+p $0034
+p $0040
caml_glob_data
!h fc 11 52 61 6e 64 6f 6d 2e 66 6c 6f 61 74 20 6e 6f 6e 20 69 6d 70 6c 65
!h 6d 65 6e 74 65 64 20 79 65 74 00 01 fc 06 52 61 6e 64 6f 6d 2e 69 6e 74
!h 00 01 fc 05 23 74 72 75 65 20 3d 20 00 01 fc 05 23 66 61 6c 73 65 3d 20
!h 00 01
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
