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
caml_PRIM__caml_nonstd_print_string = 1
caml_PRIM__caml_nonstd_print_char = 1
caml_PRIM__caml_nonstd_string_of_int = 1
caml_PRIM__caml_ml_string_length = 1
caml_PRIM__caml_create_bytes = 1
caml_PRIM__caml_blit_string = 1
caml_PRIM__caml_string_of_bytes = 1
caml_PRIM__caml_fresh_oo_id = 1
caml_PRIM__caml_nonstd_mem_peek = 1
caml_PRIM__caml_bytes_of_string = 1
caml_PRIM__caml_ml_bytes_length = 1
caml_PRIM__caml_blit_bytes = 1
caml_PRIM__caml_array_get = 1
caml_PRIM__caml_array_set = 1
caml_PRIM__caml_array_unsafe_get = 1
caml_PRIM__caml_make_vect = 1
caml_PRIM__caml_array_unsafe_set = 1
caml_PRIM__caml_nonstd_random_get_state = 1
caml_PRIM__caml_nonstd_random_set_state = 1
caml_PRIM__caml_nonstd_random_int = 1
caml_PRIM__caml_nonstd_random_self_init = 1
caml_PRIM__caml_lessthan = 1
caml_PRIM__caml_greaterthan = 1
!source "/home/pifu/.opam/4.14.3/lib/oc64ml/loader.asm"

caml_objcode

caml_0000 +i54 caml_003e
caml_0001 +i00:+i5d 0:+i63:+i36 12:+i25 2
caml_0006 +i67 13:+i5d 1:+i28 1
caml_0009 +i00:+i5d 2:+i5d 0:+i28 1
caml_000d +i00:+i87 0,caml_0011:+i00:+i88 255,caml_0014
caml_0011 +i35 13:+i36 14:+i25 2
caml_0014 +i00:+i28 1:+i29
caml_0017 +i2a 1:+i00:+i5d 3:+i0c:+i5d 3:+i0a:+i0c:+i6e:+i5d 4:+i0c:+i68:+i0c
          +i68:+i11:+i61 5:+i01:+i0d:+i0c:+i68:+i12 8:+i61 5:+i00:+i5d 6:+i28 5
caml_002f +i00:+i87 0,caml_0033:+i00:+i28 1
caml_0033 +i00:+i6d:+i28 1
caml_0036 +i00:+i36 3:+i40 0:+i5b
caml_003a +i00:+i36 2:+i40 0:+i5b
caml_003e +i2b 0,caml_003a:+i39 26:+i2b 0,caml_0036:+i39 14:+i63:+i5d 7
          +i2b 0,caml_002f:+i39 29:+i2b 0,caml_0017:+i39 33:+i2b 0,caml_000d
          +i39 38:+i2b 0,caml_0009:+i39 30:+i2b 0,caml_0006:+i39 12
          +i2b 0,caml_0001:+i39 36:+i67 255:+i6c 128:+i5e 8:+i67 255:+i39 40
          +i63:+i5d 7:+i63:+i5d 7:+i54 caml_007a
caml_005a +i00:+i5d 6:+i28 1
caml_005d +i00:+i5d 9:+i28 1:+i29
caml_0061 +i2a 2:+i01:+i87 0,caml_006d:+i02:+i87 0,caml_006d:+i02:+i0b:+i5d 10
          +i6f:+i0c:+i7d:+i56 caml_0070
caml_006d +i35 15:+i36 14:+i25 4
caml_0070 +i02:+i5d 4:+i0d:+i68:+i0c:+i0f:+i0f:+i61 11:+i00:+i28 4
caml_007a +i63:+i5d 4:+i2b 0,caml_0061:+i39 17:+i2b 0,caml_005d:+i39 20
          +i2b 0,caml_005a:+i39 19:+i54 caml_008e:+i29
caml_0084 +i2a 2:+i02:+i0c:+i0c:+i36 16:+i21:+i36 17:+i23:+i36 18:+i25 4
caml_008e +i35 19:+i39 18:+i35 20:+i39 16:+i2b 0,caml_0084:+i39 34
          +i54 caml_0203:+i29
