;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "snake.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/pifu/.opam/4.14.3/lib/breadcaml/c64defs.asm"
caml_PRIM__caml_ml_string_length = 1
caml_PRIM__caml_create_bytes = 1
caml_PRIM__caml_blit_string = 1
caml_PRIM__caml_string_of_bytes = 1
caml_PRIM__caml_fresh_oo_id = 1
caml_PRIM__caml_nonstd_mem_peek = 1
caml_PRIM__caml_bytes_of_string = 1
caml_PRIM__caml_ml_bytes_length = 1
caml_PRIM__caml_blit_bytes = 1
caml_PRIM__caml_nonstd_random_get_state = 1
caml_PRIM__caml_nonstd_random_set_state = 1
caml_PRIM__caml_nonstd_random_int = 1
caml_PRIM__caml_nonstd_random_self_init = 1
caml_PRIM__IOtools_get_key = 1
caml_PRIM__caml_nonstd_print_char = 1
caml_PRIM__IOtools_set_cursor_position = 1
caml_PRIM__caml_nonstd_print_string = 1
caml_PRIM__IOtools_videoram_write = 1
caml_PRIM__IOtools_videoram_read = 1
caml_PRIM__caml_nonstd_string_of_int = 1
!source "/home/pifu/.opam/4.14.3/lib/breadcaml/loader.asm"
!source "/home/pifu/.opam/4.14.3/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i54 caml_0029:+i29
caml_0002 +i2a 1:+i00:+i5d 0:+i0c:+i5d 0:+i0a:+i0c:+i6e:+i5d 1:+i0c:+i68:+i0c
          +i68:+i11:+i61 2:+i01:+i0d:+i0c:+i68:+i12 8:+i61 2:+i00:+i5d 3:+i28 5
caml_001a +i00:+i87 0,caml_001e:+i00:+i28 1
caml_001e +i00:+i6d:+i28 1
caml_0021 +i00:+i36 3:+i40 0:+i5b
caml_0025 +i00:+i36 2:+i40 0:+i5b
caml_0029 +i2b 0,caml_0025:+i39 20:+i2b 0,caml_0021:+i39 13:+i63:+i5d 4
          +i2b 0,caml_001a:+i39 23:+i2b 0,caml_0002:+i39 58:+i67 255:+i6c 128
          +i5e 5:+i63:+i5d 4:+i63:+i5d 4:+i54 caml_005b
caml_003b +i00:+i5d 3:+i28 1
caml_003e +i00:+i5d 6:+i28 1:+i29
caml_0042 +i2a 2:+i01:+i87 0,caml_004e:+i02:+i87 0,caml_004e:+i02:+i0b:+i5d 7
          +i6f:+i0c:+i7d:+i56 caml_0051
caml_004e +i35 12:+i36 13:+i25 4
caml_0051 +i02:+i5d 1:+i0d:+i68:+i0c:+i0f:+i0f:+i61 8:+i00:+i28 4
caml_005b +i63:+i5d 1:+i2b 0,caml_0042:+i39 15:+i2b 0,caml_003e:+i39 18
          +i2b 0,caml_003b:+i39 17:+i54 caml_006f:+i29
caml_0065 +i2a 2:+i02:+i0c:+i0c:+i36 14:+i21:+i36 15:+i23:+i36 16:+i25 4
caml_006f +i35 17:+i39 16:+i35 18:+i39 14:+i2b 0,caml_0065:+i39 56
          +i54 caml_009d:+i29
caml_0077 +i2a 2:+i63:+i5d 9:+i0c:+i43:+i5d 10:+i03:+i0c:+i21:+i68:+i5d 9:+i0e
          +i49:+i01:+i5d 10:+i00:+i28 5
caml_0088 +i35 19:+i36 20:+i25 2
caml_008b +i00:+i85 0,caml_0090:+i35 21:+i36 13:+i25 2
caml_0090 +i00:+i68:+i36 22:+i21:+i72:+i28 1
caml_0096 +i63:+i5d 11:+i36 23:+i25 2
caml_009a +i63:+i5d 12:+i28 1
caml_009d +i2b 0,caml_009a:+i39 52:+i2b 0,caml_0096:+i39 22:+i2b 0,caml_008b
          +i09:+i39 63:+i00:+i13 1:+i09:+i2b 0,caml_0088:+i09:+i2b 0,caml_0077
          +i0c:+i0b:+i21:+i02:+i0b:+i21:+i01:+i0b:+i21:+i13 1:+i13 2
          +i54 caml_0134
