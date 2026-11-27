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
;;                          C64.Screen - TEXT SCREEN
;; -----------------------------------------------------------------------------
;; Direct access to the 40x25 text screen (screen codes, not PETSCII) and to the
;; color RAM, and cursor positioning via the Kernal. x = column (0..39),
;; y = row (0..24). Coordinates out of range are saturated to the nearest edge.
;; The start of the screen RAM is taken from C64_HIBASE (page).

!zone caml_C64_SCR {

;; ---- coordinates -------------------------------------------------------------
;; Out-of-range coordinates are not an error: they are saturated to the nearest
;; edge of the screen (x to 0..39, y to 0..24), so that the primitives can be
;; called directly from OCaml, without any argument check in the ML code.

!ifdef caml_AUX__caml_scr_sat {
caml_scr_sat
        ;; in:  A = low byte and X = high byte of a tagged int, Y = maximum (< 128)
        ;; out: A := Int_val saturated to 0..Y   (Y is clobbered)
        CPX # 0
        BMI @low                        ;negative
        BNE @high                       ;>= 128
        LSR                             ;A := Int_val (0..127)
        STY TMP + 7
        CMP TMP + 7
        BCC @ret
        BEQ @ret
@high   TYA
        RTS
@low    LDA # 0
@ret    RTS
}

!ifdef caml_AUX__caml_scr_xy {
caml_scr_xy
        ;; TMP+6 := x = Int_val(ACCU) saturated to 0..39
        ;; TMP+5 := y = Int_val(SP[0]) saturated to 0..24     {Y = 0}
        LDY # 1
        LDA (SP),Y
        TAX
        DEY
        LDA (SP),Y
        LDY # 24
        JSR caml_scr_sat
        STA TMP + 5
        LDX ACCU + 1
        LDA ACCU
        LDY # 39
        JSR caml_scr_sat
        STA TMP + 6
        LDY # 0
        RTS
}

!ifdef caml_AUX__caml_scr_offset {
caml_scr_offset
        ;; TMP,TMP+1 := y * 40 + x     (x, y saturated)      {Y = 0}
        JSR caml_scr_xy
        LDA TMP + 5                     ;A := y
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
        LDA TMP + 6                     ;A := x
        CLC
        ADC TMP
        STA TMP
        LDA TMP + 1
        ADC # 0
        STA TMP + 1                     ;TMP := y * 40 + x
        RTS
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
        JSR caml_scr_offset
        +caml_scr_addr_screen
        LDY # 0
        LDA (ACCU),Y
        +caml_scr_ret_int
        RTS
}

!ifdef caml_PRIM__caml_nonstd_scr_poke {
caml_nonstd_scr_poke
        JSR caml_scr_offset
        +caml_scr_addr_screen
        +caml_scr_value 1
        STA (ACCU),Y
        +caml_scr_ret_unit
        RTS
}

!ifdef caml_PRIM__caml_nonstd_scr_color_peek {
caml_nonstd_scr_color_peek
        JSR caml_scr_offset
        +caml_scr_addr_color
        LDY # 0
        LDA (ACCU),Y
        AND # $0F
        +caml_scr_ret_int
        RTS
}

!ifdef caml_PRIM__caml_nonstd_scr_color_poke {
caml_nonstd_scr_color_poke
        JSR caml_scr_offset
        +caml_scr_addr_color
        +caml_scr_value 1
        STA (ACCU),Y
        +caml_scr_ret_unit
        RTS
}

!ifdef caml_PRIM__caml_nonstd_scr_locate {
caml_nonstd_scr_locate
        ;; locate x y : Kernal PLOT, X := row, Y := column
        JSR caml_scr_xy
        LDX TMP + 5                     ;X := row
        LDY TMP + 6                     ;Y := column
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

;; ---- PETSCII <-> screen codes ------------------------------------------------
;; code_of_char c : PETSCII character -> screen code. Control codes ($00-$1F,
;; $80-$9F) give the space code ($20); $FF (pi) gives $5E.

!ifdef caml_PRIM__caml_nonstd_scr_code_of_char {
caml_nonstd_scr_code_of_char
        LDA ACCU + 1
        LSR
        LDA ACCU
        ROR                             ;A := the character (0..255)
        CMP # $20
        BCC @space
        CMP # $40
        BCC @ret
        CMP # $60
        BCC @m40
        CMP # $80
        BCC @m20
        CMP # $A0
        BCC @space
        CMP # $C0
        BCC @m40
        CMP # $FF
        BCC @m80
        LDA # $5E
        BNE @ret
@space  LDA # $20
        BNE @ret
@m20    SEC
        SBC # $20
        BCS @ret
@m80    SEC
        SBC # $80
        BCS @ret
@m40    SEC
        SBC # $40
@ret    +caml_scr_ret_int
        RTS
}

;; char_of_code n : screen code -> PETSCII character (bit 7 of n is ignored)

!ifdef caml_PRIM__caml_nonstd_scr_char_of_code {
caml_nonstd_scr_char_of_code
        LDA ACCU + 1
        LSR
        LDA ACCU
        ROR
        AND # $7F                       ;A := the code (0..127)
        CMP # $20
        BCC @p40
        CMP # $40
        BCC @ret
        CMP # $60
        BCS @p40
        CLC
        ADC # $20
        BCC @ret
@p40    CLC
        ADC # $40
@ret    +caml_scr_ret_int
        RTS
}

}       ;; !zone caml_C64_SCR
