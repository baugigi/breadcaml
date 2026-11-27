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
;;                                   FLOATS
;; -----------------------------------------------------------------------------

;; ZP locations used by the C64's BASIC ROM float routines and by Breadcaml:

;; Breadcaml Address BASIC float routines
;; --------- ------- ----------------------------------------------------------
;; XARGS     $02      <UNUSED>
;; <UNUSED>  $12     used by tan and, preparing tan, by sin/cos routines
;; <UNUSED>  $22-$23 used to move variables into FAC/ARG and back to memory
;; <UNUSED>  $24-$25 used during FP comparisons and PETSCII to FP conversion
;; <UNUSED>  $26-$2A result of multiplication or division
;; ENV       $2B-$2C  <UNUSED>
;; TRAPSP    $2D-$2E  <UNUSED>
;; Interpr.  $2F-$3D  <UNUSED>
;; GC        $3E-$45  <UNUSED>
;; <UNUSED>  $47     used by FOUT
;; HEAP      $49-$4A  <UNUSED>
;; BLK       $4B-$4C  <UNUSED>
;; TMP+0,8   $4D-$55  <UNUSED>
;; TMP+9     $56     used in addition, subtraction, and by the exp function
;; TMP+10,14 $57-$5B  <UNUSED>
;; TMP+15,19 $5C-$60 used by the PETSCII conversion routines
;; TMP+20    $61     FAC exponent
;; TMP+21,24 $62-$65 FAC mantissa
;; TMP+25    $66     FAC sign in bit 7
;; TMP+26    $67     used by trig, exp, log, and PETSCII to FP conversion
;; TMP+27    $68     used during normalisation and FP to integer conversion
;; TMP+28    $69     ARG exponent
;; TMP+29,32 $6A-$6D ARG mantissa
;; TMP+33    $6E     ARG sign in bit 7
;; TMP+34    $6F     sign result of arithm. operations, set when ARG is loaded
;; TMP+35    $70     FAC low order rounding byte, cleared when FAC is loaded
;; TMP+36,37 $71-$72 used for series eval and PETSCII to FP conversion
;; ACCU      $FB-$FC  <UNUSED>
;; SP        $FD-$FE  <UNUSED>