caml_00b6 +i00:+i5d 13:+i28 1
caml_00b9 +i67 142:+i5d 14:+i28 1
caml_00bc +i67 147:+i5d 14:+i28 1:+i29
caml_00c0 +i2a 1:+i00:+i44:+i0b:+i43:+i6c 39:+i0b:+i68:+i36 24:+i23
          +i56 caml_00d3:+i67 24:+i0c:+i68:+i36 24:+i23:+i56 caml_00d3:+i63
          +i54 caml_00d7
caml_00d3 +i35 25:+i36 10:+i40 0:+i5b
caml_00d7 +i00:+i0c:+i6c 24:+i6f:+i6c 256:+i70:+i6e:+i5d 15:+i13 2:+i01:+i5d 16
          +i28 2:+i29
caml_00e4 +i2a 1:+i00:+i44:+i0b:+i43:+i6c 39:+i0b:+i68:+i36 24:+i23
          +i56 caml_00fd:+i67 24:+i0c:+i68:+i36 24:+i23:+i56 caml_00fd:+i67 255
          +i0e:+i68:+i36 24:+i23:+i56 caml_00fd:+i63:+i54 caml_0101
caml_00fd +i35 26:+i36 10:+i40 0:+i5b
caml_0101 +i03:+i0b:+i0d:+i6c 24:+i6f:+i6c 40:+i70:+i6e:+i5e 17:+i28 4
caml_010b +i00:+i44:+i0b:+i43:+i6c 39:+i0b:+i68:+i36 24:+i23:+i56 caml_011d
          +i67 24:+i0c:+i68:+i36 24:+i23:+i56 caml_011d:+i63:+i54 caml_0121
caml_011d +i35 27:+i36 10:+i40 0:+i5b
caml_0121 +i00:+i0c:+i6c 24:+i6f:+i6c 40:+i70:+i6e:+i5d 18:+i28 3:+i29
caml_012b +i2a 2:+i01:+i0b:+i7c:+i56 caml_0133:+i02:+i0c:+i7c
caml_0133 +i28 3
caml_0134 +i2b 0,caml_012b:+i39 24:+i2b 0,caml_010b:+i39 64:+i2b 0,caml_00e4
          +i39 62:+i2b 0,caml_00c0:+i39 60:+i2b 0,caml_00bc:+i39 49
          +i2b 0,caml_00b9:+i39 50:+i2b 0,caml_00b6:+i39 33:+i54 caml_0407
caml_0143 +i00:+i68:+i7b:+i56 caml_014b:+i00:+i7f -1:+i32:+i25 2
caml_014b +i28 1
caml_014c +i37 28,3:+i0b:+i45:+i7d:+i0a:+i56 caml_015c:+i67 23:+i69:+i36 29:+i22
          +i6c 38:+i69:+i36 29:+i22:+i40 0:+i54 caml_0165
caml_015c +i67 22:+i6a:+i36 29:+i22:+i6c 37:+i6a:+i36 29:+i22:+i40 0
caml_0165 +i0a:+i36 30:+i21:+i0a:+i81:+i56 caml_0177:+i00:+i55 caml_0177:+i02
          +i55 caml_0173:+i01:+i36 31:+i21:+i55 caml_0177
caml_0173 +i65:+i0c:+i36 32:+i26 6
caml_0177 +i03:+i32:+i25 5:+i29
caml_017b +i2a 1:+i00:+i56 caml_0180:+i00:+i43
caml_0180 +i68:+i36 33:+i21:+i36 34:+i21:+i0a:+i81:+i56 caml_0199:+i00
          +i83 1,caml_0193:+i00:+i55 caml_01a4:+i01:+i56 caml_01a4:+i03:+i0c
          +i3f 0:+i32:+i26 6
caml_0193 +i01:+i55 caml_01a4:+i03:+i36 35:+i32:+i26 6
caml_0199 +i00:+i43:+i0e:+i36 36:+i21:+i0b:+i7a:+i56 caml_01a3:+i00:+i28 5
caml_01a3 +i13 1
caml_01a4 +i03:+i28 4
caml_01a6 +i63:+i36 33:+i21:+i1a:+i21:+i0a:+i81:+i56 caml_01b7:+i00
          +i87 2,caml_01b7:+i00:+i7f -2:+i57 3,[caml_01b3,caml_01b5,caml_01b7]