caml_0096 +i2a 2:+i01:+i0b:+i1c:+i22:+i0d:+i0b:+i1b:+i5e 12:+i1a:+i22
          +i88 0,caml_00ad:+i00:+i1b:+i5e 12:+i0d:+i1b:+i5f 13:+i03:+i0b:+i0d
          +i32:+i27 7
caml_00ad +i03:+i0d:+i1b:+i5f 13:+i28 4:+i29
caml_00b3 +i2a 1:+i01:+i0b:+i1b:+i22:+i0a:+i1a:+i5e 12:+i0d:+i1a:+i5f 13:+i00
          +i0c:+i32:+i26 5:+i29
caml_00c3 +i2a 1:+i66:+i0b:+i7f -1:+i71:+i0a:+i0c:+i7a:+i56 caml_00ce:+i63
          +i54 caml_00d2
caml_00ce +i35 21:+i36 10:+i40 0:+i5b
caml_00d2 +i02:+i0b:+i1b:+i5e 12:+i1a:+i22:+i86 0,caml_00ea:+i00:+i1b:+i5e 12
          +i0c:+i1b:+i5f 13:+i00:+i88 0,caml_00e5:+i02:+i0b:+i32:+i26 5
caml_00e5 +i02:+i68:+i1b:+i5f 13:+i28 3
caml_00ea +i02:+i0c:+i1b:+i5f 13:+i28 3:+i29
caml_00f0 +i2a 1:+i01:+i0c:+i0d:+i6e:+i6e:+i7f 1:+i0a:+i0c:+i0c:+i7f 2:+i7b
          +i56 caml_011d:+i01:+i7f 1:+i1c:+i5e 12:+i0c:+i1c:+i5e 12:+i1b:+i22
          +i68:+i7d:+i56 caml_010c:+i01:+i7f 1:+i14 0
caml_010c +i01:+i7f 2:+i1c:+i5e 12:+i0b:+i1c:+i5e 12:+i1b:+i22:+i68:+i7d
          +i56 caml_011b:+i01:+i7f 2:+i14 0
caml_011b +i00:+i28 4
caml_011d +i02:+i0c:+i7f 1:+i7b:+i56 caml_012f:+i01:+i7f 1:+i1c:+i5e 12:+i0c
          +i1c:+i5e 12:+i1b:+i22:+i86 0,caml_012f:+i01:+i7f 1:+i28 4
caml_012f +i02:+i0c:+i7b:+i56 caml_0135:+i01:+i28 4
caml_0135 +i03:+i1a:+i40 0:+i5b:+i29
caml_013a +i2a 1:+i01:+i0b:+i36 22:+i2b 3,caml_00f0:+i0a:+i0d:+i0d
          +i2c 1,3,caml_0096,[]:+i01:+i0e:+i2c 1,2,caml_00b3,[]:+i04:+i0e
          +i2c 1,2,caml_00c3,[]:+i05:+i4f:+i6b:+i0b:+i7f 1:+i71:+i7f -1:+i68
          +i09:+i0c:+i7b:+i55 caml_0178
caml_0155 +i5c:+i01:+i12 9:+i5e 12:+i09:+i59 caml_0162:+i04:+i11:+i12 9:+i12 13
          +i23:+i5a:+i54 caml_0170
caml_0162 +i36 22:+i0b:+i43:+i79:+i56 caml_016d:+i01:+i0b:+i44:+i12 12:+i5f 13
          +i54 caml_016f
caml_016d +i00:+i92
caml_016f +i13 1
caml_0170 +i13 1:+i01:+i09:+i7f -1:+i14 2:+i01:+i7a:+i55 caml_0155
caml_0178 +i63:+i13 2:+i00:+i7f -1:+i6a:+i09:+i0c:+i7b:+i55 caml_01ab
caml_0181 +i5c:+i01:+i12 9:+i5e 12:+i68:+i12 10:+i5e 12:+i0d:+i12 11:+i5f 13
          +i00:+i68:+i09:+i59 caml_0195:+i04:+i12 9:+i12 13:+i22:+i5a
          +i54 caml_01a0
