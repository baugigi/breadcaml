;; ——————————————————————————————————————————————————————————————————————
;; The BreadCaml Project / Progetto BreadCaml
;; Copyright (C) 21-Apr-2026 Piero Furiesi
;; 
;; This program is  free software; you can redistribute  it and/or modify
;; it under the terms of the  GNU GENERAL PUBLIC LICENSE (GPL) version 2,
;; as specified in the LICENSE-en file in the project root folder.
;; 
;; Questo  programma  è software  libero;  può  essere ridistribuito  e/o
;; modificato nei termini della GNU GENERAL PUBLIC LICENSE (GPL) versione
;; 2, come specificato nel file  LICENZA-it nella cartella principale del
;; progetto.
;; ——————————————————————————————————————————————————————————————————————

;; -----------------------------------------------------------------------------
;;                                    SYS
;; -----------------------------------------------------------------------------

!ifdef caml_PRIM__caml_nonstd_mem_peek {
caml_nonstd_mem_peek
        ;; Sys.mem_peek lo hi returns the content of memory location at address
        ;; 256*hi+lo as an integer; lo, hi are taken modulo 256.
        INY
        LDA (SP),Y
        LSR
        DEY
        LDA (SP),Y
        ROR
        ROR ACCU + 1
        STA ACCU + 1
        ROR ACCU
        LDA (ACCU),Y
        ROL
        STA ACCU
        STY ACCU + 1
        ROL ACCU + 1
        RTS
}

!ifdef caml_PRIM__caml_nonstd_sys_argv {
caml_nonstd_sys_argv
        ;; Sys.argv (via Sys.get_argv: unit -> string array).
        ;; Returns an array whose element 0 is executable_name and whose
        ;; other elements are the program arguments, taken from the BASIC input
        ;; buffer (C64_BUF), where the direct-mode line that started the program
        ;; is still stored in tokenized form.  Syntax accepted:
        ;;      RUN:REM arg1, "arg 2", arg3
        ;; The line must be exactly RUN, ':', REM (tokens; spaces allowed
        ;; between them) followed by the arguments.  Arguments are separated by commas;
        ;; unquoted ones are trimmed of leading and trailing spaces; a quoted
        ;; one is taken verbatim, without the quotes.  Otherwise: no arguments.
        ;; The buffer is overwritten by float conversions (stdlib_floats.asm),
        ;; so this primitive must be called early (Sys.argv is evaluated when
        ;; module Sys is initialised).
@POS    = TMP                           ;buffer offset of next arg, $FF = none
@STA    = TMP + 1                       ;buffer offset of current arg
@LEN    = TMP + 2                       ;length of current arg
@CNT    = TMP + 3                       ;arg counter / copy limit
@IDX    = TMP + 4                       ;byte offset of next array field
        ;; pass 1: count the arguments
        JSR @init
        LDA # 0
        STA @CNT
-       JSR @next
        BCS +
        INC @CNT
        BNE -                           ;(always)
+       LDX @CNT
        INX                             ;array size = args + 1
        LDY # 0
        TYA                             ;tag 0
        JSR caml_alloc                  ;BLK = new array
        TXA
        ASL
        TAY                             ;Y := byte size
-       LDA # 0                         ;initialise fields with Val_unit
        DEY
        STA (BLK),Y
        LDA # < Val_unit
        DEY
        STA (BLK),Y
        BNE -
        JSR caml_load_newblk            ;ACCU := array (a GC root)
        LDA # < caml_exec_name + 2      ;array[0] := executable_name
        STA (ACCU),Y                    ;(static block: not in the heap)
        INY
        LDA # > caml_exec_name + 2
        STA (ACCU),Y
        INY
        STY @IDX
        ;; pass 2: allocate and fill the strings
        JSR @init
@loop   JSR @next
        BCS @done
        LDA @LEN
        LSR
        TAX
        INX                             ;X := size in words
        LDA # String_tag
        JSR caml_alloc                  ;ACCU = array: updated by a GC
        LDY @IDX
        LDA BLK
        STA (ACCU),Y                    ;array[i] := new string
        INY
        LDA BLK + 1
        STA (ACCU),Y
        INY
        STY @IDX
        LDY # 0
-       CPY @LEN                        ;copy the characters
        BEQ +
        TYA
        CLC
        ADC @STA
        TAX
        LDA C64_BUF,X
        STA (BLK),Y
        INY
        BNE -                           ;(always)
+       LDA # 0                         ;padding
        STA (BLK),Y
        TYA
        LSR
        BCS @loop                       ;odd length: "\000"
        INY
        LDA # 1                         ;even length: "\000\001"
        STA (BLK),Y
        BNE @loop                       ;(always)
@done   LDY # 0
        RTS
        ;; -- parse the beginning of the line; set @POS
@init   LDX # 0
        JSR @skipsp
        LDA C64_BUF,X
        CMP # $8A                       ;RUN token
        BNE @none
        INX
        JSR @skipsp
        LDA C64_BUF,X
        CMP # ':'
        BNE @none
        INX
        JSR @skipsp
        LDA C64_BUF,X
        CMP # $8F                       ;REM token
        BNE @none
        INX
        JSR @skipsp
        LDA C64_BUF,X
        BEQ @none                       ;nothing after 'REM'
        STX @POS
        RTS
@none   LDA # $FF
        STA @POS
        RTS
        ;; -- X := X + number of spaces at C64_BUF,X
@skipsp LDA C64_BUF,X
        CMP # ' '
        BNE +
        INX
        BNE @skipsp
+       RTS
        ;; -- X := offset of the first ',' or 0 at C64_BUF,X or following
@tail   LDA C64_BUF,X
        BEQ +
        CMP # ','
        BEQ +
        INX
        BNE @tail
+       RTS
        ;; -- next argument: C = 1 if none, else C = 0, @STA, @LEN set
@next   LDX @POS
        INX
        BEQ @eof
        DEX
        JSR @skipsp
        LDA C64_BUF,X
        CMP # '"'
        BEQ @quote
        STX @STA
        JSR @tail
        TXA
        TAY                             ;Y := end of text
-       CPX @STA                        ;remove trailing spaces
        BEQ +
        LDA C64_BUF - 1,X
        CMP # ' '
        BNE +
        DEX
        BNE -                           ;(always)
+       TXA
        SEC
        SBC @STA
        STA @LEN
        TYA
        TAX
        BNE @tend                       ;(always unless offset 0)
@quote  INX
        STX @STA
-       LDA C64_BUF,X                   ;find the closing quote
        BEQ +
        CMP # '"'
        BEQ +
        INX
        BNE -
+       TXA
        SEC
        SBC @STA
        STA @LEN
        JSR @tail                       ;skip to the next ',' or the end
@tend   LDA C64_BUF,X
        BEQ @last
        INX
        STX @POS                        ;next argument starts after the ','
        CLC
        RTS
@last   LDA # $FF
        STA @POS
        CLC
        RTS
@eof    SEC
        RTS
}

!ifdef caml_PRIM__caml_nonstd_get_exec_name {
caml_nonstd_get_exec_name
        ;; Sys.get_exec_name: ACCU := static string "output file name",
        ;; emitted by bcamlc (Export.export_exec_name).
        LDA # < caml_exec_name + 2
        STA ACCU
        LDA # > caml_exec_name + 2
        STA ACCU + 1
        RTS
}