caml_01b3 +i64:+i28 2
caml_01b5 +i63:+i28 2
caml_01b7 +i63:+i32:+i25 3
caml_01ba +i37 28,2:+i0b:+i45:+i70:+i38 28,1:+i6f:+i36 37:+i21:+i00:+i43:+i44
          +i68:+i36 38:+i22:+i0a:+i0c:+i43:+i43:+i36 39:+i22:+i36 30:+i21:+i0a
          +i81:+i56 caml_01f9:+i00:+i86 3,caml_01f9:+i00
          +i57 3,[caml_01d7,caml_01f9,caml_01e3]
caml_01d7 +i02:+i45:+i0d:+i36 40:+i21:+i0e:+i0e:+i36 41:+i22:+i41 0:+i32:+i25 4
caml_01e3 +i02:+i45:+i7f 1:+i0d:+i44:+i0e:+i0e:+i36 41:+i22:+i41 0:+i0a:+i36 42
          +i21:+i00:+i36 43:+i21:+i00:+i36 44:+i21:+i00:+i32:+i25 5
caml_01f9 +i35 34:+i2c 1,1,caml_01a6,[]:+i35 45:+i6c 12:+i36 46:+i22:+i35 47
          +i6c 11:+i36 46:+i22:+i63:+i0b:+i21:+i56 caml_020c:+i63:+i36 48:+i21
          +i32:+i25 5
caml_020c +i28 4
caml_020d +i67 12:+i6a:+i38 28,0:+i6c 40:+i6f:+i71:+i68:+i6b:+i0d:+i38 28,0:+i0e
          +i6e:+i40 0:+i40 0:+i6a:+i0e:+i0e:+i40 0:+i40 0:+i41 0:+i68:+i36 49
          +i21:+i63:+i36 50:+i21:+i63:+i6c 39:+i09:+i0c:+i7d:+i55 caml_0257
caml_022d +i5c:+i67 39:+i0c:+i6c 24:+i70:+i71:+i69:+i68:+i0e:+i40 0:+i36 32:+i22
          +i64:+i6c 24:+i0e:+i6c 39:+i6f:+i40 0:+i36 32:+i22:+i64:+i0b:+i68
          +i40 0:+i36 32:+i22:+i64:+i0b:+i6c 24:+i6f:+i6c 39:+i40 0:+i36 32:+i22
          +i13 1:+i01:+i09:+i7f 1:+i14 2:+i01:+i7a:+i55 caml_022d
caml_0257 +i63:+i13 2:+i00:+i36 42:+i21:+i66:+i0d:+i0d:+i40 0:+i36 32:+i22:+i64
          +i38 28,0:+i09:+i0c:+i7d:+i55 caml_0278
caml_0268 +i5c:+i35 51:+i0f:+i0d:+i10:+i6e:+i40 0:+i36 32:+i22:+i01:+i09:+i7f 1
          +i14 2:+i01:+i7a:+i55 caml_0268
caml_0278 +i63:+i13 2:+i63:+i36 52:+i21:+i00:+i36 44:+i21:+i00:+i28 4
caml_0282 +i37 28,4:+i0b:+i45:+i7d:+i56 caml_02b1:+i37 53,0:+i88 0,caml_028c
          +i35 53:+i80 -1:+i28 1
caml_028c +i67 22:+i6a:+i36 29:+i22:+i6c 37:+i6a:+i36 29:+i22:+i40 0:+i0a
          +i36 30:+i21:+i68:+i79:+i56 caml_02a8:+i00:+i0c:+i43:+i43:+i36 54:+i22
          +i6c 5:+i7b:+i56 caml_02a8:+i00:+i36 31:+i21:+i58
caml_02a8 +i56 caml_02b0:+i64:+i0b:+i36 32:+i22:+i37 28,5:+i36 53:+i49
caml_02b0 +i13 1
caml_02b1 +i28 1
caml_02b2 +i00:+i44:+i0a:+i43:+i0a:+i36 30:+i21:+i0a:+i81:+i56 caml_02bf:+i35 55
          +i36 20:+i25 5
