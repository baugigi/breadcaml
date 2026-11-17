;; ——————————————————————————————————————————————————————————————————————
;; Progetto BreadCaml / The BreadCaml Project
;; Copyright (C) 21-Apr-2026 Piero Furiesi
;; 
;; Questo  programma  è software  libero;  può  essere ridistribuito  e/o
;; modificato nei termini della GNU GENERAL PUBLIC LICENSE (GPL) versione
;; 2, come specificato nel file  LICENZA-it nella cartella principale del
;; progetto.
;; 
;; This program is  free software; you can redistribute  it and/or modify
;; it under the terms of the  GNU GENERAL PUBLIC LICENSE (GPL) version 2,
;; as specified in the LICENSE-en file in the project root folder.
;; ——————————————————————————————————————————————————————————————————————
;; -----------------------------------------------------------------------------
;;                          C64.Screen - TEXT SCREEN
;; -----------------------------------------------------------------------------
;; Direct access to the 40x25 text screen (screen codes, not PETSCII) and to the
;; color RAM, and cursor positioning via the Kernal. x = column (0..39),
;; y = row (0..24); arguments are NOT checked here (the ML wrappers do it).
;; The start of the screen RAM is taken from C64_HIBASE (page).

!zone caml_C64_SCR {

;; TMP,TMP+1 := y * 40 + x      (x = Int_val(ACCU), y = Int_val(SP[0]), both < 128)
!macro caml_scr_offset {
        LDY # 0
        LDA (SP),Y
        LSR                             ;A := y   (low byte of Int_val is enough)
        STA TMP
        STY TMP + 1
        ASL TMP
        ROL TMP + 1
        ASL TMP
        ROL TMP + 1
        ASL TMP
        ROL TMP + 1                     ;TMP := y * 8
        LDA TMP
        STA TMP + 2
        LDA TMP + 1
        STA TMP + 3
        ASL TMP
        ROL TMP + 1
        ASL TMP
        ROL TMP + 1                     ;TMP := y * 32
        LDA TMP
        CLC
        ADC TMP + 2
        STA TMP
        LDA TMP + 1
        ADC TMP + 3
        STA TMP + 1                     ;TMP := y * 40
        LDA ACCU
        LSR                             ;A := x
        CLC
        ADC TMP
        STA TMP
        LDA TMP + 1
        ADC # 0
        STA TMP + 1                     ;TMP := y * 40 + x
}
;; ACCU := screen RAM / color RAM start + TMP
!macro caml_scr_addr_screen {
        LDA TMP
        STA ACCU
        LDA TMP + 1
        CLC
        ADC C64_HIBASE
        STA ACCU + 1
}
!macro caml_scr_addr_color {
        LDA TMP
        STA ACCU
        LDA TMP + 1
        CLC
        ADC # >C64_COLRAM
        STA ACCU + 1
}
;; A := low 8 bits of Int_val(SP[.n])   {Y = 0}
!macro caml_scr_value .n {
        LDY # .n * 2 + 1
        LDA (SP),Y
        LSR
        DEY
        LDA (SP),Y
        ROR
        LDY # 0
}
!macro caml_scr_ret_int {               ;ACCU := Val_int(A)   {Y = 0}
        STY ACCU + 1
        SEC
        ROL
        STA ACCU
        ROL ACCU + 1
}
!macro caml_scr_ret_unit {              ;{Y = 0}
        LDX # <Val_unit
        STX ACCU
        STY ACCU + 1
}

!ifdef caml_PRIM__caml_nonstd_scr_peek {
caml_nonstd_scr_peek
        +caml_scr_offset
        +caml_scr_addr_screen
        LDY # 0
        LDA (ACCU),Y
        +caml_scr_ret_int
        RTS
}

!ifdef caml_PRIM__caml_nonstd_scr_poke {
caml_nonstd_scr_poke
        +caml_scr_offset
        +caml_scr_addr_screen
        +caml_scr_value 1
        STA (ACCU),Y
        +caml_scr_ret_unit
        RTS
}

!ifdef caml_PRIM__caml_nonstd_scr_color_peek {
caml_nonstd_scr_color_peek
        +caml_scr_offset
        +caml_scr_addr_color
        LDY # 0
        LDA (ACCU),Y
        AND # $0F
        +caml_scr_ret_int
        RTS
}

!ifdef caml_PRIM__caml_nonstd_scr_color_poke {
caml_nonstd_scr_color_poke
        +caml_scr_offset
        +caml_scr_addr_color
        +caml_scr_value 1
        STA (ACCU),Y
        +caml_scr_ret_unit
        RTS
}

!ifdef caml_PRIM__caml_nonstd_scr_locate {
caml_nonstd_scr_locate
        ;; locate x y : Kernal PLOT, X := row, Y := column
        LDA ACCU
        LSR
        STA TMP                         ;TMP := column
        LDY # 0
        LDA (SP),Y
        LSR
        TAX                             ;X := row
        LDY TMP                         ;Y := column
        CLC                             ;carry clear = set cursor position
        JSR C64_PLOT
        LDY # 0
        +caml_scr_ret_unit
        RTS
}

!ifdef caml_PRIM__caml_nonstd_scr_cursor {
caml_nonstd_scr_cursor
        ;; cursor_pos () = 256 * row + column
        SEC                             ;carry set = read cursor position
        JSR C64_PLOT                    ;X := row, Y := column
        TYA
        SEC
        ROL
        STA ACCU
        TXA
        ROL
        STA ACCU + 1                    ;ACCU := Val_int(256 * row + column)
        LDY # 0
        RTS
}

}       ;; !zone caml_C64_SCR
