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
;;                       NUMBER FORMATTING FOR PRINTF
;; -----------------------------------------------------------------------------
;; Primitives used by CamlinternalFormat (the reduced Printf). The digits of the
;; floating point numbers are produced by the BASIC ROM (DIV10, INT, MUL10...),
;; the results are built at $0100 and turned into a string by
;; caml_string_from_0100 (in stdlib_strings.asm).

!zone caml_FORMAT {

;; fmt_hex flags n -> string
;;   flags = 0: octal, 1: hexadecimal with the letters of the (unshifted)
;;   PETSCII "a".."f", 2: with the shifted ones ("A".."F").
;;   n is treated as a 15 bit pattern (so -1 gives 7fff), no prefix, no
;;   padding, at least one digit.
!ifdef caml_PRIM__caml_nonstd_fmt_hex {
caml_nonstd_fmt_hex
@VAL    = TMP                           ;(16 bit) value still to convert
        LDY # 1
        LDA (SP),Y                      ;n, hi byte
        LSR                             ;drop the tag bit:
        STA @VAL + 1                    ; VAL := tagged(n) >> 1 = n & $7FFF
        DEY
        LDA (SP),Y
        ROR
        STA @VAL
        LDA ACCU                        ;low byte of the tagged flags
        LSR                             ;A := flags
        BNE @hex
        LDA # 3                         ;octal: 3 bits per digit
        STA @bits
        LDA # 7
        STA @mask
        BNE @conv                       ;BNE = JMP
@hex    TAX                             ;X := 1 or 2
        LDA # 4                         ;hexadecimal: 4 bits per digit
        STA @bits
        LDA # 15
        STA @mask
        LDA @lbase - 1,X                ;letters base for flags 1, 2
        STA @letter
@conv   LDX # 0                         ;X := number of digits so far
@next   LDA @VAL                        ;next digit, least significant first,
        AND @mask                       ; stored at $0120,X
        CMP # 10
        BCC @dig
        ADC @letter                     ;(C = 1): letter = $41 or $C1 + d - 10
        BNE @put                        ;BNE = JMP
@dig    ORA # $30
@put    STA $0120,X
        INX
        LDY @bits
-       LSR @VAL + 1                    ;VAL := VAL >> bits
        ROR @VAL
        DEY
        BNE -
        LDA @VAL
        ORA @VAL + 1
        BNE @next                       ;until no more digits
        LDY # 0                         ;copy the digits reversed to $0100
-       DEX
        LDA $0120,X
        STA $0100,Y
        INY
        TXA
        BNE -
        STA $0100,Y                     ;final 0 (A = 0)
        JMP caml_string_from_0100
@lbase  !byte $41 - 11, $C1 - 11        ;value to add with C = 1
@bits   !byte 0
@mask   !byte 0
@letter !byte 0
}

;; fmt_float prec x -> string
;;   x with prec decimal digits and no exponent, like printf "%.<prec>f";
;;   0 <= prec <= 9 (prec is not checked). The number x*10^prec, rounded to an
;;   integer, must be less than 2^32: the digits are got with DIV10 and INT,
;;   exactly. If not (and for inf and nan) the result is the empty string.
!ifdef caml_PRIM__caml_nonstd_fmt_float {
caml_nonstd_fmt_float
        LDA ACCU
        LSR
        STA @p                          ;prec
        LDY # 0
        LDA (SP),Y
        STA caml_float_loadFAC__addr
        INY
        LDA (SP),Y
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC          ;FAC := x, .A = flag byte
        BEQ @normal
@empty  LDA # 0                         ;inf, nan or too big: empty string
        STA $0100
        JMP caml_string_from_0100
@normal LDA C64_FACSGN
        AND # $80
        STA @neg                        ;$80 if x < 0
        LDA # 0
        STA C64_FACSGN                  ;FAC := |x|
        LDA @p
        STA @cnt
@scale  BEQ @round                      ;FAC := |x| * 10^prec; the test of
        LDA C64_FACEXP                  ; the size avoids the BASIC overflow
        CMP # $A1
        BCS @empty                      ;|x| * 10^k >= 2^32
        +caml_JSR_BASROM C64_MUL10
        DEC @cnt
        JMP @scale
@round  +caml_JSR_BASROM C64_FADDH      ;FAC := INT(FAC + 0.5)
        +caml_JSR_BASROM C64_INT
        LDA C64_FACEXP
        CMP # $A1
        BCS @empty
        LDX # 0                         ;X := number of digits so far
        STX @n
        TAY
        BEQ @pad                        ;FAC = 0: no digits (padded below)
@digit  LDX # <@x                       ;x := FAC
        LDY # >@x
        +caml_JSR_BASROM C64_MOVMF
        +caml_JSR_BASROM C64_DIV10      ;q := INT(x / 10)
        +caml_JSR_BASROM C64_INT
        LDX # <@q
        LDY # >@q
        +caml_JSR_BASROM C64_MOVMF
        +caml_JSR_BASROM C64_MUL10      ;FAC := x - 10 * q = last digit
        LDA # <@x
        LDY # >@x
        +caml_JSR_BASROM C64_FSUB
        +caml_JSR_BASROM C64_FACINX     ;.Y := digit
        TYA
        ORA # $30
        LDX @n
        STA $0120,X                     ;digits are stored reversed
        INX
        STX @n
        LDA # <@q                       ;FAC := q
        LDY # >@q
        +caml_JSR_BASROM C64_MOVFM
        LDA C64_FACEXP
        BNE @digit                      ;until q = 0
        LDX @n
@pad    LDA @p                          ;at least prec + 1 digits, so that
        CLC                             ; there is an integer digit: "0.05"
        ADC # 1
        STA @cnt
        LDA # $30
-       CPX @cnt
        BCS @out
        STA $0120,X
        INX
        BNE -                           ;BNE = JMP
@out    LDY # 0                         ;compose the string at $0100
        LDA @neg
        BPL @nosign
        LDA # $2D                       ;'-'
        STA $0100,Y
        INY
@nosign DEX                             ;next digit, most significant first
        LDA $0120,X
        STA $0100,Y
        INY
        CPX @p                          ;just put the units digit?
        BNE @nodot
        LDA @p
        BEQ @nodot                      ;prec = 0: no decimal point
        LDA # $2E                       ;'.'
        STA $0100,Y
        INY
@nodot  TXA
        BNE @nosign
        STA $0100,Y                     ;final 0 (A = 0)
        JMP caml_string_from_0100
@p      !byte 0
@neg    !byte 0
@cnt    !byte 0
@n      !byte 0
@x      !fill 5
@q      !fill 5
}

} ;!zone caml_FORMAT