caml_0195 +i36 22:+i0b:+i43:+i79:+i56 caml_019d:+i00:+i44:+i54 caml_019f
caml_019d +i00:+i92
caml_019f +i13 1
caml_01a0 +i13 1:+i10:+i22:+i13 1:+i01:+i09:+i7f -1:+i14 2:+i01:+i7a
          +i55 caml_0181
caml_01ab +i63:+i13 2:+i00:+i69:+i7b:+i56 caml_01bf:+i64:+i11:+i5e 12:+i68
          +i12 8:+i5e 12:+i69:+i12 9:+i5f 13:+i00:+i68:+i12 9:+i5f 13:+i13 1
caml_01bf +i28 7:+i29
caml_01c1 +i2a 1:+i63:+i0c:+i4f:+i7f -1:+i09:+i0c:+i7d:+i55 caml_01d8
caml_01ca +i5c:+i01:+i0e:+i5e 14:+i0c:+i0e:+i22:+i01:+i09:+i7f 1:+i14 2:+i01
          +i7a:+i55 caml_01ca
caml_01d8 +i63:+i28 4:+i29
caml_01db +i2a 1:+i00:+i84 0,caml_01e0:+i3a:+i28 2
caml_01e0 +i00:+i86 0,caml_01e5:+i35 23:+i36 14:+i25 3
caml_01e5 +i63:+i0c:+i21:+i0b:+i5e 15:+i69:+i0c:+i7f -1:+i09:+i0c:+i7d
          +i55 caml_01ff
caml_01f1 +i5c:+i01:+i0f:+i21:+i0c:+i0e:+i5f 16:+i01:+i09:+i7f 1:+i14 2:+i01
          +i7a:+i55 caml_01f1
caml_01ff +i63:+i13 2:+i00:+i28 3
caml_0203 +i2b 0,caml_01db:+i39 41:+i2b 0,caml_01c1:+i39 37:+i63:+i5d 7:+i36 24
          +i40 248:+i39 22:+i2b 0,caml_013a:+i39 42:+i54 caml_0236:+i29
caml_0210 +i2a 2:+i63:+i5d 17:+i0c:+i43:+i5d 18:+i03:+i0c:+i21:+i68:+i5d 17:+i0e
          +i49:+i01:+i5d 18:+i00:+i28 5
caml_0221 +i35 25:+i36 26:+i25 2
caml_0224 +i00:+i85 0,caml_0229:+i35 27:+i36 14:+i25 2
caml_0229 +i00:+i68:+i36 28:+i21:+i72:+i28 1
caml_022f +i63:+i5d 19:+i36 29:+i25 2
caml_0233 +i63:+i5d 20:+i28 1
caml_0236 +i2b 0,caml_0233:+i39 39:+i2b 0,caml_022f:+i39 28:+i2b 0,caml_0224
          +i09:+i2b 0,caml_0221:+i09:+i2b 0,caml_0210:+i0c:+i0b:+i21:+i02:+i0b
          +i21:+i01:+i0b:+i21:+i13 1:+i13 2:+i54 caml_027c:+i29
caml_024c +i2a 1:+i01:+i0b:+i5e 21:+i56 caml_0253:+i67 -1:+i28 2
caml_0253 +i01:+i0b:+i5e 22:+i56 caml_0258:+i64
caml_0258 +i28 2:+i29
caml_025a +i2a 1:+i00:+i36 30:+i21:+i35 31:+i5d 0:+i01:+i5d 2:+i36 32:+i36 33
          +i22:+i6b:+i0b:+i5d 3:+i7f -3:+i0c:+i36 34:+i23:+i5d 0:+i35 35:+i36 36
          +i25 4
caml_0270 +i00:+i09:+i2b 0,caml_025a:+i36 37:+i26 3
caml_0275 +i67 255:+i68:+i36 28:+i21:+i73:+i36 38:+i25 2
caml_027c +i63:+i36 39:+i21:+i2b 0,caml_0275:+i36 40:+i36 41:+i22:+i09
          +i2b 0,caml_0270:+i09:+i2b 0,caml_024c:+i0c:+i0c:+i21:+i02:+i0b
          +i36 42:+i22:+i02:+i0c:+i21:+i13 3:+i8f