caml_02bf +i00:+i43:+i0a:+i0e:+i44:+i79:+i56 caml_02c9:+i01:+i44:+i54 caml_02ca
caml_02c9 +i00
caml_02ca +i68:+i0e:+i36 32:+i22:+i00:+i36 36:+i21:+i0b:+i0f:+i36 39:+i22:+i40 0
          +i28 6:+i29
caml_02d8 +i2a 1:+i01:+i43:+i43:+i0b:+i0b:+i36 39:+i22:+i6b:+i0b:+i36 32:+i22
          +i03:+i43:+i44:+i36 36:+i21:+i0d:+i40 0:+i0c:+i36 32:+i22:+i02:+i0b
          +i40 0:+i28 4
caml_02f2 +i00:+i45:+i5d 19:+i0a:+i5d 0:+i7f -1:+i69:+i0c:+i36 56:+i23:+i0a
          +i36 57:+i36 58:+i22:+i36 59:+i36 60:+i26 5:+i29
caml_0304 +i2a 1:+i01:+i0b:+i6a:+i0e:+i5d 0:+i6c 40:+i6f:+i71:+i40 0:+i36 60
          +i26 4:+i29
caml_0311 +i2a 1:+i01:+i81:+i56 caml_031f:+i01
          +i57 4,[caml_0317,caml_0319,caml_031b,caml_031d]
caml_0317 +i67 32:+i54 caml_033d
caml_0319 +i67 102:+i54 caml_033d
caml_031b +i67 90:+i54 caml_033d
caml_031d +i67 81:+i54 caml_033d
caml_031f +i01:+i43:+i57 4,[caml_0322,caml_0325,caml_0328,caml_032b]
caml_0322 +i01:+i44:+i57 4,[caml_032e,caml_0332,caml_0334,caml_0336]
caml_0325 +i01:+i44:+i57 4,[caml_0332,caml_032e,caml_0338,caml_033a]
caml_0328 +i01:+i44:+i57 4,[caml_0334,caml_0338,caml_032e,caml_033c]
caml_032b +i01:+i44:+i57 4,[caml_0336,caml_033a,caml_033c,caml_032e]
caml_032e +i35 61:+i36 20:+i21:+i54 caml_033d
caml_0332 +i67 66:+i54 caml_033d
caml_0334 +i67 75:+i54 caml_033d
caml_0336 +i67 74:+i54 caml_033d
caml_0338 +i67 73:+i54 caml_033d
caml_033a +i67 85:+i54 caml_033d
caml_033c +i67 67
caml_033d +i0b:+i36 62:+i26 4:+i29
caml_0341 +i2a 1:+i00:+i0c:+i7f 1:+i6f:+i36 63:+i21:+i0b:+i6e:+i28 2
caml_034b +i00:+i56 caml_0358:+i00:+i43:+i1a:+i21:+i69:+i79:+i55 caml_0358:+i00
          +i44:+i32:+i25 2
caml_0358 +i28 1
caml_0359 +i00:+i44:+i0b:+i43:+i0b:+i7f 1:+i0c:+i7f -1:+i0c:+i7f 1:+i0d:+i7f -1
          +i36 30:+i2c 1,1,caml_034b,[]:+i63:+i0e:+i0e:+i40 0:+i40 0:+i0e:+i11
          +i40 0:+i40 0:+i0e:+i0d:+i40 0:+i40 0:+i11:+i0e:+i40 0:+i40 0:+i11
          +i0d:+i40 0:+i40 0:+i0f:+i0e:+i40 0:+i40 0:+i0f:+i11:+i40 0:+i40 0
          +i0f:+i0d:+i40 0:+i40 0:+i0b:+i25 9
caml_038a +i00:+i36 64:+i21:+i0a:+i87 66,caml_03a4:+i00:+i86 91,caml_03aa:+i00
          +i7f -66
          +i57 25,[caml_0394,caml_0396,caml_03aa,caml_03aa,caml_03aa,caml_03aa,caml_03aa,caml_0398,caml_039a,caml_039c,caml_03aa,caml_03aa,caml_03aa,caml_03aa,caml_03aa,caml_039e,caml_03aa,caml_03aa,caml_03aa,caml_03a0,caml_03aa,caml_03aa,caml_03aa,caml_03aa,caml_03a2]
