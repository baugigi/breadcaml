;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "./ok/arr2.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/breadcaml/c64defs.asm"
caml_PRIM__caml_make_array = 1
caml_PRIM__caml_array_get_addr = 1
!source "/home/piero/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i54 caml_0059
caml_0001 +i00:+i0b:+i0c:+i0d:+i0e:+i0f:+i10:+i11:+i12 8:+i12 9:+i12 10:+i12 11
          +i12 12:+i12 13:+i12 14:+i12 15:+i12 16:+i12 17:+i12 18:+i12 19
          +i12 20:+i12 21:+i12 22:+i12 23:+i12 24:+i12 25:+i12 26:+i12 27
          +i12 28:+i12 29:+i12 30:+i12 31:+i12 32:+i12 33:+i12 34:+i12 35
          +i12 36:+i12 37:+i12 38:+i12 39:+i12 40:+i12 41:+i12 42:+i12 43
          +i12 44:+i12 45:+i12 46:+i12 47:+i12 48:+i12 49:+i12 50:+i12 51
          +i12 52:+i12 53:+i12 54:+i12 55:+i12 56:+i12 57:+i12 58:+i12 59
          +i12 60:+i12 61:+i12 62:+i12 63:+i12 64:+i12 65:+i12 66:+i12 67
          +i12 68:+i12 69:+i12 70:+i12 71:+i12 72:+i12 73:+i12 74:+i12 75
          +i12 76:+i12 77:+i12 78:+i12 79:+i12 80:+i12 81:+i12 82:+i12 83
          +i12 84:+i3e 0,85:+i5d 0:+i28 1
caml_0059 +i2b 0,caml_0001:+i6a:+i6a:+i0c:+i21:+i5e 1:+i13 1:+i8f
caml_program_end

!source "/home/piero/.opam/LTS/lib/breadcaml/runtime.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/memory.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_make_array)
	!byte <(caml_array_get_addr)
caml_externals_hi
	!byte >(caml_make_array)
	!byte >(caml_array_get_addr)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table

caml_glob_data

caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/breadcaml/showmem.asm"