caml_objcode_end

!source "/home/pifu/.opam/4.14.3/lib/oc64ml/runtime.asm"
!source "/home/pifu/.opam/4.14.3/lib/oc64ml/memory.asm"
!source "/home/pifu/.opam/4.14.3/lib/oc64ml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_print_string)
	!byte <(caml_nonstd_print_char)
	!byte <(caml_nonstd_string_of_int)
	!byte <(caml_ml_string_length)
	!byte <(caml_create_bytes)
	!byte <(caml_blit_string)
	!byte <(caml_string_of_bytes)
	!byte <(caml_fresh_oo_id)
	!byte <(caml_nonstd_mem_peek)
	!byte <(caml_bytes_of_string)
	!byte <(caml_ml_bytes_length)
	!byte <(caml_blit_bytes)
	!byte <(caml_array_get)
	!byte <(caml_array_set)
	!byte <(caml_array_unsafe_get)
	!byte <(caml_make_vect)
	!byte <(caml_array_unsafe_set)
	!byte <(caml_nonstd_random_get_state)
	!byte <(caml_nonstd_random_set_state)
	!byte <(caml_nonstd_random_int)
	!byte <(caml_nonstd_random_self_init)
	!byte <(caml_lessthan)
	!byte <(caml_greaterthan)
caml_externals_hi
	!byte >(caml_nonstd_print_string)
	!byte >(caml_nonstd_print_char)
	!byte >(caml_nonstd_string_of_int)
	!byte >(caml_ml_string_length)
	!byte >(caml_create_bytes)
	!byte >(caml_blit_string)
	!byte >(caml_string_of_bytes)
	!byte >(caml_fresh_oo_id)
	!byte >(caml_nonstd_mem_peek)
	!byte >(caml_bytes_of_string)
	!byte >(caml_ml_bytes_length)
	!byte >(caml_blit_bytes)
	!byte >(caml_array_get)
	!byte >(caml_array_set)
	!byte >(caml_array_unsafe_get)
	!byte >(caml_make_vect)
	!byte >(caml_array_unsafe_set)
	!byte >(caml_nonstd_random_get_state)
	!byte >(caml_nonstd_random_set_state)
	!byte >(caml_nonstd_random_int)
	!byte >(caml_nonstd_random_self_init)
	!byte >(caml_lessthan)
	!byte >(caml_greaterthan)
!macro p .ptr { !wo caml_glob_data + .ptr }
caml_glob_table
!h 01 00:+p $0002:!h 01 00:+p $0010:!h 01 00 01 00 01 00 01 00 01 00
+p $0036:!h 01 00:+p $003e:+p $004c:+p $0062:!h 01 00:+p $0086:!h 01 00 01
!h 00 01 00:+p $0094:+p $009c:!h 01 00 01 00:+p $00a2:!h 01 00 01 00 01 00
!h 01 00 01 00 01 00 01 00
caml_glob_data
!h fc 06 63 68 61 72 5f 6f 66 5f 69 6e 74 00 fc 0c 53 74 72 69 6e 67 2e 73
!h 75 62 20 2f 20 42 79 74 65 73 2e 73 75 62 00 01 fc 05 61 72 72 61 79 2e
!h 6d 6c 00 01 00 03:+p $002a:!h 85 02 09 00 fc 06 41 72 72 61 79 2e 69 6e
!h 69 74 00 01 fc 0a 53 74 64 6c 69 62 2e 41 72 72 61 79 2e 42 6f 74 74 6f
!h 6d 00 fc 11 52 61 6e 64 6f 6d 2e 66 6c 6f 61 74 20 6e 6f 6e 20 69 6d 70
!h 6c 65 6d 65 6e 74 65 64 20 79 65 74 00 01 fc 06 52 61 6e 64 6f 6d 2e 69
!h 6e 74 00 01 fc 03 20 3d 20 22 5c 00 fc 02 30 30 00 01 fc 01 22 00
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
