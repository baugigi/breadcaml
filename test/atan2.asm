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
caml_PRIM__caml_nonstd_string_of_float = 1
caml_PRIM__caml_nonstd_print_string = 1
caml_PRIM__caml_nonstd_sign_float = 1
caml_PRIM__caml_sub_float = 1
caml_PRIM__caml_div_float = 1
caml_PRIM__caml_atan_float = 1
caml_PRIM__caml_mul_float = 1
caml_PRIM__caml_neg_float = 1
caml_PRIM__caml_add_float = 1
caml_PRIM__caml_sqrt_float = 1
caml_PRIM__caml_fresh_oo_id = 1
!source "/home/pifu/.opam/4.14.3/lib/oc64ml/loader.asm"

caml_objcode

caml_0000 +i54 caml_004a
caml_0001 +i00:+i5d 0:+i5d 1:+i28 1:+i29
caml_0006 +i2a 1:+i00:+i5d 2:+i0a:+i83 0,caml_002e:+i00:+i83 1,caml_001e
          +i59 caml_001b:+i05:+i11:+i11:+i12 9:+i36 12:+i22:+i5e 3:+i5e 4:+i5d 5
          +i36 13:+i5e 6:+i5a:+i28 3
caml_001b +i36 14:+i5d 7:+i28 4
caml_001e +i59 caml_002c:+i05:+i11:+i11:+i12 9:+i36 12:+i22:+i5e 3:+i5e 4:+i5d 5
          +i36 15:+i5e 6:+i5a:+i28 3
caml_002c +i36 14:+i28 4
caml_002e +i02:+i5d 2:+i0a:+i83 0,caml_0038:+i00:+i83 1,caml_0036:+i35 14:+i28 4
caml_0036 +i35 16:+i28 4
caml_0038 +i35 17:+i36 18:+i25 5:+i29
caml_003c +i2a 1:+i01:+i0c:+i5e 6:+i0b:+i0c:+i5e 6:+i5e 8:+i5d 9:+i28 2
caml_0046 +i00:+i36 3:+i40 0:+i5b
caml_004a +i2b 0,caml_0046:+i39 18:+i63:+i5d 10:+i35 19:+i39 14:+i2b 0,caml_003c
          +i39 12:+i2b 0,caml_0006:+i39 22:+i2b 0,caml_0001:+i39 23:+i35 20
          +i36 21:+i36 22:+i22:+i36 23:+i21:+i8f
caml_objcode_end

!source "/home/pifu/.opam/4.14.3/lib/oc64ml/runtime.asm"
!source "/home/pifu/.opam/4.14.3/lib/oc64ml/memory.asm"
!source "/home/pifu/.opam/4.14.3/lib/oc64ml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_string_of_float)
	!byte <(caml_nonstd_print_string)
	!byte <(caml_nonstd_sign_float)
	!byte <(caml_sub_float)
	!byte <(caml_div_float)
	!byte <(caml_atan_float)
	!byte <(caml_mul_float)
	!byte <(caml_neg_float)
	!byte <(caml_add_float)
	!byte <(caml_sqrt_float)
	!byte <(caml_fresh_oo_id)
caml_externals_hi
	!byte >(caml_nonstd_string_of_float)
	!byte >(caml_nonstd_print_string)
	!byte >(caml_nonstd_sign_float)
	!byte >(caml_sub_float)
	!byte >(caml_div_float)
	!byte >(caml_atan_float)
	!byte >(caml_mul_float)
	!byte >(caml_neg_float)
	!byte >(caml_add_float)
	!byte >(caml_sqrt_float)
	!byte >(caml_fresh_oo_id)
!macro p .ptr { !wo caml_glob_data + .ptr }
caml_glob_table
!h 01 00:+p $0002:!h 01 00:+p $000a:+p $0012:+p $001a:!h 01 00:+p $0022
+p $002a:+p $0032:!h 01 00 01 00
caml_glob_data
!h fd 03 82 00 00 00 00 ff fd 03 82 00 00 00 00 ff fd 03 00 00 00 00 00 ff
!h fc 03 61 74 61 6e 32 00 fd 03 82 49 0f da a2 ff fd 03 86 83 99 99 9a ff
!h fd 03 86 0b 99 99 9a ff
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