caml_0394 +i35 65:+i28 2
caml_0396 +i35 66:+i28 2
caml_0398 +i35 67:+i28 2
caml_039a +i35 68:+i28 2
caml_039c +i35 69:+i28 2
caml_039e +i66:+i28 2
caml_03a0 +i35 70:+i28 2
caml_03a2 +i65:+i28 2
caml_03a4 +i00:+i6c 32:+i7a:+i56 caml_03a9:+i54 caml_03aa
caml_03a9 +i28 2
caml_03aa +i64:+i28 2
caml_03ac +i00:+i87 78,caml_03c1:+i00:+i83 145,caml_03bf:+i00:+i83 157,caml_03bd
          +i00:+i86 90,caml_03cd:+i00:+i7f -78
          +i57 12,[caml_03b7,caml_03cd,caml_03b9,caml_03cd,caml_03cd,caml_03cd,caml_03cd,caml_03cd,caml_03cd,caml_03cd,caml_03cd,caml_03bb]
caml_03b7 +i66:+i28 1
caml_03b9 +i64:+i28 1
caml_03bb +i65:+i28 1
caml_03bd +i35 71:+i28 1
caml_03bf +i35 72:+i28 1
caml_03c1 +i00:+i83 17,caml_03cb:+i00:+i83 29,caml_03c9:+i00:+i56 caml_03c8
          +i54 caml_03cd
caml_03c8 +i28 1
caml_03c9 +i35 73:+i28 1
caml_03cb +i35 74:+i28 1
caml_03cd +i67 4:+i28 1:+i29
caml_03d0 +i2a 1:+i00:+i44:+i0b:+i43:+i0d
          +i57 4,[caml_03d7,caml_03dc,caml_03e1,caml_03e6]
caml_03d7 +i01:+i7f 1:+i0b:+i40 0:+i28 4
caml_03dc +i01:+i7f -1:+i0b:+i40 0:+i28 4
caml_03e1 +i01:+i0b:+i7f -1:+i40 0:+i28 4
caml_03e6 +i01:+i0b:+i7f 1:+i40 0:+i28 4:+i29
caml_03ec +i2a 1:+i01:+i44:+i0b:+i44:+i6f:+i36 23:+i21:+i0c:+i43:+i0c:+i43:+i6f
          +i36 23:+i21:+i6e:+i28 2
caml_03fd +i00:+i57 4,[caml_03ff,caml_0401,caml_0403,caml_0405]
caml_03ff +i64:+i28 1
caml_0401 +i63:+i28 1
caml_0403 +i66:+i28 1
caml_0405 +i65:+i28 1
caml_0407 +i35 75:+i09:+i39 28:+i00:+i13 1:+i09:+i2b 0,caml_03fd:+i39 36
          +i2b 0,caml_03ec:+i39 54:+i2b 0,caml_03d0:+i39 39:+i2b 0,caml_03ac
          +i39 34:+i2b 0,caml_038a:+i39 30:+i2b 0,caml_0359:+i39 31
          +i2b 0,caml_0341:+i39 29:+i2b 0,caml_0311:+i39 32
          +i2c 1,0,caml_0143,[]:+i00:+i39 37:+i2b 0,caml_0304:+i39 46
          +i2b 0,caml_02f2:+i39 42:+i2b 0,caml_02d8:+i39 41:+i2b 0,caml_02b2
          +i39 40:+i2c 1,0,caml_014c,[]:+i00:+i39 44:+i02:+i47 5:+i3f 0:+i39 53
          +i2b 0,caml_0282:+i39 43:+i2c 1,0,caml_017b,[]:+i00:+i39 38
          +i2b 0,caml_020d:+i09:+i39 48:+i00:+i13 1:+i09:+i2c 1,0,caml_01ba,[]
          +i63:+i0c:+i21:+i0b:+i21:+i13 6:+i8f
caml_program_end

!source "iOtools.asm"
!source "/home/pifu/.opam/4.14.3/lib/breadcaml/runtime.asm"
!source "/home/pifu/.opam/4.14.3/lib/breadcaml/memory.asm"
!source "/home/pifu/.opam/4.14.3/lib/breadcaml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_ml_string_length)
	!byte <(caml_create_bytes)
	!byte <(caml_blit_string)
	!byte <(caml_string_of_bytes)
	!byte <(caml_fresh_oo_id)
	!byte <(caml_nonstd_mem_peek)
	!byte <(caml_bytes_of_string)
	!byte <(caml_ml_bytes_length)
	!byte <(caml_blit_bytes)
	!byte <(caml_nonstd_random_get_state)
	!byte <(caml_nonstd_random_set_state)
	!byte <(caml_nonstd_random_int)
	!byte <(caml_nonstd_random_self_init)
	!byte <(IOtools_get_key)
	!byte <(caml_nonstd_print_char)
	!byte <(IOtools_set_cursor_position)
	!byte <(caml_nonstd_print_string)
	!byte <(IOtools_videoram_write)
	!byte <(IOtools_videoram_read)
	!byte <(caml_nonstd_string_of_int)
