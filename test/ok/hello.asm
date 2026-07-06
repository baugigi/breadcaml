;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "./ok/hello.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/breadcaml/c64defs.asm"
caml_PRIM__caml_nonstd_print_char = 1
caml_PRIM__caml_fresh_oo_id = 1
caml_PRIM__caml_nonstd_print_string = 1
!source "/home/piero/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i54 caml_0004
caml_0001 +i67 13:+i5d 0:+i28 1
caml_0004 +i63:+i5d 1:+i2b 0,caml_0001:+i39 13:+i35 12:+i5d 2:+i63:+i36 13:+i21
          +i35 14:+i5d 2:+i63:+i36 13:+i21:+i35 15:+i5d 2:+i63:+i36 13:+i21
          +i35 16:+i5d 2:+i63:+i36 13:+i21:+i35 17:+i5d 2:+i63:+i36 13:+i21
          +i35 18:+i5d 2:+i63:+i36 13:+i21:+i35 19:+i5d 2:+i63:+i36 13:+i21
          +i35 20:+i5d 2:+i63:+i36 13:+i21:+i35 21:+i5d 2:+i63:+i36 13:+i21
          +i35 22:+i5d 2:+i63:+i36 13:+i21:+i35 23:+i5d 2:+i63:+i36 13:+i21
          +i35 24:+i5d 2:+i63:+i36 13:+i21:+i35 25:+i5d 2:+i63:+i36 13:+i21
          +i35 26:+i5d 2:+i63:+i36 13:+i21:+i8f
caml_program_end

!source "/home/piero/.opam/LTS/lib/breadcaml/runtime.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/memory.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_print_char)
	!byte <(caml_fresh_oo_id)
	!byte <(caml_nonstd_print_string)
caml_externals_hi
	!byte >(caml_nonstd_print_char)
	!byte >(caml_fresh_oo_id)
	!byte >(caml_nonstd_print_string)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
+p $0002:!h 01 00:+p $0028:+p $004e:+p $0074:+p $009a:+p $00c0:+p $00e6
+p $010c:+p $0132:+p $0158:+p $017e:+p $01a4:+p $01ca:+p $01f0
caml_glob_data
!h fc 12 20 20 2d 30 2d 31 2d 32 2d 33 2d 34 2d 35 2d 36 2d 37 2d 38 2d 39
!h 2d 41 2d 42 2d 43 2d 44 2d 45 2d 46 2d 00 fc 12 20 20 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 2d 2d 2d 2d 2d 2d 2d 2d 2d 2d 2d 2d 2d 2d 2d 2d 2d 2d 2d 2d 2d
!h 2d 2d 2d 00 fc 12 32 3a 20 20 20 21 20 22 20 23 20 24 20 25 20 26 20 27
!h 20 28 20 29 20 2a 20 2b 20 2c 20 2d 20 2e 20 2f 00 01 fc 12 33 3a 20 30
!h 20 31 20 32 20 33 20 34 20 35 20 36 20 37 20 38 20 39 20 3a 20 3b 20 3c
!h 20 3d 20 3e 20 3f 00 01 fc 12 34 3a 20 40 20 41 20 42 20 43 20 44 20 45
!h 20 46 20 47 20 48 20 49 20 4a 20 4b 20 4c 20 4d 20 4e 20 4f 00 01 fc 12
!h 35 3a 20 50 20 51 20 52 20 53 20 54 20 55 20 56 20 57 20 58 20 59 20 5a
!h 20 5b 20 5c 20 5d 20 5e 20 5f 00 01 fc 12 36 3a 20 60 20 61 20 62 20 63
!h 20 64 20 65 20 66 20 67 20 68 20 69 20 6a 20 6b 20 6c 20 6d 20 6e 20 6f
!h 00 01 fc 12 37 3a 20 70 20 71 20 72 20 73 20 74 20 75 20 76 20 77 20 78
!h 20 79 20 7a 20 7b 20 7c 20 7d 20 7e 20 7f 00 01 fc 12 41 3a 20 a0 20 a1
!h 20 a2 20 a3 20 a4 20 a5 20 a6 20 a7 20 a8 20 a9 20 aa 20 ab 20 ac 20 ad
!h 20 ae 20 af 00 01 fc 12 42 3a 20 b0 20 b1 20 b2 20 b3 20 b4 20 b5 20 b6
!h 20 b7 20 b8 20 b9 20 ba 20 bb 20 bc 20 bd 20 be 20 bf 00 01 fc 12 43 3a
!h 20 c0 20 c1 20 c2 20 c3 20 c4 20 c5 20 c6 20 c7 20 c8 20 c9 20 ca 20 cb
!h 20 cc 20 cd 20 ce 20 cf 00 01 fc 12 44 3a 20 d0 20 d1 20 d2 20 d3 20 d4
!h 20 d5 20 d6 20 d7 20 d8 20 d9 20 da 20 db 20 dc 20 dd 20 de 20 df 00 01
!h fc 12 45 3a 20 e0 20 e1 20 e2 20 e3 20 e4 20 e5 20 e6 20 e7 20 e8 20 e9
!h 20 ea 20 eb 20 ec 20 ed 20 ee 20 ef 00 01 fc 12 46 3a 20 f0 20 f1 20 f2
!h 20 f3 20 f4 20 f5 20 f6 20 f7 20 f8 20 f9 20 fa 20 fb 20 fc 20 fd 20 fe
!h 20 ff 00 01
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/breadcaml/showmem.asm"