!zone caml_FLOATS {

.dummy = $1234                          ;dummy operand for self-modifying code
                                        ;(SMC in comments)

;; SPECIAL VALUES (see loader.asm for the encoding of the flag byte, Fl_*):
;; byte 5 of a float block is 0 for finite numbers, $01 for +infinity, $FF for
;; -infinity and $80 for nan. caml_float_unop and caml_float_binop load the
;; operand(s) into FAC (and ARG) and return C=1 if at least one operand is
;; special (the primitive then jumps to caml_float_special1/2), C=0 if all
;; operands are finite (the primitive goes on with the BASIC ROM routine).

;; Float templates (offsets in caml_float_ret_tpl__tab), 6 bytes each:
Ft_ZERO = 0                             ;0.0
Ft_ONE  = 6                             ;1.0
Ft_M1   = 12                            ;-1.0
Ft_PIH  = 18                            ;pi/2
Ft_NPIH = 24                            ;-pi/2
Ft_PINF = 30                            ;+infinity
Ft_NINF = 36                            ;-infinity
Ft_NAN  = 42                            ;nan

;; Unary operations: index * 3 in the table caml_float_special1__tab
Fu_NEG   = 0
Fu_ABS   = 3
Fu_EXP   = 6
Fu_EXPM1 = 9
Fu_LOG   = 12                           ;log, log1p, log10, sqrt
Fu_TRIG  = 15                           ;sin, cos, tan
Fu_ATAN  = 18
Fu_FLOOR = 21                           ;floor, ceil

;; Binary operations: index in caml_float_special2
Fb_ADD = 0
Fb_SUB = 1
Fb_MUL = 2
Fb_DIV = 3
Fb_POW = 4

;; Operations which may overflow (stored in caml_float_overflow__op, see there)
Fo_NONE = $FF                           ;unknown: overflow raises Sys_error
;; Contract: a primitive that calls a ROM routine which may overflow must set
;; caml_float_overflow__op (and caml_float_overflow__sp, which caml_float_unop/
;; binop do) before the call. caml_float_overflow__op is reset to Fo_NONE only
;; after an overflow has been handled, so a primitive that does not follow the
;; contract after a successful float operation may find a stale value.
Fo_ADD  = 0                             ;(add and sub: same sign rule)
Fo_MUL  = 1                             ;(mul and div: same sign rule)
Fo_POW  = 2
Fo_EXP  = 3                             ;(exp, expm1)
Fo_STR  = 4                             ;float_of_string

!ifdef caml_PRIM__caml_nonstd_sign_float {
caml_nonstd_sign_float
        ;; Stdlib.sign_float: -1, 0, 1 (nan gives 0)
        LDY # Float_flag
        LDA (ACCU),Y
        BEQ @fin
        CMP # Fl_pinf
        BEQ @pos
        CMP # Fl_ninf
        BEQ @neg
        BNE @zero                       ;nan: BNE=JMP
@fin    LDY # 0
        LDA (ACCU),Y                    ;Read byte #0 (exponent)
        BEQ @zero                       ;Exponent=0 <=> float=0.
        INY
        LDA (ACCU),Y                    ;Read byte #1 (mantissa, msb)
        BPL @pos                        ;If the mantissa is negative,
@neg    LDA # $FF                       ; set ACCU=Val_Int(-1)
        STA ACCU
        STA ACCU + 1
        LDY # 0
        RTS
@pos    LDA # Val_one                   ;else set ACCU=Val_Int(1)
        BNE @store                      ; BNE=JMP.
@zero   LDA # Val_zero                  ;Zero: set ACCU=Val_Int(0).
@store  STA ACCU
        LDY # 0
        STY ACCU + 1
        RTS                             ;Y=0 at exit.
}

!ifdef caml_PRIM__caml_neg_float {
caml_neg_float
        JSR caml_float_unop
        BCC @fin
        LDX # Fu_NEG
        JMP caml_float_special1
@fin    +caml_JSR_BASROM C64_NEGOP
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_abs_float {
caml_abs_float
        JSR caml_float_unop
        BCC @fin
        LDX # Fu_ABS
        JMP caml_float_special1
@fin    +caml_JSR_BASROM C64_ABS
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_exp_float {
caml_exp_float
        JSR caml_float_unop
        BCC @fin
        LDX # Fu_EXP
        JMP caml_float_special1
@fin    LDX # Fo_EXP                    ;(overflow: +infinity)
        STX caml_float_overflow__op
        +caml_JSR_BASROM C64_EXP
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_expm1_float {
caml_expm1_float
        JSR caml_float_unop
        BCC @fin
        LDX # Fu_EXPM1
        JMP caml_float_special1
@fin    LDX # Fo_EXP                    ;(overflow: +infinity)
        STX caml_float_overflow__op
        +caml_JSR_BASROM C64_EXP
        LDA # <C64_M1
        LDY # >C64_M1
        +caml_JSR_BASROM C64_FADD
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_log_float {
caml_log_float
        JSR caml_float_unop
        BCC @fin
        LDX # Fu_LOG
        JMP caml_float_special1
@fin    LDX # 0                         ;log 0.0 = -infinity, log (x<0) = nan
        JSR caml_float_logdom
        +caml_JSR_BASROM C64_LOG
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_log1p_float {
caml_log1p_float
        JSR caml_float_unop
        BCC @fin
        LDX # Fu_LOG
        JMP caml_float_special1
@fin    LDA # <C64_ONE
        LDY # >C64_ONE
        +caml_JSR_BASROM C64_FADD
        LDX # 0                         ;log1p (-1.0) = -infinity, ... = nan
        JSR caml_float_logdom
        +caml_JSR_BASROM C64_LOG
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_log10_float {
.ln10m1 !h 7f 5e 5b d8 a9       ;(ln 10)^-1
caml_log10_float
        ;; log10 x = ln x / ln 10
        JSR caml_float_unop
        BCC @fin
        LDX # Fu_LOG
        JMP caml_float_special1
@fin    LDX # 0
        JSR caml_float_logdom
        +caml_JSR_BASROM C64_LOG
  !if caml_log10_float <= C64_BASROM {
        LDA # <.ln10m1
        LDY # >.ln10m1
  } else {
        LDY # 5
-       LDA .ln10m1 - 1,Y
        STA TMP - 1,Y
        DEY
        BNE -
        LDA # TMP
  }
        +caml_JSR_BASROM C64_FMUL
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_sin_float {
caml_sin_float
        JSR caml_float_unop
        BCC @fin
        LDX # Fu_TRIG
        JMP caml_float_special1
@fin    +caml_JSR_BASROM C64_SIN
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_cos_float {
caml_cos_float
        JSR caml_float_unop
        BCC @fin
        LDX # Fu_TRIG
        JMP caml_float_special1
@fin    +caml_JSR_BASROM C64_COS
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_tan_float {
caml_tan_float
        JSR caml_float_unop
        BCC @fin
        LDX # Fu_TRIG
        JMP caml_float_special1
@fin    +caml_JSR_BASROM C64_TAN
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_sqrt_float {
caml_sqrt_float
        JSR caml_float_unop
        BCC @fin
        LDX # Fu_LOG
        JMP caml_float_special1
@fin    LDX # 1                         ;sqrt (x<0) = nan
        JSR caml_float_logdom
        +caml_JSR_BASROM C64_SQR
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_atan_float {
caml_atan_float
        JSR caml_float_unop
        BCC @fin
        LDX # Fu_ATAN
        JMP caml_float_special1
@fin    +caml_JSR_BASROM C64_ATN
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_floor_float {
caml_floor_float
        JSR caml_float_unop
        BCC @fin
        LDX # Fu_FLOOR
        JMP caml_float_special1
@fin    +caml_JSR_BASROM C64_INT
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_ceil_float {
caml_ceil_float
        ;; let ceil x = -.(floor (-. x))
        JSR caml_float_unop
        BCC @fin
        LDX # Fu_FLOOR
        JMP caml_float_special1
@fin    +caml_JSR_BASROM C64_NEGOP
        +caml_JSR_BASROM C64_INT
        +caml_JSR_BASROM C64_NEGOP
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_classify_float {
caml_classify_float
        +Val_Int ~@FP_normal,    0      ;order must match variants in
        +Val_Int ~@FP_subnormal, 1      ;type Float.fpclass
        +Val_Int ~@FP_zero,      2
        +Val_Int ~@FP_infinite,  3
        +Val_Int ~@FP_nan,       4
        LDY # Float_flag
        LDA (ACCU),Y
        BNE @spec
        TAY                             ;.Y = 0
        LDA (ACCU),Y                    ;exponent
        STY ACCU + 1
        BEQ @zero
        LDA # @FP_normal
        STA ACCU
        RTS
@zero   LDA # @FP_zero
        STA ACCU
        RTS
@spec   LDX # @FP_infinite
        CMP # Fl_nan
        BNE @set
        LDX # @FP_nan
@set    STX ACCU
        LDY # 0
        STY ACCU + 1
        RTS
}

!ifdef caml_PRIM__caml_int_of_float {
caml_int_of_float
        JSR caml_float_unop
        BCC @fin
        LDX # $FF                       ;special value (.A = flag):
        LDY # $7F                       ; +inf gives the largest int,
        CMP # Fl_pinf
        BEQ @set
        LDX # $01                       ; -inf the smallest,
        LDY # $80
        CMP # Fl_ninf
        BEQ @set
        LDY # 0                         ; nan gives 0.
@set    STX ACCU
        STY ACCU + 1
        LDY # 0
        RTS
@fin    LDA C64_FAC + 5                 ;FAC sign byte
        PHA                             ;save sign
        LDA # 0
        STA C64_FAC + 5                 ;FAC := |FAC| (FACINX floors, OCaml
        +caml_JSR_BASROM C64_FACINX     ; truncates) => result in Y(lo), A(hi)
        STY ACCU
        STA ACCU + 1
        PLA
        BPL +                           ;negative argument:
        SEC                             ; negate the (truncated) magnitude
        LDA # 0
        SBC ACCU
        STA ACCU
        LDA # 0
        SBC ACCU + 1
        STA ACCU + 1
+       SEC
        ROL ACCU                        ;OCaml int repr
        ROL ACCU + 1
        LDY # 0
        RTS
}

!ifdef caml_PRIM__caml_float_of_int {
caml_float_of_int
        LDA ACCU + 1
        CMP # $80                       ;CMP + ROR = arithm. shift right
        ROR
        TAX
        ROR ACCU
        LDY ACCU
        TXA
        +caml_JSR_BASROM C64_GIVAYF
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_copysign_float {
caml_copysign_float
        ;; |ACCU| with the sign of SP[0] (the sign of nan is taken as '+')
        LDY # 0
        LDA (SP),Y
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1                     ;(TMP) = SP[0]
        LDY # Float_flag
        LDA (TMP),Y
        BNE @yspec
        LDY # 1                         ;finite: load 1st mantissa byte of
        LDA (TMP),Y                     ; SP[0] (its bit 7 is the sign)
@sign   PHA
        JSR caml_float_unop             ;ACCU --> FAC
        PLA                             ;(this and TAX do not touch C)
        TAX
        BCS @spx
        STA C64_FAC + 5                 ;copy the sign to FAC sign byte
        JMP caml_float_alloc_result
@yspec  CMP # Fl_ninf                   ;special: C=1 only if -inf
        LDA # 0
        ROR                             ;bit 7 of .A = sign of SP[0]
        JMP @sign
@spx    LDY # Float_flag                ;ACCU is special:
        LDA (ACCU),Y
        CMP # Fl_nan
        BNE @inf
        LDY # 0                         ; nan: result is ACCU itself
        RTS
@inf    LDA # Ft_PINF                   ; infinity:
        CPX # $80                       ;  C=1 if the sign is '-'
        BCC @tpl
        LDA # Ft_NINF
@tpl    JMP caml_float_ret_tpl
}

!ifdef caml_PRIM__caml_float_of_string {
caml_float_of_string
        ;; Special values first: [+|-] ("nan" | "inf" | "infinity"), any case
        LDY # 0
        STY TMP + 2                     ;sign ($FF = '-')
        LDA (ACCU),Y
        CMP # '-'
        BNE @plus
        DEC TMP + 2
        INY
        BNE @word                       ;BNE=JMP
@plus   CMP # '+'
        BNE @word
        INY
@word   STY TMP + 3
        LDX # @w_nan - @words
        JSR @try
        BEQ @isnan
        LDX # @w_inf - @words
        LDY TMP + 3
        JSR @try
        BEQ @isinf
        LDX # @w_infinity - @words
        LDY TMP + 3
        JSR @try
        BNE @num                        ;no match: it is a number
@isinf  LDA # Ft_PINF
        BIT TMP + 2
        BPL @tpl
        LDA # Ft_NINF
        BNE @tpl                        ;BNE=JMP
@isnan  LDA # Ft_NAN
@tpl    JMP caml_float_ret_tpl
@try    LDA @words,X                    ;match string at (ACCU),Y with word X
        BEQ @end                        ; (case-insensitive: PETSCII uppercase
        LDA (ACCU),Y                    ; letters are $C1-$DA, lowercase $41-$5A)
        AND # $7F
        CMP @words,X
        BNE @no                         ;mismatch: return Z=0
        INY
        INX
        BNE @try                        ;BNE=JMP
@end    LDA (ACCU),Y                    ;string must end here: return Z=1 if so
@no     RTS
@words
@w_nan      !text "nan", 0
@w_inf      !text "inf", 0
@w_infinity !text "infinity", 0
@num    TSX                             ;overflow (+-infinity): see
        STX caml_float_overflow__sp     ; caml_float_overflow
        LDA # Fo_STR
        STA caml_float_overflow__op
        LDA C64_CHRPTR                  ;Save the current CHRPTR value
        STA TMP
        LDA C64_CHRPTR + 1
        STA TMP + 1
        LDY # 0                         ;FIN skips the blanks inside a number
@lead   LDA (ACCU),Y                    ; ("1 2" would give 12): accept only
        CMP # $20                       ; leading blanks, and reject the string
        BNE @inner                      ; if a blank follows the first
        INY                             ; character.
        BNE @lead
@inner  LDA (ACCU),Y
        BEQ @spdone
        CMP # $20
        BEQ @bad
        INY
        BNE @inner
@spdone LDA ACCU + 1
        LDX ACCU
 !ifdef caml_basic_rom_overlap {
        ;; FIN reads the string with the BASIC ROM on, but the string may be in
        ;; the RAM under it ($A000-$BFFF): copy it (0-terminated, max 80 chars)
        ;; to the BASIC input buffer and convert the copy.
        CMP # > (C64_BASROM - 79)       ;If the first 80 characters of the
        BCC @setptr                     ; string are below $A000, skip the copy
        BNE @copy                       ; and set the pointer to ACCU;
        CPX # < (C64_BASROM - 79)
        BCC @setptr
@copy   LDY # 0                         ;else copy the string to the buffer
-       LDA (ACCU),Y
        STA C64_BUF,Y
        BEQ +
        INY
        CPY # 80
        BCC -
        LDA # 0
        STA C64_BUF,Y
+       LDA # >C64_BUF                  ; and set the pointer to it.
        LDX # <C64_BUF
 }
@setptr STA C64_CHRPTR + 1              ;CHRPTR := A:X
        STX C64_CHRPTR
        JSR C64_CHRGOT                  ;not a BASIC ROM routine
        +caml_JSR_BASROM C64_FIN        ;String to float conversion routine
        ;; FIN never fails: it converts the longest valid prefix (0 if none) and
        ;; leaves C64_CHRPTR at the first character it did not use. Accept only
        ;; a string that FIN consumed up to its end (0 byte)...
        LDY # 0
        LDA (C64_CHRPTR),Y
        BNE @bad                        ;trailing garbage ("12abc", "abc")
        LDA C64_FAC
        BNE @good                       ;...and, if the result is 0, only if
@dig    LDA (ACCU),Y                    ; there is a mantissa digit before the
        BEQ @bad                        ; exponent: "-", ".", "", "e5" are not
        CMP # $45                       ; numbers, "0", "-0.0", "0e5" are.
        BEQ @bad                        ;$45 = 'e'
        EOR # $30
        CMP # 10
        BCC @good                       ;a digit
        INY
        BNE @dig
@bad    LDA TMP                         ;Restore the previous value of CHRPTR
        STA C64_CHRPTR
        LDA TMP + 1
        STA C64_CHRPTR + 1
        +caml_raise Failure, "float_of_string"
@good   LDA TMP                         ;Restore the previous value of CHRPTR
        STA C64_CHRPTR
        LDA TMP + 1
        STA C64_CHRPTR + 1
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_ldexp_float {
        ;; compute ACCU * 2 ^ N, -255 < N < 255.
        ;; SP[0] = Val_int(N) (usual tagged int, two's complement if N < 0)
caml_ldexp_float
        LDY # Float_flag
        LDA (ACCU),Y
        BEQ @fin
        LDY # 0                         ;nan, +-infinity: ldexp x n = x
        RTS
@fin    LDY # 0
        LDA # Double_tag
        LDX # Double_wosize
        JSR caml_alloc                  ;{Y = 0}
        LDA # 0                         ;the flag byte of the result is 0
        LDY # Float_flag                ; (ldexp x n = x if x is nan or inf,
        STA (BLK),Y                     ;  see below)
        TAY                             ;.Y = 0
        LDA (ACCU),Y                    ;(biased) exponent of the source
        BEQ @save                       ;0.0 * 2^N = 0.0: don't add N to exp 0
        STA TMP
        INY
        LDA (SP),Y                      ;hi byte of Val_int(N)
        TAX                             ;X: bit 7 = sign of N
        LSR                             ;C := bit 0 of hi byte
        DEY
        LDA (SP),Y
        ROR                             ;A := low byte of N (two's complement)
        STA TMP + 1
        TXA
        BMI @neg                        ;N < 0 ?
        LDA TMP + 1                     ;no: exp := exp + N
        CLC
        ADC TMP
        BCC @save
        LDY # 1                         ; overflow: +-infinity,
        LDA (ACCU),Y                    ;  with the sign of the source
        BMI @ninf
        LDA # Ft_PINF
        BNE @tpl                        ;BNE=JMP
@ninf   LDA # Ft_NINF
@tpl    JMP caml_float_ret_tpl
@neg    LDA TMP + 1                     ;yes: exp := exp - |N| = exp + (256-|N|)
        CLC
        ADC TMP
        BCS @save                       ; if underflow,
        LDA # 0                         ;  set exp = 0 (result = 0.0)
@save   STA (BLK),Y                     ;save exp byte (Y = 0)
        BEQ +                           ;skip copy of mantissa if zero
        LDY # 4
-       LDA (ACCU),Y                    ;copy mantissa
        STA (BLK),Y
        DEY
        BNE -
+       JMP caml_load_newblk
}

!ifdef caml_PRIM__caml_frexp_float {
caml_frexp_float
        ;; allocate a new float with same mantissa and exp=0
        LDA # Double_tag                ;tag of new float
        LDX # Double_wosize             ;size of new float
        JSR caml_alloc                  ;alloc new float
        LDY # Float_flag
        LDA (ACCU),Y
        STA (BLK),Y                     ;copy the flag byte
        BEQ @fin
        LDY # 4                         ;nan, +-infinity: frexp x = (x, 0)
-       LDA (ACCU),Y                    ; copy the float,
        STA (BLK),Y
        DEY
        BPL -
        INY
        TYA
        PHA                             ; and set the exponent to 0
        BEQ @pair
@fin    LDY # 0
        LDA (ACCU),Y                    ;load (biased) exponent
        PHA                             ;save it for later
        BNE @nz                         ;float is 0.0?
        STA (BLK),Y                     ;yes: set new float exp = 0
        BEQ @pair                       ; and go further
@nz     LDA # $80                       ;no: set new float exp = $80
        STA (BLK),Y
        LDY # 4                         ; then copy the mantissa
-       LDA (ACCU),Y
        STA (BLK),Y
        DEY
        BNE -
@pair   JSR caml_load_newblk            ;ACCU = new float
        ;; allocate a new pair (float * int)
        LDA # 0                         ;tag of new pair
        LDX # 2                         ;size of new pair
        JSR caml_alloc                  ;alloc new pair
        ;; set pair elements
        LDA ACCU
        STA (BLK),Y
        INY
        LDA ACCU + 1
        STA (BLK),Y                     ;field0 := new float
        INY
        LDX # 0
        PLA                             ;reload biased exponent
        BNE @debias                     ;exp = 0?
        LDA # <Val_zero                 ;yes:
        STA (BLK),Y                     ; set field1,lo := <Val_int(0)
        LDA # >Val_zero
        BEQ @fld1h                      ; beq=jmp to set field1,hi
@debias SEC                             ;no:
        SBC # $80                       ; compute debiased exponent
        BCS @valint                     ; if negative,
        DEX                             ;  set hi byte = $FF
        SEC
@valint ROL                             ; compute <Val_int(exponent)
        STA (BLK),Y                     ; field1,lo := <Val_int(exponent)
        TXA
        ROL                             ; compute >Val_int(exponent)
@fld1h  INY
        STA (BLK),Y                     ;field1,hi := >Val_int(exponent)
        LDY # 0
        JMP caml_load_newblk   
}

!ifdef caml_PRIM__caml_add_float {
caml_add_float
        JSR caml_float_binop
        BCC @fin
        LDX # Fb_ADD
        JMP caml_float_special2
@fin    LDX # Fo_ADD                        ;(overflow: +-infinity)
        STX caml_float_overflow__op
        LDA C64_FAC                         ;FADDT tests .Z (FAC exp = 0?): the
        +caml_JSR_BASROM C64_FADDT          ; LDX above (Fo_ADD = 0) has set it
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_sub_float {
caml_sub_float
        JSR caml_float_binop
        BCC @fin
        LDX # Fb_SUB
        JMP caml_float_special2
@fin    LDX # Fo_ADD                        ;(overflow: +-infinity)
        STX caml_float_overflow__op
        +caml_JSR_BASROM C64_FSUBT
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_mul_float {
caml_mul_float
        JSR caml_float_binop
        BCC @fin
        LDX # Fb_MUL
        JMP caml_float_special2
@fin    LDX # Fo_MUL                        ;(overflow: +-infinity)
        STX caml_float_overflow__op
        +caml_JSR_BASROM C64_FMULT
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_div_float {
caml_div_float
        JSR caml_float_binop
        BCC @fin
        LDX # Fb_DIV
        JMP caml_float_special2
@fin    BEQ @dz                         ;FAC exponent = 0: division by zero
        LDX # Fo_MUL                    ;(overflow: +-infinity)
        STX caml_float_overflow__op
        +caml_JSR_BASROM C64_FDIVT
        JMP caml_float_alloc_result
@dz     LDA C64_ARG                     ;x / 0.0: nan if x = 0.0, else
        BEQ @nan                        ; +-infinity with the sign of x
        LDA C64_ARG + 5
        BPL @pinf
        LDA # Ft_NINF
        BNE @tpl                        ;BNE=JMP
@pinf   LDA # Ft_PINF
        BNE @tpl                        ;BNE=JMP
@nan    LDA # Ft_NAN
@tpl    JMP caml_float_ret_tpl
}

!ifdef caml_PRIM__caml_power_float {
caml_power_float
        JSR caml_float_binop
        BCC @fin
        LDX # Fb_POW
        JMP caml_float_special2
@fin    LDA C64_ARG                     ;x = 0.0 ?
        BNE @xnz
        BIT C64_FAC + 5                 ;yes: 0.0 ** (y<0) = +infinity
        BPL @rom                        ; (other cases are managed by ROM)
        LDA # Ft_PINF
        BNE @tpl                        ;BNE=JMP
@xnz    BIT C64_ARG + 5                 ;x < 0 ?
        BPL @rom
        LDY # 0                         ;yes: (x<0) ** y is nan if y is not
        LDA (SP),Y                      ; an integer (ROM raises an error)
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1                     ;(TMP) = y
        JSR caml_float_intclass
        TAX
        BNE @rom
        LDA # Ft_NAN
@tpl    JMP caml_float_ret_tpl
@rom    LDX # Fo_POW                    ;(overflow: +-infinity)
        STX caml_float_overflow__op
        LDA C64_FAC                     ;ROM wants .A = FAC exponent
        +caml_JSR_BASROM C64_FPWRT
        JMP caml_float_alloc_result
}


;; Auxiliary routines

;; copy ACCU to FAC. Return C=1 if ACCU is special, .A = flag byte
!ifdef caml_AUX__caml_float_unop {
caml_float_unop
        TSX                             ;Save the CPU stack pointer as it will
        INX                             ; be after returning to the primitive
        INX                             ; (see caml_float_overflow)
        STX caml_float_overflow__sp
        LDA # Fo_NONE
        STA caml_float_overflow__op     ;the primitive may change it
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC          ;.A = flag byte
        CMP # 1                         ;C=1 <=> flag <> 0
        RTS
}

;; copy SP[0] to FAC and ACCU to ARG. Return C=1 if one of them is special,
;; else C=0, .A = FAC exponent (and flags .Z, .N according to .A), .Y = 0
!ifdef caml_AUX__caml_float_binop {
caml_float_binop
        TSX                             ;as above
        INX
        INX
        STX caml_float_overflow__sp
        LDA # Fo_NONE
        STA caml_float_overflow__op
        LDA (SP),Y
        STA caml_float_loadFAC__addr
        INY
        LDA (SP),Y
        STA caml_float_loadFAC__addr + 1
       ;DEY                             ;caml_float_alloc_result will set Y=0
        JSR caml_float_loadFAC
        STY TMP                         ;flag byte of SP[0]
        LDA ACCU
        STA caml_float_loadARG__addr
        LDA ACCU + 1
        STA caml_float_loadARG__addr + 1
        JSR caml_float_loadARG          ;.Y = flag byte of ACCU, .A = FAC exp
        PHA
        TYA
        ORA TMP                         ;0 <=> both finite
        CMP # 1                         ;C=1 <=> at least one is special
        PLA                             ;(does not touch C)
        RTS
}

;; Copy FAC (operation result) to a new allocated float. Flag byte := 0
!ifdef caml_AUX__caml_float_alloc_result {
caml_float_alloc_result
        LDA # Double_tag
        LDX # Double_wosize
        LDY # 0
        JSR caml_alloc
        LDX BLK
        LDY BLK + 1
        +caml_JSR_BASROM C64_MOVMF
        LDY # Float_flag
        LDA # 0
        STA (BLK),Y                     ;finite
        TAY
        JMP caml_load_newblk   
}

;; FAC/ARG loading routines -- how to use: 1) write float address in
;; caml_float_loadFAC/ARG__addr; 2) JSR caml_float_loadFAC/ARG
;; FAC: return .A = .Y = flag byte of the float. ARG: return .Y = flag byte,
;; .A = FAC exponent

!ifdef caml_AUX__caml_float_loadFAC {
caml_float_loadFAC
        LDX # 5
caml_float_loadFAC__addr = * + 1
-       LDA .dummy,X                    ;SMC: replaced with real address
        STA C64_FAC,X
        DEX
        BPL -
        LDY C64_FAC + 5                 ;flag byte
        LDA C64_FAC + 1                 ;copy 1st byte of mantissa
        STA C64_FAC + 5                 ;to FAC sign byte
        ORA # $80
        STA C64_FAC + 1                 ;set 1st bit of mantissa = 1
        INX
        STX C64_FACRND                  ;FAC round byte := 0
        TYA                             ;.A = flag byte (sets .Z)
        RTS
}

!ifdef caml_AUX__caml_float_loadARG {
caml_float_loadARG
        LDX # 5
caml_float_loadARG__addr = * + 1
-       LDA .dummy,X                    ;SMC: replaced with real address
        STA C64_ARG,X
        DEX
        BPL -
        LDY C64_ARG + 5                 ;flag byte
        LDX C64_ARG + 1                 ;copy 1st byte of mantissa
        STX C64_ARG + 5                 ;to ARG sign byte
        TXA
        EOR C64_FAC + 5                 ;compare with FAC sign byte
        STA C64_ARISGN                  ;store result of comparison
        TXA
        ORA # $80
        STA C64_ARG + 1                 ;set 1st bit of mantissa = 1
        LDA C64_FAC                     ;.A := FAC exponent
        RTS
}

;; Allocate a new float, copying the template at offset .A (Ft_*) in the table
!ifdef caml_AUX__caml_float_ret_tpl {
caml_float_ret_tpl
        PHA
        LDA # Double_tag
        LDX # Double_wosize
        LDY # 0
        JSR caml_alloc
        PLA
        TAX
        LDY # 0
-       LDA caml_float_ret_tpl__tab,X
        STA (BLK),Y
        INX
        INY
        CPY # 6
        BNE -
        LDY # 0
        JMP caml_load_newblk
caml_float_ret_tpl__tab
        !byte $00, $00, $00, $00, $00, $00      ;Ft_ZERO  0.0
        !byte $81, $00, $00, $00, $00, $00      ;Ft_ONE   1.0
        !byte $81, $80, $00, $00, $00, $00      ;Ft_M1   -1.0
        !byte $81, $49, $0F, $DA, $A2, $00      ;Ft_PIH   pi/2
        !byte $81, $C9, $0F, $DA, $A2, $00      ;Ft_NPIH -pi/2
        !byte $FF, $7F, $FF, $FF, $FF, Fl_pinf  ;Ft_PINF +infinity
        !byte $FF, $FF, $FF, $FF, $FF, Fl_ninf  ;Ft_NINF -infinity
        !byte $00, $00, $00, $00, $00, Fl_nan   ;Ft_NAN  nan
}

;; Unary operation on a special float: .X = Fu_* (operation * 3), ACCU = float
;; Result: template of the class (+inf, -inf, nan) of the operand
!ifdef caml_AUX__caml_float_special1 {
caml_float_special1
        LDY # Float_flag
        LDA (ACCU),Y
        LDY # 0
        CMP # Fl_pinf
        BEQ @cls
        INY
        CMP # Fl_ninf
        BEQ @cls
        INY
@cls    STY TMP
        TXA
        CLC
        ADC TMP
        TAX
        LDA caml_float_special1__tab,X
        JMP caml_float_ret_tpl
caml_float_special1__tab                        ;+inf    -inf    nan
        !byte Ft_NINF, Ft_PINF, Ft_NAN          ;neg
        !byte Ft_PINF, Ft_PINF, Ft_NAN          ;abs
        !byte Ft_PINF, Ft_ZERO, Ft_NAN          ;exp
        !byte Ft_PINF, Ft_M1,   Ft_NAN          ;expm1
        !byte Ft_PINF, Ft_NAN,  Ft_NAN          ;log, log1p, log10, sqrt
        !byte Ft_NAN,  Ft_NAN,  Ft_NAN          ;sin, cos, tan
        !byte Ft_PIH,  Ft_NPIH, Ft_NAN          ;atan
        !byte Ft_PINF, Ft_NINF, Ft_NAN          ;floor, ceil
}

;; Binary operation, at least one operand being special: .X = Fb_*,
;; ACCU = x, SP[0] = y. Allocates the result (IEEE 754 rules).
;; TMP,TMP+1 = pointer to y; TMP+2 = flag of x; TMP+3 = flag of y
!ifdef caml_AUX__caml_float_special2 {
caml_float_special2
        LDY # 0
        LDA (SP),Y
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1
        LDY # Float_flag
        LDA (TMP),Y
        STA TMP + 3
        LDA (ACCU),Y
        STA TMP + 2
        CPX # Fb_MUL
        BCS @n2
        CPX # Fb_SUB
        BNE @add
        LDA # 0                         ;x - y = x + (-y)
        SEC
        SBC TMP + 3                     ;(negates the flag: swaps +-inf,
        STA TMP + 3                     ; keeps 0 and nan)
@add    LDA TMP + 2                     ;fx = 0 (finite): result = fy
        BEQ @rfy
        LDA TMP + 3
        BEQ @rfx                        ;fy = 0: result = fx
        CMP TMP + 2
        BEQ @rfx                        ;fx = fy: result = fx (inf+inf, nan)
        LDA # Fl_nan                    ;else (inf-inf, inf+nan, ...): nan
        BNE @emit                       ;BNE=JMP
@rfx    LDA TMP + 2
        BNE @emit                       ;BNE=JMP
@rfy    LDA TMP + 3
@emit   LDX # Ft_PINF                   ;.A = flag: emit +inf, -inf or nan
        CMP # Fl_pinf
        BEQ @tpl
        LDX # Ft_NINF
        CMP # Fl_ninf
        BEQ @tpl
        LDX # Ft_NAN
@tpl    TXA
        JMP caml_float_ret_tpl
@n2     CPX # Fb_POW                    ;MUL, DIV, POW:
        BEQ @pow                        ;(pow: x^0=1 and 1^y=1 even if nan)
        LDA TMP + 2
        CMP # Fl_nan
        BEQ @nan
        LDA TMP + 3
        CMP # Fl_nan
        BEQ @nan
        CPX # Fb_DIV
        BEQ @div
        ;; ---- multiplication: infinity unless inf * 0
        LDA TMP + 2
        BEQ @mfx                        ;x finite, y infinite
        LDX TMP + 3
        BEQ @mfy                        ;y finite, x infinite
        EOR TMP + 3                     ;both infinite: sign = fx xor fy
        BPL @pinf
        BMI @ninf
@mfx    LDY # 0
        LDA (ACCU),Y                    ;x = 0.0 ?
        BEQ @nan
        INY
        LDA (ACCU),Y                    ;sign of x
        EOR TMP + 3
        BPL @pinf
        BMI @ninf
@mfy    LDY # 0
        LDA (TMP),Y                     ;y = 0.0 ?
        BEQ @nan
        INY
        LDA (TMP),Y                     ;sign of y
        EOR TMP + 2
        BPL @pinf
        BMI @ninf

        ;; ---- division
@div    LDA TMP + 2
        BNE @dx
        LDA # Ft_ZERO                   ;finite / infinite = 0.0
        BEQ @tpl2                       ;BEQ=JMP
@dx     LDX TMP + 3
        BNE @nan    ;inf / inf = nan
        LDY # 0
        LDA (TMP),Y                     ;inf / y: if y = 0.0 sign is the sign
        BEQ @dsg                        ; of x, else sign(x) xor sign(y)
        INY
        LDA (TMP),Y
        EOR TMP + 2
        BPL @pinf
        BMI @ninf
@dsg    LDA TMP + 2                     ;(flag $01 or $FF)
        BPL @pinf
       ;BMI @ninf
@ninf   LDA # Ft_NINF
        BNE @tpl2
@nan    LDA # Ft_NAN
        BNE @tpl2
@pinf   LDA # Ft_PINF
@tpl2   JMP caml_float_ret_tpl

        ;; ---- x ^ y
@pow    LDA TMP + 3
        BNE @p2
        LDY # 0                         ;y finite (so x is special):
        LDA (TMP),Y                     ; x ^ 0.0 = 1.0
        BEQ @one
@p2     LDA TMP + 2
        BEQ @xfin
        LDA # 1                         ;x infinite: |x| > 1
        BNE @m
@xfin   JSR @cmp1                       ;compare |x| with 1: $FF, 0, 1
        BNE @m
        LDY # 1                         ;|x| = 1: if x = +1.0 result is 1.0
        LDA (ACCU),Y                    ; for every y (even nan)
        BPL @one
        LDA # 0
@m      STA TMP + 4                     ;TMP+4 = -1, 0, 1 for |x| <, =, > 1
        LDA TMP + 2
        CMP # Fl_nan
        BEQ @nan
        LDA TMP + 3
        CMP # Fl_nan
        BEQ @nan
        LDA TMP + 3
        BEQ @yfin
        LDA TMP + 4                     ;y = +-infinity
        BEQ @one                        ; |x| = 1: 1.0
        EOR TMP + 3                     ; same sign (|x|>1 and y=+inf, or
        BPL @pinf   ;  |x|<1 and y=-inf): +inf, else 0.0
@zero   LDA # Ft_ZERO
        BEQ @tpl2                       ;BEQ=JMP
@one    LDA # Ft_ONE
        BNE @tpl2                       ;BNE=JMP
@yfin   LDY # 1                         ;y finite, x infinite:
        LDA (TMP),Y
        BMI @zero                       ; y < 0: 0.0
        LDA TMP + 2
        CMP # Fl_pinf
        BEQ @pinf   ; (+inf) ^ (y>0) = +inf
        JSR caml_float_intclass         ; (-inf) ^ y: -inf if y is an odd
        CMP # 2                         ;  integer, else +inf
        BCS @ninf
        BCC @pinf
@cmp1   LDY # 0                         ;compare |ACCU| with 1.0 (finite)
        LDA (ACCU),Y                    ; return .A=$FF if |x|<1, 0 if |x|=1,
        CMP # $81                       ; 1 if |x|>1 (flags set by .A)
        BCC @lt
        BNE @gt
        INY
        LDA (ACCU),Y
        AND # $7F
        BNE @gt
-       INY
        LDA (ACCU),Y
        BNE @gt
        CPY # 4
        BCC -
        LDA # 0
        RTS
@lt     LDA # $FF
        RTS
@gt     LDA # 1
        RTS
}

;; Class of the finite float (TMP) = y: .A = 0 if y is not an integer, 1 if it
;; is an even integer (or 0.0), 2 if it is an odd integer. Flags set by .A
;; y = 0.m * 2^E, E = exponent - $80. Not an integer if E <= 0 (y <> 0); even
;; if E > 32; else odd <=> E + (trailing zeroes of the 32 bits of the mantissa)
;; = 32, even if > 32, not an integer if < 32.
!ifdef caml_AUX__caml_float_intclass {
caml_float_intclass
        LDY # 0
        LDA (TMP),Y
        BEQ @even
        SEC
        SBC # $80
        BCC @no
        BEQ @no
        CMP # 33
        BCS @even
        STA TMP + 5
        LDX # 0
        LDY # 4
@tz     LDA (TMP),Y
        BNE @bits
        TXA
        CLC
        ADC # 8
        TAX
        DEY
        CPY # 1
        BNE @tz
        LDA (TMP),Y                     ;1st byte: bit 7 is the sign, the
        ORA # $80                       ; mantissa bit is 1
@bits   LSR
        BCS @cnt
        INX
        BNE @bits
@cnt    TXA
        CLC
        ADC TMP + 5
        CMP # 32
        BEQ @odd
        BCS @even
@no     LDA # 0
        RTS
@even   LDA # 1
        RTS
@odd    LDA # 2
        RTS
}

;; Domain check for the float just loaded into FAC: log x (.X = 0) or sqrt x
;; (.X <> 0). If x < 0, or x = 0 and .X = 0, the primitive is terminated here
;; with the result (nan, -infinity): the routine pops its return address and
;; jumps to caml_float_ret_tpl.
!ifdef caml_AUX__caml_float_logdom {
caml_float_logdom
        LDA C64_FAC
        BNE @nz
        TXA                             ;x = 0.0: sqrt is fine,
        BNE @ok                         ; log 0.0 = -infinity
        PLA
        PLA
        LDA # Ft_NINF
        JMP caml_float_ret_tpl
@nz     BIT C64_FAC + 5                 ;x < 0 ?
        BPL @ok
        PLA
        PLA
        LDA # Ft_NAN
        JMP caml_float_ret_tpl
@ok     RTS
}

;; A BASIC ROM routine called by a floating-point primitive raised the OVERFLOW
;; error. Called (JSR) by caml_syserr. If the primitive set the operation in
;; caml_float_overflow__op, the CPU stack is restored as it was when
;; caml_float_unop/binop (or the primitive itself) saved it in
;; caml_float_overflow__sp, and the primitive returns +-infinity to its caller.
;; Otherwise return to caml_syserr, which raises Sys_error "OVERFLOW".
;; The sign of the result is: add, sub: sign of x (ACCU); mul, div: sign(x)
;; xor sign(y) (SP[0]); pow: - if x < 0 and y is an odd integer; exp: +;
;; float_of_string: - if the string starts with '-'.
!ifdef caml_AUX__caml_float_overflow {
caml_float_overflow
        LDA caml_float_overflow__op
        BPL @known
        RTS                             ;unknown operation: raise the error
@known  BEQ @sgnx                       ;Fo_ADD
        CMP # Fo_POW
        BEQ @pow
        BCS @exp                        ;Fo_EXP, Fo_STR
        LDY # 0                         ;Fo_MUL
        LDA (SP),Y
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1                     ;(TMP) = y
        LDA (TMP),Y                     ;.Y = 1: sign of y,
        EOR (ACCU),Y                    ; xor sign of x
        BMI @neg
        BPL @pos
@exp    CMP # Fo_STR
        BNE @pos                        ;Fo_EXP: +infinity
        LDA TMP                         ;Fo_STR: restore the BASIC program
        STA C64_CHRPTR                  ; pointer, saved by the primitive
        LDA TMP + 1
        STA C64_CHRPTR + 1
        LDY # 0
        LDA (ACCU),Y
        CMP # '-'
        BEQ @neg
        BNE @pos
@pow    LDY # 1
        LDA (ACCU),Y                    ;x < 0 ?
        BPL @pos
        LDY # 0
        LDA (SP),Y
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1                     ;(TMP) = y
        JSR caml_float_intclass
        CMP # 2                         ;negative result iff y is odd
        BCS @neg
        BCC @pos
@sgnx   LDY # 1
        LDA (ACCU),Y                    ;sign of x
        BMI @neg
@pos    LDA # Ft_PINF
        BNE @res                        ;BNE=JMP
@neg    LDA # Ft_NINF
@res    LDX # Fo_NONE                   ;Handle overflow: reset op, so that a
        STX caml_float_overflow__op     ; later overflow raised by a ROM routine
        LDX caml_float_overflow__sp     ; which doesn't set it is an error.
        TXS                             ;Restore the CPU stack pointer
        JMP caml_float_ret_tpl          ;return the result to the caller
caml_float_overflow__sp
        !byte 0
caml_float_overflow__op
        !byte Fo_NONE
}

}      ;; !zone caml_FLOATS