caml_externals_hi
	!byte >(caml_ml_string_length)
	!byte >(caml_create_bytes)
	!byte >(caml_blit_string)
	!byte >(caml_string_of_bytes)
	!byte >(caml_fresh_oo_id)
	!byte >(caml_nonstd_mem_peek)
	!byte >(caml_bytes_of_string)
	!byte >(caml_ml_bytes_length)
	!byte >(caml_blit_bytes)
	!byte >(caml_nonstd_random_get_state)
	!byte >(caml_nonstd_random_set_state)
	!byte >(caml_nonstd_random_int)
	!byte >(caml_nonstd_random_self_init)
	!byte >(IOtools_get_key)
	!byte >(caml_nonstd_print_char)
	!byte >(IOtools_set_cursor_position)
	!byte >(caml_nonstd_print_string)
	!byte >(IOtools_videoram_write)
	!byte >(IOtools_videoram_read)
	!byte >(caml_nonstd_string_of_int)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
+p $0002:!h 01 00 01 00 01 00 01 00 01 00 01 00:+p $001c:!h 01 00:+p $0040
!h 01 00 01 00 01 00:+p $005c:+p $0072:+p $0088:!h 01 00 01 00 01 00 01 00
!h 01 00 01 00 01 00:+p $0090:!h 01 00 01 00 01 00 01 00 01 00 01 00 01 00
!h 01 00 01 00:+p $0094:!h 01 00:+p $00aa:!h 01 00 01 00 01 00:+p $00c0
!h 01 00 01 00 01 00:+p $00c6:!h 01 00:+p $00d2:!h 01 00:+p $00dc:!h 01 00
+p $00e2:!h 01 00 01 00 01 00:+p $00ee:+p $00f4:+p $00fa:+p $0100:+p $0106
+p $010c:+p $0112:+p $0116:+p $011a:+p $011e:+p $0122
caml_glob_data
!h fc 0c 53 74 72 69 6e 67 2e 73 75 62 20 2f 20 42 79 74 65 73 2e 73 75 62
!h 00 01 fc 11 52 61 6e 64 6f 6d 2e 66 6c 6f 61 74 20 6e 6f 6e 20 69 6d 70
!h 6c 65 6d 65 6e 74 65 64 20 79 65 74 00 01 fc 06 52 61 6e 64 6f 6d 2e 69
!h 6e 74 00 01 fc 06 69 4f 74 6f 6f 6c 73 2e 6d 6c 00 01 00 03:+p $004e
!h 47 00 05 00 fc 06 69 4f 74 6f 6f 6c 73 2e 6d 6c 00 01 00 03:+p $0064
!h 3f 00 05 00 fc 06 69 4f 74 6f 6f 6c 73 2e 6d 6c 00 01 00 03:+p $007a
!h 37 00 05 00 00 01 03 00 fc 0a 20 2a 2a 2a 20 59 4f 55 20 4c 4f 53 54 21
!h 20 2a 2a 2a 20 00 fc 0a 20 50 4c 41 59 20 41 47 41 49 4e 20 28 59 2f 4e
!h 29 3f 20 00 00 02 05 00 07 00 fc 05 6d 6f 76 65 5f 74 61 69 6c 00 fc 04
!h 53 43 4f 52 45 3a 00 01 00 02 05 00 31 00 fc 05 70 75 74 5f 63 65 6c 6c
!h 00 01 00 02 01 00 03 00 00 02 05 00 07 00 00 02 03 00 05 00 00 02 01 00
!h 07 00 00 02 01 00 05 00 00 02 03 00 07 00 00 01 05 00 00 01 01 00 00 01
!h 07 00 00 01 03 00 00 06 15 00 f5 01 09 00 65 00 29 00 07 00
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/pifu/.opam/4.14.3/lib/breadcaml/showmem.asm"
